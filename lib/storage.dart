import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'l10n.dart';
import 'models.dart';

class Store {
  Store._();

  static final Store instance = Store._();

  final List<Bird> _birds = <Bird>[];

  /// أنواع/حمامات افتراضية تُستخدم في التزويج الاختباري فقط.
  final List<Bird> _types = <Bird>[];
  final List<Clutch> _clutches = <Clutch>[];
  final List<Expense> _expenses = <Expense>[];
  final List<FeedItem> _feed = <FeedItem>[];
  final List<HealthRecord> _health = <HealthRecord>[];
  final List<WeightRecord> _weights = <WeightRecord>[];
  final List<CalendarEvent> _events = <CalendarEvent>[];

  List<Bird> get birds => List<Bird>.unmodifiable(_birds);
  List<Bird> get types => List<Bird>.unmodifiable(_types);
  List<Clutch> get clutches => List<Clutch>.unmodifiable(_clutches);
  List<Expense> get expenses => List<Expense>.unmodifiable(_expenses);
  List<FeedItem> get feed => List<FeedItem>.unmodifiable(_feed);
  List<HealthRecord> get health => List<HealthRecord>.unmodifiable(_health);
  List<WeightRecord> get weights => List<WeightRecord>.unmodifiable(_weights);
  List<CalendarEvent> get events => List<CalendarEvent>.unmodifiable(_events);

  Directory? _dir;
  String? folderPath;
  String? lastError;
  int postponeDays = 2;
  ThemeMode themeMode = ThemeMode.system;
  final themeListenable = ValueNotifier<ThemeMode>(ThemeMode.system);
  final localeListenable = ValueNotifier<Locale>(const Locale('ar'));
  bool notificationsEnabled = true;
  int notificationHour = 8;
  int notificationMinute = 0;

  Directory get dir => _dir ?? Directory.systemTemp;

  Future<void> init() async {
    // كل خطوة محمية بشكل مستقل: فشل أي جزء لا يمنع ظهور الواجهة.
    try {
      final prefs = await SharedPreferences.getInstance();
      folderPath = prefs.getString('folder_path');
      postponeDays = prefs.getInt('postpone_days') ?? 2;
      notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      notificationHour = prefs.getInt('notification_hour') ?? 8;
      notificationMinute = prefs.getInt('notification_minute') ?? 0;
      themeMode = _themeMode(prefs.getString('theme_mode'));
      themeListenable.value = themeMode;
      final lang = prefs.getString('language');
      L.locale = Locale(lang == 'en' ? 'en' : 'ar');
      localeListenable.value = L.locale;
    } catch (_) {
      lastError = 'تعذّر قراءة الإعدادات، تُستخدم الإعدادات الافتراضية';
    }

    try {
      _dir = await _resolve(folderPath);
    } catch (_) {
      _dir = Directory.systemTemp;
      lastError = 'تعذّر فتح مجلد الحفظ، يُستخدم مجلد التطبيق المؤقت';
    }

    try {
      await load();
    } catch (_) {
      lastError = 'تعذّر قراءة السجلات المحلية';
    }
  }

