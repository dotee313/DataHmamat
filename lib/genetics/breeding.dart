/// توقّع التزويج بمربع بونيت، مطابق لخوارزمية UP-Pigen:
/// مواقع جسدية مستقلة، ومواقع مرتبطة بالجنس مع نسبة جنس ١:١.
library;

import 'constants.dart';
import 'genes.dart';
import 'genotype.dart';
import 'phenotype.dart';

class Offspring {
  const Offspring({
    required this.sex,
    required this.genotype,
    required this.probability,
  });

  final PigeonSex sex;
  final Genotype genotype;
  final double probability;
}

/// نتيجة توقعات الشكل الظاهري المجمّعة للواجهة.
class PhenotypePrediction {
  const PhenotypePrediction({
    required this.phenotype,
    required this.chance,
    required this.sex,
  });

  final String phenotype;
  final double chance;
  final PigeonSex sex;
}

int _rank(Locus locus, String allele) {
  try {
    return locus.get(allele).dominance;
  } on ArgumentError {
    // الآليل غير المسجّل يحتفظ بترتيبه الأصلي كما في UP-Pigen.
    return 0;
  }
}

/// ترتيب زوج الآليلات بالسيادة: الأقوى أولاً، مع ثبات ترتيب المتساويات.
List<String> _dominanceSort(String locusSymbol, List<String> alleles) {
  Locus? locus;
  try {
    locus = getLocus(locusSymbol);
  } on ArgumentError {
    return List<String>.from(alleles);
  }
  final indexes = List<int>.generate(alleles.length, (i) => i);
  indexes.sort((i, j) {
    final byDominance = _rank(locus!, alleles[j]).compareTo(_rank(locus, alleles[i]));
    return byDominance != 0 ? byDominance : i.compareTo(j);
  });
  return <String>[for (final i in indexes) alleles[i]];
}

String _keyOf(String locusSymbol, List<String> alleles) =>
    _dominanceSort(locusSymbol, alleles).join('/');

List<List<List<String>>> punnettSquare(
  List<String> fatherAlleles,
  List<String> motherAlleles, {
  String locusSymbol = 'B',
}) =>
    <List<List<String>>>[
      for (final fa in fatherAlleles)
        <List<String>>[
          for (final ma in motherAlleles)
            _keyOf(locusSymbol, <String>[fa, ma]).split('/'),
        ],
    ];

Map<String, double> _outcomes(
  String locusSymbol,
  List<String> fatherAlleles,
  List<String> motherAlleles, {
  required bool hemizygous,
}) {
  final result = <String, double>{};
  if (hemizygous) {
    // الأنثى ZW: تعطي الأب نسخة واحدة من الكروموسوم Z.
    for (final fa in fatherAlleles) {
      result[fa] = (result[fa] ?? 0) + 1 / fatherAlleles.length;
    }
    return result;
  }
  for (final fa in fatherAlleles) {
    for (final ma in motherAlleles) {
      final key = _keyOf(locusSymbol, <String>[fa, ma]);
      result[key] = (result[key] ?? 0) +
          1 / (fatherAlleles.length * motherAlleles.length);
    }
  }
  return result;
}

class _Combined {
  const _Combined(this.alleles, this.probability);

  final Map<String, List<String>> alleles;
  final double probability;
}

List<_Combined> _combine(
  List<String> symbols,
  Map<String, Map<String, double>> perLocus,
) {
  var combined = <_Combined>[_Combined(<String, List<String>>{}, 1.0)];
  for (final symbol in symbols) {
    final next = <_Combined>[];
    for (final current in combined) {
      for (final outcome in perLocus[symbol]!.entries) {
        next.add(_Combined(
          <String, List<String>>{
            ...current.alleles,
            symbol: outcome.key.split('/'),
          },
          current.probability * outcome.value,
        ));
      }
    }
    combined = next;
  }
  return combined;
}

class _SexResult {
  const _SexResult(this.sex, this.alleles, this.probability);

  final PigeonSex sex;
  final Map<String, List<String>> alleles;
  final double probability;
}

