import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/error_handler.dart';

/// Service for handling file upload operations
class FileUploadService {
  // Base URL for the backend API
  static const String baseUrl = 'http://45.129.87.38:6065';
  
  // Upload timeout duration (longer for file uploads)
  static const Duration uploadTimeout = Duration(minutes: 2);

  final http.Client _httpClient;

  FileUploadService({
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  /// Upload a file to the server
  /// 
  /// Returns the file URL on success
  /// Throws [Exception] if upload fails or network error occurs
  Future<String> uploadFile({
    required File file,
    required String fileName,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/upload');

      // Create multipart request
      final request = http.MultipartRequest('POST', url);

      // Add file to request
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          filename: fileName,
        ),
      );

      // Send request with timeout
      final streamedResponse = await request.send().timeout(
        uploadTimeout,
        onTimeout: () {
          throw TimeoutException('Upload timed out. Please try again.');
        },
      );
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = json.decode(response.body) as Map<String, dynamic>;

        // Extract file URL from response
        // The API might return the URL in different fields, so we check multiple possibilities
        final fileUrl = responseBody['fileUrl'] as String? ??
            responseBody['url'] as String? ??
            responseBody['file'] as String? ??
            responseBody['path'] as String?;

        if (fileUrl == null || fileUrl.isEmpty) {
          throw Exception('Server did not return a valid file URL');
        }

        return fileUrl;
      } else if (response.statusCode >= 500) {
        throw Exception('Server error. Please try again later');
      } else {
        try {
          final errorBody = json.decode(response.body) as Map<String, dynamic>;
          throw Exception(errorBody['message'] ?? 'Failed to upload file');
        } catch (_) {
          throw Exception('Failed to upload file');
        }
      }
    } on TimeoutException catch (e, stackTrace) {
      ErrorHandler.logError('FileUploadService.uploadFile', e, stackTrace);
      rethrow;
    } on http.ClientException catch (e, stackTrace) {
      ErrorHandler.logError('FileUploadService.uploadFile', e, stackTrace);
      throw Exception('Network error: ${e.message}');
    } on SocketException catch (e, stackTrace) {
      ErrorHandler.logError('FileUploadService.uploadFile', e, stackTrace);
      throw Exception('Network error: ${e.message}');
    } catch (e, stackTrace) {
      ErrorHandler.logError('FileUploadService.uploadFile', e, stackTrace);
      if (e is Exception) {
        rethrow;
      }
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Upload a file from bytes (for web platform)
  /// 
  /// Returns the file URL on success
  /// Throws [Exception] if upload fails or network error occurs
  Future<String> uploadFileFromBytes({
    required List<int> bytes,
    required String fileName,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/upload');

      // Create multipart request
      final request = http.MultipartRequest('POST', url);

      // Add file to request
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: fileName,
        ),
      );

      // Send request with timeout
      final streamedResponse = await request.send().timeout(
        uploadTimeout,
        onTimeout: () {
          throw TimeoutException('Upload timed out. Please try again.');
        },
      );
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = json.decode(response.body) as Map<String, dynamic>;

        // Extract file URL from response
        final fileUrl = responseBody['fileUrl'] as String? ??
            responseBody['url'] as String? ??
            responseBody['file'] as String? ??
            responseBody['path'] as String?;

        if (fileUrl == null || fileUrl.isEmpty) {
          throw Exception('Server did not return a valid file URL');
        }

        return fileUrl;
      } else if (response.statusCode >= 500) {
        throw Exception('Server error. Please try again later');
      } else {
        try {
          final errorBody = json.decode(response.body) as Map<String, dynamic>;
          throw Exception(errorBody['message'] ?? 'Failed to upload file');
        } catch (_) {
          throw Exception('Failed to upload file');
        }
      }
    } on TimeoutException catch (e, stackTrace) {
      ErrorHandler.logError('FileUploadService.uploadFileFromBytes', e, stackTrace);
      rethrow;
    } on http.ClientException catch (e, stackTrace) {
      ErrorHandler.logError('FileUploadService.uploadFileFromBytes', e, stackTrace);
      throw Exception('Network error: ${e.message}');
    } on SocketException catch (e, stackTrace) {
      ErrorHandler.logError('FileUploadService.uploadFileFromBytes', e, stackTrace);
      throw Exception('Network error: ${e.message}');
    } catch (e, stackTrace) {
      ErrorHandler.logError('FileUploadService.uploadFileFromBytes', e, stackTrace);
      if (e is Exception) {
        rethrow;
      }
      throw Exception('An unexpected error occurred: $e');
    }
  }
  
  /// Dispose resources
  void dispose() {
    _httpClient.close();
  }
}
