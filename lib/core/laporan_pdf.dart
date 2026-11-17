import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'skor_kualitas.dart';

String _p(double? v) => v == null ? '-' : '${v.toStringAsFixed(1)}%';

/// Membuat PDF laporan evaluasi.
Future<Uint8List> buatLaporanPdf({
  required HasilEvaluasi evaluasi,
  required int responden,
  required int totalKasus,
  required int berhasil,
  required int gagal,
  required List<String> komentar,
}) async {
  final doc = pw.Document(title: 'Laporan Evaluasi Kualitas SIAKAD');
  final now = DateTime.now();
  final tanggal = '${now.day.toString().padLeft(2, '0')}/'
      '${now.month.toString().padLeft(2, '0')}/${now.year}';

  pw.Widget judul(String t) => pw.Padding(
    padding: const pw.EdgeInsets.only(top: 18, bottom: 8),
    child: pw.Text(
      t,
      style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
    ),
  );

  final dinilai = berhasil + gagal;

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      build: (_) => [
        pw.Text(
          'Laporan Evaluasi Kualitas SIAKAD',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(
          'Berdasarkan ISO/IEC 25010 - dicetak $tanggal',
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),
        judul('Ringkasan'),
        pw.Bullet(text: 'Skor kualitas gabungan: ${_p(evaluasi.skorKeseluruhan)} '
            '(${evaluasi.kategoriKeseluruhan})'),
        pw.Bullet(text: 'Bobot: kuesioner ${(kBobotKuesioner * 100).round()}%, '
            'black box ${(kBobotBlackBox * 100).round()}%'),
        pw.Bullet(text: 'Jumlah responden kuesioner: $responden'),
        pw.Bullet(text: 'Kasus uji: $totalKasus total, $dinilai dinilai '
            '($berhasil berhasil, $gagal gagal)'),
        judul('Skor per karakteristik'),
        pw.TableHelper.fromTextArray(
          headers: ['Karakteristik', 'Kuesioner', 'Black box', 'Gabungan', 'Kategori'],
          data: [
            for (final k in evaluasi.karakteristik)
              [k.nama, _p(k.skorKuesioner), _p(k.skorBlackBox), _p(k.skorAkhir), k.kategori],
          ],
          headerStyle: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          cellStyle: const pw.TextStyle(fontSize: 10),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
          cellAlignments: {
            for (var i = 1; i <= 3; i++) i: pw.Alignment.centerRight,
          },
        ),
        judul('Rekomendasi'),
        for (final k in evaluasi.karakteristik) ...[
          pw.Text(
            '${k.nama} (${_p(k.skorAkhir)})',
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
          for (final r in k.rekomendasi)
            pw.Bullet(text: r, style: const pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 6),
        ],
        if (komentar.isNotEmpty) ...[
          judul('Komentar responden'),
          for (final c in komentar)
            pw.Bullet(text: c, style: const pw.TextStyle(fontSize: 10)),
        ],
      ],
    ),
  );

  return doc.save();
}

/// Membuka pratinjau PDF (bisa cetak, simpan, atau bagikan).
Future<void> tampilkanLaporanPdf(Uint8List bytes) {
  return Printing.layoutPdf(
    name: 'laporan_evaluasi_akademis.pdf',
    onLayout: (_) async => bytes,
  );
}