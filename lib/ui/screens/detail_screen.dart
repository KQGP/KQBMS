import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/bms_provider.dart';
import '../../providers/settings_provider.dart';
import '../../models/bms_data.dart';
import '../../l10n/app_localizations.dart';
import '../theme.dart';
import '../widgets/glass_container.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppTheme.getBackground(context),
      body: SafeArea(
        child: Consumer<BmsProvider>(
          builder: (context, provider, child) {
            return DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  _buildHeader(context, l10n),
                  _buildTabBar(context, l10n),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildCellsTab(context, provider, l10n),
                        _buildStatusTab(context, provider, l10n),
                        _buildParametersTab(context, provider, l10n),
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

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
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
          Text(l10n.details, style: AppTheme.title2Style(context)),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppTheme.getGlassColor(context).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        indicator: BoxDecoration(
          color: AppTheme.getPrimary(context).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(14),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: AppTheme.getPrimary(context),
        unselectedLabelColor: AppTheme.getTextTertiary(context),
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        tabs: [
          Tab(text: l10n.cells),
          Tab(text: l10n.status),
          Tab(text: l10n.params),
        ],
      ),
    );
  }

  Widget _buildCellsTab(BuildContext context, BmsProvider provider, AppLocalizations l10n) {
    final cells = provider.cellVoltages;
    final info = provider.baseInfo;
    final balancing = info?.balancingCells ?? [];

    double maxV = 0, minV = 0, diff = 0, avg = 0;
    if (cells != null && cells.voltages.isNotEmpty) {
      maxV = cells.voltages.reduce((a, b) => a > b ? a : b);
      minV = cells.voltages.reduce((a, b) => a < b ? a : b);
      diff = maxV - minV;
      avg = cells.voltages.fold(0.0, (p, c) => p + c) / cells.voltages.length;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          GlassContainer(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _cellStat(context, l10n.max, maxV > 0 ? maxV.toStringAsFixed(3) : "--", "V", AppTheme.getError(context)),
                _cellStat(context, l10n.min, minV > 0 ? minV.toStringAsFixed(3) : "--", "V", AppTheme.getPrimary(context)),
                _cellStat(context, l10n.diff, cells != null ? (diff * 1000).toStringAsFixed(0) : "--", "mV",
                    diff > 0.02 ? AppTheme.getWarning(context) : AppTheme.getSuccess(context)),
                _cellStat(context, l10n.avg, avg > 0 ? avg.toStringAsFixed(3) : "--", "V", AppTheme.getTextPrimary(context)),
              ],
            ),
          ),
          const SizedBox(height: 10),

          if (balancing.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GlassContainer(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                child: Row(
                  children: [
                    Icon(Icons.balance_rounded, size: 16, color: AppTheme.getWarning(context)),
                    const SizedBox(width: 8),
                    Text("${l10n.balancing}: #${balancing.join(', #')}",
                        style: AppTheme.labelStyle(context).copyWith(color: AppTheme.getWarning(context))),
                  ],
                ),
              ),
            ),

          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.85,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: math.max(4, cells?.voltages.length ?? 0),
              itemBuilder: (context, index) {
                if (cells != null && index < cells.voltages.length) {
                  final voltage = cells.voltages[index];
                  final isBalancing = balancing.contains(index + 1);
                  Color barColor = AppTheme.getSuccess(context);
                  if (voltage < 3.0) {
                    barColor = AppTheme.getError(context);
                  } else if (voltage > 4.15) {
                    barColor = AppTheme.getWarning(context);
                  }
                  double normalized = ((voltage - 2.8) / (4.2 - 2.8)).clamp(0.0, 1.0);

                  return GlassContainer(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text("#${index + 1}", style: AppTheme.labelStyle(context).copyWith(fontSize: 12)),
                          Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(
                              color: isBalancing ? AppTheme.getWarning(context) : barColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ]),
                        Center(
                          child: Text(voltage.toStringAsFixed(3),
                              style: AppTheme.headlineStyle(context).copyWith(fontSize: 18, fontWeight: FontWeight.w600)),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: normalized,
                            backgroundColor: AppTheme.isDark(context) ? Colors.white24 : Colors.black12,
                            valueColor: AlwaysStoppedAnimation(barColor),
                            minHeight: 4,
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return GlassContainer(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text("#${index + 1}", style: AppTheme.labelStyle(context).copyWith(fontSize: 12, color: Colors.white38)),
                          Container(width: 8, height: 8,
                              decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle)),
                        ]),
                        Center(child: Text("--", style: AppTheme.headlineStyle(context).copyWith(fontSize: 18, color: Colors.white30))),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(value: 0,
                              backgroundColor: AppTheme.isDark(context) ? Colors.white24 : Colors.black12, minHeight: 4),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _cellStat(BuildContext context, String label, String value, String unit, Color color) {
    return Column(children: [
      Text(label, style: AppTheme.labelStyle(context)),
      const SizedBox(height: 4),
      Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
        Text(value, style: AppTheme.title2Style(context).copyWith(color: color, fontSize: 18)),
        const SizedBox(width: 2),
        Text(unit, style: AppTheme.labelStyle(context).copyWith(fontSize: 12)),
      ]),
    ]);
  }

  Widget _buildStatusTab(BuildContext context, BmsProvider provider, AppLocalizations l10n) {
    final info = provider.baseInfo;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ListView(
        children: [
          _sectionHeader(context, l10n.mosfetStatus),
          const SizedBox(height: 8),
          GlassContainer(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(children: [
              _statusChip(context, l10n.charge, info?.isCharging ?? false, AppTheme.getSuccess(context)),
              const SizedBox(width: 16),
              _statusChip(context, l10n.discharge, info?.isDischarging ?? false, AppTheme.getPrimary(context)),
            ]),
          ),
          const SizedBox(height: 20),

          _sectionHeader(context, l10n.temperature),
          const SizedBox(height: 8),
          GlassContainer(
            padding: const EdgeInsets.all(14),
            child: Wrap(
              spacing: 8, runSpacing: 8,
              children: _buildTempChips(context, info, l10n),
            ),
          ),
          const SizedBox(height: 20),

          _sectionHeader(context, l10n.protections),
          const SizedBox(height: 8),
          GlassContainer(
            padding: const EdgeInsets.all(14),
            child: _buildProtectionFlags(context, info, l10n),
          ),
          const SizedBox(height: 20),

          _sectionHeader(context, l10n.balanceStatus),
          const SizedBox(height: 8),
          GlassContainer(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${l10n.balancingCells}: #${info?.balancingCells.join(', #') ?? l10n.none}",
                    style: AppTheme.bodyStyle(context)),
                if (info?.balanceCurrent != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text("${l10n.balanceCurrent}: ${info!.balanceCurrent!.toStringAsFixed(1)} mA",
                        style: AppTheme.labelStyle(context)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _statusChip(BuildContext context, String label, bool on, Color color) {
    return Expanded(
      child: Row(children: [
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(color: on ? color : AppTheme.getTextTertiary(context), shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: AppTheme.bodyStyle(context).copyWith(
            color: on ? AppTheme.getTextPrimary(context) : AppTheme.getTextTertiary(context))),
      ]),
    );
  }

  List<Widget> _buildTempChips(BuildContext context, BmsBaseInfo? info, AppLocalizations l10n) {
    if (info == null || info.temperatures.isEmpty) {
      return [Text(l10n.noData, style: AppTheme.labelStyle(context))];
    }
    final settings = context.read<SettingsProvider>();
    return List.generate(info.temperatures.length, (i) {
      final temp = info.temperatures[i];
      final label = i == 0 ? "MOS" : "NTC$i";
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _tempColor(context, temp).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text("$label ${settings.formatTemp(temp)}",
            style: AppTheme.bodyStyle(context).copyWith(
                fontSize: 13, color: _tempColor(context, temp), fontWeight: FontWeight.w600)),
      );
    });
  }

  Color _tempColor(BuildContext context, double temp) {
    if (temp > 60) return AppTheme.getError(context);
    if (temp > 50) return AppTheme.getWarning(context);
    return AppTheme.getSuccess(context);
  }

  Widget _buildProtectionFlags(BuildContext context, BmsBaseInfo? info, AppLocalizations l10n) {
    if (info == null) {
      return Text(l10n.noData, style: AppTheme.labelStyle(context));
    }
    final activeFlags = info.activeProtections;
    if (activeFlags.isEmpty) {
      return Row(children: [
        Icon(Icons.check_circle_rounded, size: 16, color: AppTheme.getSuccess(context)),
        const SizedBox(width: 8),
        Text(l10n.noActiveProtections, style: AppTheme.bodyStyle(context).copyWith(color: AppTheme.getSuccess(context))),
      ]);
    }
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: activeFlags.map((f) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.getError(context).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(_translateToken(l10n, f), style: AppTheme.bodyStyle(context).copyWith(
            fontSize: 13, color: AppTheme.getError(context), fontWeight: FontWeight.w600)),
      )).toList(),
    );
  }

  String _translateToken(AppLocalizations l10n, BmsMalfunction item) {
    switch (item.token) {
      case "cellOvp": return l10n.cellOvp;
      case "cellUvp": return l10n.cellUvp;
      case "packOvp": return l10n.packOvp;
      case "packUvp": return l10n.packUvp;
      case "chargeOtp": return l10n.chargeOtp;
      case "chargeUtp": return l10n.chargeUtp;
      case "dischOtp": return l10n.dischOtp;
      case "dischUtp": return l10n.dischUtp;
      case "chargeOcp": return l10n.chargeOcp;
      case "dischOcp": return l10n.dischOcp;
      case "shortCkt": return l10n.shortCkt;
      case "icError": return l10n.icError;
      case "mosLock": return l10n.mosLock;
      case "overTemperature": return l10n.overTemperature;
      case "sensorFault": return l10n.sensorFault;
      case "noReading": return l10n.noReading;
      default: return item.token;
    }
  }

  Widget _buildParametersTab(BuildContext context, BmsProvider provider, AppLocalizations l10n) {
    final info = provider.baseInfo;
    final hw = provider.hardwareVersion;
    final di = provider.deviceInfo;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ListView(
        children: [
          _sectionHeader(context, l10n.battery),
          const SizedBox(height: 8),
          _paramCard(context, [
            _paramRow(context, l10n.nominalCapacity, info != null ? "${info.nominalCapacity.toStringAsFixed(1)} Ah" : "--"),
            _paramRow(context, l10n.remaining, info != null ? "${info.remainingCapacity.toStringAsFixed(2)} Ah" : "--"),
            if (info?.learnCapacity != null)
              _paramRow(context, l10n.learnedCapacity, "${info!.learnCapacity!.toStringAsFixed(1)} Ah"),
            _paramRow(context, l10n.soc, info != null ? "${info.rsoc}%" : "--"),
            _paramRow(context, l10n.cycleCount, info != null ? "${info.cycleCount}" : "--"),
            _paramRow(context, l10n.productionDate, info?.productionDate.isNotEmpty == true ? info!.productionDate : "--"),
          ]),
          const SizedBox(height: 16),

          _sectionHeader(context, l10n.electrical),
          const SizedBox(height: 8),
          _paramCard(context, [
            _paramRow(context, l10n.packVoltage, info != null ? "${info.totalVoltage.toStringAsFixed(2)} V" : "--"),
            _paramRow(context, l10n.packCurrent, info != null ? "${info.current.toStringAsFixed(2)} A" : "--"),
            _paramRow(context, l10n.power, info != null ? "${(info.current.abs() * info.totalVoltage).toStringAsFixed(0)} W" : "--"),
            _paramRow(context, l10n.cellCount, info != null ? "${info.cellCount}" : "--"),
            _paramRow(context, l10n.ntcCount, info != null ? "${info.ntcCount}" : "--"),
          ]),
          const SizedBox(height: 16),

          _sectionHeader(context, l10n.identity),
          const SizedBox(height: 8),
          _paramCard(context, [
            _paramRow(context, l10n.software, info?.softwareVersion ?? "--"),
            _paramRow(context, l10n.hardware, hw?.version ?? "--"),
            if (di.serialNumber.isNotEmpty)
              _paramRow(context, l10n.serialNumberShort, di.serialNumber),
            if (di.barcode.isNotEmpty)
              _paramRow(context, l10n.barcode, di.barcode),
            if (di.manufacturer.isNotEmpty)
              _paramRow(context, l10n.manufacturer, di.manufacturer),
            if (di.batteryModel.isNotEmpty)
              _paramRow(context, l10n.batteryModel, di.batteryModel),
            if (di.bmsModel.isNotEmpty)
              _paramRow(context, l10n.bmsModel, di.bmsModel),
            if (di.bmsAddress.isNotEmpty)
              _paramRow(context, l10n.bmsAddress, di.bmsAddress),
          ]),
          const SizedBox(height: 16),

          if (di.ratedChargeCurrent > 0 || di.ratedDischargeCurrent > 0) ...[
            _sectionHeader(context, l10n.ratings),
            const SizedBox(height: 8),
            _paramCard(context, [
              if (di.ratedChargeCurrent > 0)
                _paramRow(context, l10n.ratedCharge, "${di.ratedChargeCurrent.toStringAsFixed(1)} A"),
              if (di.ratedDischargeCurrent > 0)
                _paramRow(context, l10n.ratedDischarge, "${di.ratedDischargeCurrent.toStringAsFixed(1)} A"),
              if (di.ratedDischargePower > 0)
                _paramRow(context, l10n.ratedPower, "${di.ratedDischargePower.toStringAsFixed(0)} W"),
            ]),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(title.toUpperCase(), style: AppTheme.labelStyle(context).copyWith(
          fontSize: 13, letterSpacing: 1, fontWeight: FontWeight.w600)),
    );
  }

  Widget _paramCard(BuildContext context, List<Widget> rows) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Column(children: rows),
    );
  }

  Widget _paramRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: AppTheme.bodyStyle(context).copyWith(color: AppTheme.getTextSecondary(context))),
        Text(value, style: AppTheme.bodyStyle(context).copyWith(fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
