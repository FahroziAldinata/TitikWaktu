import 'package:flutter/material.dart';
import 'package:titik_waktu/services/ringtone_service.dart';
import 'package:titik_waktu/theme/app_colors.dart';

class RingtonePickerResult {
  final String? uri;
  final String? title;
  final bool isReset;

  const RingtonePickerResult({
    this.uri,
    this.title,
    this.isReset = false,
  });
}

Future<RingtonePickerResult?> showRingtonePickerSheet(
  BuildContext context, {
  String? currentUri,
  String? currentTitle,
  bool showReset = true,
}) {
  return showModalBottomSheet<RingtonePickerResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _RingtonePickerSheet(
      currentUri: currentUri,
      currentTitle: currentTitle,
      showReset: showReset,
    ),
  );
}

class _RingtonePickerSheet extends StatefulWidget {
  final String? currentUri;
  final String? currentTitle;
  final bool showReset;

  const _RingtonePickerSheet({
    this.currentUri,
    this.currentTitle,
    required this.showReset,
  });

  @override
  State<_RingtonePickerSheet> createState() => _RingtonePickerSheetState();
}

class _RingtonePickerSheetState extends State<_RingtonePickerSheet> {
  final _ringtoneService = RingtoneService();
  String? _displayTitle;
  bool _isLoadingTitle = false;

  @override
  void initState() {
    super.initState();
    _displayTitle = widget.currentTitle;
    if (_displayTitle == null && widget.currentUri != null && widget.currentUri!.isNotEmpty) {
      _loadTitle(widget.currentUri!);
    }
  }

  Future<void> _loadTitle(String uri) async {
    setState(() => _isLoadingTitle = true);
    final title = await _ringtoneService.getRingtoneTitle(uri);
    if (mounted) {
      setState(() {
        _displayTitle = title;
        _isLoadingTitle = false;
      });
    }
  }

  Future<void> _pickSystem() async {
    final item = await _ringtoneService.pickSystemRingtone(
      currentUri: widget.currentUri,
    );
    if (item != null && mounted) {
      Navigator.pop(
        context,
        RingtonePickerResult(uri: item.uri, title: item.title),
      );
    }
  }

  Future<void> _pickFile() async {
    final item = await _ringtoneService.pickAudioFile();
    if (item != null && mounted) {
      Navigator.pop(
        context,
        RingtonePickerResult(uri: item.uri, title: item.title),
      );
    }
  }

  void _resetToDefault() {
    Navigator.pop(
      context,
      const RingtonePickerResult(isReset: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasCurrent = widget.currentUri != null && widget.currentUri!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pilih Ringtone Alarm',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Current selection preview (if any)
            if (hasCurrent) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.accentAmber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.accentAmber.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.music_note_rounded,
                      color: AppColors.accentAmber,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ringtone Aktif',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.accentAmber,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _isLoadingTitle
                                ? 'Memuat nama nada...'
                                : (_displayTitle ?? 'Ringtone Kustom'),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (widget.showReset)
                      TextButton.icon(
                        onPressed: _resetToDefault,
                        icon: const Icon(Icons.restore, size: 16),
                        label: const Text('Reset', style: TextStyle(fontSize: 12)),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            Text(
              'SUMBER AUDIO',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 10),

            // Opsi 1: Dari sistem
            _OptionCard(
              icon: Icons.notifications_active_outlined,
              iconColor: const Color(0xFF4A90E2),
              title: 'Pilih dari Nada Tersedia',
              subtitle: 'Nada bawaan sistem & alarm HP',
              onTap: _pickSystem,
              isDark: isDark,
            ),
            const SizedBox(height: 10),

            // Opsi 2: Dari penyimpanan file
            _OptionCard(
              icon: Icons.folder_open_rounded,
              iconColor: const Color(0xFF50E3C2),
              title: 'Pilih File Sendiri',
              subtitle: 'Buka file manager untuk audio (.mp3, .wav, dsb)',
              onTap: _pickFile,
              isDark: isDark,
            ),

            if (!hasCurrent && widget.showReset) ...[
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Saat ini menggunakan pengaturan default aplikasi',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDark;

  const _OptionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? const Color(0xFF22242B) : const Color(0xFFF4F6F9),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: isDark ? Colors.white38 : Colors.black26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
