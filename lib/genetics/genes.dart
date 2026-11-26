/// تعريف المواقع الجينية والآليلات، مطابق لمكتبة UP-Pigen.
library;

class Allele {
  const Allele({
    required this.symbol,
    required this.name,
    required this.description,
    required this.dominance,
    this.phenotypeHint = '',
  });

  final String symbol;
  final String name;
  final String description;

  /// كلما زاد الرقم زادت السيادة داخل الموقع الواحد.
  final int dominance;
  final String phenotypeHint;
}

class Locus {
  Locus({
    required this.symbol,
    required this.name,
    required Map<String, Allele> alleles,
    this.sexLinked = false,
    this.description = '',
  }) : alleles = Map<String, Allele>.unmodifiable(alleles);

  final String symbol;
  final String name;
  final Map<String, Allele> alleles;
  final bool sexLinked;
  final String description;

  Allele get(String symbol) {
    final allele = alleles[symbol];
    if (allele == null) {
      throw ArgumentError('آليل غير معروف $symbol في الموقع $this.symbol');
    }
    return allele;
  }

  List<Allele> sortedByDominance() =>
      alleles.values.toList()..sort((a, b) => b.dominance.compareTo(a.dominance));

  Allele get wildType {
    for (final allele in alleles.values) {
      if (allele.symbol == '+' || allele.symbol.endsWith('+')) return allele;
    }
    // كإصدار UP-Pigen المحدّث: لا نخترع نمطاً برياً؛ يجب تسميته "+" أو "*+".
    throw ArgumentError(
      'الموقع $symbol لا يملك آليل "+"; النمط البري يجب أن يُسمّى صراحةً.',
    );
  }

  @override
  String toString() => '$symbol ($name)';
}

Allele _a(
  String symbol,
  String name,
  String description,
  int dominance, [
  String hint = '',
]) =>
    Allele(
      symbol: symbol,
      name: name,
      description: description,
      dominance: dominance,
      phenotypeHint: hint,
    );

