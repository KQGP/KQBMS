import 'dart:async';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../providers/bms_provider.dart';
import '../../providers/settings_provider.dart';
import '../theme.dart';
import 'scan_screen.dart';
import 'dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.5)),
    );
    _scaleAnim = Tween(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.5, curve: Curves.easeOutCubic),
      ),
    );
    _glowAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.7, curve: Curves.easeInOut),
      ),
    );
    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initAppFlow();
    });

    _controller.forward();
  }

  Future<void> _initAppFlow() async {
    final bmsProvider = context.read<BmsProvider>();
    final settingsProvider = context.read<SettingsProvider>();

    await settingsProvider.load();

    await bmsProvider.initializeBluetooth();

    final lastId = settingsProvider.lastDeviceId;
    bool autoConnected = false;

    if (lastId != null && settingsProvider.autoReconnect) {
      autoConnected = await bmsProvider.autoConnect(lastId);
    }

    if (!mounted) return;

    await Future.delayed(const Duration(milliseconds: 1000));

    if (autoConnected) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, _, _) => const ScanScreen(),
          transitionsBuilder: (_, animation, _, child) {
            return FadeTransition(
              opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              child: child,
            );
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppTheme.getBackground(context),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnim.value,
            child: Transform.scale(
              scale: _scaleAnim.value,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Opacity(
                          opacity: _glowAnim.value * 0.3,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppTheme.getPrimary(context).withValues(alpha: 0.4),
                                  AppTheme.getPrimary(context).withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: AppTheme.getPrimary(context).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.getPrimary(context).withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            Icons.battery_charging_full_rounded,
                            size: 36,
                            color: AppTheme.getPrimary(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.appTitle,
                      style: AppTheme.largeTitleStyle(context).copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.batteryMonitor,
                      style: AppTheme.labelStyle(context).copyWith(
                        color: AppTheme.getTextTertiary(context),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
