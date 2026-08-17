import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/bms_provider.dart';
import '../../providers/settings_provider.dart';
import '../theme.dart';
import '../widgets/glass_container.dart';
import 'package:provider/provider.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppTheme.getBackground(context),
      body: SafeArea(
        child: Consumer2<BmsProvider, SettingsProvider>(
          builder: (context, provider, settings, child) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 24),
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
                      Text(l10n.about, style: AppTheme.title2Style(context)),
                    ]),
                  ),

                  Expanded(
                    child: ListView(
                      children: [
                        const SizedBox(height: 20),
                        Center(
                          child: Container(
                            width: 72, height: 72,
                            decoration: BoxDecoration(
                              color: AppTheme.getPrimary(context).withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.getPrimary(context).withValues(alpha: 0.3), width: 1.5),
                            ),
                            child: Icon(Icons.battery_charging_full_rounded, size: 36, color: AppTheme.getPrimary(context)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(child: Text(l10n.appTitle, style: AppTheme.largeTitleStyle(context))),
                        const SizedBox(height: 4),
                        Center(child: Text(l10n.appDescriptionSubtitle, style: AppTheme.labelStyle(context).copyWith(color: AppTheme.getTextTertiary(context)))),
                        const SizedBox(height: 24),

                        GlassContainer(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppTheme.getPrimary(context).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                              ),
                                child: Icon(
                                  Icons.favorite_rounded,
                                  size: 18,
                                  color: AppTheme.getPrimary(context),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.developedBy,
                                      style: AppTheme.labelStyle(context).copyWith(fontSize: 11),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      l10n.userName,
                                      style: AppTheme.headlineStyle(context).copyWith(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        GlassContainer(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.description,
                                style: AppTheme.labelStyle(context).copyWith(
                                  fontSize: 11,
                                  letterSpacing: 1.0,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.getTextTertiary(context),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                l10n.longDescription,
                                style: AppTheme.bodyStyle(context).copyWith(
                                  color: AppTheme.getTextSecondary(context),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