final Map<String, Locus> loci = <String, Locus>{
  'B': Locus(
    symbol: 'B',
    name: 'B (سلسلة اللون المرتبطة بالجنس)',
    sexLinked: true,
    description: 'سلسلة اللون الأساسي على الكروموسوم Z. الذكور ZZ والإناث ZW. '
        'السيادة: B^A > B^+ > b.',
    alleles: <String, Allele>{
      'B^A': _a('B^A', 'Ash-red', 'أش-red / mealy سائد', 3,
          'جسم ash-red وأجنحة mealy عند الذكور'),
      'B^+': _a('B^+', 'Blue/black (wild type)', 'أزرق بري بشريطين أسودين', 2,
          'جسم رمادي مزرق وشريطان أسودان'),
      'b': _a('b', 'Brown', 'بني متوارٍ', 1, 'جسم بني وشرائط بنية'),
    },
  ),
  'C': Locus(
    symbol: 'C',
    name: 'Check / Bar / T-pattern',
    description: 'نقش درع الجناح: T > C > + (شريط) > c (بلا شريط).',
    alleles: <String, Allele>{
      'T': _a('T', 'T-pattern', 'نقش T داكن شبه صلب', 4, 'check داكن'),
      'C': _a('C', 'Check', 'نقش منقّط / check', 3, 'checker'),
      '+': _a('+', 'Bar (wild type)', 'شريطان أسودان', 2, 'bar'),
      'c': _a('c', 'Barless', 'بلا شرائط', 1, 'barless'),
    },
  ),
  'S': Locus(
    symbol: 'S',
    name: 'Spread',
    description: 'ينشر الصبغة الداكنة على كل الريش.',
    alleles: <String, Allele>{
      'S': _a('S', 'Spread', 'داكن / أسود كامل', 2, 'self-colored / black'),
      's+': _a('s+', 'Non-spread (wild type)', 'النقش الظاهر طبيعياً', 1),
    },
  ),
  'D': Locus(
    symbol: 'D',
    name: 'Dilute',
    description: 'تخفيف متوارٍ لكل الصبغات.',
    alleles: <String, Allele>{
      'D+': _a('D+', 'Normal', 'صبغة كاملة', 2),
      'd': _a('d', 'Dilute', 'باهت / فضي', 1, 'silver / dun'),
    },
  ),
  'e': Locus(
    symbol: 'e',
    name: 'Recessive Red',
    description: 'أحمر متوارٍ يحجب النقش ويعطي أحمر/كريمي.',
    alleles: <String, Allele>{
      'E+': _a('E+', 'Normal', 'تصبغ طبيعي', 2),
      'e': _a('e', 'Recessive Red', 'جسم أحمر/كريمي', 1, 'recessive red / cream'),
    },
  ),
  'G': Locus(
    symbol: 'G',
    name: 'Grizzle',
    description: 'برقش سائد ببقع بيضاء.',
    alleles: <String, Allele>{
      'G': _a('G', 'Grizzle', 'مبرقش / grizzle', 2, 'grizzle'),
      'g+': _a('g+', 'Normal', 'بلا برقش', 1),
    },
  ),
  'P': Locus(
    symbol: 'P',
    name: 'Pied',
    description: 'أبرق متوارٍ (بقع بيضاء)، العامل الرئيسي.',
    alleles: <String, Allele>{
      'P+': _a('P+', 'Normal', 'بلا بقع بيضاء', 2),
      'p': _a('p', 'Pied', 'بقع بيضاء على الجسم والأجنحة', 1, 'pied'),
    },
  ),
  'A': Locus(
    symbol: 'A',
    name: 'Almond',
    description: 'عامل اللوز المتوارٍ: رخامي/منقّط.',
    alleles: <String, Allele>{
      'A+': _a('A+', 'Normal', 'بلا لوز', 2),
      'a': _a('a', 'Almond', 'لوزي / رخامي', 1, 'almond'),
    },
  ),
  'I': Locus(
    symbol: 'I',
    name: 'Ice',
    description: 'تخفيف جليدي سائد بريش باهت متجمد.',
    alleles: <String, Allele>{
      'I': _a('I', 'Ice', 'ريش باهت متجمد', 2, 'ice'),
      'i+': _a('i+', 'Normal', 'بلا جليد', 1),
    },
  ),
  'M': Locus(
    symbol: 'M',
    name: 'Milky',
    description: 'تخفيف حليبي متوارٍ.',
    alleles: <String, Allele>{
      'M+': _a('M+', 'Normal', 'صبغة طبيعية', 2),
      'm': _a('m', 'Milky', 'حليبي / باهت', 1, 'milky'),
    },
  ),
  'Fr': Locus(
    symbol: 'Fr',
    name: 'Frill',
    description: 'ريش مجعد سائد.',
    alleles: <String, Allele>{
      'Fr': _a('Fr', 'Frill', 'ريش مجعد', 2, 'frillback'),
      'fr+': _a('fr+', 'Normal', 'ريش عادي', 1),
    },
  ),
  'Cr': Locus(
    symbol: 'Cr',
    name: 'Crest',
    description: 'فتيلا الرأس السائدة.',
    alleles: <String, Allele>{
      'Cr': _a('Cr', 'Crest', 'رأس مُعرّف/فتيلا', 2, 'crested'),
      'cr+': _a('cr+', 'Normal', 'بلا فتيلا', 1),
    },
  ),
  'F': Locus(
    symbol: 'F',
    name: 'Foot Feathering',
    description: 'ريش الرجلين السائد.',
    alleles: <String, Allele>{
      'F': _a('F', 'Foot feathering', 'ريش الرجلين', 2, 'muffed'),
      'f+': _a('f+', 'Normal', 'رجلان نظيفتان', 1),
    },
  ),
};

Locus getLocus(String symbol) {
  final locus = loci[symbol];
  if (locus == null) {
    throw ArgumentError('موقع غير معروف $symbol. المواقع: ${loci.keys.toList()..sort()}');
  }
  return locus;
}

List<String> listLoci() => loci.keys.toList()..sort();
