import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:titik_waktu/providers/ringtone_provider.dart';
import 'package:titik_waktu/providers/theme_provider.dart';
import 'package:titik_waktu/theme/app_colors.dart';
import 'package:titik_waktu/widgets/ringtone_picker_sheet.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _packageInfo = info;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeMode = ref.watch(themeProvider);
    final defaultRingtone = ref.watch(defaultRingtoneProvider);

    final surfaceBg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textMuted = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: surfaceBg,
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          // ── Section 1: Info Aplikasi ──────────────────────────────────
          _buildAppInfoCard(
            context,
            isDark: isDark,
            cardBg: cardBg,
            borderColor: borderColor,
            textPrimary: textPrimary,
            textMuted: textMuted,
          ),

          const SizedBox(height: 24),

          // ── Section 2: Izin Aplikasi ──────────────────────────────────
          _buildSectionHeader('Izin & Keamanan', textMuted),
          const SizedBox(height: 8),
          _buildSettingsCard(
            isDark: isDark,
            cardBg: cardBg,
            borderColor: borderColor,
            children: [
              _buildNavItem(
                context,
                icon: Icons.shield_outlined,
                label: 'Kelola Izin Aplikasi',
                subtitle: 'Periksa & aktifkan izin alarm, notifikasi',
                textPrimary: textPrimary,
                textMuted: textMuted,
                onTap: () => context.push('/permissions/onboarding'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Section 3: Ringtone Default ───────────────────────────────
          _buildSectionHeader('Suara & Ringtone', textMuted),
          const SizedBox(height: 8),
          _buildSettingsCard(
            isDark: isDark,
            cardBg: cardBg,
            borderColor: borderColor,
            children: [
              _buildRingtoneItem(
                context,
                defaultRingtone: defaultRingtone,
                textPrimary: textPrimary,
                textMuted: textMuted,
                isDark: isDark,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Section 4: Tampilan ───────────────────────────────────────
          _buildSectionHeader('Tampilan', textMuted),
          const SizedBox(height: 8),
          _buildSettingsCard(
            isDark: isDark,
            cardBg: cardBg,
            borderColor: borderColor,
            children: [
              _buildThemeToggleItem(
                context,
                themeMode: themeMode,
                textPrimary: textPrimary,
                textMuted: textMuted,
                isDark: isDark,
                borderColor: borderColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── App Info Card ─────────────────────────────────────────────────────────

  Widget _buildAppInfoCard(
    BuildContext context, {
    required bool isDark,
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
    required Color textMuted,
  }) {
    final version = _packageInfo != null
        ? 'Versi ${_packageInfo!.version}+${_packageInfo!.buildNumber}'
        : '—';

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // App Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1A),
              borderRadius: BorderRadius.circular(14),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/icon/app_icon.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.access_time_rounded,
                color: Color(0xFFFAC775),
                size: 30,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // App Name & Version
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Titik Waktu',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Jadwal & Alarm Kegiatan',
                  style: TextStyle(
                    fontSize: 12,
                    color: textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkBorder.withValues(alpha: 0.6)
                        : const Color(0xFFF0EFEA),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    version,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: textMuted,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section Header ────────────────────────────────────────────────────────

  Widget _buildSectionHeader(String title, Color textMuted) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
          color: textMuted,
        ),
      ),
    );
  }

  // ── Settings Card Container ───────────────────────────────────────────────

  Widget _buildSettingsCard({
    required bool isDark,
    required Color cardBg,
    required Color borderColor,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }

  // ── Ringtone List Item ──────────────────────────────────────────────────
  Widget _buildRingtoneItem(
    BuildContext context, {
    required RingtoneData defaultRingtone,
    required Color textPrimary,
    required Color textMuted,
    required bool isDark,
  }) {
    final hasCustom = defaultRingtone.isSet;
    final displayTitle = defaultRingtone.title ?? (hasCustom ? 'Ringtone Kustom' : 'Default Sistem Android');

    return InkWell(
      onTap: () async {
        final result = await showRingtonePickerSheet(
          context,
          currentUri: defaultRingtone.uri,
          currentTitle: defaultRingtone.title,
          showReset: true,
        );

        if (result != null) {
          final notifier = ref.read(defaultRingtoneProvider.notifier);
          if (result.isReset) {
            await notifier.reset();
          } else {
            await notifier.setRingtone(result.uri, result.title);
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              hasCustom ? Icons.music_note_rounded : Icons.notifications_active_outlined,
              size: 20,
              color: hasCustom ? AppColors.accentAmber : textPrimary,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ringtone Default Alarm',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    displayTitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: hasCustom ? AppColors.accentAmber : textMuted,
                      fontWeight: hasCustom ? FontWeight.w500 : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: textMuted,
            ),
          ],
        ),
      ),
    );
  }

  // ── Navigation List Item ──────────────────────────────────────────────────

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    String? subtitle,
    required Color textPrimary,
    required Color textMuted,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: textPrimary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: textMuted,
            ),
          ],
        ),
      ),
    );
  }

  // ── Theme Toggle Item ─────────────────────────────────────────────────────

  Widget _buildThemeToggleItem(
    BuildContext context, {
    required ThemeMode themeMode,
    required Color textPrimary,
    required Color textMuted,
    required bool isDark,
    required Color borderColor,
  }) {
    final options = [
      _ThemeOption(
        mode: ThemeMode.system,
        icon: Icons.brightness_auto_rounded,
        label: 'Otomatis',
      ),
      _ThemeOption(
        mode: ThemeMode.light,
        icon: Icons.light_mode_rounded,
        label: 'Terang',
      ),
      _ThemeOption(
        mode: ThemeMode.dark,
        icon: Icons.dark_mode_rounded,
        label: 'Gelap',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.palette_outlined, size: 20, color: textPrimary),
              const SizedBox(width: 14),
              Text(
                'Tema Tampilan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: options.map((opt) {
              final isSelected = themeMode == opt.mode;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: opt == options.last ? 0 : 8,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      ref.read(themeProvider.notifier).setMode(opt.mode);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark
                                ? AppColors.amberDarkIndicator.withValues(alpha: 0.12)
                                : const Color(0xFFFCF6EC))
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? (isDark
                                  ? AppColors.amberDarkIndicator.withValues(alpha: 0.4)
                                  : AppColors.amberLightHighlightBorder)
                              : borderColor,
                          width: isSelected ? 1.0 : 0.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            opt.icon,
                            size: 18,
                            color: isSelected
                                ? (isDark
                                    ? AppColors.amberDarkIndicator
                                    : AppColors.amberLightIndicator)
                                : textMuted,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            opt.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected
                                  ? (isDark
                                      ? AppColors.amberDarkIndicator
                                      : AppColors.amberLightIndicator)
                                  : textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption {
  final ThemeMode mode;
  final IconData icon;
  final String label;

  const _ThemeOption({
    required this.mode,
    required this.icon,
    required this.label,
  });
}
