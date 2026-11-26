/// قائمة الجينات التي يمكن اختيارها في «سلالة المرغوبة» وفي تلوين الشجرة.
library;

import '../l10n.dart';
import 'genes.dart';

class GeneChoice {
  const GeneChoice(this.locus, this.allele, this.labelAr, this.labelEn);

  final String locus;
  final String allele;
  final String labelAr;
  final String labelEn;

  String get key => '$locus|$allele';

  String get label => S.ar ? labelAr : labelEn;

  /// النمط البري هو الافتراضي لكل طير، فلا يُتتبّع في الشجرة.
  bool get isWild => getLocus(locus).wildType.symbol == allele;
}

const List<GeneChoice> geneChoices = <GeneChoice>[
  GeneChoice('B', 'B^A', 'احمر (أش ريد)', 'Ash-red'),
  GeneChoice('B', 'B^+', 'أزرق / أسود', 'Blue / black'),
  GeneChoice('B', 'b', 'جوزي', 'Brown'),
  GeneChoice('C', 'T', 'مكتف', 'T-check'),
  GeneChoice('C', 'C', 'محبب', 'Check'),
  GeneChoice('C', '+', 'المشرط', 'Bar'),
  GeneChoice('C', 'c', 'فخارلي', 'Barless'),
  GeneChoice('S', 'S', 'صلت', 'Spread'),
  GeneChoice('D', 'd', 'مخفّف', 'Dilute'),
  GeneChoice('e', 'e', 'احمر متنحي', 'Recessive red'),
  GeneChoice('G', 'G', 'مبرقش', 'Grizzle'),
  GeneChoice('P', 'p', 'أبرق', 'Pied'),
  GeneChoice('A', 'a', 'لوزي', 'Almond'),
  GeneChoice('I', 'I', 'باهت', 'Ice'),
  GeneChoice('M', 'm', 'حليبي', 'Milky'),
  GeneChoice('Fr', 'Fr', 'مفتل (وردة الصدر)', 'Frill'),
  GeneChoice('Cr', 'Cr', 'فتيلا الرأس', 'Crest'),
  GeneChoice('F', 'F', 'مكلش الرجل', 'Foot feathering'),
];

/// الجينات التي لها معنى في التتبّع (بلا النمط البري).
List<GeneChoice> get traceChoices =>
    geneChoices.where((c) => !c.isWild).toList();

GeneChoice? geneChoiceByKey(String? key) {
  if (key == null) return null;
  for (final choice in geneChoices) {
    if (choice.key == key) return choice;
  }
  return null;
}
