/// حساب الشكل الظاهري من التركيب الوراثي، مطابق لـ UP-Pigen،
/// مع أسماء عربية للعرض داخل التطبيق.
library;

import 'genotype.dart';

class Phenotype {
  const Phenotype({
    required this.baseColor,
    required this.pattern,
    required this.spread,
    required this.dilute,
    required this.recessiveRed,
    required this.grizzle,
    required this.pied,
    required this.almond,
    required this.ice,
    required this.milky,
    required this.beakColor,
    required this.eyeColor,
    this.featherStructure = const <String>[],
    this.modifiers = const <String>[],
  });

  final String baseColor;
  final String pattern;
  final bool spread;
  final bool dilute;
  final bool recessiveRed;
  final bool grizzle;
  final bool pied;
  final bool almond;
  final bool ice;
  final bool milky;
  final String beakColor;
  final String eyeColor;
  final List<String> featherStructure;
  final List<String> modifiers;

  String describe() {
    final bits = <String>[baseColor, pattern];
    if (spread) bits.add('spread');
    if (dilute) bits.add('dilute');
    if (recessiveRed) bits.add('recessive red');
    if (grizzle) bits.add('grizzle');
    if (pied) bits.add('pied');
    if (almond) bits.add('almond');
    if (ice) bits.add('ice');
    if (milky) bits.add('milky');
    bits.addAll(featherStructure);
    return bits.join(', ');
  }

  /// وصف مختصر بالعربية للعرض في نتائج التزويج الاختباري.
  String describeAr() {
    final bits = <String>[_colorAr(baseColor), _patternAr(pattern)];
    if (spread) bits.add('منتشر');
    if (dilute) bits.add('مخفّف');
    if (recessiveRed) bits.add('أحمر متوارٍ');
    if (grizzle) bits.add('مبرقش');
    if (pied) bits.add('أبرق');
    if (almond) bits.add('لوزي');
    if (ice) bits.add('جليدي');
    if (milky) bits.add('حليبي');
    for (final structure in featherStructure) {
      bits.add(_structureAr(structure));
    }
    return bits.join('، ');
  }

  Map<String, dynamic> asDict() => <String, dynamic>{
        'base_color': baseColor,
        'pattern': pattern,
        'spread': spread,
        'dilute': dilute,
        'recessive_red': recessiveRed,
        'grizzle': grizzle,
        'pied': pied,
        'almond': almond,
        'ice': ice,
        'milky': milky,
        'beak_color': beakColor,
        'eye_color': eyeColor,
        'feather_structure': featherStructure,
        'modifiers': modifiers,
      };

  static String _colorAr(String value) {
    switch (value) {
      case 'Ash-red':
        return 'أش ريد';
      case 'Blue/black (wild type)':
        return 'أزرق';
      case 'Brown':
        return 'جوزي';
      case 'recessive red':
        return 'أحمر';
      default:
        return value;
    }
  }

  static String _patternAr(String value) {
    switch (value) {
      case 'T-pattern':
        return 'نقش T';
      case 'Check':
        return 'نقاط';
      case 'Bar (wild type)':
        return 'شريط';
      case 'Barless':
        return 'صافي';
      case 'masked':
        return 'مخفي';
      case 'solid':
        return 'صلب';
      default:
        return value;
    }
  }

  static String _structureAr(String value) {
    switch (value) {
      case 'frilled':
        return 'مجعّد';
      case 'crested':
        return 'فتيلا الرأس';
      case 'foot-feathered':
        return 'مكسو الرجل';
      default:
        return value;
    }
  }
}

String _beakColor(Genotype genotype) {
  final spread = genotype.expressedAllele('S').symbol == 'S';
  final dilute = genotype.expressedAllele('D').symbol == 'd';
  final red = genotype.expressedAllele('e').symbol == 'e';
  if (red) return 'pinkish-horn';
  if (dilute) return 'light horn';
  if (spread) return 'dark horn';
  return 'dark';
}

String _eyeColor(Genotype genotype) {
  final dilute = genotype.expressedAllele('D').symbol == 'd';
  final red = genotype.expressedAllele('e').symbol == 'e';
  final almond = genotype.expressedAllele('A').symbol == 'a';
  if (red || dilute || almond) return 'bull (dark)';
  return 'pearl';
}

List<String> _featherStructure(Genotype genotype) {
  final out = <String>[];
  if (genotype.expressedAllele('Fr').symbol == 'Fr') out.add('frilled');
  if (genotype.expressedAllele('Cr').symbol == 'Cr') out.add('crested');
  if (genotype.expressedAllele('F').symbol == 'F') out.add('foot-feathered');
  return out;
}

Phenotype computePhenotype(Genotype genotype) {
  var baseColor = genotype.expressedAllele('B').name;
  var pattern = genotype.expressedAllele('C').name;
  final spread = genotype.expressedAllele('S').symbol == 'S';
  final dilute = genotype.expressedAllele('D').symbol == 'd';
  final recessiveRed = genotype.expressedAllele('e').symbol == 'e';
  final grizzle = genotype.expressedAllele('G').symbol == 'G';
  final pied = genotype.expressedAllele('P').symbol == 'p';
  final almond = genotype.expressedAllele('A').symbol == 'a';
  final ice = genotype.expressedAllele('I').symbol == 'I';
  final milky = genotype.expressedAllele('M').symbol == 'm';

  final modifiers = <String>[];
  if (recessiveRed) {
    modifiers.add('epistatic over pattern');
    baseColor = 'recessive red';
    pattern = 'masked';
  }
  if (spread) {
    modifiers.add('dark pigment over whole plumage');
    pattern = 'solid';
  }
  if (dilute) modifiers.add('pigment reduced');
  if (ice) modifiers.add('frosted');
  if (milky) modifiers.add('washed');

  return Phenotype(
    baseColor: baseColor,
    pattern: pattern,
    spread: spread,
    dilute: dilute,
    recessiveRed: recessiveRed,
    grizzle: grizzle,
    pied: pied,
    almond: almond,
    ice: ice,
    milky: milky,
    beakColor: _beakColor(genotype),
    eyeColor: _eyeColor(genotype),
    featherStructure: _featherStructure(genotype),
    modifiers: modifiers,
  );
}
