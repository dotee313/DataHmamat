/// نموذج المنقار التراكمي ووصفات السلالات، منقول من UP-Pigen.
library;

class BeakModel {
  const BeakModel({
    this.lengthScore = 0.0,
    this.widthScore = 0.0,
  });

  /// ٠ ≈ حمام زاجل بري. الموجب أطول/أعرض، والسالب أقصر/أضيق.
  final double lengthScore;
  final double widthScore;

  String lengthClass() {
    final s = lengthScore;
    if (s <= -2.0) return 'very short';
    if (s <= -1.0) return 'short';
    if (s < 1.0) return 'medium';
    if (s < 2.0) return 'long';
    return 'very long';
  }

  String widthClass() {
    final s = widthScore;
    if (s <= -1.0) return 'narrow';
    if (s < 1.0) return 'medium';
    return 'broad';
  }

  String lengthClassAr() {
    final s = lengthScore;
    if (s <= -2.0) return 'قصير جداً';
    if (s <= -1.0) return 'قصير';
    if (s < 1.0) return 'متوسط';
    if (s < 2.0) return 'طويل';
    return 'طويل جداً';
  }

  String widthClassAr() {
    final s = widthScore;
    if (s <= -1.0) return 'ضيق';
    if (s < 1.0) return 'متوسط';
    return 'عريض';
  }

  String describe() => '${lengthClass()} / ${widthClass()} beak';

  String describeAr() => 'منقار ${lengthClassAr()} / ${widthClassAr()}';
}

final Map<String, BeakModel> breedBeakPresets = <String, BeakModel>{
  'racing_homer': const BeakModel(0.0, 0.0),
  'carrier': const BeakModel(2.0, 1.5),
  'short_faced_tumbler': const BeakModel(-2.5, -0.5),
  'owl': const BeakModel(-1.5, 0.5),
  'frillback': const BeakModel(0.0, 0.0),
  'pouter': const BeakModel(1.0, 0.5),
  'archangel': const BeakModel(0.5, 0.0),
  'jacobin': const BeakModel(0.0, 0.0),
};

BeakModel beakFromBreed(String breed) {
  final key = breed.toLowerCase().replaceAll(' ', '_').replaceAll('-', '_');
  final beak = breedBeakPresets[key];
  if (beak == null) {
    throw ArgumentError('وصفة سلالة غير معروفة: $breed');
  }
  return beak;
}
