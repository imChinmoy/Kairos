import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../domain/report_model.dart';

class PdfService {
  static Future<void> generateAndSharePdf(InspectionReportModel report) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('KAIROS Inspection Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Investigation ID: ${report.fastApiInvestigationId}'),
              pw.Text('Report ID: ${report.id}'),
              pw.Text('Date Submitted: ${report.submittedAt?.toString() ?? 'N/A'}'),
              pw.SizedBox(height: 20),
              pw.Text('Status: ${report.status}', style: pw.TextStyle(fontSize: 16)),
              pw.Text('Finding: ${report.finding ?? 'N/A'}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              if (report.hasEvidence)
                pw.Text('Note: Evidence (Photos/Videos) was attached to this report via the KAIROS system.', style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();
    await Printing.sharePdf(bytes: bytes, filename: 'KAIROS_Report_${report.fastApiInvestigationId}.pdf');
  }
}
