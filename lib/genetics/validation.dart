/// فحص صحة التركيب الوراثي، منقول من UP-Pigen (النسخة المحدّثة).
library;

import 'constants.dart';
import 'genes.dart';
import 'genotype.dart';

List<String> validate(Genotype genotype) {
  final warnings = <String>[];
  for (final entry in loci.entries) {
    final symbol = entry.key;
    final locus = entry.value;
    final copies = genotype.get(symbol);
    if (copies.isEmpty) {
      warnings.add('الموقع $symbol مفقود (يُعامل كنمط بري)');
      continue;
    }
    for (final allele in copies) {
      if (!locus.alleles.containsKey(allele)) {
        warnings.add('الموقع $symbol: آليل غير معروف $allele');
      }
    }
    if (locus.sexLinked) {
      final expected = genotype.sex == PigeonSex.male ? 2 : 1;
      if (copies.length != expected) {
        warnings.add(
          'الموقع $symbol مرتبط بالجنس: المتوقع $expected نسخ، الموجود ${copies.length}',
        );
      }
    } else if (copies.length != 2) {
      warnings.add(
        'الموقع $symbol جسدي: المتوقع نسختان، الموجود ${copies.length}',
      );
    }
  }
  return warnings;
}
