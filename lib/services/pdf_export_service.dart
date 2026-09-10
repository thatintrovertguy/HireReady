import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/resume_analysis.dart';

/// PDF Export service using [pdf] and [printing] packages.
/// Generates a clean PDF document summary of the resume evaluation.
class PdfExportService {
  static Future<void> exportAnalysisPdf(ResumeAnalysis analysis) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header Banner
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.indigo900,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'HireReady - AI Resume Analysis Report',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Generated on: ${analysis.createdAt.toString().split('.')[0]}',
                      style: const pw.TextStyle(
                        color: PdfColors.indigo100,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 16),

              // File & Role Details
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('File: ${analysis.fileName ?? "Resume"}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  if (analysis.targetRole != null)
                    pw.Text('Target Role: ${analysis.targetRole}',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),

              pw.SizedBox(height: 12),
              pw.Divider(),
              pw.SizedBox(height: 12),

              // Score Summary Box
              pw.Row(
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey200,
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Text(
                      'Overall Score: ${analysis.overallScore} / 100',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.indigo800,
                      ),
                    ),
                  ),
                  if (analysis.matchPercent != null) ...[
                    pw.SizedBox(width: 12),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey200,
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Text(
                        'Role Match: ${analysis.matchPercent}%',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.green800,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              pw.SizedBox(height: 20),

              // Section Scores Breakdown
              pw.Text('Section Breakdown',
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),

              ...analysis.sections.map(
                (sec) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 8),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(sec.name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text('${sec.score} / 100',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(sec.feedback, style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
              ),

              pw.SizedBox(height: 16),

              // Missing Keywords (if any)
              if (analysis.missingKeywords.isNotEmpty) ...[
                pw.Text('Missing Job Keywords',
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text(analysis.missingKeywords.join(', '),
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.orange900)),
                pw.SizedBox(height: 16),
              ],

              // Key Suggestions
              pw.Text('Key Improvement Suggestions',
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),

              ...analysis.suggestions.map(
                (sugg) => pw.Bullet(
                  text: sugg,
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ),
            ],
          );
        },
      ),
    );

    // Displays native print preview / PDF download dialog on Android
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'HireReady_Analysis_Report.pdf',
    );
  }
}
