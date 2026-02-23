import 'dart:io';

import 'package:digistore/src/data/services/image_services.dart';
import 'package:dio/dio.dart';
import 'package:file_saver/file_saver.dart';
import 'package:share_plus/share_plus.dart';

class ReceiptService {
  final Dio _dio;

  ReceiptService({Dio? dio}) : _dio = dio ?? Dio();

  Future<String> downloadReceipt(String receiptUrl) async {
    return FileDownloadService().downloadFile(
      url: receiptUrl,
      fileExtension: 'pdf',
      mimeType: MimeType.pdf,
    );
  }

  Future<void> shareReceipt(String receiptUrl) async {
    try {
      final fileName = _extractFileName(receiptUrl);

      final response = await _dio.get<List<int>>(
        receiptUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.data == null) {
        throw Exception('Failed to download receipt data');
      }

      // Create temporary file for sharing
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(response.data!);

      final file = XFile(tempFile.path);

      await Share.shareXFiles(
        [file],
        subject: 'Donation Receipt',
        text: 'Please find my donation receipt attached.',
      );
    } catch (e) {
      throw Exception('Failed to share receipt: $e');
    }
  }

  /// Extract filename from URL
  String _extractFileName(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.path.split('/');
      return pathSegments.last.isNotEmpty
          ? pathSegments.last
          : 'receipt_${DateTime.now().millisecondsSinceEpoch}.pdf';
    } catch (e) {
      return 'receipt_${DateTime.now().millisecondsSinceEpoch}.pdf';
    }
  }
}
