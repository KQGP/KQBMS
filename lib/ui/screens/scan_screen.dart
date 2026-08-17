import 'dart:ui';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../providers/bms_provider.dart';
import '../theme.dart';
import '../widgets/glass_container.dart';
import 'dashboard_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _fadeController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BmsProvider>().startScan();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppTheme.getBackground(context),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -60,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.getPrimary(context).withValues(alpha: 0.2),
                      AppTheme.getPrimary(context).withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.appTitle,
                                style: AppTheme.labelStyle(context).copyWith(
                                  fontSize: 11,
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                l10n.discoverDevices,
                                style: AppTheme.title2Style(context),
                              ),
                            ],
                          ),
                        ),
                        _buildScanButton(context, l10n),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Consumer<BmsProvider>(
                      builder: (context, provider, child) {
                        if (provider.scanResults.isEmpty &&
                            provider.isScanning) {
                          return _buildSearchingState(context, l10n);
                        }
                        if (provider.scanResults.isEmpty) {
                          return _buildEmptyState(context, provider, l10n);
                        }
                        return FadeTransition(
                          opacity: _fadeAnim,
                          child: ListView.builder(
                            itemCount: provider.scanResults.length,
                            itemBuilder: (context, index) {
                              return _buildDeviceCard(
                                context,
                                provider,
                                provider.scanResults[index],
                                l10n,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanButton(BuildContext context, AppLocalizations l10n) {
    return Consumer<BmsProvider>(
      builder: (context, provider, _) {
        return GestureDetector(
          onTap: provider.isScanning
              ? provider.stopScan
              : provider.startScan,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: provider.isScanning
                  ? AppTheme.getError(context).withValues(alpha: 0.15)
                  : AppTheme.getPrimary(context).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: provider.isScanning
                    ? AppTheme.getError(context).withValues(alpha: 0.3)
                    : AppTheme.getPrimary(context).withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (provider.isScanning)
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: AppTheme.getError(context),
                    ),
                  )
                else
                  Icon(
                    Icons.bluetooth_searching_rounded,
                    size: 14,
                    color: AppTheme.getPrimary(context),
                  ),
                const SizedBox(width: 6),
                Text(
                  provider.isScanning ? l10n.stop : l10n.scan,
                  style: AppTheme.labelStyle(context).copyWith(
                    fontSize: 12,
                    color: provider.isScanning
                        ? AppTheme.getError(context)
                        : AppTheme.getPrimary(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchingState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppTheme.getPrimary(context),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.scanningForDevices,
            style: AppTheme.labelStyle(context).copyWith(
              color: AppTheme.getTextTertiary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, BmsProvider provider, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.getPrimary(context).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bluetooth_disabled_rounded,
              size: 28,
              color: AppTheme.getTextTertiary(context),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noDevicesFound,
            style: AppTheme.headlineStyle(context),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.makeSureBmsPowered,
            textAlign: TextAlign.center,
            style: AppTheme.bodyStyle(context).copyWith(
              color: AppTheme.getTextTertiary(context),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: provider.startScan,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: AppTheme.getPrimary(context),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                l10n.retryScan,
                style: AppTheme.bodyStyle(context).copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(
    BuildContext context,
    BmsProvider provider,
    ScanResult result,
    AppLocalizations l10n,
  ) {
    final device = result.device;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: provider.isConnecting
            ? null
            : () async {
                provider.stopScan();
                await provider.connectToDevice(device);
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DashboardScreen(),
                    ),
                  );
                }
              },
        child: GlassContainer(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.getPrimary(context).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.bluetooth_rounded,
                  size: 22,
                  color: AppTheme.getPrimary(context),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.platformName.isNotEmpty
                          ? device.platformName
                          : l10n.unknownDevice,
                      style: AppTheme.headlineStyle(context),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      device.remoteId.toString(),
                      style: AppTheme.labelStyle(context).copyWith(
                        fontSize: 12,
                        color: AppTheme.getTextTertiary(context),
                      ),
                    ),
                  ],
                ),
              ),
              if (provider.isConnecting)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: AppTheme.getPrimary(context),
                  ),
                )
              else
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.getTextTertiary(context),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
