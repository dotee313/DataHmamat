import 'package:flutter/material.dart';

/// لغة الواجهة: عربية افتراضياً، ويمكن تبديلها إلى الإنجليزية من الإعدادات.
abstract final class L {
  static Locale locale = const Locale('ar');
  static bool get isAr => locale.languageCode == 'ar';
}

abstract final class S {
  static bool get ar => L.isAr;

  static String get appName => 'Data Hmamat';
  static String get birds => ar ? 'طيوري' : 'My Birds';
  static String get pedigree => ar ? 'النسب' : 'Pedigree';
  static String get photos => ar ? 'الصور' : 'Photos';
  static String get eggs => ar ? 'البيض' : 'Eggs';
  static String get finance => ar ? 'المصاريف' : 'Finance';
  static String get settings => ar ? 'الإعدادات' : 'Settings';

  static String get addBird => ar ? 'طير جديد' : 'New bird';
  static String get editBird => ar ? 'تعديل بيانات الطير' : 'Edit bird';
  static String get search => ar ? 'ابحث بالاسم أو النوع أو رقم الحلقة' : 'Search name, breed or ring';
  static String get noBirds => ar ? 'لا توجد طيور بعد' : 'No birds yet';
  static String get noResults => ar ? 'لا توجد نتائج' : 'No results';
  static String get noBirdsSub => ar ? 'أضف أول طير وابدأ سجلك الخاص' : 'Add your first bird to start your record';
  static String get noResultsSub => ar ? 'جرّب كلمة بحث أخرى' : 'Try another search term';
  static String get dueChip => ar ? 'طير ينتظر صورته الأسبوعية' : 'birds waiting for weekly photo';
  static String get dueNow => ar ? 'الصورة مستحقة الآن' : 'Photo due now';
  static String get dueLater => ar ? 'الموعد القادم محفوظ' : 'Next date saved';

