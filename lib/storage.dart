import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

class Store {
  Store._();

  static final Store instance = Store._();

  final List<Bird> _birds = <Bird>[];
  List<Bird> get birds => List<Bird>.unmodifiable(_birds);

  Directory? _dir;
  String? folderPath;
  String? lastError;
  int postponeDays = 2;

  Directory get dir => _dir ?? Directory.systemTemp;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    folderPath = prefs.getString('folder_path');
    postponeDays = prefs.getInt('postpone_days') ?? 2;
    _dir = await _resolve(folderPath);
    await load();
  }

  Future<void> load() async {
    final file = File(joinPath(dir.path, 'birds.json'));
    if (!await file.exists()) {
      _birds.clear();
      return;
    }
    try {
      final decoded = jsonDecode(await file.readAsString()) as List<dynamic>;
      _birds
        ..clear()
        ..addAll(decoded
            .map((e) => Bird.fromJson(Map<String, dynamic>.from(e as Map))));
      _birds.sort((a, b) => a.name.compareTo(b.name));
    } catch (_) {
      lastError = 'تعذّر قراءة ملف البيانات';
      _birds.clear();
    }
  }

  Future<void> save() async {
    _birds.sort((a, b) => a.name.compareTo(b.name));
    final file = File(joinPath(dir.path, 'birds.json'));
    final data = _birds.map((b) => b.toJson()).toList();
    await file.writeAsString(jsonEncode(data));
  }

  Future<String?> chooseFolder() async {
    // ignore: deprecated_member_use
    final picked = await FilePicker.getDirectoryPath(
      dialogTitle: 'اختر مجلد حفظ بيانات الحمام',
    );
    if (picked == null || picked.isEmpty) return null;

    final resolved = await _resolve(picked);
    if (resolved.path != picked) {
      lastError =
          'المجلد المختار غير قابل للكتابة، سيُستخدم مجلد التطبيق بدلاً منه';
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('folder_path', resolved.path);
    folderPath = resolved.path;
    _dir = resolved;
    await load();
    return resolved.path;
  }

  Future<void> setPostponeDays(int days) async {
    postponeDays = days < 1 ? 1 : days;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('postpone_days', postponeDays);
  }

  Future<Directory> _resolve(String? saved) async {
    final docs = await getApplicationDocumentsDirectory();
    final fallback = Directory(joinPath(docs.path, 'data_hmamat'));
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

  Future<void> upsert(Bird bird) async {
    final index = _birds.indexWhere((b) => b.id == bird.id);
    if (index >= 0) {
      _birds[index] = bird;
    } else {
      _birds.add(bird);
    }
    await save();
  }

  Future<void> remove(String id) async {
    _birds.removeWhere((b) => b.id == id);
    await save();
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
    await upsert(bird.copyWith(
      photos: <String>[...bird.photos, path],
      lastPhotoAt: now,
      nextPhotoDue: now.add(const Duration(days: 7)),
      photoLog: <String>[...bird.photoLog, now.toIso8601String()],
    ));
  }

  Future<void> postpone(Bird bird, {int? days}) async {
    final base = bird.nextPhotoDue ?? DateTime.now();
    await upsert(bird.copyWith(
      nextPhotoDue: base.add(Duration(days: days ?? postponeDays)),
    ));
  }

  Future<void> skipWeek(Bird bird) async {
    final now = DateTime.now();
    await upsert(bird.copyWith(
      nextPhotoDue: now.add(const Duration(days: 7)),
      photoLog: <String>[
        ...bird.photoLog,
        'skipped:${now.toIso8601String()}',
      ],
    ));
  }

  Future<void> setReminder(Bird bird, bool enabled) async {
    await upsert(bird.copyWith(reminders: enabled));
  }

  List<Bird> get dueBirds => _birds.where((b) => b.isDue).toList();

  Bird? find(String? id) {
    if (id == null) return null;
    for (final bird in _birds) {
      if (bird.id == id) return bird;
    }
    return null;
  }

  static String joinPath(String a, String b) {
    if (a.endsWith(Platform.pathSeparator)) return '$a$b';
    return '$a${Platform.pathSeparator}$b';
  }
}
