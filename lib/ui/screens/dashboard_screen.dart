import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/bms_provider.dart';
import '../../providers/settings_provider.dart';
import '../../models/bms_data.dart';
import '../../l10n/app_localizations.dart';
import 'detail_screen.dart';
import 'settings_screen.dart';
import 'scan_screen.dart';
import 'malfunctions_screen.dart';
import '../theme.dart';
import '../widgets/glass_container.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final l10n = AppLocalizations.of(context)!;

    return Consumer2<BmsProvider, SettingsProvider>(
      builder: (context, provider, settings, child) {
        final info = provider.baseInfo;

        return Scaffold(
          backgroundColor: AppTheme.getBackground(context),
          body: Stack(
            children: [
              Positioned(
                top: -120,
                left: -60,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                  child: Container(
                    width: 350,
                    height: 350,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.getPrimary(context).withValues(alpha: 0.25),
                          AppTheme.getPrimary(context).withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -80,
                right: -40,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.getSuccess(context).withValues(alpha: 0.15),
                          AppTheme.getSuccess(context).withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),


              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.appTitle,
                                    style: AppTheme.labelStyle(context)
                                        .copyWith(
                                          fontSize: 12,
                                          letterSpacing: 1.2,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    provider.deviceName,
                                    style: AppTheme.title2Style(context),
                                  ),
                                  if (provider.hardwareVersion != null)
                                    Text(
                                      provider.hardwareVersion!.version,
                                      style: AppTheme.labelStyle(context).copyWith(
                                        fontSize: 12,
                                        color: AppTheme.getTextTertiary(context),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                _buildHeaderButton(
                                  context,
                                  icon: Icons.grid_view_rounded,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const DetailScreen(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _buildHeaderButton(
                                  context,
                                  icon: Icons.settings_rounded,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const SettingsScreen(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _buildMalfunctionButton(context, provider),
                                const SizedBox(width: 8),
                                _buildHeaderButton(
                                  context,
                                  icon: Icons.power_settings_new_rounded,
                                  color: AppTheme.getError(context),
                                  onTap: () {
                                    provider.disconnect();
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const ScanScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      _buildHeroSoc(context, info, isDark, l10n),

                      const SizedBox(height: 24),

                      _buildQuickInfoRow(context, info, settings, l10n),

                      const SizedBox(height: 20),

                      _buildPowerFlow(context, info, l10n),

                      const SizedBox(height: 20),

                      _buildSocTime(context, info, l10n),

                      const SizedBox(height: 16),

                      _buildMosfetControls(context, provider, l10n),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.getGlassColor(context).withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.getGlassBorder(context),
            width: 0.5,
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: color ?? AppTheme.getTextPrimary(context),
        ),
      ),
    );
  }

  Widget _buildMalfunctionButton(BuildContext context, BmsProvider provider) {
    final hasMalfunctions = provider.hasMalfunctions;
    final bgColor = hasMalfunctions
        ? AppTheme.getError(context).withValues(alpha: 0.2)
        : AppTheme.getGlassColor(context).withValues(alpha: 0.3);
    final borderColor = hasMalfunctions
        ? AppTheme.getError(context).withValues(alpha: 0.4)
        : AppTheme.getGlassBorder(context);
    final iconColor = hasMalfunctions
        ? AppTheme.getError(context)
        : AppTheme.getTextSecondary(context);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MalfunctionsScreen()),
      ),
      child: Stack(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 0.5),
            ),
            child: Icon(
              Icons.warning_rounded,
              size: 20,
              color: iconColor,
            ),
          ),
          if (hasMalfunctions)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: AppTheme.getError(context),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.getBackground(context),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.badge,
                  size: 10,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeroSoc(BuildContext context, BmsBaseInfo? info, bool isDark, AppLocalizations l10n) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            width: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    color: isDark
                        ? const Color(0xFF2C2C2E)
                        : const Color(0xFFE5E5EA),
                    strokeWidth: 14,
                  ),
                ),
                SizedBox(
                  width: 200,
                  height: 200,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(
                      begin: 0,
                      end: (info?.rsoc ?? 0) / 100.0,
                    ),
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) =>
                        CircularProgressIndicator(
                      value: value,
                      color: _getSocColor(context, info?.rsoc ?? 0),
                      strokeWidth: 14,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${info?.totalVoltage.toStringAsFixed(1) ?? "--"}V",
                      style: AppTheme.headlineStyle(context).copyWith(
                        color: AppTheme.getPrimary(context),
                        fontSize: 20,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          info != null ? "${info.rsoc}" : "--",
                          style: AppTheme.largeValueStyle(context).copyWith(
                            fontSize: 56,
                            fontWeight: FontWeight.w200,
                            height: 1,
                          ),
                        ),
                        Text(
                          "%",
                          style: AppTheme.labelStyle(context).copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.getTextTertiary(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${info?.current.toStringAsFixed(1) ?? "--"}A",
                      style: AppTheme.headlineStyle(context).copyWith(
                        fontSize: 20,
                        letterSpacing: -0.5,
                        color: info != null
                            ? (info.current > 0
                                ? AppTheme.getSuccess(context)
                                : info.current < 0
                                    ? AppTheme.getError(context)
                                    : AppTheme.getTextPrimary(context))
                            : AppTheme.getTextPrimary(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfoRow(BuildContext context, BmsBaseInfo? info, SettingsProvider settings, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickCard(
            context,
            l10n.cycles,
            info != null ? "${info.cycleCount}" : "--",
            Icons.replay_rounded,
            AppTheme.getPrimary(context),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildQuickCard(
            context,
            l10n.capacity,
            info != null
                ? "${info.remainingCapacity.toStringAsFixed(1)}Ah"
                : "--Ah",
            Icons.battery_std_rounded,
            AppTheme.getSuccess(context),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildQuickCard(
            context,
            l10n.temp,
            (info != null && info.temperatures.isNotEmpty)
                ? settings.formatTempShort(info.temperatures.first)
                : "--",
            Icons.thermostat_rounded,
            AppTheme.getError(context),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTheme.headlineStyle(context).copyWith(fontSize: 16),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTheme.labelStyle(context).copyWith(
              fontSize: 12,
              color: AppTheme.getTextTertiary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPowerFlow(BuildContext context, BmsBaseInfo? info, AppLocalizations l10n) {
    final double power = info != null ? (info.totalVoltage * info.current).abs() : 0;
    final bool isCharging = info != null && info.current > 0.05;
    final bool isDischarging = info != null && info.current < -0.05;

    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    l10n.charge.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                    softWrap: false,
                    style: AppTheme.labelStyle(context).copyWith(
                      fontSize: 11,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isCharging ? "${power.toStringAsFixed(0)}W" : "0W",
                  maxLines: 1,
                  style: AppTheme.headlineStyle(context).copyWith(
                    color: isCharging ? AppTheme.getSuccess(context) : AppTheme.getTextTertiary(context),
                  ),
                ),
                const SizedBox(height: 8),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: isCharging ? AppTheme.getSuccess(context) : AppTheme.getTextTertiary(context).withValues(alpha: 0.4),
                  size: 24,
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.battery_full_rounded,
                      size: 52,
                      color: _getSocColor(context, info?.rsoc ?? 0),
                    ),
                    if (isCharging)
                      const Icon(Icons.bolt_rounded, size: 22, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  "${info?.rsoc ?? 0}%",
                  style: AppTheme.labelStyle(context).copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: AppTheme.getTextPrimary(context),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Column(
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    l10n.discharge.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                    softWrap: false,
                    style: AppTheme.labelStyle(context).copyWith(
                      fontSize: 11,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isDischarging ? "${power.toStringAsFixed(0)}W" : "0W",
                  maxLines: 1,
                  style: AppTheme.headlineStyle(context).copyWith(
                    color: isDischarging ? AppTheme.getError(context) : AppTheme.getTextTertiary(context),
                  ),
                ),
                const SizedBox(height: 8),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: isDischarging ? AppTheme.getError(context) : AppTheme.getTextTertiary(context).withValues(alpha: 0.4),
                  size: 24,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocTime(BuildContext context, BmsBaseInfo? info, AppLocalizations l10n) {
    if (info == null || info.current == 0) return const SizedBox.shrink();
    double hours;
    bool isCharging = info.current > 0;
    if (isCharging) {
      double remainingToFull = info.nominalCapacity - info.remainingCapacity;
      hours = remainingToFull / info.current;
    } else {
      hours = info.remainingCapacity / info.current.abs();
    }
    if (hours <= 0 || hours > 999) return const SizedBox.shrink();
    int h = hours.floor();
    int m = ((hours - h) * 60).round();
    String label = isCharging ? l10n.timeToFull : l10n.timeRemaining;
    IconData icon = isCharging ? Icons.battery_charging_full_rounded : Icons.battery_std_rounded;
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(children: [
        Icon(icon, size: 18, color: isCharging ? AppTheme.getSuccess(context) : AppTheme.getPrimary(context)),
        const SizedBox(width: 10),
        Text(label, style: AppTheme.bodyStyle(context).copyWith(color: AppTheme.getTextSecondary(context))),
        const Spacer(),
        Text("${h}h ${m}m",
            style: AppTheme.headlineStyle(context).copyWith(fontSize: 18)),
      ]),
    );
  }

  Widget _buildMosfetControls(BuildContext context, BmsProvider provider, AppLocalizations l10n) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Row(
        children: [
          _buildMosToggle(
            context,
            icon: Icons.battery_charging_full_rounded,
            label: l10n.charge,
            value: provider.isChargeEnabled,
            onChanged: (v) => provider.enableCharge(v),
            activeColor: AppTheme.getSuccess(context),
          ),
          Container(
            width: 1,
            height: 24,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            color: AppTheme.getDividerColor(context),
          ),
          _buildMosToggle(
            context,
            icon: Icons.battery_std_rounded,
            label: l10n.discharge,
            value: provider.isDischargeEnabled,
            onChanged: (v) => provider.enableDischarge(v),
            activeColor: AppTheme.getPrimary(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMosToggle(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool value,
    required void Function(bool) onChanged,
    required Color activeColor,
  }) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: value ? activeColor : AppTheme.getTextTertiary(context),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                label.toUpperCase(),
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.visible,
                style: AppTheme.labelStyle(context).copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                  color: value
                      ? AppTheme.getTextPrimary(context)
                      : AppTheme.getTextTertiary(context),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Transform.scale(
            scale: 0.75,
            alignment: Alignment.centerRight,
            child: Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeTrackColor: activeColor,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Color _getSocColor(BuildContext context, int rsoc) {
    if (rsoc > 50) return AppTheme.getSuccess(context);
    if (rsoc > 20) return AppTheme.getWarning(context);
    return AppTheme.getError(context);
  }
}
