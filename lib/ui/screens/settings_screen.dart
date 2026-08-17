import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../l10n/app_localizations.dart';
import '../theme.dart';
import '../widgets/glass_container.dart';
import 'about_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppTheme.getBackground(context),
      body: SafeArea(
        child: Consumer<SettingsProvider>(
          builder: (context, settings, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, l10n),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _sectionHeader(context, l10n.interface),
                      const SizedBox(height: 8),
                      _buildThemeSelector(context, settings, l10n),
                      const SizedBox(height: 8),
                      _tempUnitSelector(context, settings, l10n),
                      const SizedBox(height: 20),

                      _sectionHeader(context, l10n.device),
                      const SizedBox(height: 8),
                      _buildRefreshInterval(context, settings, l10n),
                      const SizedBox(height: 16),
                      _buildAutoReconnect(context, settings, l10n),
                      const SizedBox(height: 16),

                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen())),
                        child: GlassContainer(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          child: Row(children: [
                            Icon(Icons.info_outline_rounded, size: 20, color: AppTheme.getTextSecondary(context)),
                            const SizedBox(width: 12),
                            Text(l10n.about, style: AppTheme.bodyStyle(context)),
                            const Spacer(),
                            Icon(Icons.chevron_right_rounded, color: AppTheme.getTextTertiary(context)),
                          ]),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppTheme.getGlassColor(context).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.getGlassBorder(context), width: 0.5),
            ),
            child: Icon(Icons.arrow_back_ios_rounded, size: 18, color: AppTheme.getTextPrimary(context)),
          ),
        ),
        const SizedBox(width: 12),
        Text(l10n.settings, style: AppTheme.title2Style(context)),
      ]),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(title.toUpperCase(), style: AppTheme.labelStyle(context).copyWith(
          fontSize: 13, letterSpacing: 1, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildThemeSelector(BuildContext context, SettingsProvider settings, AppLocalizations l10n) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Row(children: [
        _themeOption(context, settings, ThemeMode.system, l10n.system, Icons.settings_brightness_rounded),
        _themeOption(context, settings, ThemeMode.light, l10n.light, Icons.light_mode_rounded),
        _themeOption(context, settings, ThemeMode.dark, l10n.dark, Icons.dark_mode_rounded),
      ]),
    );
  }

  Widget _themeOption(BuildContext context, SettingsProvider settings, ThemeMode mode, String label, IconData icon) {
    final selected = settings.themeMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => settings.setThemeMode(mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppTheme.getPrimary(context).withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(children: [
            Icon(icon, size: 20, color: selected ? AppTheme.getPrimary(context) : AppTheme.getTextTertiary(context)),
            const SizedBox(height: 4),
            Text(label, style: AppTheme.labelStyle(context).copyWith(
                color: selected ? AppTheme.getPrimary(context) : AppTheme.getTextTertiary(context),
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
          ]),
        ),
      ),
    );
  }

  Widget _tempUnitSelector(BuildContext context, SettingsProvider settings, AppLocalizations l10n) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          Icon(Icons.thermostat_rounded, size: 20, color: AppTheme.getTextSecondary(context)),
          const SizedBox(width: 10),
          Text(l10n.temperature, style: AppTheme.bodyStyle(context)),
        ]),
        Row(children: [
          _unitButton(context, "°C", settings.tempUnit == 'C', () => settings.setTempUnit('C')),
          const SizedBox(width: 8),
          _unitButton(context, "°F", settings.tempUnit == 'F', () => settings.setTempUnit('F')),
        ]),
      ]),
    );
  }

  Widget _unitButton(BuildContext context, String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppTheme.getPrimary(context).withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? AppTheme.getPrimary(context).withValues(alpha: 0.3) : AppTheme.getGlassBorder(context)),
        ),
        child: Text(label, style: AppTheme.labelStyle(context).copyWith(
            color: selected ? AppTheme.getPrimary(context) : AppTheme.getTextTertiary(context),
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
      ),
    );
  }

  Widget _buildRefreshInterval(BuildContext context, SettingsProvider settings, AppLocalizations l10n) {
    const intervals = [1000, 2000, 5000, 10000, 15000];
    const labels = ["1s", "2s", "5s", "10s", "15s"];
    int currentIdx = intervals.indexOf(settings.refreshIntervalMs);
    if (currentIdx < 0) currentIdx = 2;
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.refresh_rounded, size: 20, color: AppTheme.getTextSecondary(context)),
          const SizedBox(width: 10),
          Text(l10n.refreshInterval, style: AppTheme.bodyStyle(context)),
          const Spacer(),
          Text(labels[currentIdx],
              style: AppTheme.headlineStyle(context).copyWith(fontSize: 15)),
        ]),
        const SizedBox(height: 8),
        Slider(
          value: currentIdx.toDouble(),
          min: 0, max: 4,
          divisions: 4,
          activeColor: AppTheme.getPrimary(context),
          inactiveColor: AppTheme.getGlassBorder(context),
          onChanged: (v) {
            int idx = v.round();
            if (idx >= 0 && idx < intervals.length) {
              settings.setRefreshIntervalMs(intervals[idx]);
            }
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:
            labels.map((l) => Text(l, style: AppTheme.labelStyle(context).copyWith(fontSize: 12))).toList()),
        ),
      ]),
    );
  }

  Widget _buildAutoReconnect(BuildContext context, SettingsProvider settings, AppLocalizations l10n) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          Icon(Icons.bluetooth_rounded, size: 20, color: AppTheme.getTextSecondary(context)),
          const SizedBox(width: 10),
          Text(l10n.autoReconnect, style: AppTheme.bodyStyle(context)),
        ]),
        Switch(
          value: settings.autoReconnect,
          activeThumbColor: AppTheme.getPrimary(context),
          onChanged: (v) => settings.setAutoReconnect(v),
        ),
      ]),
    );
  }
}
