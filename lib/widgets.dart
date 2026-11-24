import 'dart:io';

import 'package:flutter/material.dart';

import 'theme.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    this.icon,
    this.trailing,
    required this.child,
  });

  final String title;
  final IconData? icon;
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: AppTheme.green, size: 20),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFE8EFEB),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 42, color: AppTheme.green),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppTheme.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppTheme.muted),
            ),
            if (action != null) ...[
              const SizedBox(height: 18),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// صورة قابلة للتكبير بالسحب، بلمسة مزدوجة للعودة للحجم الأصلي.
class ZoomableImage extends StatefulWidget {
  const ZoomableImage({super.key, required this.path});

  final String path;

  @override
  State<ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<ZoomableImage> {
  final _controller = TransformationController();

  void _reset() => _controller.value = Matrix4.identity();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final file = File(widget.path);
    final exists = file.existsSync();

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            color: const Color(0xFFECEEEA),
            width: double.infinity,
            height: double.infinity,
            child: exists
                ? InteractiveViewer(
                    transformationController: _controller,
                    minScale: 0.6,
                    maxScale: 6,
                    child: Image.file(
                      file,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.broken_image_outlined,
                        color: AppTheme.muted,
                        size: 48,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.broken_image_outlined,
                    color: AppTheme.muted,
                    size: 48,
                  ),
          ),
        ),
        if (exists)
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _ZoomButton(
                  icon: Icons.zoom_in_rounded,
                  onTap: () => _controller.value = Matrix4.diagonal3Values(2, 2, 1),
                ),
                const SizedBox(width: 8),
                _ZoomButton(icon: Icons.restart_alt_rounded, onTap: _reset),
              ],
            ),
          ),
      ],
    );
  }
}

class _ZoomButton extends StatelessWidget {
  const _ZoomButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.green, size: 18),
      ),
    );
  }
}
