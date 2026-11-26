/// ثوابت وراث الحمام، منقولة من مكتبة UP-Pigen إلى Dart.
/// تعمل محلياً داخل التطبيق بلا إنترنت وبلا أي حزمة بايثون.
enum PigeonSex {
  male('male'),
  female('female');

  const PigeonSex(this.value);

  final String value;

  /// الإناث ZW تحمل نسخة واحدة من الجين المرتبط بالجنس.
  bool get isHeterogametic => this == PigeonSex.female;

  List<String> get chromosomes => this == PigeonSex.male
      ? const <String>['Z', 'Z']
      : const <String>['Z', 'W'];
}

enum Zygosity {
  homozygous('homozygous'),
  heterozygous('heterozygous'),
  hemizygous('hemizygous'),
  unknown('unknown');

  const Zygosity(this.value);

  final String value;
}
