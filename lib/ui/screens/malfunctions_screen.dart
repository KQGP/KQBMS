import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/bms_provider.dart';
import '../../providers/settings_provider.dart';
import '../../models/bms_data.dart';
import '../../l10n/app_localizations.dart';
import '../theme.dart';
import '../widgets/glass_container.dart';

class MalfunctionsScreen extends StatelessWidget {
  const MalfunctionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppTheme.getBackground(context),
      body: SafeArea(
        child: Consumer2<BmsProvider, SettingsProvider>(
          builder: (context, provider, settings, child) {
            final malfunctions = provider.activeMalfunctions;
            final hasMalfunctions = malfunctions.isNotEmpty;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, l10n),
                Expanded(
                  child: hasMalfunctions
                      ? _buildMalfunctionsList(context, malfunctions, l10n)
                      : _buildEmptyState(context, l10n),
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
              Icons.arrow_back_ios_rounded,
              size: 18,
              color: AppTheme.getTextPrimary(context),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(l10n.malfunctions, style: AppTheme.title2Style(context)),
        const Spacer(),
        Consumer<BmsProvider>(
          builder: (context, provider, child) {
            final count = provider.activeMalfunctions.length;
            if (count == 0) return const SizedBox.shrink();
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.getError(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "$count",
                style: AppTheme.headlineStyle(context).copyWith(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          },
        ),
      ]),
    );
  }

  Widget _buildMalfunctionsList(
      BuildContext context, List<BmsMalfunction> malfunctions, AppLocalizations l10n) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: malfunctions.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = malfunctions[index];
        IconData icon = Icons.warning_rounded;

        if (item.token == "overTemperature" || item.token == "sensorFault") {
          icon = Icons.thermostat_rounded;
        } else if (item.token == "cellUvp" || item.token == "cellOvp") {
          icon = Icons.battery_alert_rounded;
        } else if (item.token == "noReading") {
          icon = Icons.perm_scan_wifi_rounded;
        }

        return GlassContainer(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          child: Row(children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.getError(context).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: AppTheme.getError(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _translateToken(l10n, item),
                style: AppTheme.bodyStyle(context).copyWith(
                  color: AppTheme.getTextPrimary(context),
                  height: 1.3,
                ),
              ),
            ),
          ]),
        );
      },
    );
  }

  String _translateToken(AppLocalizations l10n, BmsMalfunction item) {
    String message = "";
    switch (item.token) {
      case "cellOvp": message = l10n.cellOvp; break;
      case "cellUvp": message = l10n.cellUvp; break;
      case "packOvp": message = l10n.packOvp; break;
      case "packUvp": message = l10n.packUvp; break;
      case "chargeOtp": message = l10n.chargeOtp; break;
      case "chargeUtp": message = l10n.chargeUtp; break;
      case "dischOtp": message = l10n.dischOtp; break;
      case "dischUtp": message = l10n.dischUtp; break;
      case "chargeOcp": message = l10n.chargeOcp; break;
      case "dischOcp": message = l10n.dischOcp; break;
      case "shortCkt": message = l10n.shortCkt; break;
      case "icError": message = l10n.icError; break;
      case "mosLock": message = l10n.mosLock; break;
      case "overTemperature": message = l10n.overTemperature; break;
      case "sensorFault": message = l10n.sensorFault; break;
      case "noReading": message = l10n.noReading; break;
      default: message = item.token;
    }

    if (item.source != null && item.value != null) {
      return "${item.source} ${item.value}${item.unit} — $message";
    } else if (item.source != null) {
      return "${item.source} — $message";
    }
    return message;
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.getSuccess(context).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_rounded,
              size: 32,
              color: AppTheme.getSuccess(context),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.allSystemsNormal,
            style: AppTheme.title2Style(context),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.noMalfunctionsDetected,
            textAlign: TextAlign.center,
            style: AppTheme.bodyStyle(context).copyWith(
              color: AppTheme.getTextSecondary(context),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
