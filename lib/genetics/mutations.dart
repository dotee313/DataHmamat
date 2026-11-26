/// دليل الطفرات المعروف في مكتبة UP-Pigen.
library;

class Mutation {
  const Mutation({
    required this.name,
    required this.locus,
    required this.allele,
    required this.inheritance,
    required this.description,
    this.breeds = const <String>[],
  });

  final String name;
  final String locus;
  final String allele;
  final String inheritance;
  final String description;
  final List<String> breeds;
}

final List<Mutation> mutations = <Mutation>[
  const Mutation(
    name: 'Ash-red',
    locus: 'B',
    allele: 'B^A',
    inheritance: 'sex-linked dominant',
    description: 'أش-red / mealy سائد على الموقع B المرتبط بالجنس.',
    breeds: <String>['Carrier', 'Racing Homer'],
  ),
  const Mutation(
    name: 'Brown',
    locus: 'B',
    allele: 'b',
    inheritance: 'sex-linked recessive',
    description: 'لون بني متوارٍ على الموقع B.',
    breeds: <String>['Brown Racing Homer'],
  ),
  const Mutation(
    name: 'Recessive Red',
    locus: 'e',
    allele: 'e',
    inheritance: 'autosomal recessive',
    description: 'أحمر/كريمي متوارٍ يحجب النقش.',
    breeds: <String>['Recessive Red', 'Cream'],
  ),
  const Mutation(
    name: 'Checker',
    locus: 'C',
    allele: 'C',
    inheritance: 'dominant over bar',
    description: 'نقش منقّط على درع الجناح.',
    breeds: <String>['Check Homers'],
  ),
  const Mutation(
    name: 'T-pattern',
    locus: 'C',
    allele: 'T',
    inheritance: 'dominant over check',
    description: 'نقش T داكن شبه صلب.',
  ),
  const Mutation(
    name: 'Barless',
    locus: 'C',
    allele: 'c',
    inheritance: 'recessive',
    description: 'درع بلا شرائط.',
  ),
  const Mutation(
    name: 'Spread',
    locus: 'S',
    allele: 'S',
    inheritance: 'autosomal dominant',
    description: 'ينشر الصبغة الداكنة على كل الريش.',
    breeds: <String>['Black Homer', 'Black Nun'],
  ),
  const Mutation(
    name: 'Dilute',
    locus: 'D',
    allele: 'd',
    inheritance: 'autosomal recessive',
    description: 'يخفف الصبغات؛ فضي وداكن.',
    breeds: <String>['Silver', 'Dun'],
  ),
  const Mutation(
    name: 'Grizzle',
    locus: 'G',
    allele: 'G',
    inheritance: 'autosomal dominant',
    description: 'برقش أبيض على الريش.',
    breeds: <String>['Grizzle Racing Homer'],
  ),
  const Mutation(
    name: 'Pied',
    locus: 'P',
    allele: 'p',
    inheritance: 'recessive (major factor)',
    description: 'بقع بيضاء؛ العامل الرئيسي متوارٍ.',
    breeds: <String>['Baldhead', 'Pied'],
  ),
  const Mutation(
    name: 'Almond',
    locus: 'A',
    allele: 'a',
    inheritance: 'autosomal recessive',
    description: 'عامل لوزي رخامي بعين bull غالباً.',
    breeds: <String>['Almond Tumbler'],
  ),
  const Mutation(
    name: 'Ice',
    locus: 'I',
    allele: 'I',
    inheritance: 'autosomal dominant',
    description: 'تخفيف جليدي بريش باهت.',
    breeds: <String>['Ice Pigeon'],
  ),
  const Mutation(
    name: 'Milky',
    locus: 'M',
    allele: 'm',
    inheritance: 'autosomal recessive',
    description: 'تخفيف حليبي للصبغة.',
    breeds: <String>['Milky'],
  ),
  const Mutation(
    name: 'Frill',
    locus: 'Fr',
    allele: 'Fr',
    inheritance: 'autosomal dominant',
    description: 'ريش مجعد.',
    breeds: <String>['Frillback'],
  ),
  const Mutation(
    name: 'Crest',
    locus: 'Cr',
    allele: 'Cr',
    inheritance: 'autosomal dominant',
    description: 'فتيلا الرأس.',
    breeds: <String>['Crested', 'Shell Crest', 'Peak Crest'],
  ),
  const Mutation(
    name: 'Foot Feathering',
    locus: 'F',
    allele: 'F',
    inheritance: 'autosomal dominant',
    description: 'ريش الرجلين والفخذ.',
    breeds: <String>['Muffed', 'Grouse'],
  ),
];

Mutation findMutation(String name) {
  for (final mutation in mutations) {
    if (mutation.name.toLowerCase() == name.toLowerCase()) return mutation;
  }
  throw ArgumentError('طفرة غير معروفة: $name');
}

List<Mutation> mutationsForLocus(String locus) =>
    mutations.where((m) => m.locus == locus).toList();
