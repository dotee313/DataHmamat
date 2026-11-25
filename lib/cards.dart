import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import 'l10n.dart';
import 'models.dart';
import 'storage.dart';
import 'theme.dart';

/// بطاقة تعريف للطير برمز QR، قابلة للحفظ والمشاركة والطباعة.
class QrCardPage extends StatefulWidget {
  const QrCardPage({super.key, required this.birdId});

  final String birdId;

  @override
  State<QrCardPage> createState() => _QrCardPageState();
}

class _QrCardPageState extends State<QrCardPage> {
  final _boundaryKey = GlobalKey();

  Future<File?> _render() async {
    final boundary =
        _boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: 3);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) return null;
    final dir = await Store.instance.photosDir();
    final file = File(Store.joinPath(dir.path, 'card_${widget.birdId}.png'));
    await file.writeAsBytes(bytes.buffer.asUint8List());
    return file;
  }

  Future<void> _save() async {
    final file = await _render();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(file == null ? S.noData : S.imageSaved)),
    );
  }

  Future<void> _share() async {
    final file = await _render();
    if (file == null) return;
    await SharePlus.instance.share(
      ShareParams(
        files: <XFile>[XFile(file.path)],
        subject: S.idCard,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bird = Store.instance.find(widget.birdId);
    if (bird == null) {
      return Scaffold(
        appBar: AppBar(title: Text(S.idCard)),
        body: Center(child: Text(S.deleted)),
      );
    }
    final payload = jsonEncode(<String, String>{
      'app': S.appName,
      'id': bird.id,
      'name': bird.name,
      'ring': bird.ring,
      'kind': bird.kind,
    });

    return Scaffold(
      appBar: AppBar(title: Text(S.idCard)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: RepaintBoundary(
              key: _boundaryKey,
              child: Container(
                width: 330,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppTheme.purple, width: 2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      S.appName,
                      style: const TextStyle(
                        color: AppTheme.purple,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      L.isAr ? 'بطاقة تعريف الطير' : 'Bird identity card',
                      style: const TextStyle(
                        color: AppTheme.muted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: AppTheme.purple.withValues(alpha: 0.12),
                      child: Text(
                        bird.name.isEmpty ? '?' : bird.name[0],
                        style: const TextStyle(
                          color: AppTheme.purple,
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      bird.name,
                      style: const TextStyle(
                        color: AppTheme.navy,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      <String>[
                        if (bird.kind.isNotEmpty) bird.kind,
                        if (bird.color.isNotEmpty) bird.color,
                        bird.sex,
                      ].join(' • '),
                      style: const TextStyle(color: AppTheme.muted, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${S.ring}: ${bird.ring.isEmpty ? S.unknown : bird.ring}',
                      style: const TextStyle(color: AppTheme.navy, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    QrImageView(
                      data: payload,
                      version: QrVersions.auto,
                      size: 148,
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.navy,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${S.bornOn}: ${formatDate(bird.bornOn)}',
                      style: const TextStyle(color: AppTheme.muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            S.qrHint,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: AppTheme.muted),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_alt_outlined),
                  label: Text(S.saveImage),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _share,
                  icon: const Icon(Icons.share_outlined),
                  label: Text(S.share),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
