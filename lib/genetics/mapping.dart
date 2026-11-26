/// الجسر بين بيانات الطير في التطبيق ونموذج UP-Pigen.
/// الأسماء العربية تُترجم إلى تراكيب جينية تقريبية، ثم تُحسب المراحل
/// التالية بالمنطق الوراثي الحقيقي للمكتبة.
library;

import '../models.dart';
import 'constants.dart';
import 'genotype.dart';
import 'traits.dart';

PigeonSex sexOf(Bird bird) => (bird.sex == 'أنثى' || bird.sex == 'female')
    ? PigeonSex.female
    : PigeonSex.male;

Genotype genotypeFor(Bird bird) =>
    genotypeForParts(sexOf(bird), bird.color, bird.traits);

/// اللون يضبط مواقع اللون فقط؛ أما نقش الجناح وبقية الصفات فتؤخذ من
/// اختيار المستخدم في شاشة التزويج، لأن اللون الواحد قد يكون مشرطاً أو فخارلياً.
Genotype genotypeForParts(
  PigeonSex sex,
  String color,
  Iterable<String> traits,
) {
  final builder = GenotypeBuilder(sex);
  _applyColor(builder, color.trim());
  for (final trait in traits) {
    _applyTrait(builder, trait.trim());
  }
  return builder.build();
}

void _applyColor(GenotypeBuilder builder, String color) {
  switch (color) {
    case 'ابيض':
      builder.setBoth('P', 'p', 'p');
      builder.setBoth('I', 'I', 'I');
      break;
    case 'كريمي':
      builder.setBoth('e', 'e', 'e');
      builder.setBoth('D', 'd', 'd');
      break;
    case 'اصفر':
      builder.setBoth('e', 'e', 'e');
      break;
    case 'جوزي':
      builder.setB('b');
      break;
    case 'طيني':
      builder.setB('b');
      builder.setBoth('D', 'd', 'd');
      break;
    case 'حني':
      builder.setBoth('e', 'e', 'e');
      builder.setBoth('S', 'S', 'S');
      break;
    case 'احمر':
      builder.setBoth('e', 'e', 'e');
      break;
    case 'ازرق':
      // النقش لا يُستنتج من اللون؛ المستخدم يختاره في شاشة التزويج.
      builder.setB('B^+');
      break;
    case 'رمادي':
      builder.setB('B^+');
      builder.setBoth('D', 'd', 'd');
      break;
    case 'اسود':
      builder.setB('B^+');
      builder.setBoth('S', 'S', 'S');
      break;
    default:
      // اللون الحر المكتوب يبقى على النمط البري؛ لا يُخترع له جين غير معروف.
      break;
  }
}

void _applyTrait(GenotypeBuilder builder, String trait) {
  switch (trait) {
    case 'جناح ذو شريط':
    case 'ذو شريطين':
      builder.setBoth('C', '+', '+');
      break;
    case 'جناح ذو نقاط':
      builder.setBoth('C', 'C', 'C');
      break;
    case 'جناح صافي':
      builder.setBoth('C', 'c', 'c');
      break;
    case 'جناح ذو شريط منقط':
      builder.setBoth('C', 'C', '+');
      break;
    case 'جناح ذو شريطين منقط':
      builder.setBoth('C', 'T', '+');
      break;
    case 'مكحكل الراس':
    case 'فتيلا الراس':
      // كلاهما فتيلا في الرأس: موقع Crest (Cr).
      builder.setBoth('Cr', 'Cr', 'Cr');
      break;
    case 'وردة الصدر':
      // فتيلا/مفتل الصدر: موقع Frill (Fr).
      builder.setBoth('Fr', 'Fr', 'Fr');
      break;
    case 'مكلش الرجل':
      // مكلش الرجل = ريش على الرجلين (Foot feathering).
      builder.setBoth('F', 'F', 'F');
      break;
    case 'حافي':
      // حافي = بلا ريش في القدمين.
      builder.setBoth('F', 'f+', 'f+');
      break;
    default:
      // صفة المنقار تراكمية وتُحسب في expectedBeak أدناه.
      break;
  }
}

double beakScoreForTraits(Iterable<String> traits) {
  var score = 0.0;
  if (traits.contains('منقار قصير')) score -= 2.0;
  if (traits.contains('منقار طويل')) score += 2.0;
  return score;
}

double beakScoreFor(Bird bird) => beakScoreForTraits(bird.traits);

/// المنقار صفة متعددة الجينات: متوسط درجتي الأب والأم.
BeakModel expectedBeakTraits(
  Iterable<String> fatherTraits,
  Iterable<String> motherTraits,
) =>
    BeakModel(
      lengthScore: (beakScoreForTraits(fatherTraits) +
              beakScoreForTraits(motherTraits)) /
          2,
    );

BeakModel expectedBeak(Bird father, Bird mother) =>
    expectedBeakTraits(father.traits, mother.traits);
