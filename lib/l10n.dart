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
  static String get version => ar ? 'الإصدار 0.3.1' : 'Version 0.3.1';
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
