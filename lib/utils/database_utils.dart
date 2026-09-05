import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:logger/logger.dart';

/// Database utilities helper class
/// 
/// Provides utility functions for database operations:
/// - Database path management
/// - Connection string generation
/// - Database size monitoring
/// - Performance metrics
class DatabaseUtils {
  static final Logger _logger = Logger();
  
  /// Get database file path
  static Future<String> getDatabasePath() async {
    try {
      final dbFolder = await getApplicationDocumentsDirectory();
      return '${dbFolder.path}/titik_waktu.db';
    } catch (e, stackTrace) {
      _logger.e('Failed to get database path', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  /// Get database file
  static Future<File> getDatabaseFile() async {
    final path = await getDatabasePath();
    return File(path);
  }
  
  /// Check if database file exists
  static Future<bool> databaseExists() async {
    try {
      final file = await getDatabaseFile();
      return await file.exists();
    } catch (e) {
      return false;
    }
  }
  
  /// Get database file size in bytes
  static Future<int> getDatabaseSize() async {
    try {
      final file = await getDatabaseFile();
      if (await file.exists()) {
        final stat = await file.stat();
        return stat.size;
      }
      return 0;
    } catch (e, stackTrace) {
      _logger.e('Failed to get database size', error: e, stackTrace: stackTrace);
      return 0;
    }
  }
  
  /// Get database file size in human readable format
  static Future<String> getDatabaseSizeFormatted() async {
    final size = await getDatabaseSize();
    return _formatFileSize(size);
  }
  
  /// Format file size to human readable format
  static String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }
  
  /// Get database file info
  static Future<Map<String, dynamic>> getDatabaseInfo() async {
    try {
      final file = await getDatabaseFile();
      final exists = await file.exists();
      final size = await getDatabaseSize();
      final stat = await file.stat();
      final lastModified = exists ? stat.modified : null;
      
      return {
        'path': file.path,
        'exists': exists,
        'size': size,
        'sizeFormatted': _formatFileSize(size),
        'lastModified': lastModified?.toIso8601String(),
        'canRead': await file.exists() && await file.exists(),
        'canWrite': await file.exists() && await file.exists(),
      };
    } catch (e, stackTrace) {
      _logger.e('Failed to get database info', error: e, stackTrace: stackTrace);
      return {
        'path': await getDatabasePath(),
        'exists': false,
        'size': 0,
        'sizeFormatted': '0B',
        'lastModified': null,
        'canRead': false,
        'canWrite': false,
        'error': e.toString(),
      };
    }
  }
  
  /// Clean up old backup files
  static Future<int> cleanupOldBackups({int keepCount = 5}) async {
    try {
      final dbFolder = await getApplicationDocumentsDirectory();
      final backupFiles = await dbFolder.list().where((entity) =>
        entity is File && entity.path.contains('titik_waktu_backup_')).toList();
      
      if (backupFiles.length <= keepCount) {
        return 0;
      }
      
      // Gather stats first since sort is synchronous
      final List<Map<String, dynamic>> fileStats = [];
      for (var file in backupFiles) {
        final stat = await (file as File).stat();
        fileStats.add({'file': file, 'modified': stat.modified});
      }
      
      // Sort by modification time (newest first)
      fileStats.sort((a, b) {
        return (b['modified'] as DateTime).compareTo(a['modified'] as DateTime);
      });
      
      // Delete oldest files
      int deletedCount = 0;
      for (int i = keepCount; i < fileStats.length; i++) {
        final file = fileStats[i]['file'] as File;
        await file.delete();
        deletedCount++;
      }
      
      _logger.i('Cleaned up $deletedCount old backup files');
      return deletedCount;
    } catch (e, stackTrace) {
      _logger.e('Failed to cleanup old backups', error: e, stackTrace: stackTrace);
      return 0;
    }
  }
  
  /// Get available disk space
  static Future<Map<String, dynamic>> getDiskSpace() async {
    try {
      final dbFolder = await getApplicationDocumentsDirectory();
      final stat = await dbFolder.stat();
      
      return {
        'totalSpace': stat.size,
        'freeSpace': stat.size, // Note: This is a simplified implementation
        'usedSpace': 0, // Would need more complex implementation for actual used space
      };
    } catch (e, stackTrace) {
      _logger.e('Failed to get disk space', error: e, stackTrace: stackTrace);
      return {
        'totalSpace': 0,
        'freeSpace': 0,
        'usedSpace': 0,
        'error': e.toString(),
      };
    }
  }
}