import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:digistore/src/data/services/secure_storage_service.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_compress/video_compress.dart';

Future<String> imageUpload(String imagePath) async {
  File imageFile = File(imagePath);
  Uint8List imageBytes = await imageFile.readAsBytes();
  log(
    "Original image size: ${(imageBytes.lengthInBytes / 1024).toStringAsFixed(2)} KB",
  );

  final String extension = p.extension(imagePath);
  final String? mimeType = lookupMimeType(imagePath, headerBytes: imageBytes);

  log("Image extension: $extension");
  log("Image MIME type: $mimeType");

  if (imageBytes.lengthInBytes > 2 * 1024 * 1024) {
    img.Image? decodedImage = img.decodeImage(imageBytes);

    if (decodedImage != null) {
      final resizedImage = img.copyResize(
        decodedImage,
        width: (decodedImage.width * 0.5).toInt(),
      );

      imageBytes = Uint8List.fromList(img.encodeJpg(resizedImage, quality: 80));

      log(
        "Compressed image size: ${(imageBytes.lengthInBytes / 1024).toStringAsFixed(2)} KB",
      );

      imageFile = await imageFile.writeAsBytes(imageBytes);
    }
  }

  final String baseUrl = dotenv.env['BASE_URL'] ?? '';
  final String apiKey = dotenv.env['API_KEY'] ?? '';

  final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload'));

  request.headers['x-api-key'] = apiKey;

  final secureStorage = SecureStorageService();
  final bearerToken = await secureStorage.getBearerToken();

  if (bearerToken != null) {
    request.headers['Authorization'] = 'Bearer $bearerToken';
  }

  request.files.add(
    await http.MultipartFile.fromPath(
      'file',
      imageFile.path,
      contentType: mimeType != null
          ? http.MediaType.parse(mimeType)
          : http.MediaType('image', 'jpeg'),
    ),
  );

  final response = await request.send();
  final responseBody = await response.stream.bytesToString();

  if (response.statusCode == 200) {
    return extractImageUrl(responseBody);
  } else {
    log("Upload failed: $responseBody");
    throw Exception('Failed to upload image');
  }
}

String extractImageUrl(String responseBody) {
  final responseJson = jsonDecode(responseBody);
  log(name: "image upload response", responseJson.toString());
  return responseJson['data'];
}

Future<String> saveUint8ListToFile(Uint8List bytes, String fileName) async {
  final tempDir = await getTemporaryDirectory();
  final file = File('${tempDir.path}/$fileName');
  await file.writeAsBytes(bytes);
  return file.path;
}

class MediaService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    return image != null ? File(image.path) : null;
  }

  Future<File?> pickImageFromCamera() async {
    final canUseCamera = await requestPermission(Permission.camera);
    if (!canUseCamera) return null;

    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    return image != null ? File(image.path) : null;
  }

  Future<File?> pickVideoFromGallery() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    return video != null ? File(video.path) : null;
  }

  Future<File?> pickVideoFromCamera() async {
    final canUseCamera = await requestPermission(Permission.camera);
    if (!canUseCamera) return null;

    final XFile? video = await _picker.pickVideo(source: ImageSource.camera);
    return video != null ? File(video.path) : null;
  }

  Future<File?> pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'txt',
          'rtf',
          'ppt',
          'pptx',
          'xls',
          'xlsx',
        ],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        return File(result.files.single.path!);
      }
    } catch (e) {
      log('Error picking document: $e');
    }
    return null;
  }
}

class FileDownloadService {
  final Dio _dio = Dio();

  Future<String> downloadFile({
    required String url,
    String? fileName,
    String? fileExtension,
    MimeType mimeType = MimeType.other,
  }) async {
    try {
      final name = fileName ?? _extractFileName(url);

      log('Starting download: $name');

      // Download file to bytes
      final response = await _dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(0);
            log('Download progress: $progress%');
          }
        },
      );

      if (response.data == null) {
        throw Exception('Failed to download file data');
      }

      // Determine extension if not provided
      String ext = fileExtension ?? '';
      if (ext.isEmpty) {
        if (mimeType == MimeType.pdf) {
          ext = 'pdf';
        } else if (mimeType == MimeType.jpeg) {
          ext = 'jpg';
        } else if (mimeType == MimeType.png) {
          ext = 'png';
        } else {
          // Try to get from URL
          final uri = Uri.parse(url);
          final segments = uri.path.split('/');
          if (segments.isNotEmpty && segments.last.contains('.')) {
            ext = segments.last.split('.').last;
          } else {
            ext = 'txt';
          }
        }
      }

      // Save using file_saver
      final path = await FileSaver.instance.saveFile(
        name: name,
        bytes: Uint8List.fromList(response.data!),
        fileExtension: ext,
        mimeType: mimeType,
      );

      log('File saved at: $path');
      return path;
    } catch (e) {
      log('Download error: $e');
      throw Exception('Failed to download file: $e');
    }
  }

  /// Extract filename from URL
  String _extractFileName(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.path.split('/');
      return pathSegments.last.isNotEmpty
          ? pathSegments.last
          : 'file_${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      return 'file_${DateTime.now().millisecondsSinceEpoch}';
    }
  }
}