  static String get name => ar ? 'اسم الطير' : 'Bird name';
  static String get kind => ar ? 'النوع / السلالة' : 'Breed / type';
  static String get color => ar ? 'اللون' : 'Color';
  static String get sex => ar ? 'الجنس' : 'Sex';
  static String get male => ar ? 'ذكر' : 'Male';
  static String get female => ar ? 'أنثى' : 'Female';
  static String get ring => ar ? 'رقم الحلقة' : 'Ring number';
  static String get bornOn => ar ? 'تاريخ الولادة أو الشراء' : 'Born / purchased on';
  static String get week => ar ? 'الأسبوع' : 'Week';
  static String get month => ar ? 'الشهر' : 'Month';
  static String get year => ar ? 'السنة' : 'Year';
  static String get birthHint => ar
      ? 'اختر الأسبوع من الشهر ثم الشهر ثم السنة. يُحفظ التاريخ تلقائياً.'
      : 'Choose the week of the month, then the month and year. The date is saved automatically.';
  static String weekName(int n) => ar
      ? <String>['الأول', 'الثاني', 'الثالث', 'الرابع', 'الخامس'][(n - 1).clamp(0, 4).toInt()]
      : <String>['1st', '2nd', '3rd', '4th', '5th'][(n - 1).clamp(0, 4).toInt()];
  static String monthName(int n) {
    const ar = <String>[
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];
    const en = <String>[
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return (S.ar ? ar : en)[(n - 1).clamp(0, 11).toInt()];
  }
  static String get father => ar ? 'الأب' : 'Father';
  static String get mother => ar ? 'الأم' : 'Mother';
  static String get none => ar ? 'لا يوجد' : 'None';
  static String get cv => ar ? 'السيرة الذاتية للطير (CV)' : 'Bird CV / notes';
  static String get save => ar ? 'حفظ' : 'Save';
  static String get cancel => ar ? 'إلغاء' : 'Cancel';
  static String get delete => ar ? 'حذف' : 'Delete';
  static String get edit => ar ? 'تعديل' : 'Edit';
  static String get close => ar ? 'إغلاق' : 'Close';
  static String get saved => ar ? 'حُفظ بنجاح' : 'Saved';
  static String get deleted => ar ? 'حُذف' : 'Deleted';
  static String get data => ar ? 'البيانات' : 'Details';
  static String get noData => ar ? 'لا توجد بيانات' : 'No data';
  static String get notRegistered => ar ? 'غير مسجّل' : 'Not recorded';
  static String get unknown => ar ? '—' : '—';

  static String get camera => ar ? 'كاميرا' : 'Camera';
  static String get gallery => ar ? 'معرض' : 'Gallery';
  static String get postpone => ar ? 'تأجيل' : 'Postpone';
  static String get skip => ar ? 'تخطي' : 'Skip';
  static String get skipWeek => ar ? 'تخطي الأسبوع' : 'Skip week';
  static String get reminders => ar ? 'تذكير صورة كل أسبوع' : 'Weekly photo reminder';
  static String get remindersSub => ar ? 'يظهر شعار في الواجهة عند موعد الصورة' : 'A badge appears when a photo is due';
  static String get stopReminder => ar ? 'إيقاف التذكير' : 'Disable reminder';
  static String get startReminder => ar ? 'تفعيل التذكير' : 'Enable reminder';
  static String get weeklyPhoto => ar ? 'الصورة الأسبوعية' : 'Weekly photo';
  static String get lastPhoto => ar ? 'آخر صورة' : 'Last photo';
  static String get nextDue => ar ? 'الموعد' : 'Due';
  static String get photoLog => ar ? 'سجل المواعيد' : 'Schedule log';
  static String get photoSaved => ar ? 'حُفظت الصورة' : 'Photo saved';
  static String get photoBadge => ar ? 'شعار الصورة الأسبوعية' : 'Weekly photo badge';
  static String get noPhotoDue => ar ? 'لا يوجد موعد صورة الآن' : 'No photo is due now';
  static String get noPhotos => ar ? 'لا توجد صور بعد' : 'No photos yet';
  static String get noPhotosSub => ar ? 'التقط صورة أسبوعية لطيرك وستظهر هنا' : 'Take a weekly photo and it will appear here';
  static String get photoView => ar ? 'عرض الصورة' : 'View photo';

  static String get ancestry => ar ? 'شجرة الأجداد' : 'Ancestors';
  static String get children => ar ? 'الأبناء المباشرون' : 'Direct children';
  static String get noChildren => ar ? 'لا يوجد أبناء مسجّلون' : 'No children recorded';
  static String get paternalLine => ar ? 'خط الأب' : 'Paternal line';
  static String get maternalLine => ar ? 'خط الأم' : 'Maternal line';
  static String get bilateral => ar ? 'النسب الثنائي' : 'Bilateral descent';
  static String get bilateralSub => ar
      ? 'خط الأب وخط الأم منفصلان حتى خمسة أجيال، مع حساب القرابة والتزواج الداخلي'
      : 'Father and mother lines shown separately up to five generations';
  static String get selectBird => ar ? 'اختر الطير' : 'Select bird';
  static String get relation => ar ? 'درجة القرابة بين طيرين' : 'Relationship between two birds';
  static String get relationValue => ar ? 'القرابة' : 'Relationship';
  static String get inbreeding => ar ? 'معامل التزواج الداخلي' : 'Inbreeding coefficient';
  static String get noPedigree => ar ? 'لا يوجد نسب لعرضه' : 'No pedigree to show';
  static String get noPedigreeSub => ar
      ? 'أضف طيرين ثم اربط الأب والأم من نموذج الإضافة'
      : 'Add two birds then link father and mother in the form';
  static String get generation => ar ? 'الجيل' : 'Generation';

  static String get eggsPage => ar ? 'البيض والفقس' : 'Eggs & hatching';
  static String get addClutch => ar ? 'إضافة حضنة' : 'Add clutch';
  static String get laidOn => ar ? 'تاريخ الوضع' : 'Laid on';
  static String get hatchDue => ar ? 'موعد الفقس' : 'Hatch due';
  static String get eggsCount => ar ? 'عدد البيض' : 'Eggs';
  static String get hatchedCount => ar ? 'عدد الخارج' : 'Hatched';
  static String get status => ar ? 'الحالة' : 'Status';
  static String get incubating => ar ? 'قيد الحضانة' : 'Incubating';
  static String get hatched => ar ? 'فقس' : 'Hatched';
  static String get failed => ar ? 'لم يفقس' : 'Failed';
  static String get noClutches => ar ? 'لا توجد حضنات بعد' : 'No clutches yet';
  static String get noClutchesSub => ar
      ? 'سجّل حضنة لطيرك لتتبع البيض وموعد الفقس ونسبة النجاح'
      : 'Add a clutch to track eggs, hatch date and success rate';
  static String get hatchSuccess => ar ? 'نسبة الفقس' : 'Hatch rate';
  static String get note => ar ? 'ملاحظة' : 'Note';

  static String get expensesPage => ar ? 'المصاريف والعلف' : 'Expenses & feed';
  static String get expenses => ar ? 'المصاريف' : 'Expenses';
  static String get feedStock => ar ? 'مخزون العلف' : 'Feed stock';
  static String get addExpense => ar ? 'إضافة مصروف' : 'Add expense';
  static String get addFeed => ar ? 'إضافة علف' : 'Add feed';
  static String get category => ar ? 'التصنيف' : 'Category';
  static String get amount => ar ? 'المبلغ' : 'Amount';
  static String get date => ar ? 'التاريخ' : 'Date';
  static String get total => ar ? 'الإجمالي' : 'Total';
  static String get feed => ar ? 'علف' : 'Feed';
  static String get medicine => ar ? 'أدوية' : 'Medicine';
  static String get equipment => ar ? 'معدات' : 'Equipment';
  static String get other => ar ? 'أخرى' : 'Other';
  static String get quantity => ar ? 'الكمية (كغ)' : 'Quantity (kg)';
  static String get lowLimit => ar ? 'حد التنبيه (كغ)' : 'Alert limit (kg)';
  static String get lowStock => ar ? 'مخزون منخفض' : 'Low stock';
  static String get noExpenses => ar ? 'لا توجد مصاريف بعد' : 'No expenses yet';
  static String get noFeed => ar ? 'لا يوجد علف مسجّل' : 'No feed recorded';

  static String get health => ar ? 'السجل الصحي' : 'Health log';
  static String get addHealth => ar ? 'إضافة سجل صحي' : 'Add health record';
  static String get treatment => ar ? 'علاج' : 'Treatment';
  static String get vaccine => ar ? 'تطعيم' : 'Vaccine';
  static String get vetVisit => ar ? 'زيارة طبيب' : 'Vet visit';
  static String get nextVisit => ar ? 'الموعد القادم' : 'Next due';
  static String get weight => ar ? 'الوزن' : 'Weight';
  static String get weightLog => ar ? 'سجل الوزن' : 'Weight log';
  static String get addWeight => ar ? 'إضافة وزن' : 'Add weight';
  static String get grams => ar ? 'غرام' : 'g';
  static String get noHealth => ar ? 'لا توجد سجلات صحية' : 'No health records';
  static String get noWeight => ar ? 'لا توجد قياسات وزن' : 'No weight records';

  static String get folder => ar ? 'مجلد الحفظ' : 'Storage folder';
  static String get chooseFolder => ar ? 'اختر مجلداً على الجهاز' : 'Choose a device folder';
  static String get folderHint => ar
      ? 'تُحفظ بياناتك وصورك داخل هذا المجلد على جهازك فقط، بلا إنترنت ولا رفع لأي خادم.'
      : 'Your data and photos stay in this folder on your device only.';
  static String get noFolderChosen => ar ? 'لم يتم اختيار مجلد' : 'No folder chosen';
  static String get folderPath => ar ? 'مجلد الحفظ' : 'Storage path';
  static String get postponeDays => ar ? 'أيام التأجيل الافتراضية' : 'Default postpone days';
  static String get postponeHint => ar
      ? 'يمكن تأجيل أي صورة أو تخطيها في أي وقت، ويبقى وقت الموعد الأصلي محفوظاً في السجل.'
      : 'You can postpone or skip anytime; the original time stays in the log.';
  static String get language => ar ? 'اللغة' : 'Language';
  static String get arabic => ar ? 'العربية' : 'Arabic';
  static String get english => ar ? 'الإنجليزية' : 'English';
  static String get appearance => ar ? 'المظهر' : 'Appearance';
  static String get light => ar ? 'فاتح' : 'Light';
  static String get dark => ar ? 'داكن' : 'Dark';
  static String get system => ar ? 'حسب النظام' : 'System';
  static String get notifications => ar ? 'الإشعارات' : 'Notifications';
  static String get notificationsOn => ar ? 'تنبيه الصور الأسبوعية' : 'Weekly photo alerts';
  static String get notificationTime => ar ? 'وقت التنبيه اليومي' : 'Daily alert time';
  static String get backup => ar ? 'النسخ الاحتياطي' : 'Backup';
  static String get export => ar ? 'تصدير البيانات' : 'Export data';
  static String get import => ar ? 'استيراد البيانات' : 'Import data';
  static String get exportHint => ar
      ? 'يُكتب ملف كامل بجميع السجلات داخل مجلد الحفظ.'
      : 'Writes a full file with all records into the storage folder.';
  static String get importDone => ar ? 'استُوردت البيانات' : 'Data imported';
  static String get exportDone => ar ? 'صُدّرت البيانات' : 'Data exported';
  static String get about => ar ? 'عن التطبيق' : 'About';
  static String get aboutText => ar
      ? 'سجل الحمامات المحلي. بياناتك ملكك، تبقى على جهازك.'
      : 'Your offline pigeon record. Your data stays on your device.';
  static String get version => ar ? 'الإصدار 0.6.2' : 'Version 0.6.2';

  /// الصفات الجاهزة بأسمائها العربية كما كُتبت، بلا تحريف ولا تشكيل.
  static const List<String> readyColors = <String>[
    'ابيض',
    'كريمي',
    'اصفر',
    'جوزي',
    'طيني',
    'حني',
    'احمر',
    'ازرق',
    'رمادي',
    'اسود',
  ];
  static const List<String> readyMarks = <String>[
    'مكحكل الراس',
    'مكلش الرجل',
    'حافي',
    'وردة الصدر',
    'فتيلا الراس',
  ];
  static const List<String> readyWingBeak = <String>[
    'جناح ذو شريط',
    'ذو شريطين',
    'جناح ذو نقاط',
    'جناح صافي',
    'جناح ذو شريطين منقط',
    'جناح ذو شريط منقط',
    'منقار قصير',
    'منقار متوسط',
    'منقار طويل',
  ];
  static const List<String> readyTraits = <String>[
    ...readyMarks,
    ...readyWingBeak,
  ];

  /// أسماء الأجيال كما طلبها المستخدم حرفياً.
  static String generationName(int n) {
    if (n <= 0) return 'الاول';
    const names = <String>[
      'الاول',
      'ثاني',
      'الثالث',
      'الرابع',
      'الخامس',
      'السادس',
      'السابع',
      'الثامن',
      'التاسع',
      'العاشر',
    ];
    return n <= names.length ? names[n - 1] : 'ال$n';
  }

  static String get alive => ar ? 'حي' : 'Alive';
  static String get dead => ar ? 'ميت' : 'Deceased';
  static String get lifeStatus => ar ? 'الحالة' : 'Life status';
  static String get eggPartner => ar ? 'شريك البيضة' : 'Egg partner';
  static String get eggPartnerHint => ar
      ? 'البيضة الثانية أو الأخت من الحضنة نفسها. كل بيضتين معاً جيل.'
      : 'The second egg or sibling from the same clutch. Every two eggs form a generation.';
  static String get eggPartnerNone => ar
      ? 'لا يوجد شريك بيضة مسجّل'
      : 'No egg partner recorded';
  static String generationLabel(int n) =>
      ar ? 'جيل ${generationName(n)}' : 'Generation $n';
  static String get readyTraitsTitle =>
      ar ? 'الصفات الجاهزة' : 'Ready traits';
  static String get colorsTitle => ar ? 'الألوان' : 'Colors';
  static String get marksTitle => ar ? 'الرأس والرجل والصدر' : 'Head, feet, chest';
  static String get wingBeakTitle => ar ? 'الجناح والمنقار' : 'Wing and beak';
  static String get writeType => ar ? 'اكتب نوعًا' : 'Write a type';
  static String get writeTypeHint => ar
      ? 'احفظ نوع الأب أو الأم حين لا تعرفه، بالاسم والصورة والصفات، دون إضافته إلى قائمة طيوري.'
      : 'Save an unknown parent type with its name, photo and traits without adding it to My Birds.';
  static String get addType => ar ? 'إضافة نوع' : 'Add type';
  static String get typeName => ar ? 'اسم النوع' : 'Type name';
  static String get savedTypes => ar ? 'الأنواع المحفوظة' : 'Saved types';
  static String get noSavedTypes => ar ? 'لا توجد أنواع محفوظة' : 'No saved types';
  static String get virtualBird => ar ? 'حمامة افتراضية' : 'Virtual pigeon';
  static String get myBirdsSource => ar ? 'من طيوري' : 'From my birds';
  static String get typesSource => ar ? 'من الأنواع المكتوبة' : 'From saved types';
  static String get testMating => ar ? 'التزويج الاختباري' : 'Test mating';
  static String get testMatingSub => ar
      ? 'تزويج طيرين لمعرفة ألوان وأشكال الفراخ المتوقعة، ويمكن صنع حمامة افتراضية لمعرفة ماذا تشتري.'
      : 'Mate two birds to see expected chick colors and traits, including virtual pigeons.';
  static String get selectFirstParent => ar ? 'الطير الأول' : 'First bird';
  static String get selectSecondParent => ar ? 'الطير الثاني' : 'Second bird';
  static String get calculate => ar ? 'احسب الاحتمالات' : 'Calculate chances';
  static String get expectedTraits => ar ? 'الصفات المتوقعة' : 'Expected traits';
  static String get traitChance => ar ? 'الاحتمال' : 'Chance';
  static String get testMatingHint => ar
      ? 'يستخدم نموذج UP-Pigen الوراثي: توريث مرتبط بالجنس ومربع بونيت. اختر صفات كل طير بنفسك، لأن اللون وحده لا يخبرنا إن كان الجناح مشرطاً أم فخارلياً؛ النتيجة احتمالية وليست ضماناً.'
      : 'Uses the UP-Pigen model: sex-linked inheritance and Punnett squares. Pick each parent\'s traits yourself, since color alone does not tell whether the wing is barred or barless; results are probabilities, not guarantees.';
  static String get parentTraits =>
      ar ? 'صفات هذا الطير عند الاختبار' : 'Traits for this parent';
  static String get parentTraitsHint => ar
      ? 'اختر ما تراه في اللون: المشرط، محبب، مكتف، فخارلي، وغيرها. اختيارك هنا لا يغيّر بيانات الطير المحفوظة.'
      : 'Choose what you see in the color: barred, check, T-check, barless, and so on. This does not change the saved bird.';
  static String get chooseTwoParents => ar
      ? 'اختر طيرين أو نوعين مختلفين لحساب الاحتمالات.'
      : 'Choose two different birds or types to calculate chances.';
  static String get noPrediction => ar ? 'لا توجد صفات كافية للتوقّع' : 'Not enough traits to predict';
  static String get sameSexError => ar
      ? 'لا يمكن التزويج بين طيرين من نفس الجنس؛ اختر ذكراً وأنثى.'
      : 'Choose one male and one female to mate.';
  static String get geneticBasis =>
      ar ? 'الأساس الوراثي (UP-Pigen)' : 'Genetic basis (UP-Pigen)';
  static String get parentGenotypes =>
      ar ? 'التركيب الوراثي للأب والأم' : 'Parent genotypes';
  static String get offspringSexes =>
      ar ? 'نسبة الذكور إلى الإناث' : 'Sex ratio';
  static String get expectedBeak => ar ? 'المنقار المتوقع' : 'Expected beak';
  static String get approximateMapping => ar
      ? 'اللون يُترجم إلى مواقع اللون فقط، أما الصفات فتؤخذ من اختيارك في هذه الشاشة. كل ذلك تقريب وفق نموذج UP-Pigen، والنتائج احتمالية وليست ضماناً.'
      : 'Color maps to color loci only; traits come from your choices in this screen. Both are approximations under UP-Pigen, and results are probabilities, not guarantees.';
  static String resultCount(int n) =>
      ar ? 'عدد النتائج المختلفة: $n' : '$n distinct results';
  static String get confirmDelete => ar ? 'تأكيد الحذف؟' : 'Confirm delete?';
  static String get confirmDeleteBody => ar
      ? 'ستُحذف البيانات من الملف المحلي.'
      : 'The record will be removed from the local file.';

  static String get stats => ar ? 'الإحصائيات' : 'Statistics';
  static String get weightTrend => ar ? 'تطور الوزن' : 'Weight trend';
  static String get eggProduction => ar ? 'إنتاج البيض' : 'Egg production';
  static String get monthlyExpenses => ar ? 'المصاريف الشهرية' : 'Monthly expenses';
  static String get noStats => ar ? 'لا توجد بيانات كافية للرسم' : 'Not enough data to chart';
  static String get lastSixMonths => ar ? 'آخر ستة أشهر' : 'Last six months';

  static String get idCard => ar ? 'بطاقة التعريف' : 'ID card';
  static String get qrCard => ar ? 'بطاقة برمز QR' : 'QR ID card';
  static String get qrHint => ar
      ? 'احفظ الصورة أو شاركها؛ يمكن طباعتها من المعرض.'
      : 'Save or share the image; print it from the gallery.';
  static String get saveImage => ar ? 'حفظ الصورة' : 'Save image';
  static String get share => ar ? 'مشاركة' : 'Share';
  static String get imageSaved => ar ? 'حُفظت الصورة' : 'Image saved';
  static String get pdfReport => ar ? 'تقرير PDF' : 'PDF report';
  static String get familyTree => ar ? 'شجرة العائلة' : 'Family tree';
  static String get chartHint => ar
      ? 'شجرة تفاعلية: اسحب للتحريك، قرّب وبعّد، واضغط على أي بطاقة لتركيز الشجرة عليها.'
      : 'Interactive chart: drag to pan, pinch or use the buttons to zoom, and tap a card to focus it.';
  static String get ancestors => ar ? 'الأجيال للأعلى' : 'Ancestor levels';
  static String get zoomIn => ar ? 'تكبير' : 'Zoom in';
  static String get zoomOut => ar ? 'تصغير' : 'Zoom out';
  static String get fitView => ar ? 'ملاءمة الشاشة' : 'Fit to screen';
  static String get focusBird => ar ? 'الطير المركزي' : 'Focus bird';

  // سلالة المرغوبة
  static String get desiredBreed => ar ? 'سلالة المرغوبة' : 'Desired breed';
  static String get desiredBreedSub => ar
      ? 'اختر الصفات التي تحلم بها، ويبحث التطبيق في طيورك الحالية عن أقصر سلسلة تزاوجات للوصول إليها.'
      : 'Pick the traits you dream of and the app searches your current birds for the shortest chain of matings to reach them.';
  static String get pickGoals => ar ? 'الصفات المطلوبة' : 'Wanted traits';
  static String get pickGoalsHint => ar
      ? 'اختر صفة واحدة لكل جين، حتى خمس صفات.'
      : 'One trait per gene, up to five traits.';
  static String get findPath => ar ? 'ابحث عن أقصر طريق' : 'Find the shortest path';
  static String get alreadyHaveIt => ar
      ? 'عندك طير يحمل هذه المواصفات بالفعل:'
      : 'You already have a bird with these traits:';
  static String missingGenesMsg(String names) => ar
      ? 'لا يحمل أي طير عندك: $names. التزاوج لا يصنع جيناً غير موجود، فتحتاج إلى شراء طير يحمله.'
      : 'None of your birds carries: $names. Mating cannot create a missing gene, so you need to buy a bird that has it.';
  static String get noPairMsg => ar
      ? 'تحتاج إلى ذكر حي وأنثى حية على الأقل في طيورك.'
      : 'You need at least one living male and one living female.';
  static String tooFarMsg(int n) => ar
      ? 'لا يمكن الوصول إليها خلال $n أجيال من طيورك الحالية. جرّب تقليل الصفات أو إضافة طير جديد.'
      : 'Cannot be reached within $n generations from your current birds. Try fewer traits or add a new bird.';
  static String stepN(int n) => ar ? 'الخطوة $n' : 'Step $n';
  static String fromStep(int n) => ar ? 'فرخ الخطوة $n' : 'Chick of step $n';
  static String get finalTarget => ar ? 'هذا هو الطير المطلوب' : 'This is the wanted bird';
  static String get chickChance => ar ? 'احتمال هذا الفرخ' : 'Chance of this chick';
  static String oneInEggs(int n) =>
      ar ? 'واحد من كل $n بيضة تقريباً' : 'about 1 in every $n eggs';
  static String generationsCount(int n) =>
      ar ? 'عدد الأجيال: $n' : 'Generations: $n';
  static String expectedEggsLabel(int n) =>
      ar ? 'بيض متوقع: ≈ $n' : 'Expected eggs: ≈ $n';
  static String get planNote => ar
      ? 'الخطة مبنية على التراكيب الجينية التقريبية للألوان والصفات المسجّلة؛ الحامل الخفي غير المعروف لا يدخل في الحساب، والنتائج احتمالية وليست ضماناً.'
      : 'The plan uses approximate genotypes mapped from recorded colors and traits; unknown hidden carriers are not counted, and results are probabilities, not guarantees.';

  // تلوين الشجرة بالجين
  static String get colorByGene => ar ? 'لوّن الشجرة حسب جين' : 'Color tree by gene';
  static String get noColoring => ar ? 'بلا تلوين' : 'No coloring';
  static String get geneShows => ar ? 'يظهر' : 'Shows';
  static String get geneCarrier => ar ? 'حامل' : 'Carrier';
  static String get genePossible => ar ? 'محتمل' : 'Possible';
  static String get geneAbsent => ar ? 'لا يحمله' : 'None';
  static String get geneTraceNote => ar
      ? 'مبني على الألوان والصفات المسجّلة وعلى النسب؛ «محتمل» تقدير بقوانين مندل.'
      : 'Based on recorded colors, traits and ancestry; "possible" is a Mendelian estimate.';

  // شكل الفرخ المتوقع
  static String get chickLooks => ar ? 'شكل الفرخ المتوقع' : 'Expected chick look';
  static String get chickLooksSub => ar
      ? 'رسم تقريبي لأكثر الفراخ احتمالاً بألوانها وصفاتها.'
      : 'A rough drawing of the most likely chicks with their colors and traits.';
  static String get partnersChildren => ar ? 'الأزواج والأبناء' : 'Mates and offspring';
  static String get tapToOpen => ar ? 'اضغط على أي طير لفتح شجرته' : 'Tap any bird to open its tree';
  static String get risk => ar ? 'مستوى الخطر' : 'Risk level';
  static String get riskLow => ar ? 'منخفض' : 'Low';
  static String get riskMid => ar ? 'متوسط' : 'Medium';
  static String get riskHigh => ar ? 'مرتفع' : 'High';
  static String get age => ar ? 'العمر' : 'Age';
  static String get newborn => ar ? 'حديث الولادة' : 'Newborn';
  static String get moreSections => ar ? 'أقسام إضافية' : 'More sections';
  static String get pedigreePdf => ar ? 'تقرير النسب PDF' : 'Pedigree PDF';
  static String get pdfReady => ar ? 'جاهز للمشاركة' : 'Ready to share';

  static String get calendar => ar ? 'التقويم' : 'Calendar';
  static String get calendarPage => ar ? 'تقويم المواعيد' : 'Appointment calendar';
  static String get addEvent => ar ? 'إضافة موعد' : 'Add appointment';
  static String get eventTitle => ar ? 'عنوان الموعد' : 'Appointment title';
  static String get eventType => ar ? 'نوع الموعد' : 'Appointment type';
  static String get customEvent => ar ? 'موعد مخصص' : 'Custom';
  static String get photoEvent => ar ? 'صورة أسبوعية' : 'Weekly photo';
  static String get hatchEvent => ar ? 'فقس' : 'Hatching';
  static String get healthEvent => ar ? 'صحة' : 'Health';
  static String get noEvents => ar ? 'لا توجد مواعيد في هذا اليوم' : 'No appointments on this day';
  static String get today => ar ? 'اليوم' : 'Today';
  static String get eventForBird => ar ? 'الطير المرتبط' : 'Related bird';
  static String get derivedEvents => ar
      ? 'تظهر تلقائياً مواعيد الصور والفقس والعلاجات من سجلاتك.'
      : 'Photo, hatch and health dates appear automatically from your records.';
}


/// العمر بالسنة والشهر والأسبوع داخل الشهر (الأول، الثاني، الثالث، الرابع، الخامس).
String ageText(DateTime born, [DateTime? now]) {
  final n = now ?? DateTime.now();
  var years = n.year - born.year;
  var months = n.month - born.month;
  var days = n.day - born.day;
  if (days < 0) {
    months -= 1;
    final prevMonthDays = DateTime(n.year, n.month, 0).day;
    days += prevMonthDays;
  }
  if (months < 0) {
    years -= 1;
    months += 12;
  }
  if (years < 0) return '—';
  final w = (days ~/ 7).clamp(0, 4).toInt() + 1;
  final ar = S.ar;
  const arW = <String>['الأول', 'الثاني', 'الثالث', 'الرابع', 'الخامس'];
  final parts = <String>[];
  if (years > 0) parts.add(ar ? '$years سنة' : '$years y');
  if (months > 0) parts.add(ar ? '$months شهر' : '$months mo');
  parts.add(ar ? 'الأسبوع ${arW[w - 1]}' : 'Week $w');
  return parts.join(' • ');
}
