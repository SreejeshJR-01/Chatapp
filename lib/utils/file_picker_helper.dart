import 'package:file_picker/file_picker.dart';

/// Helper class for file picking with validation
class FilePickerHelper {
  // Maximum file size: 10MB
  static const int maxFileSizeInBytes = 10 * 1024 * 1024;

  // Allowed file extensions
  static const List<String> allowedImageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
  ];

  static const List<String> allowedDocumentExtensions = [
    'pdf',
    'doc',
    'docx',
    'txt',
    'xls',
    'xlsx',
  ];

  /// Pick a file with validation
  /// 
  /// Returns [PickedFileResult] containing the file or error message
  /// Validates file type and size
  static Future<PickedFileResult> pickFile() async {
    try {
      // Pick file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          ...allowedImageExtensions,
          ...allowedDocumentExtensions,
        ],
      );

      if (result == null || result.files.isEmpty) {
        return PickedFileResult.cancelled();
      }

      final file = result.files.first;

      // Validate file size
      if (file.size > maxFileSizeInBytes) {
        return PickedFileResult.error(
          'File size exceeds 10MB limit. Please select a smaller file.',
        );
      }

      // Validate file extension
      final extension = file.extension?.toLowerCase();
      if (extension == null ||
          (!allowedImageExtensions.contains(extension) &&
              !allowedDocumentExtensions.contains(extension))) {
        return PickedFileResult.error(
          'Invalid file type. Allowed types: images (jpg, png, gif) and documents (pdf, doc, docx).',
        );
      }

      return PickedFileResult.success(file);
    } catch (e) {
      return PickedFileResult.error('Failed to pick file: $e');
    }
  }

  /// Check if file is an image based on extension
  static bool isImageFile(String? extension) {
    if (extension == null) return false;
    return allowedImageExtensions.contains(extension.toLowerCase());
  }

  /// Check if file is a document based on extension
  static bool isDocumentFile(String? extension) {
    if (extension == null) return false;
    return allowedDocumentExtensions.contains(extension.toLowerCase());
  }

  /// Format file size for display
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}

/// Result of file picking operation
class PickedFileResult {
  final PlatformFile? file;
  final String? errorMessage;
  final bool isCancelled;

  PickedFileResult._({
    this.file,
    this.errorMessage,
    this.isCancelled = false,
  });

  factory PickedFileResult.success(PlatformFile file) {
    return PickedFileResult._(file: file);
  }

  factory PickedFileResult.error(String message) {
    return PickedFileResult._(errorMessage: message);
  }

  factory PickedFileResult.cancelled() {
    return PickedFileResult._(isCancelled: true);
  }

  bool get isSuccess => file != null;
  bool get isError => errorMessage != null;
}
