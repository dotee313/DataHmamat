import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'bird_form.dart';
import 'models.dart';
import 'storage.dart';
import 'theme.dart';
import 'widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  static const _titles = <String>[
    'طيوري',
    'شجرة النسب',
    'الصور الأسبوعية',
    'الإعدادات',
  ];

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final due = Store.instance.dueBirds.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          if (due > 0)
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 14),
              child: InkWell(
                onTap: () => setState(() => _index = 2),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.photo_camera_outlined,
                          size: 16, color: AppTheme.greenDark),
                      const SizedBox(width: 4),
                      Text('$due',
                          style: const TextStyle(
                              color: AppTheme.greenDark,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: [
          BirdsPage(onChanged: _refresh),
          PedigreePage(onChanged: _refresh),
          PhotosPage(onChanged: _refresh),
          SettingsPage(onChanged: _refresh),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.pets_outlined), label: 'الطيور'),
          NavigationDestination(
              icon: Icon(Icons.family_restroom_outlined), label: 'النسب'),
          NavigationDestination(
              icon: Icon(Icons.photo_library_outlined), label: 'الصور'),
          NavigationDestination(
              icon: Icon(Icons.settings_outlined), label: 'الإعدادات'),
        ],
      ),
    );
  }
}

class BirdsPage extends StatefulWidget {
  const BirdsPage({super.key, required this.onChanged});

  final VoidCallback onChanged;

  @override
  State<BirdsPage> createState() => _BirdsPageState();
}

class _BirdsPageState extends State<BirdsPage> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _open(Bird bird) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BirdDetailPage(birdId: bird.id),
      ),
    );
    widget.onChanged();
  }

  Future<void> _add() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const BirdFormPage()),
    );
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();
    final birds = Store.instance.birds
        .where((b) =>
            query.isEmpty ||
            b.name.toLowerCase().contains(query) ||
            b.kind.toLowerCase().contains(query) ||
            b.ring.toLowerCase().contains(query))
        .toList();
    final due = Store.instance.dueBirds;

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
          children: [
            TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'ابحث بالاسم أو النوع أو رقم الحلقة',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            if (due.isNotEmpty) ...[
              const SizedBox(height: 14),
              Card(
                color: const Color(0xFFFBF4E4),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.camera_alt_outlined,
                              color: AppTheme.gold),
                          const SizedBox(width: 8),
                          Text(
                            '${due.length} طير ينتظر صورته الأسبوعية',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.ink,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: [
                          for (final bird in due)
                            ActionChip(
                              label: Text(bird.name),
                              onPressed: () => _open(bird),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 6),
            if (birds.isEmpty)
              EmptyState(
                icon: Icons.pets_outlined,
                title: query.isEmpty ? 'لا توجد طيور بعد' : 'لا توجد نتائج',
                subtitle: query.isEmpty
                    ? 'أضف أول طير وابدأ سجلك الخاص'
                    : 'جرّب كلمة بحث أخرى',
                action: query.isEmpty
                    ? FilledButton(
                        onPressed: _add,
                        child: const Text('إضافة طير'),
                      )
                    : null,
              )
            else
              for (final bird in birds)
                Card(
                  child: ListTile(
                    onTap: () => _open(bird),
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.green.withValues(alpha: 0.12),
                      child: Text(
                        bird.name.isEmpty ? '?' : bird.name[0],
                        style: const TextStyle(
                            color: AppTheme.green,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                    title: Text(bird.name,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(
                      <String>[
                        if (bird.kind.isNotEmpty) bird.kind,
                        if (bird.color.isNotEmpty) bird.color,
                        bird.sex,
                      ].join(' • '),
                    ),
                    trailing: bird.isDue
                        ? const Icon(Icons.photo_camera_outlined,
                            color: AppTheme.gold)
                        : const Icon(Icons.chevron_left, color: AppTheme.muted),
                  ),
                ),
          ],
        ),
        Positioned(
          left: 18,
          bottom: 18,
          child: FloatingActionButton.extended(
            onPressed: _add,
            backgroundColor: AppTheme.green,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_rounded),
            label: const Text('طير جديد'),
          ),
        ),
      ],
    );
  }
}

