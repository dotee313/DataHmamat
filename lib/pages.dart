import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'bird_form.dart';
import 'l10n.dart';
import 'models.dart';
import 'notifications.dart';
import 'pedigree.dart';
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

  List<String> get _titles => <String>[
        S.birds,
        S.pedigree,
        S.photos,
        S.eggs,
        S.finance,
        S.settings,
      ];

  void _refresh() {
    Notifications.sync();
    setState(() {});
  }

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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.photo_camera_outlined,
                          size: 16, color: AppTheme.navy),
                      const SizedBox(width: 4),
                      Text('$due',
                          style: const TextStyle(
                            color: AppTheme.navy,
                            fontWeight: FontWeight.w800,
                          )),
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
          EggsPage(onChanged: _refresh),
          FinancePage(onChanged: _refresh),
          SettingsPage(onChanged: _refresh),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
              icon: const Icon(Icons.pets_outlined), label: S.birds),
          NavigationDestination(
              icon: const Icon(Icons.family_restroom_outlined),
              label: S.pedigree),
          NavigationDestination(
              icon: const Icon(Icons.photo_library_outlined), label: S.photos),
          NavigationDestination(
              icon: const Icon(Icons.egg_outlined), label: S.eggs),
          NavigationDestination(
              icon: const Icon(Icons.account_balance_wallet_outlined),
              label: S.finance),
          NavigationDestination(
              icon: const Icon(Icons.settings_outlined), label: S.settings),
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
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => BirdDetailPage(birdId: bird.id),
      ),
    );
    widget.onChanged();
  }

  Future<void> _add() async {
    await Navigator.of(context).push<void>(
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
              decoration: InputDecoration(
                hintText: S.search,
                prefixIcon: const Icon(Icons.search_rounded),
              ),
            ),
            if (due.isNotEmpty) ...[
              const SizedBox(height: 14),
              Card(
                color: AppTheme.gold.withValues(alpha: 0.16),
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
                            '${due.length} ${S.dueChip}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.navy,
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
                title: query.isEmpty ? S.noBirds : S.noResults,
                subtitle: query.isEmpty ? S.noBirdsSub : S.noResultsSub,
                action: query.isEmpty
                    ? FilledButton(onPressed: _add, child: Text(S.addBird))
                    : null,
              )
            else
              for (final bird in birds)
                Card(
                  child: ListTile(
                    onTap: () => _open(bird),
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.purple.withValues(alpha: 0.12),
                      child: Text(
                        bird.name.isEmpty ? '?' : bird.name[0],
                        style: const TextStyle(
                          color: AppTheme.purple,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    title: Text(bird.name,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(<String>[
                      if (bird.kind.isNotEmpty) bird.kind,
                      if (bird.color.isNotEmpty) bird.color,
                      bird.sex,
                    ].join(' • ')),
                    trailing: bird.isDue
                        ? const Icon(Icons.photo_camera_outlined,
                            color: AppTheme.gold)
                        : const Icon(Icons.chevron_left,
                            color: AppTheme.muted),
                  ),
                ),
          ],
        ),
        Positioned(
          left: 18,
          bottom: 18,
          child: FloatingActionButton.extended(
            onPressed: _add,
            backgroundColor: AppTheme.purple,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_rounded),
            label: Text(S.addBird),
          ),
        ),
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
        .showSnackBar(SnackBar(content: Text(S.photoSaved)));
  }

  Future<void> _view(String path) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => PhotoViewerPage(path: path)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final due = Store.instance.dueBirds;
    final entries = <MapEntry<Bird, String>>[];
    for (final bird in Store.instance.birds) {
      for (final path in bird.photos) {
        entries.add(MapEntry<Bird, String>(bird, path));
      }
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionCard(
          title: S.photoBadge,
          icon: Icons.photo_camera_outlined,
          child: due.isEmpty
              ? Text(S.noPhotoDue,
                  style: const TextStyle(fontSize: 12, color: AppTheme.muted))
              : Column(
                  children: [
                    for (final bird in due)
                      Card(
                        color: AppTheme.gold.withValues(alpha: 0.14),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(bird.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                              Text(
                                '${S.nextDue}: ${formatDateTime(bird.nextPhotoDue)}',
                                style: const TextStyle(
                                    fontSize: 11, color: AppTheme.muted),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () =>
                                        _take(bird, ImageSource.camera),
                                    icon: const Icon(Icons.camera_alt_outlined,
                                        size: 16),
                                    label: Text(S.camera),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: () =>
                                        _take(bird, ImageSource.gallery),
                                    icon: const Icon(Icons.photo_outlined,
                                        size: 16),
                                    label: Text(S.gallery),
                                  ),
                                  OutlinedButton(
                                    onPressed: () async {
                                      await Store.instance.postpone(bird);
                                      widget.onChanged();
                                    },
                                    child: Text(S.postpone),
                                  ),
                                  OutlinedButton(
                                    onPressed: () async {
                                      await Store.instance.skipWeek(bird);
                                      widget.onChanged();
                                    },
                                    child: Text(S.skip),
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
          EmptyState(
            icon: Icons.photo_library_outlined,
            title: S.noPhotos,
            subtitle: S.noPhotosSub,
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
              final entry = entries[index];
              return GestureDetector(
                onTap: () => _view(entry.value),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ImageGridTile(path: entry.value, name: entry.key.name),
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
        title: Text(S.photoView),
      ),
      body: ZoomableImage(path: path),
    );
  }
}

class EggsPage extends StatefulWidget {
  const EggsPage({super.key, required this.onChanged});

  final VoidCallback onChanged;

  @override
  State<EggsPage> createState() => _EggsPageState();
}

class _EggsPageState extends State<EggsPage> {
  Future<void> _add() async {
    final birds = Store.instance.birds;
    if (birds.isEmpty) return;
    final mothers = birds.where((b) => b.sex == 'أنثى').toList();
    if (mothers.isEmpty) return;

    String motherId = mothers.first.id;
    String fatherId = birds.first.id;
    DateTime laid = DateTime.now();
    DateTime hatch = DateTime.now().add(const Duration(days: 18));
    final eggs = TextEditingController(text: '5');
    final hatched = TextEditingController(text: '0');
    String status = 'incubating';
    final note = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: Text(S.addClutch),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: motherId,
                  decoration: InputDecoration(labelText: S.mother),
                  items: [
                    for (final b in mothers)
                      DropdownMenuItem<String>(value: b.id, child: Text(b.name)),
                  ],
                  onChanged: (v) => setDialog(() => motherId = v ?? motherId),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: fatherId,
                  decoration: InputDecoration(labelText: S.father),
                  items: [
                    for (final b in birds)
                      DropdownMenuItem<String>(value: b.id, child: Text(b.name)),
                  ],
                  onChanged: (v) => setDialog(() => fatherId = v ?? fatherId),
                ),
                const SizedBox(height: 10),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('${S.laidOn}: ${formatDate(laid)}'),
                  trailing: const Icon(Icons.calendar_today_outlined),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: laid,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setDialog(() => laid = picked);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('${S.hatchDue}: ${formatDate(hatch)}'),
                  trailing: const Icon(Icons.calendar_today_outlined),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: hatch,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setDialog(() => hatch = picked);
                  },
                ),
                TextField(
                  controller: eggs,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: S.eggsCount),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: hatched,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: S.hatchedCount),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: status,
                  decoration: InputDecoration(labelText: S.status),
                  items: [
                    DropdownMenuItem<String>(value: 'incubating', child: Text(S.incubating)),
                    DropdownMenuItem<String>(value: 'hatched', child: Text(S.hatched)),
                    DropdownMenuItem<String>(value: 'failed', child: Text(S.failed)),
                  ],
                  onChanged: (v) => setDialog(() => status = v ?? status),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: note,
                  decoration: InputDecoration(labelText: S.note),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(S.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(S.save),
            ),
          ],
        ),
      ),
    );
    if (ok != true) return;

    await Store.instance.addClutch(Clutch(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      motherId: motherId,
      fatherId: fatherId,
      laidOn: laid,
      hatchDue: hatch,
      eggsCount: int.tryParse(eggs.text) ?? 0,
      hatchedCount: int.tryParse(hatched.text) ?? 0,
      status: status,
      note: note.text.trim(),
    ));
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final clutches = Store.instance.clutches;
    final totalEggs = clutches.fold<int>(0, (s, c) => s + c.eggsCount);
    final totalHatched = clutches.fold<int>(0, (s, c) => s + c.hatchedCount);
    final rate = totalEggs == 0 ? 0.0 : totalHatched * 100 / totalEggs;

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
          children: [
            SectionCard(
              title: S.hatchSuccess,
              icon: Icons.egg_outlined,
              child: Text(
                '${rate.toStringAsFixed(1)} %  (${totalHatched}/${totalEggs})',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.purple,
                ),
              ),
            ),
            if (clutches.isEmpty)
              EmptyState(
                icon: Icons.egg_outlined,
                title: S.noClutches,
                subtitle: S.noClutchesSub,
              )
            else
              for (final c in clutches)
                Card(
                  child: ListTile(
                    title: Text(
                      '${Store.instance.find(c.motherId)?.name ?? S.unknown} + '
                      '${Store.instance.find(c.fatherId)?.name ?? S.unknown}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      '${S.laidOn}: ${formatDate(c.laidOn)} • '
                      '${S.hatchDue}: ${formatDate(c.hatchDue)} • '
                      '${S.eggsCount}: ${c.eggsCount} / ${S.hatchedCount}: ${c.hatchedCount}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: () async {
                        await Store.instance.removeClutch(c.id);
                        widget.onChanged();
                      },
                    ),
                  ),
                ),
          ],
        ),
        Positioned(
          left: 18,
          bottom: 18,
          child: FloatingActionButton.extended(
            onPressed: _add,
            backgroundColor: AppTheme.purple,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_rounded),
            label: Text(S.addClutch),
          ),
        ),
      ],
    );
  }
}

