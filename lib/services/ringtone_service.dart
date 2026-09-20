import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

class RingtoneItem {
  final String uri;
  final String title;

  const RingtoneItem({required this.uri, required this.title});

  @override
  String toString() => 'RingtoneItem(title: $title, uri: $uri)';
}

class RingtoneService {
  static const MethodChannel _channel =
      MethodChannel('com.titikwaktu.alarm/ringtone_picker');

  /// Buka Android System Ringtone Picker (ACTION_RINGTONE_PICKER)
  Future<RingtoneItem?> pickSystemRingtone({String? currentUri}) async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'pickSystemRingtone',
        {'currentUri': currentUri},
      );
      if (result == null) return null;
      final uri = result['uri'] as String?;
      final title = result['title'] as String? ?? 'Ringtone';
      if (uri == null) return null;
      return RingtoneItem(uri: uri, title: title);
    } catch (e) {
      print('Error picking system ringtone: $e');
      return null;
    }
  }

  /// Buka File Picker untuk memilih file audio sendiri dari penyimpanan
  Future<RingtoneItem?> pickAudioFile() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.audio,
      );

      if (file == null) return null;

      final uriString = file.uri.toString();
      if (uriString.isEmpty) return null;

      // WAJIB: Grant persistable URI permission di sisi native
      if (Platform.isAndroid && uriString.startsWith('content://')) {
        await takePersistableUriPermission(uriString);
      }

      final title = file.name.isNotEmpty ? file.name : 'Audio File';
      return RingtoneItem(uri: uriString, title: title);
    } catch (e) {
      print('Error picking audio file: $e');
      return null;
    }
  }

  /// Panggil ContentResolver.takePersistableUriPermission() di native Android
  Future<bool> takePersistableUriPermission(String uri) async {
    try {
      final success = await _channel.invokeMethod<bool>(
        'takePersistableUriPermission',
        {'uri': uri},
      );
      return success ?? false;
    } catch (e) {
      print('Error taking persistable URI permission for $uri: $e');
      return false;
    }
  }

  /// Dapatkan nama judul/title ringtone dari URI (via RingtoneManager atau segment)
  Future<String> getRingtoneTitle(String uri) async {
    try {
      final title = await _channel.invokeMethod<String>(
        'getRingtoneTitle',
        {'uri': uri},
      );
      if (title != null && title.isNotEmpty) {
        return title;
      }
    } catch (e) {
      // Ignored, fallback below
    }

    // Fallback: extract from URI
    try {
      final parsed = Uri.parse(uri);
      final segment = parsed.pathSegments.isNotEmpty ? parsed.pathSegments.last : null;
      if (segment != null && segment.isNotEmpty) {
        return Uri.decodeComponent(segment);
      }
    } catch (_) {}

    return 'Custom Ringtone';
  }
}
