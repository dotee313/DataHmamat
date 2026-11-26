/// تمثيل التركيب الوراثي وتحليله، مطابق لواجهة UP-Pigen.
library;

import 'constants.dart';
import 'genes.dart';

class Genotype {
  Genotype(this.sex, Map<String, List<String>> alleles)
      : _alleles = <String, List<String>>{} {
    for (final entry in alleles.entries) {
      final locus = getLocus(entry.key);
      final copies = List<String>.from(entry.value);
      if (copies.isEmpty) {
        throw ArgumentError('لا آليلات للموقع ${entry.key}');
      }
      final expected = locus.sexLinked
          ? (sex == PigeonSex.male ? 2 : 1)
          : 2;
      if (copies.length != expected) {
        throw ArgumentError(
          'الموقع ${locus.symbol} يحتاج $expected آليلات عند $sex، أعطي ${copies.length}',
        );
      }
      for (final allele in copies) {
        locus.get(allele);
      }
      copies.sort();
      _alleles[entry.key] = copies;
    }
  }

  final PigeonSex sex;
  final Map<String, List<String>> _alleles;

  factory Genotype.wildType(PigeonSex sex) {
    final alleles = <String, List<String>>{};
    for (final entry in loci.entries) {
      final count = entry.value.sexLinked
          ? (sex == PigeonSex.male ? 2 : 1)
          : 2;
      alleles[entry.key] = List<String>.filled(count, entry.value.wildType.symbol);
    }
    return Genotype(sex, alleles);
  }

  /// صيغة مختصرة: "B:B^+/b, C:C/+" ثم تحديد الجنس.
  factory Genotype.fromString(
    String notation, {
    PigeonSex sex = PigeonSex.male,
  }) {
    final alleles = <String, List<String>>{};
    for (final chunk in notation.split(',')) {
      final part = chunk.trim();
      if (part.isEmpty) continue;
      final colon = part.indexOf(':');
      if (colon < 0) throw ArgumentError(' جزء موقع غير صالح: $part');
      final symbol = part.substring(0, colon).trim();
      final copies = part
          .substring(colon + 1)
          .split('/')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      alleles[symbol] = copies;
    }
    return Genotype(sex, alleles);
  }

  Map<String, List<String>> get alleles =>
      Map<String, List<String>>.unmodifiable(_alleles);

  List<String> get(String symbol) =>
      List<String>.unmodifiable(_alleles[symbol] ?? const <String>[]);

  Zygosity zygosity(String symbol) {
    final copies = _alleles[symbol];
    if (copies == null || copies.isEmpty) return Zygosity.unknown;
    if (copies.length == 1) return Zygosity.hemizygous;
    return copies[0] == copies[1]
        ? Zygosity.homozygous
        : Zygosity.heterozygous;
  }

  /// الآليل المعبَّر عنه ظاهرياً: الأعلى سيادةً.
  Allele expressedAllele(String symbol) {
    final locus = getLocus(symbol);
    final copies = _alleles[symbol];
    if (copies == null || copies.isEmpty) return locus.wildType;
    final ranked = List<String>.from(copies)
      ..sort((a, b) => locus.get(b).dominance.compareTo(locus.get(a).dominance));
    return locus.get(ranked.first);
  }

  bool carries(String symbol, String allele) =>
      (_alleles[symbol] ?? const <String>[]).contains(allele);

  List<String> gametes(String symbol) => get(symbol);

  @override
  String toString() {
    final symbols = _alleles.keys.toList()..sort();
    return 'Genotype(${sex.value}, '
        '${symbols.map((s) => '$s:${_alleles[s]!.join('/')}').join(', ')})';
  }

  @override
  bool operator ==(Object other) =>
      other is Genotype && other.sex == sex && other.toString() == toString();

  @override
  int get hashCode => Object.hash(sex, toString());
}

/// باني آمن يبدأ من النمط البري ثم يعدّل المواقع المطلوبة.
class GenotypeBuilder {
  GenotypeBuilder(this.sex) {
    for (final entry in loci.entries) {
      final count = entry.value.sexLinked
          ? (sex == PigeonSex.male ? 2 : 1)
          : 2;
      _alleles[entry.key] = List<String>.filled(count, entry.value.wildType.symbol);
    }
  }

  final PigeonSex sex;
  final Map<String, List<String>> _alleles = <String, List<String>>{};

  /// موقع B مرتبط بالجنس: ذكر نسختان، أنثى نسخة واحدة.
  void setB(String allele) {
    if (sex == PigeonSex.male) {
      set('B', <String>[allele, allele]);
    } else {
      set('B', <String>[allele]);
    }
  }

  void setBoth(String symbol, String a, String b) =>
      set(symbol, <String>[a, b]);

  void set(String symbol, List<String> alleles) {
    final locus = getLocus(symbol);
    final copies = List<String>.from(alleles);
    final expected = locus.sexLinked
        ? (sex == PigeonSex.male ? 2 : 1)
        : 2;
    if (copies.length != expected) {
      throw ArgumentError(
        'الموقع $symbol يحتاج $expected آليلات عند $sex، أعطي ${copies.length}',
      );
    }
    for (final allele in copies) {
      locus.get(allele);
    }
    copies.sort();
    _alleles[symbol] = copies;
  }

  Genotype build() => Genotype(sex, _alleles);
}
