import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class CapturedPhoto {
  final String localPath;
  final String sha256;
  final int fileSize;
  final String mimeType;
  final DateTime capturedAt;
  final double? latitude;
  final double? longitude;
  final double? accuracy;

  const CapturedPhoto({
    required this.localPath,
    required this.sha256,
    required this.fileSize,
    required this.mimeType,
    required this.capturedAt,
    this.latitude,
    this.longitude,
    this.accuracy,
  });

  String get fileName => path.basename(localPath);
}

class CameraService {
  static final _picker = ImagePicker();
  static const _uuid = Uuid();

  static Future<CapturedPhoto?> capturePhoto({
    double? latitude,
    double? longitude,
    double? accuracy,
  }) async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
      preferredCameraDevice: CameraDevice.rear,
    );

    if (photo == null) return null;

    return _processFile(
      photo,
      mimeType: 'image/jpeg',
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
    );
  }

  static Future<CapturedPhoto?> pickFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (image == null) return null;
    return _processFile(image, mimeType: 'image/jpeg');
  }

  static Future<CapturedPhoto> _processFile(
    XFile file, {
    required String mimeType,
    double? latitude,
    double? longitude,
    double? accuracy,
  }) async {
    final bytes = await file.readAsBytes();

    // Compute SHA-256
    final digest = sha256.convert(bytes);
    final hashHex = digest.toString();

    // Save to app documents directory with unique name
    final appDir = await getApplicationDocumentsDirectory();
    final evidenceDir = Directory(path.join(appDir.path, 'evidence'));
    if (!await evidenceDir.exists()) {
      await evidenceDir.create(recursive: true);
    }

    final ext = path.extension(file.path).isEmpty ? '.jpg' : path.extension(file.path);
    final uniqueName = '${_uuid.v4()}$ext';
    final destPath = path.join(evidenceDir.path, uniqueName);

    // Write original file unchanged
    await File(destPath).writeAsBytes(bytes);

    return CapturedPhoto(
      localPath: destPath,
      sha256: hashHex,
      fileSize: bytes.length,
      mimeType: mimeType,
      capturedAt: DateTime.now(),
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
    );
  }

  static Future<String> computeFileSha256(String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    return sha256.convert(bytes).toString();
  }
}
