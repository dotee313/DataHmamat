/// تتبّع جين واحد عبر الشجرة: من يظهر عليه، ومن يحمله، ومن قد يحمله.
/// مبني على الألوان والصفات المسجّلة للطيور (تراكيب تقريبية)، وعلى قوانين
/// مندل للأجداد والآباء، وبلا أي اتصال بالإنترنت.
library;

import 'dart:math' as math;

import '../models.dart';
import 'constants.dart';
import 'genes.dart';
import 'genotype.dart';
import 'mapping.dart';

enum GeneStatus { shows, carrier, possible, absent }

class GeneTrace {
  const GeneTrace(this.status, this.copies);

  final GeneStatus status;

  /// العدد المتوقع لنسخ الآليل عند الطير.
  final double copies;

  int get percent => (copies.clamp(0.0, 1.0) * 100).round();
}

class GeneTracer {
  GeneTracer({
    required this.byId,
    required this.locus,
    required this.allele,
  })  : _sexLinked = getLocus(locus).sexLinked,
        _kids = <String, List<Bird>>{} {
    for (final bird in byId.values) {
      final father = bird.fatherId;
      final mother = bird.motherId;
      if (father != null) _kids.putIfAbsent(father, () => <Bird>[]).add(bird);
      if (mother != null) _kids.putIfAbsent(mother, () => <Bird>[]).add(bird);
    }
  }

  final Map<String, Bird> byId;
  final String locus;
  final String allele;
  final bool _sexLinked;
  final Map<String, List<Bird>> _kids;
  final Map<String, Genotype> _genotypes = <String, Genotype>{};
  final Map<String, double> _memo = <String, double>{};

  Genotype _genotype(Bird bird) =>
      _genotypes.putIfAbsent(bird.id, () => genotypeFor(bird));

  int _direct(Bird bird) =>
      _genotype(bird).get(locus).where((a) => a == allele).length;

  bool _shows(Bird bird) =>
      _direct(bird) > 0 &&
      _genotype(bird).expressedAllele(locus).symbol == allele;

  /// حدّ أدنى مؤكد: إن ظهر الجين على فرخ بنسختين فكلا أبويه يحمله.
  double _forcedMinimum(Bird bird) {
    var forced = 0.0;
    for (final kid in _kids[bird.id] ?? const <Bird>[]) {
      final copies = _direct(kid);
      if (copies == 0) continue;
      final kidMale = sexOf(kid) == PigeonSex.male;
      if (_sexLinked) {
        if (!kidMale && kid.fatherId == bird.id) forced = math.max(forced, 1.0);
        if (kidMale && copies >= 2) forced = math.max(forced, 1.0);
      } else if (copies >= 2) {
        forced = math.max(forced, 1.0);
      }
    }
    return forced;
  }

  double _copiesOf(Bird bird, Set<String> path) {
    final cached = _memo[bird.id];
    if (cached != null) return cached;
    final direct = _direct(bird);
    if (direct > 0) {
      _memo[bird.id] = direct.toDouble();
      return direct.toDouble();
    }
    if (path.contains(bird.id)) return 0;
    final next = <String>{...path, bird.id};
    final father = byId[bird.fatherId];
    final mother = byId[bird.motherId];
    final fatherCopies = father == null ? 0.0 : _copiesOf(father, next);
    final motherCopies = mother == null ? 0.0 : _copiesOf(mother, next);

    double inherited;
    if (_sexLinked) {
      inherited = sexOf(bird) == PigeonSex.male
          ? fatherCopies / 2 + motherCopies
          : fatherCopies / 2;
    } else {
      inherited = fatherCopies / 2 + motherCopies / 2;
    }
    final result = math.max(_forcedMinimum(bird), inherited);
    _memo[bird.id] = result;
    return result;
  }

  GeneTrace traceOf(Bird bird) {
    if (_shows(bird)) {
      return GeneTrace(GeneStatus.shows, _direct(bird).toDouble());
    }
    final copies = _copiesOf(bird, <String>{});
    if (_direct(bird) > 0 || copies >= 0.95) {
      return GeneTrace(GeneStatus.carrier, copies);
    }
    if (copies >= 0.2) return GeneTrace(GeneStatus.possible, copies);
    return GeneTrace(GeneStatus.absent, copies);
  }
}
