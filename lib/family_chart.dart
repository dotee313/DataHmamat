import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'family_tree.dart';
import 'genetics/genetics.dart'
    show GeneTrace, GeneStatus, GeneTracer, geneChoiceByKey;
import 'l10n.dart';
import 'models.dart';
import 'theme.dart';

/// شجرة تفاعلية مستوحاة من مكتبة family-chart (بطاقات + صلات منحنية + تكبير وتحريك).
/// تُبنى محلياً من بيانات الطيور المخزّنة على الجهاز، بلا اتصال بالإنترنت.
class FamilyChartView extends StatefulWidget {
  const FamilyChartView({
    super.key,
    required this.focus,
    required this.byId,
    required this.depth,
    required this.onSelect,
    this.geneKey,
  });

  final Bird focus;
  final Map<String, Bird> byId;
  final int depth;
  final ValueChanged<String> onSelect;

  /// مفتاح جين لتلوين البطاقات به (مثل `e|e`)، أو null بلا تلوين.
  final String? geneKey;

  @override
  State<FamilyChartView> createState() => _FamilyChartViewState();
}

class _ChartNode {
  const _ChartNode({
    required this.bird,
    required this.row,
    required this.x,
    this.role,
    this.eggInfo,
  });

  final Bird? bird;
  final int row;
  final double x;

  /// دور هذه البطاقة في الفرع (أب/أم/شريك بيضة...)؛ كل ظهور لهويته المستقلة.
  final String? role;
  final String? eggInfo;
}

class _ChartLink {
  const _ChartLink(this.from, this.to, this.color, this.couple);

  final Offset from;
  final Offset to;
  final Color color;
  final bool couple;
}

class _ChartLayout {
  const _ChartLayout({
    required this.nodes,
    required this.links,
    required this.size,
    required this.cardWidth,
    required this.cardHeight,
    required this.yFor,
  });

  final List<_ChartNode> nodes;
  final List<_ChartLink> links;
  final Size size;
  final double cardWidth;
  final double cardHeight;
  final double Function(int row) yFor;
}

class _FamilyChartViewState extends State<FamilyChartView> {
  final TransformationController _ctrl = TransformationController();
  bool _fitted = false;
  Size _viewport = Size.zero;

  static const double _cardW = 116;
  static const double _cardH = 132;
  static const double _leafGap = 142;
  static const double _siblingGap = 132;
  static const double _levelGap = 168;
  static const double _pad = 74;