class FinancePage extends StatefulWidget {
  const FinancePage({super.key, required this.onChanged});

  final VoidCallback onChanged;

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  Future<void> _addExpense() async {
    final amount = TextEditingController();
    final note = TextEditingController();
    String category = 'feed';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: Text(S.addExpense),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: InputDecoration(labelText: S.category),
                items: [
                  DropdownMenuItem<String>(value: 'feed', child: Text(S.feed)),
                  DropdownMenuItem<String>(
                      value: 'medicine', child: Text(S.medicine)),
                  DropdownMenuItem<String>(
                      value: 'equipment', child: Text(S.equipment)),
                  DropdownMenuItem<String>(value: 'other', child: Text(S.other)),
                ],
                onChanged: (v) => setDialog(() => category = v ?? category),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: amount,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: S.amount),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: note,
                decoration: InputDecoration(labelText: S.note),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(S.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(S.save),
            ),
          ],
        ),
      ),
    );
    if (ok != true) return;
    await Store.instance.addExpense(Expense(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      category: category,
      amount: double.tryParse(amount.text) ?? 0,
      note: note.text.trim(),
    ));
    widget.onChanged();
  }

  Future<void> _addFeed() async {
    final name = TextEditingController();
    final qty = TextEditingController(text: '0');
    final limit = TextEditingController(text: '5');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.addFeed),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: InputDecoration(labelText: S.name),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: qty,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: S.quantity),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: limit,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: S.lowLimit),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(S.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(S.save),
          ),
        ],
      ),
    );
    if (ok != true || name.text.trim().isEmpty) return;
    await Store.instance.addFeed(FeedItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.text.trim(),
      quantity: double.tryParse(qty.text) ?? 0,
      threshold: double.tryParse(limit.text) ?? 5,
    ));
    widget.onChanged();
  }

  String _categoryName(String key) {
    switch (key) {
      case 'medicine':
        return S.medicine;
      case 'equipment':
        return S.equipment;
      case 'other':
        return S.other;
      default:
        return S.feed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenses = Store.instance.expenses;
    final feed = Store.instance.feed;
    final total = expenses.fold<double>(0, (s, e) => s + e.amount);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionCard(
          title: S.expenses,
          icon: Icons.account_balance_wallet_outlined,
          trailing: IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppTheme.purple),
            onPressed: _addExpense,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${S.total}: ${total.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.purple,
                ),
              ),
              const SizedBox(height: 8),
              if (expenses.isEmpty)
                Text(S.noExpenses,
                    style: const TextStyle(fontSize: 12, color: AppTheme.muted))
              else
                for (final e in expenses)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text('${_categoryName(e.category)} — ${e.amount.toStringAsFixed(0)}'),
                    subtitle: Text('${formatDate(e.date)} ${e.note}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      onPressed: () async {
                        await Store.instance.removeExpense(e.id);
                        widget.onChanged();
                      },
                    ),
                  ),
            ],
          ),
        ),
        SectionCard(
          title: S.feedStock,
          icon: Icons.inventory_2_outlined,
          trailing: IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppTheme.purple),
            onPressed: _addFeed,
          ),
          child: feed.isEmpty
              ? Text(S.noFeed,
                  style: const TextStyle(fontSize: 12, color: AppTheme.muted))
              : Column(
                  children: [
                    for (final f in feed)
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          f.isLow ? Icons.warning_amber_rounded : Icons.grain,
                          color: f.isLow ? AppTheme.gold : AppTheme.purple,
                        ),
                        title: Text(f.name),
                        subtitle: Text(
                          '${S.quantity}: ${f.quantity.toStringAsFixed(1)}'
                          '${f.isLow ? ' • ${S.lowStock}' : ''}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.add, size: 18),
                              onPressed: () async {
                                await Store.instance.updateFeed(f.copyWith(
                                    quantity: f.quantity + 1));
                                widget.onChanged();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove, size: 18),
                              onPressed: () async {
                                await Store.instance.updateFeed(f.copyWith(
                                    quantity: f.quantity - 1));
                                widget.onChanged();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18),
                              onPressed: () async {
                                await Store.instance.removeFeed(f.id);
                                widget.onChanged();
                              },
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
      ],
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
        content: Text(path == null ? S.noFolderChosen : '${S.folderPath}: $path'),
      ),
    );
  }

  Future<void> _pickTime() async {
    final store = Store.instance;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: store.notificationHour, minute: store.notificationMinute),
    );
    if (picked == null) return;
    await store.setNotificationTime(picked.hour, picked.minute);
    await Notifications.sync();
    setState(() {});
  }

  Future<void> _export() async {
    final path = await Store.instance.exportData();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('${S.exportDone}: $path')));
  }

  Future<void> _import() async {
    final file = await Store.instance.pickBackupFile();
    if (file == null) return;
    try {
      await Store.instance.importData(await file.readAsString());
      await Notifications.sync();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(S.importDone)));
      widget.onChanged();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Import failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = Store.instance;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionCard(
          title: S.folder,
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
                label: Text(S.chooseFolder),
              ),
              if (store.lastError != null) ...[
                const SizedBox(height: 8),
                Text(store.lastError!,
                    style: const TextStyle(fontSize: 11, color: Colors.red)),
              ],
              const SizedBox(height: 8),
              Text(S.folderHint,
                  style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
            ],
          ),
        ),
        SectionCard(
          title: S.appearance,
          icon: Icons.palette_outlined,
          child: Column(
            children: [
              DropdownButtonFormField<ThemeMode>(
                initialValue: store.themeMode,
                decoration: InputDecoration(labelText: S.appearance),
                items: [
                  DropdownMenuItem<ThemeMode>(
                      value: ThemeMode.system, child: Text(S.system)),
                  DropdownMenuItem<ThemeMode>(
                      value: ThemeMode.light, child: Text(S.light)),
                  DropdownMenuItem<ThemeMode>(
                      value: ThemeMode.dark, child: Text(S.dark)),
                ],
                onChanged: (v) async {
                  await store.setThemeMode(v ?? ThemeMode.system);
                  setState(() {});
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Locale>(
                initialValue: L.locale,
                decoration: InputDecoration(labelText: S.language),
                items: [
                  DropdownMenuItem<Locale>(
                      value: const Locale('ar'), child: Text(S.arabic)),
                  DropdownMenuItem<Locale>(
                      value: const Locale('en'), child: Text(S.english)),
                ],
                onChanged: (v) async {
                  await store.setLocale(v ?? const Locale('ar'));
                  await Notifications.sync();
                  setState(() {});
                },
              ),
            ],
          ),
        ),
        SectionCard(
          title: S.notifications,
          icon: Icons.notifications_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: store.notificationsEnabled,
                onChanged: (v) async {
                  await store.setNotifications(v);
                  await Notifications.sync();
                  setState(() {});
                },
                title: Text(S.notificationsOn),
                subtitle: Text(S.remindersSub),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  '${S.notificationTime}: ${store.notificationHour.toString().padLeft(2, '0')}:${store.notificationMinute.toString().padLeft(2, '0')}',
                ),
                trailing: const Icon(Icons.access_time),
                onTap: _pickTime,
              ),
              OutlinedButton.icon(
                onPressed: Notifications.test,
                icon: const Icon(Icons.notifications_active_outlined),
                label: Text(L.isAr ? 'تجربة الإشعار' : 'Test notification'),
              ),
            ],
          ),
        ),
        SectionCard(
          title: S.backup,
          icon: Icons.backup_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(S.exportHint,
                  style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _export,
                      icon: const Icon(Icons.upload_file_outlined),
                      label: Text(S.export),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _import,
                      icon: const Icon(Icons.download_outlined),
                      label: Text(S.import),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SectionCard(
          title: S.postponeDays,
          icon: Icons.schedule_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${S.postponeDays}: ${store.postponeDays}',
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
              Text(S.postponeHint,
                  style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
            ],
          ),
        ),
        SectionCard(
          title: S.about,
          icon: Icons.info_outline,
          child: Text(
            '${S.appName}\n${S.version}\n${S.aboutText}',
            style: const TextStyle(fontSize: 12, color: AppTheme.muted, height: 1.7),
          ),
        ),
      ],
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
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => BirdFormPage(bird: bird)),
    );
    setState(() {});
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.confirmDelete),
        content: Text(S.confirmDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(S.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(S.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await Store.instance.removeBird(widget.birdId);
    await Notifications.sync();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _take(ImageSource source) async {
    final bird = Store.instance.find(widget.birdId);
    if (bird == null) return;
    final path = await Store.instance.capturePhoto(bird, source);
    if (path == null) return;
    await Store.instance.attachPhoto(bird, path);
    await Notifications.sync();
    setState(() {});
  }

  Future<void> _addHealth() async {
    final note = TextEditingController();
    String type = 'treatment';
    DateTime? next;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: Text(S.addHealth),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: type,
                decoration: InputDecoration(labelText: S.category),
                items: [
                  DropdownMenuItem<String>(
                      value: 'treatment', child: Text(S.treatment)),
                  DropdownMenuItem<String>(
                      value: 'vaccine', child: Text(S.vaccine)),
                  DropdownMenuItem<String>(
                      value: 'vet', child: Text(S.vetVisit)),
                ],
                onChanged: (v) => setDialog(() => type = v ?? type),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: note,
                decoration: InputDecoration(labelText: S.note),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('${S.nextVisit}: ${formatDate(next)}'),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setDialog(() => next = picked);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(S.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(S.save),
            ),
          ],
        ),
      ),
    );
    if (ok != true) return;
    await Store.instance.addHealth(HealthRecord(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      birdId: widget.birdId,
      type: type,
      note: note.text.trim(),
      nextDue: next,
    ));
    setState(() {});
  }

  Future<void> _addWeight() async {
    final grams = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.addWeight),
        content: TextField(
          controller: grams,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: S.grams),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(S.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(S.save),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await Store.instance.addWeight(WeightRecord(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      birdId: widget.birdId,
      grams: double.tryParse(grams.text) ?? 0,
    ));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bird = Store.instance.find(widget.birdId);
    if (bird == null) {
      return Scaffold(
        appBar: AppBar(title: Text(S.deleted)),
        body: Center(child: Text(S.noBirds)),
      );
    }

    final father = Store.instance.find(bird.fatherId);
    final mother = Store.instance.find(bird.motherId);
    final health = Store.instance.health
        .where((h) => h.birdId == bird.id)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final weights = Store.instance.weights
        .where((w) => w.birdId == bird.id)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final coefficient = inbreedingCoefficient(bird, Store.instance.byId);

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
                color: AppTheme.purple.withValues(alpha: 0.08),
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
                  label: Text(S.camera),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _take(ImageSource.gallery),
                  icon: const Icon(Icons.photo_outlined, size: 18),
                  label: Text(S.gallery),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SectionCard(
            title: S.data,
            icon: Icons.badge_outlined,
            child: Column(
              children: [
                InfoRow(label: S.kind, value: bird.kind),
                InfoRow(label: S.color, value: bird.color),
                InfoRow(label: S.sex, value: bird.sex),
                InfoRow(label: S.ring, value: bird.ring),
                InfoRow(label: S.bornOn, value: formatDate(bird.bornOn)),
                InfoRow(label: S.father, value: father?.name ?? S.unknown),
                InfoRow(label: S.mother, value: mother?.name ?? S.unknown),
                InfoRow(
                  label: S.inbreeding,
                  value: '${(coefficient * 100).toStringAsFixed(1)} %',
                ),
              ],
            ),
          ),
          SectionCard(
            title: S.cv,
            icon: Icons.description_outlined,
            child: Text(
              bird.cv.isEmpty ? S.noData : bird.cv,
              style: const TextStyle(color: AppTheme.muted, fontSize: 13),
            ),
          ),
          SectionCard(
            title: S.health,
            icon: Icons.medical_services_outlined,
            trailing: IconButton(
              icon: const Icon(Icons.add_circle_outline, color: AppTheme.purple),
              onPressed: _addHealth,
            ),
            child: health.isEmpty
                ? Text(S.noHealth,
                    style: const TextStyle(fontSize: 12, color: AppTheme.muted))
                : Column(
                    children: [
                      for (final h in health)
                        ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            '${h.type} — ${formatDate(h.date)}'
                            '${h.nextDue == null ? '' : ' • ${S.nextVisit}: ${formatDate(h.nextDue)}'}',
                          ),
                          subtitle: Text(h.note),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18),
                            onPressed: () async {
                              await Store.instance.removeHealth(h.id);
                              setState(() {});
                            },
                          ),
                        ),
                    ],
                  ),
          ),
          SectionCard(
            title: S.weightLog,
            icon: Icons.monitor_weight_outlined,
            trailing: IconButton(
              icon: const Icon(Icons.add_circle_outline, color: AppTheme.purple),
              onPressed: _addWeight,
            ),
            child: weights.isEmpty
                ? Text(S.noWeight,
                    style: const TextStyle(fontSize: 12, color: AppTheme.muted))
                : Column(
                    children: [
                      for (final w in weights)
                        ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text('${w.grams.toStringAsFixed(0)} ${S.grams}'),
                          subtitle: Text(formatDate(w.date)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18),
                            onPressed: () async {
                              await Store.instance.removeWeight(w.id);
                              setState(() {});
                            },
                          ),
                        ),
                    ],
                  ),
          ),
          SectionCard(
            title: S.weeklyPhoto,
            icon: Icons.event_note_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bird.isDue ? S.dueNow : S.dueLater,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: bird.isDue ? AppTheme.gold : AppTheme.purple,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${S.lastPhoto}: ${formatDateTime(bird.lastPhotoAt)}\n'
                  '${S.nextDue}: ${formatDateTime(bird.nextPhotoDue)}',
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
                        await Notifications.sync();
                        setState(() {});
                      },
                      child: Text(S.postpone),
                    ),
                    OutlinedButton(
                      onPressed: () async {
                        await Store.instance.skipWeek(bird);
                        await Notifications.sync();
                        setState(() {});
                      },
                      child: Text(S.skipWeek),
                    ),
                    OutlinedButton(
                      onPressed: () async {
                        await Store.instance
                            .setReminder(bird, !bird.reminders);
                        await Notifications.sync();
                        setState(() {});
                      },
                      child: Text(
                        bird.reminders ? S.stopReminder : S.startReminder,
                      ),
                    ),
                  ],
                ),
                if (bird.photoLog.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(S.photoLog,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.navy,
                      )),
                  for (final log in bird.photoLog.take(6))
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        log.startsWith('skipped:')
                            ? '${S.skip} — ${formatDateTime(DateTime.tryParse(log.substring(8)))}'
                            : '${S.photos} — ${formatDateTime(DateTime.tryParse(log))}',
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
}