class PedigreePage extends StatefulWidget {
  const PedigreePage({super.key, required this.onChanged});

  final VoidCallback onChanged;

  @override
  State<PedigreePage> createState() => _PedigreePageState();
}

class _PedigreePageState extends State<PedigreePage> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    final birds = Store.instance.birds;
    final selected = Store.instance.find(_selected) ??
        (birds.isEmpty ? null : birds.first);

    if (birds.isEmpty) {
      return const EmptyState(
        icon: Icons.family_restroom_outlined,
        title: 'لا يوجد نسب لعرضه',
        subtitle: 'أضف طيرين ثم اربط الأب والأم من نموذج الإضافة',
      );
    }

    final children = birds
        .where((b) => b.fatherId == selected?.id || b.motherId == selected?.id)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DropdownButtonFormField<String>(
          initialValue: selected!.id,
          decoration: const InputDecoration(
            labelText: 'اختر الطير',
            prefixIcon: Icon(Icons.pets_outlined),
          ),
          items: [
            for (final b in birds)
              DropdownMenuItem<String>(value: b.id, child: Text(b.name)),
          ],
          onChanged: (v) => setState(() => _selected = v),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'شجرة الأجداد',
          icon: Icons.account_tree_outlined,
          child: _ancestor(selected!.id, 0),
        ),
        SectionCard(
          title: 'الأبناء المباشرون',
          icon: Icons.child_care_outlined,
          child: children.isEmpty
              ? const Text('لا يوجد أبناء مسجّلون',
                  style: TextStyle(color: AppTheme.muted, fontSize: 12))
              : Column(
                  children: [
                    for (final child in children)
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.pets_outlined,
                            size: 18, color: AppTheme.green),
                        title: Text(child.name),
                        subtitle: Text(child.kind),
                        onTap: () => setState(() => _selected = child.id),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _ancestor(String id, int depth) {
    final bird = Store.instance.find(id);
    if (bird == null || depth > 4) {
      return const Padding(
        padding: EdgeInsets.all(8),
        child: Text('غير مسجّل',
            style: TextStyle(color: AppTheme.muted, fontSize: 11)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: depth == 0
                ? AppTheme.green.withValues(alpha: 0.10)
                : const Color(0xFFF3F5F2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(bird.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, color: AppTheme.ink)),
              Text(
                <String>[
                  if (bird.kind.isNotEmpty) bird.kind,
                  if (bird.ring.isNotEmpty) 'حلقة ${bird.ring}',
                  formatDate(bird.bornOn),
                ].join(' • '),
                style: const TextStyle(fontSize: 11, color: AppTheme.muted),
              ),
            ],
          ),
        ),
        if (bird.fatherId != null || bird.motherId != null) ...[
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _ancestor(bird.fatherId ?? '', depth + 1)),
              const SizedBox(width: 8),
              Expanded(child: _ancestor(bird.motherId ?? '', depth + 1)),
            ],
          ),
        ],
      ],
    );
  }
}

class PhotosPage extends StatefulWidget {
  const PhotosPage({super.key, required this.onChanged});

  final VoidCallback onChanged;

  @override
  State<PhotosPage> createState() => _PhotosPageState();
}

