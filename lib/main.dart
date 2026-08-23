import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/bms_provider.dart';
import 'providers/settings_provider.dart';
import 'ui/theme.dart';
import 'ui/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KQBMS());
}

class KQBMS extends StatefulWidget {
  const KQBMS({super.key});

  @override
  State<KQBMS> createState() => _KQBMSState();
}

class _KQBMSState extends State<KQBMS> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()..load()),
        ChangeNotifierProxyProvider<SettingsProvider, BmsProvider>(
          create: (_) => BmsProvider(),
          update: (_, settings, bms) => bms!..updateSettings(settings),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