// ============================================================================
// MEDIA PICKER DIALOG
// ============================================================================

// ============================================================================
// VIDEO COMPRESSION HELPER
// ============================================================================

Future<File?> _compressVideo(File file) async {
  try {
    await VideoCompress.setLogLevel(0);
    final MediaInfo? info = await VideoCompress.compressVideo(
      file.path,
      quality: VideoQuality.MediumQuality, // Balance between size and quality
      deleteOrigin: false,
      includeAudio: true,
    );
    return info?.file;
  } catch (e) {
    log('Video compression failed: $e');
    return null;
  }
}

Future<String> uploadMedia(String filePath, {bool isVideo = false}) async {
  File file = File(filePath);
  if (!file.existsSync()) {
    throw Exception('File not found');
  }

  String? mimeType = lookupMimeType(filePath);

  // If it's an image and not a video, try to compress it
  if (!isVideo && (mimeType?.startsWith('image/') ?? true)) {
    return await imageUpload(filePath);
  }

  // Handle Video/Raw Upload
  // Check if it's a video and try to compress
  if (isVideo) {
    int originalSize = await file.length();
    log(
      "Original video size: ${(originalSize / 1024 / 1024).toStringAsFixed(2)} MB",
    );

    // Only compress if larger than 10MB to verify efficiency, or just always compress for consistency
    // User requested "seperate compressor... shouldn't compress that much"
    // MediumQuality is usually good for social feeds (approx 720p/480p and optimized bitrates)

    File? compressedFile = await _compressVideo(file);
    if (compressedFile != null) {
      int compressedSize = await compressedFile.length();
      log(
        "Compressed video size: ${(compressedSize / 1024 / 1024).toStringAsFixed(2)} MB",
      );
      file = compressedFile;
      // Update mimeType for the compressed file (usually mp4)
      mimeType = lookupMimeType(file.path);
    } else {
      log("Using original video file as compression failed or returned null");
    }
  }

  final String baseUrl = dotenv.env['BASE_URL'] ?? '';
  final String apiKey = dotenv.env['API_KEY'] ?? '';

  final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload'));
  request.headers['x-api-key'] = apiKey;

  final secureStorage = SecureStorageService();
  final bearerToken = await secureStorage.getBearerToken();

  if (bearerToken != null) {
    request.headers['Authorization'] = 'Bearer $bearerToken';
  }

  request.files.add(
    await http.MultipartFile.fromPath(
      'file',
      file.path,
      contentType: mimeType != null
          ? http.MediaType.parse(mimeType)
          : http.MediaType(isVideo ? 'video' : 'application', 'octet-stream'),
    ),
  );

  final response = await request.send();
  final responseBody = await response.stream.bytesToString();

  if (isVideo) {
    // Cleanup compressed file if created by VideoCompress
    // VideoCompress usually manages cache, but good to be aware.
    // VideoCompress.deleteAllCache(); // Can be called periodically, maybe not immediately here if upload is async in background?
    // But since we await response, we can safely clear cache if we want, or rely on VideoCompress's cache management.
  }

  if (response.statusCode == 200) {
    return extractImageUrl(responseBody);
  } else {
    log("Upload failed: $responseBody");
    throw Exception('Failed to upload media');
  }
}

// ============================================================================
// MEDIA PICKER DIALOG
// ============================================================================

Future<dynamic> pickMedia({
  required BuildContext context,
  bool allowMultiple = false,
  bool enableCrop = false,
  CropAspectRatio? cropRatio,
  bool showDocument = true,
  bool allowVideo = false,
  bool onlyVideo = false,
}) async {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _PickSourceDialog(
      allowMultiple: allowMultiple,
      enableCrop: enableCrop,
      cropRatio: cropRatio,
      showDocument: showDocument,
      allowVideo: allowVideo,
      onlyVideo: onlyVideo,
    ),
  );
}