class _PhotosPageState extends State<PhotosPage> {
  Future<void> _take(Bird bird, ImageSource source) async {
    final path = await Store.instance.capturePhoto(bird, source);
    if (path == null) return;
    await Store.instance.attachPhoto(bird, path);
    widget.onChanged();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('حُفظت الصورة')));
  }

  Future<void> _view(String path) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PhotoViewerPage(path: path),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final due = Store.instance.dueBirds;
    final entries = <MapEntry<Bird, String>>[];
    for (final bird in Store.instance.birds) {
      for (final path in bird.photos) {
        entries.add(MapEntry(bird, path));
      }
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionCard(
          title: 'شعار الصورة الأسبوعية',
          icon: Icons.photo_camera_outlined,
          child: due.isEmpty
              ? const Text('لا يوجد موعد صورة الآن',
                  style: TextStyle(color: AppTheme.muted, fontSize: 12))
              : Column(
                  children: [
                    for (final bird in due)
                      Card(
                        color: const Color(0xFFFBF4E4),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(bird.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                              Text(
                                'الموعد: ${formatDateTime(bird.nextPhotoDue)}',
                                style: const TextStyle(
                                    fontSize: 11, color: AppTheme.muted),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () => _take(
                                        bird, ImageSource.camera),
                                    icon: const Icon(Icons.camera_alt_outlined,
                                        size: 16),
                                    label: const Text('كاميرا'),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: () => _take(
                                        bird, ImageSource.gallery),
                                    icon: const Icon(Icons.photo_outlined,
                                        size: 16),
                                    label: const Text('معرض'),
                                  ),
                                  OutlinedButton(
                                    onPressed: () async {
                                      await Store.instance.postpone(bird);
                                      widget.onChanged();
                                    },
                                    child: const Text('تأجيل'),
                                  ),
                                  OutlinedButton(
                                    onPressed: () async {
                                      await Store.instance.skipWeek(bird);
                                      widget.onChanged();
                                    },
                                    child: const Text('تخطي'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
        ),
        const SizedBox(height: 6),
        if (entries.isEmpty)
          const EmptyState(
            icon: Icons.photo_library_outlined,
            title: 'لا توجد صور بعد',
            subtitle: 'التقط صورة أسبوعية لطيرك وستظهر هنا',
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final path = entries[index].value;
              return GestureDetector(
                onTap: () => _view(path),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ImageGridTile(path: path, name: entries[index].key.name),
                ),
              );
            },
          ),
      ],
    );
  }
}

class ImageGridTile extends StatelessWidget {
  const ImageGridTile({super.key, required this.path, required this.name});

  final String path;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ZoomableImage(path: path),
        Positioned(
          right: 0,
          left: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            color: Colors.black54,
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
        ),
      ],
    );
  }
}

class PhotoViewerPage extends StatelessWidget {
  const PhotoViewerPage({super.key, required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('عرض الصورة'),
      ),
      body: ZoomableImage(path: path),
    );
  }
}

class BirdDetailPage extends StatefulWidget {
  const BirdDetailPage({super.key, required this.birdId});

  final String birdId;

  @override
  State<BirdDetailPage> createState() => _BirdDetailPageState();
}