List<Offspring> cross(Genotype father, Genotype mother) {
  if (father.sex != PigeonSex.male) {
    throw ArgumentError('الأب يجب أن يكون ذكراً (ZZ)');
  }
  if (mother.sex != PigeonSex.female) {
    throw ArgumentError('الأم يجب أن تكون أنثى (ZW)');
  }

  final all = listLoci();
  final sexLinked = all.where((s) => getLocus(s).sexLinked).toList();
  final autosomal = all.where((s) => !getLocus(s).sexLinked).toList();

  final autoOutcomes = <String, Map<String, double>>{};
  for (final symbol in autosomal) {
    final locus = getLocus(symbol);
    final fatherAlleles = father.get(symbol).isEmpty
        ? List<String>.filled(2, locus.wildType.symbol)
        : father.get(symbol);
    final motherAlleles = mother.get(symbol).isEmpty
        ? List<String>.filled(2, locus.wildType.symbol)
        : mother.get(symbol);
    autoOutcomes[symbol] = _outcomes(
      symbol,
      fatherAlleles,
      motherAlleles,
      hemizygous: false,
    );
  }
  final combinedAuto = _combine(autosomal, autoOutcomes);

  final sexResults = <_SexResult>[];
  for (final sex in <PigeonSex>[PigeonSex.male, PigeonSex.female]) {
    final perLocus = <String, Map<String, double>>{};
    for (final symbol in sexLinked) {
      final locus = getLocus(symbol);
      final fatherAlleles = father.get(symbol).isEmpty
          ? List<String>.filled(2, locus.wildType.symbol)
          : father.get(symbol);
      final motherAlleles = mother.get(symbol).isEmpty
          ? <String>[locus.wildType.symbol]
          : mother.get(symbol);
      perLocus[symbol] = _outcomes(
        symbol,
        fatherAlleles,
        motherAlleles,
        hemizygous: sex == PigeonSex.female,
      );
    }
    for (final combined in _combine(sexLinked, perLocus)) {
      sexResults.add(_SexResult(sex, combined.alleles, 0.5 * combined.probability));
    }
  }

  final merged = <String, Offspring>{};
  for (final sexResult in sexResults) {
    for (final auto in combinedAuto) {
      final full = <String, List<String>>{
        ...auto.alleles,
        ...sexResult.alleles,
      };
      final child = Genotype(sexResult.sex, full);
      final key = '${sexResult.sex.value}|$child';
      final probability = sexResult.probability * auto.probability;
      final existing = merged[key];
      if (existing != null) {
        merged[key] = Offspring(
          sex: existing.sex,
          genotype: existing.genotype,
          probability: existing.probability + probability,
        );
      } else {
        merged[key] = Offspring(
          sex: sexResult.sex,
          genotype: child,
          probability: probability,
        );
      }
    }
  }

  final result = merged.values.toList()
    ..sort((a, b) => b.probability.compareTo(a.probability));
  return result;
}

/// تجميع النتائج بالتركيب الوراثي، كما في UP-Pigen.
Map<String, double> summarizeOffspring(List<Offspring> offspring) {
  final result = <String, double>{};
  for (final item in offspring) {
    final key = '${item.sex.value} ${item.genotype}';
    result[key] = (result[key] ?? 0) + item.probability;
  }
  final entries = result.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return Map<String, double>.fromEntries(entries);
}

/// تجميع النتائج بالشكل الظاهري العربي مع الجنس، لعرضها في الواجهة.
List<PhenotypePrediction> summarizeByPhenotype(
  List<Offspring> offspring, {
  int limit = 12,
}) {
  final groups = <String, PhenotypePrediction>{};
  for (final item in offspring) {
    final phenotype = computePhenotype(item.genotype).describeAr();
    final key = '${item.sex.value}|$phenotype';
    final existing = groups[key];
    if (existing != null) {
      groups[key] = PhenotypePrediction(
        phenotype: existing.phenotype,
        chance: existing.chance + item.probability,
        sex: existing.sex,
      );
    } else {
      groups[key] = PhenotypePrediction(
        phenotype: phenotype,
        chance: item.probability,
        sex: item.sex,
      );
    }
  }
  final list = groups.values.toList()
    ..sort((a, b) => b.chance.compareTo(a.chance));
  return limit <= 0 ? list : list.take(limit).toList();
}

Map<PigeonSex, double> sexRatios(List<Offspring> offspring) {
  var male = 0.0;
  var female = 0.0;
  for (final item in offspring) {
    if (item.sex == PigeonSex.male) {
      male += item.probability;
    } else {
      female += item.probability;
    }
  }
  return <PigeonSex, double>{
    PigeonSex.male: male,
    PigeonSex.female: female,
  };
}