  @override
  void didUpdateWidget(covariant FamilyChartView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.depth != widget.depth ||
        oldWidget.focus.id != widget.focus.id) {
      _fitted = false;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  double _yFor(int row) => _pad + (widget.depth - row) * _levelGap;

  _ChartLayout _computeLayout() {
    final nodes = <_ChartNode>[];
    final links = <_ChartLink>[];
    final seen = <String, _ChartNode>{};
    var leaf = 0.0;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final line = (dark ? Colors.white : AppTheme.purple).withValues(alpha: 0.45);

    String? eggText(Bird b) {
      if (eggPartnerOf(b, widget.byId) == null && b.eggGeneration == null) {
        return null;
      }
      return '${S.eggPartner} • ${S.generationLabel(eggGenerationOf(b, widget.byId))}';
    }

    _ChartNode add(
      String? id,
      int row,
      double x, {
      required String key,
      String? role,
      String? eggInfo,
    }) {
      final existing = seen[key];
      if (existing != null) return existing;
      final node = _ChartNode(
        bird: id == null ? null : widget.byId[id],
        row: row,
        x: x,
        role: role,
        eggInfo: eggInfo,
      );
      seen[key] = node;
      nodes.add(node);
      return node;
    }

    // مفتاح كل بطاقة هو «موقعها في الفرع» لا اسم الطير، حتى يبقى الطير
    // نفسه حاضراً باسمه وصورته في خط الأب وخط الأم معاً عند التزويج بالقربى.
    double place(
      String? id,
      int row,
      String key,
      Set<String> path, {
      String? role,
    }) {
      final bird = row <= widget.depth ? widget.byId[id] : null;
      if (id == null || bird == null || path.contains(id)) {
        final x = _pad + leaf * _leafGap;
        leaf++;
        add(id, row, x, key: key, role: role);
        return x;
      }
      final nextPath = <String>{...path, id};
      final fatherX = place(
        bird.fatherId,
        row + 1,
        '$key.father',
        nextPath,
        role: S.father,
      );
      final motherX = place(
        bird.motherId,
        row + 1,
        '$key.mother',
        nextPath,
        role: S.mother,
      );
      final x = (fatherX + motherX) / 2;
      add(id, row, x, key: key, role: role);

      if (widget.byId[bird.fatherId] != null &&
          widget.byId[bird.motherId] != null) {
        links.add(_ChartLink(
          Offset(fatherX, _yFor(row + 1)),
          Offset(motherX, _yFor(row + 1)),
          line,
          true,
        ));
      }
      links.add(_ChartLink(
        Offset(x, _yFor(row + 1) + _cardH / 2),
        Offset(x, _yFor(row) - _cardH / 2),
        line,
        false,
      ));
      return x;
    }

    // خط الأب وخط الأم منفصلان، ثم يتقيان عند الطير المركزي وإخوته.
    final rootPath = <String>{widget.focus.id};
    final fatherX = place(
      widget.focus.fatherId,
      1,
      'focus.father',
      rootPath,
      role: S.father,
    );
    final motherX = place(
      widget.focus.motherId,
      1,
      'focus.mother',
      rootPath,
      role: S.mother,
    );
    final fatherKnown = widget.byId[widget.focus.fatherId] != null;
    final motherKnown = widget.byId[widget.focus.motherId] != null;
    final parentsKnown = fatherKnown && motherKnown;
    final hasParents = fatherKnown || motherKnown;
    final parentX = (fatherX + motherX) / 2;
    if (parentsKnown) {
      links.add(_ChartLink(
        Offset(fatherX, _yFor(1)),
        Offset(motherX, _yFor(1)),
        line,
        true,
      ));
    }

    final siblings = <Bird>[];
    if (hasParents) {
      siblings.addAll(widget.byId.values.where((b) =>
          b.fatherId == widget.focus.fatherId &&
          b.motherId == widget.focus.motherId));
    } else {
      siblings.add(widget.focus);
    }
    siblings.sort((a, b) => a.bornOn.compareTo(b.bornOn));
    if (!siblings.any((b) => b.id == widget.focus.id)) {
      siblings.add(widget.focus);
      siblings.sort((a, b) => a.bornOn.compareTo(b.bornOn));
    }
    final focusIndex = siblings.indexWhere((b) => b.id == widget.focus.id);
    final focusX = hasParents || siblings.length > 1
        ? parentX + (focusIndex - (siblings.length - 1) / 2) * _siblingGap
        : _pad + leaf * _leafGap;

    for (var i = 0; i < siblings.length; i++) {
      final b = siblings[i];
      final x = hasParents || siblings.length > 1
          ? parentX + (i - (siblings.length - 1) / 2) * _siblingGap
          : focusX;
      add(
        b.id,
        0,
        x,
        key: 'sibling.${b.id}',
        role: b.id == widget.focus.id ? null : S.eggPartner,
        eggInfo: eggText(b),
      );
      if (hasParents) {
        links.add(_ChartLink(
          Offset(parentX, _yFor(1) + _cardH / 2),
          Offset(x, _yFor(0) - _cardH / 2),
          line,
          false,
        ));
      }
    }
    if (!hasParents && siblings.length == 1) leaf++;

    final children = widget.byId.values
        .where((b) =>
            b.fatherId == widget.focus.id || b.motherId == widget.focus.id)
        .toList()
      ..sort((a, b) => a.bornOn.compareTo(b.bornOn));
    for (var i = 0; i < children.length; i++) {
      final b = children[i];
      final x = focusX + (i - (children.length - 1) / 2) * _siblingGap;
      add(
        b.id,
        -1,
        x,
        key: 'child.${b.id}',
        eggInfo: eggText(b),
      );
      links.add(_ChartLink(
        Offset(focusX, _yFor(0) + _cardH / 2),
        Offset(x, _yFor(-1) - _cardH / 2),
        line,
        false,
      ));
    }

    final maxX = nodes.fold<double>(
      0,
      (value, node) => math.max(value, node.x),
    );
    final size = Size(
      maxX + _cardW / 2 + _pad,
      _yFor(-1) + _cardH + _pad,
    );

    return _ChartLayout(
      nodes: nodes,
      links: links,
      size: size,
      cardWidth: _cardW,
      cardHeight: _cardH,
      yFor: _yFor,
    );
  }

  void _fit(Size viewport, Size content) {
    final scale = math.min(
          1.0,
          math.min(viewport.width / content.width, viewport.height / content.height),
        ) *
        0.94;
    _ctrl.value = Matrix4.identity()
      ..translate((viewport.width - content.width * scale) / 2,
          (viewport.height - content.height * scale) / 2)
      ..scale(scale);
  }

  void _zoom(double factor) {
    final old = _ctrl.value.getMaxScaleOnAxis();
    final next = (old * factor).clamp(0.35, 2.5).toDouble();
    final ratio = next / old;
    final c = Offset(_viewport.width / 2, _viewport.height / 2);
    _ctrl.value = Matrix4.translationValues(c.dx, c.dy, 0) *
        Matrix4.diagonal3Values(ratio, ratio, 1) *
        Matrix4.translationValues(-c.dx, -c.dy, 0) *
        _ctrl.value;
  }

  Widget _control(IconData icon, String tip, VoidCallback onPressed) => Tooltip(
        message: tip,
        child: IconButton(
          icon: Icon(icon, size: 20),
          onPressed: onPressed,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 36, height: 36),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewport = Size(
          constraints.maxWidth.isFinite ? constraints.maxWidth : 360,
          constraints.maxHeight.isFinite ? constraints.maxHeight : 420,
        );
        _viewport = viewport;
        final layout = _computeLayout();
        final choice = geneChoiceByKey(widget.geneKey);
        final tracer = choice == null
            ? null
            : GeneTracer(
                byId: widget.byId,
                locus: choice.locus,
                allele: choice.allele,
              );
        if (!_fitted && constraints.hasBoundedHeight && constraints.hasBoundedWidth) {
          _fitted = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _fit(viewport, layout.size);
          });
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              InteractiveViewer(
                transformationController: _ctrl,
                constrained: false,
                boundaryMargin: const EdgeInsets.all(80),
                minScale: 0.3,
                maxScale: 2.6,
                child: SizedBox(
                  width: layout.size.width,
                  height: layout.size.height,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _ChartPainter(
                            links: layout.links,
                            cardWidth: layout.cardWidth,
                            cardHeight: layout.cardHeight,
                          ),
                        ),
                      ),
                      for (final node in layout.nodes)
                        Positioned(
                          left: node.x - layout.cardWidth / 2,
                          top: layout.yFor(node.row),
                          child: _ChartCard(
                            node: node,
                            width: layout.cardWidth,
                            height: layout.cardHeight,
                            selected: node.bird?.id == widget.focus.id,
                            trace: node.bird == null
                                ? null
                                : tracer?.traceOf(node.bird!),
                            onTap: () {
                              final bird = node.bird;
                              if (bird != null) widget.onSelect(bird.id);
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 10,
                top: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surface
                        .withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.purple.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    S.chartHint,
                    style: const TextStyle(fontSize: 10, color: AppTheme.muted),
                  ),
                ),
              ),
              Positioned(
                right: 10,
                bottom: 10,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppTheme.purple.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _control(Icons.add_rounded, S.zoomIn, () => _zoom(1.25)),
                      _control(Icons.remove_rounded, S.zoomOut, () => _zoom(0.8)),
                      _control(Icons.fit_screen_outlined, S.fitView, () {
                        final layoutNow = _computeLayout();
                        _fit(_viewport, layoutNow.size);
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChartPainter extends CustomPainter {
  const _ChartPainter({
    required this.links,
    required this.cardWidth,
    required this.cardHeight,
  });

  final List<_ChartLink> links;
  final double cardWidth;
  final double cardHeight;

  @override
  void paint(Canvas canvas, Size size) {
    for (final link in links) {
      final paint = Paint()
        ..color = link.color
        ..strokeWidth = link.couple ? 3 : 2.2
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      if (link.couple) {
        final a = Offset(link.from.dx + cardWidth / 2, link.from.dy);
        final b = Offset(link.to.dx - cardWidth / 2, link.to.dy);
        if (a.dx < b.dx) {
          canvas.drawLine(a, b, paint);
          canvas.drawCircle(
            Offset((a.dx + b.dx) / 2, a.dy),
            7,
            Paint()..color = paint.color,
          );
        }
        continue;
      }
      final dy = (link.to.dy - link.from.dy) / 2;
      final path = Path()
        ..moveTo(link.from.dx, link.from.dy)
        ..cubicTo(
          link.from.dx,
          link.from.dy + dy,
          link.to.dx,
          link.to.dy - dy,
          link.to.dx,
          link.to.dy,
        );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter old) =>
      old.links != links ||
      old.cardWidth != cardWidth ||
      old.cardHeight != cardHeight;
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.node,
    required this.width,
    required this.height,
    required this.selected,
    required this.onTap,
    this.trace,
  });

  final _ChartNode node;
  final double width;
  final double height;
  final bool selected;
  final VoidCallback onTap;
  final GeneTrace? trace;

  String _rowLabel() {
    if (node.role != null && node.role!.isNotEmpty) return node.role!;
    if (node.row == 0) return S.focusBird;
    if (node.row < 0) return S.children;
    return '${S.generation} ${node.row}';
  }

  @override
  Widget build(BuildContext context) {
    final bird = node.bird;
    final color = birdColor(bird);
    final surface = Theme.of(context).colorScheme.surface;
    final ink = Theme.of(context).colorScheme.onSurface;
    final label = _rowLabel();

    // تلوين الجين: يظهر (أحمر)، حامل (برتقالي)، محتمل (أصفر)، لا يحمله (رمادي).
    Color? geneColor;
    String? geneLabel;
    final t = trace;
    if (t != null && bird != null) {
      if (t.status == GeneStatus.shows) {
        geneColor = const Color(0xFFE5484D);
        geneLabel = S.geneShows;
      } else if (t.status == GeneStatus.carrier) {
        geneColor = const Color(0xFFF0A020);
        geneLabel = S.geneCarrier;
      } else if (t.status == GeneStatus.possible) {
        geneColor = const Color(0xFFD9B400);
        geneLabel = '${S.genePossible} ${t.percent}%';
      } else {
        geneColor = const Color(0xFF8E9AAF);
        geneLabel = S.geneAbsent;
      }
    }

    final card = AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: width,
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
        decoration: BoxDecoration(
          color: Color.alphaBlend(
            (geneColor ?? color).withValues(
              alpha: geneColor != null ? 0.2 : (bird == null ? 0.04 : 0.1),
            ),
            surface,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? color
                : (geneColor ?? color).withValues(
                    alpha: geneColor != null ? 0.9 : (bird == null ? 0.3 : 0.5),
                  ),
            width: selected ? 3 : (geneColor != null ? 2.4 : 1.5),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BirdCircle(
              bird: bird,
              diameter: 46,
              highlight: selected,
              placeholderColor: AppTheme.muted,
            ),
            const SizedBox(height: 5),
            Text(
              bird?.name ?? S.notRegistered,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: bird == null ? AppTheme.muted : ink,
              ),
            ),
            if (bird != null)
              Text(
                <String>[
                  if (bird.kind.isNotEmpty) bird.kind,
                  '${bird.bornOn.year}',
                ].join(' • '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 9, color: AppTheme.muted),
              ),
            if (bird != null)
              Text(
                bird.alive ? S.alive : S.dead,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: bird.alive ? const Color(0xFF2E9E5B) : Colors.red,
                ),
              ),
            if (node.eggInfo != null && node.eggInfo!.isNotEmpty)
              Text(
                node.eggInfo!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 8.5, color: AppTheme.gold),
              ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      );

    return GestureDetector(
      onTap: bird == null ? null : onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          card,
          if (geneColor != null && geneLabel != null)
            Positioned(
              top: -8,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: geneColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    geneLabel,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