class _BirdDetailPageState extends State<BirdDetailPage> {
  Future<void> _edit() async {
    final bird = Store.instance.find(widget.birdId);
    if (bird == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BirdFormPage(bird: bird),
      ),
    );
    setState(() {});
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الطير؟'),
        content: const Text('ستُحذف بياناته من الملف المحلي.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await Store.instance.remove(widget.birdId);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _take(ImageSource source) async {
    final bird = Store.instance.find(widget.birdId);
    if (bird == null) return;
    final path = await Store.instance.capturePhoto(bird, source);
    if (path == null) return;
    await Store.instance.attachPhoto(bird, path);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bird = Store.instance.find(widget.birdId);
    if (bird == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('تم الحذف')),
        body: const Center(child: Text('لم يعد هذا الطير موجوداً')),
      );
    }

    final father = Store.instance.find(bird.fatherId);
    final mother = Store.instance.find(bird.motherId);

    return Scaffold(
      appBar: AppBar(
        title: Text(bird.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: _edit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _delete,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
        children: [
          if (bird.photos.isNotEmpty)
            SizedBox(
              height: 260,
              child: PageView.builder(
                itemCount: bird.photos.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ZoomableImage(path: bird.photos[index]),
                ),
              ),
            )
          else
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFFECEEEA),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.pets_outlined,
                  size: 64, color: AppTheme.muted),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _take(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_outlined, size: 18),
                  label: const Text('كاميرا'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _take(ImageSource.gallery),
                  icon: const Icon(Icons.photo_outlined, size: 18),
                  label: const Text('معرض'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SectionCard(
            title: 'البيانات',
            icon: Icons.badge_outlined,
            child: Column(
              children: [
                _row('النوع', bird.kind),
                _row('اللون', bird.color),
                _row('الجنس', bird.sex),
                _row('رقم الحلقة', bird.ring),
                _row('تاريخ الولادة', formatDate(bird.bornOn)),
                _row('الأب', father?.name ?? '—'),
                _row('الأم', mother?.name ?? '—'),
              ],
            ),
          ),
          SectionCard(
            title: 'السيرة الذاتية (CV)',
            icon: Icons.description_outlined,
            child: Text(
              bird.cv.isEmpty ? 'لا توجد ملاحظات' : bird.cv,
              style: const TextStyle(color: AppTheme.muted, fontSize: 13),
            ),
          ),
          SectionCard(
            title: 'الصورة الأسبوعية',
            icon: Icons.event_note_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bird.isDue ? 'الصورة مستحقة الآن' : 'الموعد القادم محفوظ',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: bird.isDue ? AppTheme.gold : AppTheme.green,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'آخر صورة: ${formatDateTime(bird.lastPhotoAt)}\n'
                  'الموعد: ${formatDateTime(bird.nextPhotoDue)}',
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.muted, height: 1.6),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton(
                      onPressed: () async {
                        await Store.instance.postpone(bird);
                        setState(() {});
                      },
                      child: const Text('تأجيل'),
                    ),
                    OutlinedButton(
                      onPressed: () async {
                        await Store.instance.skipWeek(bird);
                        setState(() {});
                      },
                      child: const Text('تخطي الأسبوع'),
                    ),
                    OutlinedButton(
                      onPressed: () async {
                        await Store.instance.setReminder(bird, !bird.reminders);
                        setState(() {});
                      },
                      child: Text(bird.reminders ? 'إيقاف التذكير' : 'تفعيل التذكير'),
                    ),
                  ],
                ),
                if (bird.photoLog.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text('سجل المواعيد',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.ink)),
                  for (final log in bird.photoLog.take(6))
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        log.startsWith('skipped:')
                            ? 'تخطي — ${formatDateTime(DateTime.tryParse(log.substring(8)))}'
                            : 'صورة — ${formatDateTime(DateTime.tryParse(log))}',
                        style: const TextStyle(
                            fontSize: 11, color: AppTheme.muted),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
          ),
          Expanded(
            child: Text(value.isEmpty ? '—' : value,
                style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.ink,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.onChanged});

  final VoidCallback onChanged;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Future<void> _chooseFolder() async {
    final path = await Store.instance.chooseFolder();
    if (!mounted) return;
    widget.onChanged();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(path == null
            ? 'لم يتم اختيار مجلد'
            : 'مجلد الحفظ: $path'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = Store.instance;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionCard(
          title: 'مجلد الحفظ',
          icon: Icons.folder_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(store.folderPath ?? store.dir.path,
                  style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: _chooseFolder,
                icon: const Icon(Icons.folder_open_outlined),
                label: const Text('اختر مجلداً على الجهاز'),
              ),
              if (store.lastError != null) ...[
                const SizedBox(height: 8),
                Text(store.lastError!,
                    style: const TextStyle(fontSize: 11, color: Colors.red)),
              ],
              const SizedBox(height: 8),
              const Text(
                'تُحفظ بياناتك وصورك داخل هذا المجلد على جهازك فقط، بلا إنترنت ولا رفع لأي خادم.',
                style: TextStyle(fontSize: 11, color: AppTheme.muted),
              ),
            ],
          ),
        ),
        SectionCard(
          title: 'تأجيل الصورة',
          icon: Icons.schedule_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('أيام التأجيل الافتراضية: ${store.postponeDays}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.ink)),
              Slider(
                min: 1,
                max: 14,
                divisions: 13,
                value: store.postponeDays.toDouble(),
                onChanged: (v) async {
                  await store.setPostponeDays(v.round());
                  setState(() {});
                },
              ),
              const Text(
                'يمكن تأجيل أي صورة أو تخطيها في أي وقت، ويبقى وقت الموعد الأصلي محفوظاً في السجل.',
                style: TextStyle(fontSize: 11, color: AppTheme.muted),
              ),
            ],
          ),
        ),
        SectionCard(
          title: 'عن التطبيق',
          icon: Icons.info_outline,
          child: const Text(
            'Data Hmamat — سجل حماماتك المحلي.\n'
            'الإصدار 0.1.0\n'
            'بياناتك ملكك، تبقى على جهازك.',
            style: TextStyle(fontSize: 12, color: AppTheme.muted, height: 1.7),
          ),
        ),
      ],
    );
  }
}
