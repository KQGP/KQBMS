import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kqbms/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'package:kqbms/providers/bms_provider.dart';
import 'package:kqbms/providers/settings_provider.dart';
import 'package:kqbms/ui/screens/about_screen.dart';

void main() {
  testWidgets('about screen shows app branding and license list', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => BmsProvider()),
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            Locale('en'),
            Locale('ar'),
          ],
          home: AboutScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('About'), findsOneWidget);
    expect(find.text('KQBMS'), findsOneWidget);
    expect(find.text('Khalil Anes Alqisy'), findsOneWidget);
  });
}