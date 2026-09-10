import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:titik_waktu/providers/permission_provider.dart';
import 'package:titik_waktu/theme/app_colors.dart';

class MiuiOnboardingWizardScreen extends ConsumerStatefulWidget {
  final bool isModalMode;

  const MiuiOnboardingWizardScreen({super.key, this.isModalMode = false});

  @override
  ConsumerState<MiuiOnboardingWizardScreen> createState() => _MiuiOnboardingWizardScreenState();
}

class _MiuiOnboardingWizardScreenState extends ConsumerState<MiuiOnboardingWizardScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final int _totalPages = 5;

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishWizard();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _finishWizard() {
    ref.read(permissionProvider.notifier).completeOnboarding();
    if (widget.isModalMode || Navigator.canPop(context)) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panduan Optimasi Android'),
        actions: [
          TextButton(
            onPressed: _finishWizard,
            child: Text(
              'Lewati',
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Linear Progress Indicator
            LinearProgressIndicator(
              value: (_currentPage + 1) / _totalPages,
              backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? AppColors.amberDarkIndicator : AppColors.amberLightIndicator,
              ),
              minHeight: 3,
            ),

            // Page View with 5 Steps
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  _buildStep1Autostart(isDark),
                  _buildStep2BatterySaver(isDark),
                  _buildStep3Notifications(isDark),
                  _buildStep4FullscreenPopup(isDark),
                  _buildStep5LockRecentApps(isDark),
                ],
              ),
            ),

            // Bottom Navigation Controls
            _buildBottomControls(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1Autostart(bool isDark) {
    return _buildStepLayout(
      stepNumber: 1,
      title: 'Mulai Otomatis (Autostart)',
      subtitle: 'Izinkan aplikasi jalan di latar belakang',
      icon: Icons.rocket_launch_rounded,
      iconColor: AppColors.categoryCoral,
      description:
          'Pada perangkat Xiaomi / MIUI / HyperOS dan beberapa merek lain, sistem secara agresif mematikan aplikasi saat reboot.\n\n'
          'Aktifkan opsi **Autostart** agar Titik Waktu dapat menjadwalkan ulang alarm saat ponsel dinyalakan kembali.',
      actionLabel: 'Buka Pengaturan Autostart',
      onAction: () async {
        final service = ref.read(permissionServiceProvider);
        await service.openAutostartSettings();
      },
      isDark: isDark,
    );
  }

  Widget _buildStep2BatterySaver(bool isDark) {
    return _buildStepLayout(
      stepNumber: 2,
      title: 'Penghemat Baterai (Battery Saver)',
      subtitle: 'Pilih "Tidak Ada Pembatasan"',
      icon: Icons.battery_charging_full_rounded,
      iconColor: AppColors.categoryGreen,
      description:
          'Sistem penghemat baterai dapat menahan pemicu alarm tepat waktu.\n\n'
          'Untuk keandalan maksimal:\n'
          '• Buka pengaturan baterai aplikasi\n'
          '• Pilih opsi **"Tidak Ada Pembatasan" (No Restrictions)** atau minimal Default MIUI.',
      actionLabel: 'Buka Pengaturan Penghemat Baterai',
      onAction: () async {
        final service = ref.read(permissionServiceProvider);
        await service.openBatteryOptimizationSettings();
      },
      isDark: isDark,
    );
  }

  Widget _buildStep3Notifications(bool isDark) {
    return _buildStepLayout(
      stepNumber: 3,
      title: 'Izin Notifikasi & Layar Kunci',
      subtitle: 'Tampilkan notifikasi di layar kunci',
      icon: Icons.notifications_active_rounded,
      iconColor: AppColors.categoryBlue,
      description:
          'Pastikan semua kategori notifikasi diizinkan, terutama:\n\n'
          '• **Tampilkan di Layar Kunci (Lock Screen Notifications)**\n'
          '• **Izinkan Notifikasi Melayang (Floating Notifications / Heads-up)**\n'
          '• **Izinkan Suara & Getaran**',
      actionLabel: 'Buka Pengaturan Notifikasi',
      onAction: () async {
        final service = ref.read(permissionServiceProvider);
        await service.openNotificationSettings();
      },
      isDark: isDark,
    );
  }

  Widget _buildStep4FullscreenPopup(bool isDark) {
    return _buildStepLayout(
      stepNumber: 4,
      title: 'Izin Jendela Pop-Up Latar Belakang',
      subtitle: 'Alarm Layar Penuh (Full-screen intent)',
      icon: Icons.picture_in_picture_alt_rounded,
      iconColor: AppColors.categoryAmber,
      description:
          'Agar alarm layar penuh dapat langsung terbuka saat HP terkunci atau saat membuka aplikasi lain:\n\n'
          '• Buka **Izin Lainnya (Other Permissions)**\n'
          '• Berikan izin pada **"Tampilkan jendela pop-up saat berjalan di latar belakang"** (Display pop-up windows while running in the background).',
      actionLabel: 'Buka Pengaturan Izin Aplikasi',
      onAction: () async {
        final service = ref.read(permissionServiceProvider);
        await service.openAppDetailsSettings();
      },
      isDark: isDark,
    );
  }

  Widget _buildStep5LockRecentApps(bool isDark) {
    return _buildStepLayout(
      stepNumber: 5,
      title: 'Kunci di Recent Apps (Gembok)',
      subtitle: 'Mencegah pembersihan memori RAM',
      icon: Icons.lock_outline_rounded,
      iconColor: AppColors.categoryTeal,
      description:
          'Pengaturan ini dilakukan manual oleh pengguna:\n\n'
          '1. Buka layar **Recent Apps** (geser dari bawah dan tahan).\n'
          '2. Tekan & tahan kartu aplikasi **Titik Waktu**.\n'
          '3. Ketuk ikon **Gembok (Lock)** hingga ikon gembok terkunci muncul di sudut kartu.\n\n'
          'Ini memastikan alarm tetap siap berbunyi meski Anda sering menekan tombol "Bersihkan Semua".',
      actionLabel: 'Mengerti, Saya Akan Lakukan',
      onAction: _finishWizard,
      isDark: isDark,
      isManualGuide: true,
    );
  }

  Widget _buildStepLayout({
    required int stepNumber,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required String description,
    required String actionLabel,
    required VoidCallback onAction,
    required bool isDark,
    bool isManualGuide = false,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Step Counter Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 0.5,
              ),
            ),
            child: Text(
              'Langkah $stepNumber dari $_totalPages',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Icon Graphic
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 36, color: iconColor),
          ),
          const SizedBox(height: 16),

          // Title & Subtitle
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Description Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 0.5,
              ),
            ),
            child: Text(
              description,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.5,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Intent Trigger Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onAction,
              icon: Icon(
                isManualGuide ? Icons.check_circle_outline : Icons.open_in_new,
                size: 18,
              ),
              label: Text(actionLabel),
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                side: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 1,
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            TextButton(
              onPressed: _previousPage,
              child: const Text('Sebelumnya'),
            )
          else
            const SizedBox(width: 80),

          // Dots indicator
          Row(
            children: List.generate(_totalPages, (index) {
              final isCurrent = index == _currentPage;
              return Container(
                width: isCurrent ? 16 : 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 2.5),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? (isDark ? AppColors.amberDarkIndicator : AppColors.amberLightIndicator)
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),

          FilledButton(
            onPressed: _nextPage,
            style: FilledButton.styleFrom(
              backgroundColor: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              foregroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(_currentPage == _totalPages - 1 ? 'Selesai' : 'Lanjut'),
          ),
        ],
      ),
    );
  }
}
