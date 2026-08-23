import 'dart:ui';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../providers/bms_provider.dart';
import '../../providers/settings_provider.dart';
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

  String _mode = 'ble';
  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  bool _connecting = false;
  bool _discovering = false;

  bool get _isBle => _mode == 'ble';

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
      final settings = context.read<SettingsProvider>();
      setState(() {
        _mode = settings.transportMode == 'wifi' ? 'wifi' : 'ble';
        _hostController.text = settings.wifiHost;
        _portController.text = settings.wifiPort.toString();
      });
      if (_isBle) {
        context.read<BmsProvider>().startScan();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _hostController.dispose();
    _portController.dispose();
    super.dispose();
  }

  void _switchMode(String mode) {
    if (_mode == mode || _connecting || _discovering) return;
    final provider = context.read<BmsProvider>();
    provider.stopScan();
    context.read<SettingsProvider>().setTransportMode(mode);
    setState(() => _mode = mode);
    if (mode == 'ble') {
      provider.startScan();
    }
  }

  Future<void> _discoverBridge() async {
    FocusScope.of(context).unfocus();
    final provider = context.read<BmsProvider>();
    setState(() => _discovering = true);
    try {
      final found = await provider.discoverBridge();
      if (!mounted) return;
      if (found != null) {
        setState(() {
          _hostController.text = found.key;
          _portController.text = found.value.toString();
        });
        _showSnack(_l10n.bridgeFound, success: true);
      } else {
        _showSnack(_l10n.bridgeNotFound, success: false);
      }
    } finally {
      if (mounted) setState(() => _discovering = false);
    }
  }

  Future<void> _connectWifi() async {
    FocusScope.of(context).unfocus();
    final host = _hostController.text.trim();
    if (host.isEmpty) {
      _showSnack(_l10n.enterBridgeAddress, success: false);
      return;
    }
    final port = int.tryParse(_portController.text.trim()) ?? 3333;

    final provider = context.read<BmsProvider>();
    setState(() => _connecting = true);
    try {
      await provider.connectToWifi(host: host, port: port);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } catch (e) {
      if (mounted) {
        _showSnack(_l10n.connectionFailed, success: false);
      }
    } finally {
      if (mounted) setState(() => _connecting = false);
    }
  }

  void _showSnack(String message, {required bool success}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success
            ? AppTheme.getSuccess(context)
            : AppTheme.getError(context),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

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
                    padding: const EdgeInsets.only(top: 12, bottom: 16),
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
                        if (_isBle) _buildScanButton(context, l10n),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildModeToggle(context, l10n),
                  ),

                  Expanded(
                    child: _isBle
                        ? _buildBluetoothPane(l10n)
                        : _buildWifiPane(context, l10n),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeToggle(BuildContext context, AppLocalizations l10n) {
    return SegmentedButton<String>(
      segments: [
        ButtonSegment(
          value: 'ble',
          icon: Icon(Icons.bluetooth_rounded, size: 18),
          label: Text(l10n.bluetooth),
        ),
        ButtonSegment(
          value: 'wifi',
          icon: Icon(Icons.wifi_rounded, size: 18),
          label: Text(l10n.wifi),
        ),
      ],
      selected: {_mode},
      onSelectionChanged: (selection) => _switchMode(selection.first),
      showSelectedIcon: false,
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor:
            AppTheme.getPrimary(context).withValues(alpha: 0.15),
        selectedForegroundColor: AppTheme.getPrimary(context),
        foregroundColor: AppTheme.getTextTertiary(context),
        side: BorderSide(color: AppTheme.getGlassBorder(context)),
      ),
    );
  }

  Widget _buildBluetoothPane(AppLocalizations l10n) {
    return Consumer<BmsProvider>(
      builder: (context, provider, child) {
        if (provider.scanResults.isEmpty && provider.isScanning) {
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
    );
  }

  Widget _buildWifiPane(BuildContext context, AppLocalizations l10n) {
    return ListView(
      children: [
        GlassContainer(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.getPrimary(context).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.router_rounded,
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
                          l10n.wifiBridge,
                          style: AppTheme.headlineStyle(context),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          l10n.wifiBridgeSubtitle,
                          style: AppTheme.labelStyle(context).copyWith(
                            fontSize: 12,
                            color: AppTheme.getTextTertiary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _hostController,
                keyboardType: TextInputType.url,
                enabled: !_connecting,
                textInputAction: TextInputAction.next,
                style: TextStyle(color: AppTheme.getTextPrimary(context)),
                decoration: _inputDecoration(
                  context,
                  l10n.bridgeAddress,
                  l10n.bridgeAddressHint,
                  Icons.dns_rounded,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _portController,
                keyboardType: TextInputType.number,
                enabled: !_connecting,
                style: TextStyle(color: AppTheme.getTextPrimary(context)),
                decoration: _inputDecoration(
                  context,
                  l10n.portLabel,
                  '3333',
                  Icons.settings_ethernet_rounded,
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _connecting || _discovering ? null : _discoverBridge,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          color: AppTheme.getGlassColor(context),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppTheme.getGlassBorder(context),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _discovering
                                ? SizedBox(
                                    width: 15,
                                    height: 15,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.8,
                                      color: AppTheme.getPrimary(context),
                                    ),
                                  )
                                : Icon(
                                    Icons.travel_explore_rounded,
                                    size: 17,
                                    color: AppTheme.getPrimary(context),
                                  ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.autoDiscover,
                              style: AppTheme.bodyStyle(context).copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              GestureDetector(
                onTap: _connecting || _discovering ? null : _connectWifi,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.getPrimary(context),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _connecting
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.8,
                                color: Colors.white,
                              ),
                            )
                          : Icon(Icons.wifi_rounded,
                              size: 18, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        _connecting ? l10n.connecting : l10n.connect,
                        style: AppTheme.bodyStyle(context).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context,
    String label,
    String hint,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, size: 19, color: AppTheme.getTextTertiary(context)),
      labelStyle: TextStyle(color: AppTheme.getTextSecondary(context)),
      hintStyle: TextStyle(color: AppTheme.getTextTertiary(context)),
      filled: true,
      fillColor: AppTheme.getGlassColor(context),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
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
