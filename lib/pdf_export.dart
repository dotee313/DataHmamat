import 'dart:io';

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'l10n.dart';
import 'models.dart';
import 'storage.dart';

/// توليد تقارير PDF محلياً بخط عربي مضمّن، ثم مشاركتها بلا رفع لأي خادم.
abstract final class PdfExporter {
  static Future<pw.Font> _font() async {
    final data = await rootBundle.load('assets/fonts/Amiri-Regular.ttf');
    return pw.Font.ttf(data);
  }

  static Future<String> birdReport(Bird bird) async {
    final font = await _font();
    final store = Store.instance;
    final father = store.find(bird.fatherId);
    final mother = store.find(bird.motherId);
    final coefficient = inbreedingCoefficient(bird, store.byId);
    final health = store.health.where((h) => h.birdId == bird.id).toList();
    final weights = store.weights.where((w) => w.birdId == bird.id).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(base: font, bold: font),
        textDirection: pw.TextDirection.rtl,
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (context) => <pw.Widget>[
          pw.Header(
            level: 0,
            child: pw.Text(
              '${S.appName} — ${S.pdfReport}',
              style: pw.TextStyle(fontSize: 22, font: font),
            ),
          ),
          pw.SizedBox(height: 10),
          _title(bird.name, font),
          _line(S.kind, bird.kind, font),
          _line(S.color, bird.color, font),
          _line(S.sex, bird.sex, font),
          _line(S.ring, bird.ring, font),
          _line(S.bornOn, formatDate(bird.bornOn), font),
          _line(S.father, father?.name ?? S.unknown, font),
          _line(S.mother, mother?.name ?? S.unknown, font),
          _line(
            S.inbreeding,
            '${(coefficient * 100).toStringAsFixed(1)} %',
            font,
          ),
          _line(S.lastPhoto, formatDateTime(bird.lastPhotoAt), font),
          _line(S.nextDue, formatDateTime(bird.nextPhotoDue), font),
          pw.SizedBox(height: 14),
          _section(S.cv, font),
          pw.Text(bird.cv.isEmpty ? S.noData : bird.cv, style: pw.TextStyle(font: font)),
          pw.SizedBox(height: 14),
          _section(S.health, font),
          if (health.isEmpty) pw.Text(S.noHealth, style: pw.TextStyle(font: font)),
          for (final h in health)
            pw.Text(
              '${formatDate(h.date)} — ${h.type} — ${h.note}',
              style: pw.TextStyle(font: font),
            ),
          pw.SizedBox(height: 14),
          _section(S.weightLog, font),
          if (weights.isEmpty) pw.Text(S.noWeight, style: pw.TextStyle(font: font)),
          for (final w in weights)
            pw.Text(
              '${formatDate(w.date)} — ${w.grams.toStringAsFixed(0)} ${S.grams}',
              style: pw.TextStyle(font: font),
            ),
        ],
      ),
    );
    return _save(doc, 'report_${bird.id}.pdf');
  }

  static Future<String> pedigreeReport(Bird bird) async {
    final font = await _font();
    final lines = <String>[];
    void collect(String? id, int depth) {
      final ancestor = Store.instance.find(id);
      if (ancestor == null || depth > 5) return;
      lines.add(
        '${S.generation} $depth — ${ancestor.name}'
        '${ancestor.ring.isEmpty ? '' : ' • ${S.ring}: ${ancestor.ring}'}',
      );
      collect(ancestor.fatherId, depth + 1);
      collect(ancestor.motherId, depth + 1);
    }

    collect(bird.fatherId, 1);
    final fatherLines = List<String>.from(lines);
    lines.clear();
    collect(bird.motherId, 1);
    final motherLines = List<String>.from(lines);

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(base: font, bold: font),
        textDirection: pw.TextDirection.rtl,
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (context) => <pw.Widget>[
          pw.Header(
            level: 0,
            child: pw.Text(
              '${S.appName} — ${S.pedigreePdf}',
              style: pw.TextStyle(fontSize: 22, font: font),
            ),
          ),
          _title(bird.name, font),
          pw.SizedBox(height: 10),
          _section(S.paternalLine, font),
          if (fatherLines.isEmpty) pw.Text(S.noData, style: pw.TextStyle(font: font)),
          for (final line in fatherLines)
            pw.Text(line, style: pw.TextStyle(font: font)),
          pw.SizedBox(height: 12),
          _section(S.maternalLine, font),
          if (motherLines.isEmpty) pw.Text(S.noData, style: pw.TextStyle(font: font)),
          for (final line in motherLines)
            pw.Text(line, style: pw.TextStyle(font: font)),
          pw.SizedBox(height: 12),
          _line(
            S.inbreeding,
            '${(inbreedingCoefficient(bird, Store.instance.byId) * 100).toStringAsFixed(1)} %',
            font,
          ),
        ],
      ),
    );
    return _save(doc, 'pedigree_${bird.id}.pdf');
  }

  static pw.Widget _title(String text, pw.Font font) => pw.Text(
        text,
        style: pw.TextStyle(fontSize: 18, font: font, fontWeight: pw.FontWeight.bold),
      );

  static pw.Widget _section(String title, pw.Font font) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 4),
        child: pw.Text(
          title,
          style: pw.TextStyle(fontSize: 14, font: font, fontWeight: pw.FontWeight.bold),
        ),
      );

  static pw.Widget _line(String label, String value, pw.Font font) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Text(
          '$label: ${value.isEmpty ? S.unknown : value}',
          style: pw.TextStyle(fontSize: 11, font: font),
        ),
      );

  static Future<String> _save(pw.Document doc, String name) async {
    final bytes = await doc.save();
    final dir = Store.instance.dir;
    final file = File(Store.joinPath(dir.path, name));
    await file.writeAsBytes(bytes);
    return file.path;
  }
}