class _PickSourceDialog extends StatelessWidget {
  final bool allowMultiple;
  final bool enableCrop;
  final CropAspectRatio? cropRatio;
  final bool showDocument;
  final bool allowVideo;
  final bool onlyVideo;

  const _PickSourceDialog({
    required this.allowMultiple,
    required this.enableCrop,
    required this.cropRatio,
    required this.showDocument,
    required this.allowVideo,
    required this.onlyVideo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Wrap(
        runSpacing: 15,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (!onlyVideo) ...[
            _option(
              context,
              "Camera",
              Icons.camera_alt_rounded,
              () => _pickFromCamera(context),
            ),
            _option(
              context,
              "Gallery",
              Icons.photo_library_rounded,
              () => _pickFromGallery(context),
            ),
          ],
          if (allowVideo || onlyVideo) ...[
            _option(
              context,
              "Video Camera",
              Icons.videocam_rounded,
              () => _pickVideo(context, source: ImageSource.camera),
            ),
            _option(
              context,
              "Video Gallery",
              Icons.video_collection_rounded,
              () => _pickVideo(context, source: ImageSource.gallery),
            ),
          ],
          if (showDocument)
            _option(
              context,
              "Document",
              Icons.insert_drive_file_rounded,
              () => _pickDocument(context),
            ),
        ],
      ),
    );
  }

  Widget _option(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: Colors.grey.shade100,
        child: Icon(icon, color: Colors.black87),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      onTap: onTap,
    );
  }

  Future<void> _pickFromCamera(BuildContext context) async {
    final canUseCamera = await requestPermission(Permission.camera);
    if (!canUseCamera) {
      if (context.mounted) {
        openAppSettings();
      }
      return;
    }

    final picker = ImagePicker();
    final XFile? rawImage = await picker.pickImage(source: ImageSource.camera);

    if (rawImage == null) {
      Navigator.pop(context, null);
      return;
    }

    if (enableCrop) {
      final cropped = await _cropImage(rawImage.path);
      Navigator.pop(context, cropped);
      return;
    }

    Navigator.pop(context, rawImage);
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    final picker = ImagePicker();

    if (allowMultiple) {
      final List<XFile> images = await picker.pickMultiImage();

      if (enableCrop) {
        final List<XFile> croppedImages = [];

        for (final img in images) {
          final cropped = await _cropImage(img.path);
          if (cropped != null) croppedImages.add(cropped);
        }

        Navigator.pop(context, croppedImages);
        return;
      }

      Navigator.pop(context, images);
      return;
    }

    final XFile? rawImage = await picker.pickImage(source: ImageSource.gallery);

    if (rawImage == null) {
      Navigator.pop(context, null);
      return;
    }

    if (enableCrop) {
      final cropped = await _cropImage(rawImage.path);
      Navigator.pop(context, cropped);
      return;
    }

    Navigator.pop(context, rawImage);
  }

  Future<void> _pickVideo(
    BuildContext context, {
    required ImageSource source,
  }) async {
    final picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: source);
    if (video != null) {
      Navigator.pop(context, video);
    }
  }

  // -------------------------
  // PICK DOCUMENT
  // -------------------------
  Future<void> _pickDocument(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: allowMultiple,
      type: FileType.custom,
      allowedExtensions: [
        "pdf",
        "doc",
        "docx",
        "xls",
        "xlsx",
        "png",
        "jpg",
        "jpeg",
      ],
    );
    Navigator.pop(context, result);
  }

  Future<XFile?> _cropImage(String path) async {
    final File? cropped = await cropImage(path, cropRatio: cropRatio);
    if (cropped == null) return null;
    return XFile(cropped.path);
  }
}

Future<File?> cropImage(String path, {CropAspectRatio? cropRatio}) async {
  final croppedFile = await ImageCropper().cropImage(
    sourcePath: path,
    aspectRatio: cropRatio,
    compressQuality: 95,
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: "cropImage",
        hideBottomControls: false,
        lockAspectRatio: cropRatio != null,
      ),
      IOSUiSettings(title: "cropImage"),
    ],
  );

  if (croppedFile == null) return null;

  return File(croppedFile.path);
}

Future<bool> requestPermission(Permission setting) async {
  final result = await setting.request();
  switch (result) {
    case PermissionStatus.granted:
    case PermissionStatus.limited:
    case PermissionStatus.provisional:
      return true;
    case PermissionStatus.denied:
    case PermissionStatus.restricted:
    case PermissionStatus.permanentlyDenied:
      return false;
  }
}