  ThemeMode _themeMode(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> load() async {
    _birds
      ..clear()
      ..addAll(_read<Bird>('birds.json', (j) => Bird.fromJson(j)));
    _types
      ..clear()
      ..addAll(_read<Bird>('types.json', (j) => Bird.fromJson(j))
          .where((b) => b.isVirtual)
          .toList());
    _clutches
      ..clear()
      ..addAll(_read<Clutch>('clutches.json', (j) => Clutch.fromJson(j)));
    _expenses
      ..clear()
      ..addAll(_read<Expense>('expenses.json', (j) => Expense.fromJson(j)));
    _feed
      ..clear()
      ..addAll(_read<FeedItem>('feed.json', (j) => FeedItem.fromJson(j)));
    _health
      ..clear()
      ..addAll(_read<HealthRecord>('health.json', (j) => HealthRecord.fromJson(j)));
    _weights
      ..clear()
      ..addAll(_read<WeightRecord>('weights.json', (j) => WeightRecord.fromJson(j)));
    _events
      ..clear()
      ..addAll(_read<CalendarEvent>('events.json', (j) => CalendarEvent.fromJson(j)));
    _birds.sort((a, b) => a.name.compareTo(b.name));
    _types.sort((a, b) => a.name.compareTo(b.name));
  }

  List<T> _read<T>(String file, T Function(Map<String, dynamic>) build) {
    final f = File(joinPath(dir.path, file));
    if (!f.existsSync()) return <T>[];
    try {
      final decoded = jsonDecode(f.readAsStringSync()) as List<dynamic>;
      return decoded
          .whereType<Map>()
          .map((e) => build(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      lastError = 'تعذّر قراءة $file';
      return <T>[];
    }
  }

  Future<void> _write<T>(String file, List<T> items) async {
    final data = items.map((e) => (e as dynamic).toJson()).toList();
    final f = File(joinPath(dir.path, file));
    await f.writeAsString(jsonEncode(data));
  }

  Future<void> saveBirds() async {
    _birds.sort((a, b) => a.name.compareTo(b.name));
    await _write('birds.json', _birds);
  }

  Future<void> saveTypes() async {
    _types.sort((a, b) => a.name.compareTo(b.name));
    await _write('types.json', _types);
  }

  Future<void> upsertType(Bird bird) async {
    final type = bird.copyWith(isVirtual: true);
    final i = _types.indexWhere((b) => b.id == type.id);
    if (i >= 0) {
      _types[i] = type;
    } else {
      _types.add(type);
    }
    await saveTypes();
  }

  Future<void> removeType(String id) async {
    _types.removeWhere((b) => b.id == id);
    await saveTypes();
  }

  Bird? findType(String? id) {
    if (id == null) return null;
    for (final type in _types) {
      if (type.id == id) return type;
    }
    return null;
  }

  Future<void> attachTypePhoto(Bird type, String path) async {
    final now = DateTime.now();
    await upsertType(type.copyWith(
      photos: <String>[...type.photos, path],
      lastPhotoAt: now,
      photoLog: <String>[...type.photoLog, now.toIso8601String()],
    ));
  }

  Future<void> upsertBird(Bird bird) async {
    final i = _birds.indexWhere((b) => b.id == bird.id);
    if (i >= 0) {
      _birds[i] = bird;
    } else {
      _birds.add(bird);
    }
    await saveBirds();
  }

  Future<void> removeBird(String id) async {
    _birds.removeWhere((b) => b.id == id);
    _clutches.removeWhere((c) => c.motherId == id || c.fatherId == id);
    _health.removeWhere((h) => h.birdId == id);
    _weights.removeWhere((w) => w.birdId == id);
    _events.removeWhere((e) => e.birdId == id);
    for (final bird in _birds) {
      if (bird.fatherId == id ||
          bird.motherId == id ||
          bird.eggPartnerId == id) {
        await upsertBird(bird.copyWith(
          clearFather: bird.fatherId == id,
          clearMother: bird.motherId == id,
          clearEggPartner: bird.eggPartnerId == id,
          clearEggGeneration: bird.eggPartnerId == id,
        ));
      }
    }
    await saveBirds();
    await _write('clutches.json', _clutches);
    await _write('health.json', _health);
    await _write('weights.json', _weights);
    await _write('events.json', _events);
  }

  Future<void> addClutch(Clutch c) async {
    _clutches.add(c);
    await _write('clutches.json', _clutches);
  }

  Future<void> updateClutch(Clutch c) async {
    final i = _clutches.indexWhere((x) => x.id == c.id);
    if (i >= 0) _clutches[i] = c;
    await _write('clutches.json', _clutches);
  }

  Future<void> removeClutch(String id) async {
    _clutches.removeWhere((c) => c.id == id);
    await _write('clutches.json', _clutches);
  }

  Future<void> addExpense(Expense e) async {
    _expenses.add(e);
    await _write('expenses.json', _expenses);
  }

  Future<void> removeExpense(String id) async {
    _expenses.removeWhere((e) => e.id == id);
    await _write('expenses.json', _expenses);
  }

  Future<void> addFeed(FeedItem f) async {
    _feed.add(f);
    await _write('feed.json', _feed);
  }

  Future<void> updateFeed(FeedItem f) async {
    final i = _feed.indexWhere((x) => x.id == f.id);
    if (i >= 0) _feed[i] = f;
    await _write('feed.json', _feed);
  }

  Future<void> removeFeed(String id) async {
    _feed.removeWhere((f) => f.id == id);
    await _write('feed.json', _feed);
  }

  Future<void> addHealth(HealthRecord h) async {
    _health.add(h);
    await _write('health.json', _health);
  }

  Future<void> removeHealth(String id) async {
    _health.removeWhere((h) => h.id == id);
    await _write('health.json', _health);
  }

  Future<void> addWeight(WeightRecord w) async {
    _weights.add(w);
    await _write('weights.json', _weights);
  }

  Future<void> removeWeight(String id) async {
    _weights.removeWhere((w) => w.id == id);
    await _write('weights.json', _weights);
  }

  Future<void> addEvent(CalendarEvent event) async {
    _events.add(event);
    await _write('events.json', _events);
  }

  Future<void> removeEvent(String id) async {
    _events.removeWhere((e) => e.id == id);
    await _write('events.json', _events);
  }

  Future<String?> chooseFolder() async {
    // ignore: deprecated_member_use
    final picked = await FilePicker.getDirectoryPath(
      dialogTitle: S.chooseFolder,
    );
    if (picked == null || picked.isEmpty) return null;
    final resolved = await _resolve(picked);
    if (resolved.path != picked) {
      lastError = 'المجلد المختار غير قابل للكتابة، سيُستخدم مجلد التطبيق بدلاً منه';
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('folder_path', resolved.path);
    folderPath = resolved.path;
    _dir = resolved;
    await load();
    return resolved.path;
  }

  Future<void> _savePref(Future<void> Function(SharedPreferences) fn) async {
    final prefs = await SharedPreferences.getInstance();
    await fn(prefs);
  }

  Future<void> setPostponeDays(int days) async {
    postponeDays = days < 1 ? 1 : days;
    await _savePref((p) async {
      await p.setInt('postpone_days', postponeDays);
    });
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode = mode;
    themeListenable.value = mode;
    final name = mode == ThemeMode.light
        ? 'light'
        : mode == ThemeMode.dark
            ? 'dark'
            : 'system';
    await _savePref((p) async {
      await p.setString('theme_mode', name);
    });
  }

  Future<void> setLocale(Locale locale) async {
    L.locale = locale;
    localeListenable.value = locale;
    await _savePref((p) async {
      await p.setString('language', locale.languageCode);
    });
  }

  Future<void> setNotifications(bool enabled) async {
    notificationsEnabled = enabled;
    await _savePref((p) async {
      await p.setBool('notifications_enabled', enabled);
    });
  }

  Future<void> setNotificationTime(int hour, int minute) async {
    notificationHour = hour;
    notificationMinute = minute;
    await _savePref((p) async {
      await p.setInt('notification_hour', hour);
      await p.setInt('notification_minute', minute);
    });
  }

  Future<Directory> _resolve(String? saved) async {
    Directory fallback;
    try {
      final docs = await getApplicationDocumentsDirectory();
      fallback = Directory(joinPath(docs.path, 'data_hmamat'));
    } catch (_) {
      fallback = Directory(joinPath(Directory.systemTemp.path, 'data_hmamat'));
    }
    if (saved != null && saved.isNotEmpty) {
      final candidate = Directory(saved);
      try {
        if (!await candidate.exists()) {
          await candidate.create(recursive: true);
        }
        final probe = File(joinPath(candidate.path, '.write_probe'));
        await probe.writeAsString('ok');
        await probe.delete();
        return candidate;
      } catch (_) {
        lastError = 'المجلد المحفوظ غير متاح، سيُستخدم مجلد التطبيق';
      }
    }
    if (!await fallback.exists()) {
      await fallback.create(recursive: true);
    }
    return fallback;
  }

  Future<Directory> photosDir() async {
    final d = Directory(joinPath(dir.path, 'photos'));
    if (!await d.exists()) await d.create(recursive: true);
    return d;
  }

  Future<String?> capturePhoto(Bird bird, ImageSource source) async {
    final xFile = await ImagePicker().pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 2400,
    );
    if (xFile == null) return null;
    final bytes = await xFile.readAsBytes();
    final d = await photosDir();
    final name = '${bird.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final target = File(joinPath(d.path, name));
    await target.writeAsBytes(bytes);
    return target.path;
  }

  Future<void> attachPhoto(Bird bird, String path) async {
    final now = DateTime.now();
    await upsertBird(bird.copyWith(
      photos: <String>[...bird.photos, path],
      lastPhotoAt: now,
      nextPhotoDue: now.add(const Duration(days: 7)),
      photoLog: <String>[...bird.photoLog, now.toIso8601String()],
    ));
  }

  Future<void> postpone(Bird bird, {int? days}) async {
    final base = bird.nextPhotoDue ?? DateTime.now();
    await upsertBird(bird.copyWith(
      nextPhotoDue: base.add(Duration(days: days ?? postponeDays)),
    ));
  }

  Future<void> skipWeek(Bird bird) async {
    final now = DateTime.now();
    await upsertBird(bird.copyWith(
      nextPhotoDue: now.add(const Duration(days: 7)),
      photoLog: <String>[...bird.photoLog, 'skipped:${now.toIso8601String()}'],
    ));
  }

  Future<void> setReminder(Bird bird, bool enabled) async =>
      upsertBird(bird.copyWith(reminders: enabled));

  List<Bird> get dueBirds => _birds.where((b) => b.isDue).toList();

  Bird? find(String? id) {
    if (id == null) return null;
    for (final bird in _birds) {
      if (bird.id == id) return bird;
    }
    return null;
  }

  Map<String, Bird> get byId =>
      <String, Bird>{for (final bird in _birds) bird.id: bird};

  /// تصدير شامل لكل السجلات داخل ملف واحد.
  Future<String> exportData() async {
    final payload = <String, dynamic>{
      'version': 4,
      'exportedAt': DateTime.now().toIso8601String(),
      'birds': _birds.map((e) => e.toJson()).toList(),
      'types': _types.map((e) => e.toJson()).toList(),
      'clutches': _clutches.map((e) => e.toJson()).toList(),
      'expenses': _expenses.map((e) => e.toJson()).toList(),
      'feed': _feed.map((e) => e.toJson()).toList(),
      'health': _health.map((e) => e.toJson()).toList(),
      'weights': _weights.map((e) => e.toJson()).toList(),
      'events': _events.map((e) => e.toJson()).toList(),
    };
    final text = jsonEncode(payload);
    final file = File(joinPath(dir.path, 'backup.json'));
    await file.writeAsString(text);
    return file.path;
  }

  Future<void> importData(String raw) async {
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    List<dynamic> section(String key) {
      final value = decoded[key];
      return value is List ? value : <dynamic>[];
    }

    _birds
      ..clear()
      ..addAll(section('birds')
          .whereType<Map>()
          .map((e) => Bird.fromJson(Map<String, dynamic>.from(e))));
    _types
      ..clear()
      ..addAll(section('types')
          .whereType<Map>()
          .map((e) => Bird.fromJson(Map<String, dynamic>.from(e)))
          .where((b) => b.isVirtual));
    _clutches
      ..clear()
      ..addAll(section('clutches')
          .whereType<Map>()
          .map((e) => Clutch.fromJson(Map<String, dynamic>.from(e))));
    _expenses
      ..clear()
      ..addAll(section('expenses')
          .whereType<Map>()
          .map((e) => Expense.fromJson(Map<String, dynamic>.from(e))));
    _feed
      ..clear()
      ..addAll(section('feed')
          .whereType<Map>()
          .map((e) => FeedItem.fromJson(Map<String, dynamic>.from(e))));
    _health
      ..clear()
      ..addAll(section('health')
          .whereType<Map>()
          .map((e) => HealthRecord.fromJson(Map<String, dynamic>.from(e))));
    _weights
      ..clear()
      ..addAll(section('weights')
          .whereType<Map>()
          .map((e) => WeightRecord.fromJson(Map<String, dynamic>.from(e))));
    _events
      ..clear()
      ..addAll(section('events')
          .whereType<Map>()
          .map((e) => CalendarEvent.fromJson(Map<String, dynamic>.from(e))));
    await saveBirds();
    await saveTypes();
    await _write('clutches.json', _clutches);
    await _write('expenses.json', _expenses);
    await _write('feed.json', _feed);
    await _write('health.json', _health);
    await _write('weights.json', _weights);
    await _write('events.json', _events);
  }

  Future<File?> pickBackupFile() async {
    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: <String>['json'],
      dialogTitle: S.import,
    );
    if (picked.isEmpty) return null;
    final path = picked.first.path;
    return path == null ? null : File(path);
  }

  static String joinPath(String a, String b) {
    if (a.endsWith(Platform.pathSeparator)) return '$a$b';
    return '$a${Platform.pathSeparator}$b';
  }
}
