import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'KQBMS'**
  String get appTitle;

  /// The name of the user
  ///
  /// In en, this message translates to:
  /// **'Khalil Anes Alqisy'**
  String get userName;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @appDescriptionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Jiabaida BMS Companion'**
  String get appDescriptionSubtitle;

  /// No description provided for @developedBy.
  ///
  /// In en, this message translates to:
  /// **'Developed by'**
  String get developedBy;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @longDescription.
  ///
  /// In en, this message translates to:
  /// **'KQBMS is a cross-platform companion app for Jiabaida (JBD) Battery Management Systems. It connects over Bluetooth Low Energy to display real-time battery telemetry, control charge/discharge MOSFETs, and monitor cell status.'**
  String get longDescription;

  /// No description provided for @openSourceLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open Source Licenses'**
  String get openSourceLicenses;

  /// No description provided for @batteryMonitor.
  ///
  /// In en, this message translates to:
  /// **'Battery Monitor'**
  String get batteryMonitor;

  /// No description provided for @discoverDevices.
  ///
  /// In en, this message translates to:
  /// **'Discover Devices'**
  String get discoverDevices;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// No description provided for @scanningForDevices.
  ///
  /// In en, this message translates to:
  /// **'Scanning for BMS devices...'**
  String get scanningForDevices;

  /// No description provided for @noDevicesFound.
  ///
  /// In en, this message translates to:
  /// **'No devices found'**
  String get noDevicesFound;

  /// No description provided for @makeSureBmsPowered.
  ///
  /// In en, this message translates to:
  /// **'Make sure your BMS is powered on\nand in range'**
  String get makeSureBmsPowered;

  /// No description provided for @retryScan.
  ///
  /// In en, this message translates to:
  /// **'Retry Scan'**
  String get retryScan;

  /// No description provided for @unknownDevice.
  ///
  /// In en, this message translates to:
  /// **'Unknown Device'**
  String get unknownDevice;

  /// No description provided for @voltage.
  ///
  /// In en, this message translates to:
  /// **'Voltage'**
  String get voltage;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// No description provided for @cycles.
  ///
  /// In en, this message translates to:
  /// **'Cycles'**
  String get cycles;

  /// No description provided for @capacity.
  ///
  /// In en, this message translates to:
  /// **'Capacity'**
  String get capacity;

  /// No description provided for @temp.
  ///
  /// In en, this message translates to:
  /// **'Temp'**
  String get temp;

  /// No description provided for @charge.
  ///
  /// In en, this message translates to:
  /// **'Charge'**
  String get charge;

  /// No description provided for @discharge.
  ///
  /// In en, this message translates to:
  /// **'Discharge'**
  String get discharge;

  /// No description provided for @timeToFull.
  ///
  /// In en, this message translates to:
  /// **'Time to full'**
  String get timeToFull;

  /// No description provided for @timeRemaining.
  ///
  /// In en, this message translates to:
  /// **'Time remaining'**
  String get timeRemaining;

  /// No description provided for @interface.
  ///
  /// In en, this message translates to:
  /// **'Interface'**
  String get interface;

  /// No description provided for @device.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get device;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @refreshInterval.
  ///
  /// In en, this message translates to:
  /// **'Refresh Interval'**
  String get refreshInterval;

  /// No description provided for @autoReconnect.
  ///
  /// In en, this message translates to:
  /// **'Auto Reconnect'**
  String get autoReconnect;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @cells.
  ///
  /// In en, this message translates to:
  /// **'Cells'**
  String get cells;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @params.
  ///
  /// In en, this message translates to:
  /// **'Params'**
  String get params;

  /// No description provided for @max.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get max;

  /// No description provided for @min.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get min;

  /// No description provided for @diff.
  ///
  /// In en, this message translates to:
  /// **'Diff'**
  String get diff;

  /// No description provided for @avg.
  ///
  /// In en, this message translates to:
  /// **'Avg'**
  String get avg;

  /// No description provided for @balancing.
  ///
  /// In en, this message translates to:
  /// **'Balancing'**
  String get balancing;

  /// No description provided for @mosfetStatus.
  ///
  /// In en, this message translates to:
  /// **'MOSFET Status'**
  String get mosfetStatus;

  /// No description provided for @protections.
  ///
  /// In en, this message translates to:
  /// **'Protections'**
  String get protections;

  /// No description provided for @balanceStatus.
  ///
  /// In en, this message translates to:
  /// **'Balance Status'**
  String get balanceStatus;

  /// No description provided for @balancingCells.
  ///
  /// In en, this message translates to:
  /// **'Balancing cells'**
  String get balancingCells;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'none'**
  String get none;

  /// No description provided for @balanceCurrent.
  ///
  /// In en, this message translates to:
  /// **'Balance current'**
  String get balanceCurrent;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @noActiveProtections.
  ///
  /// In en, this message translates to:
  /// **'No active protections'**
  String get noActiveProtections;

  /// No description provided for @battery.
  ///
  /// In en, this message translates to:
  /// **'Battery'**
  String get battery;

  /// No description provided for @nominalCapacity.
  ///
  /// In en, this message translates to:
  /// **'Nominal Capacity'**
  String get nominalCapacity;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @learnedCapacity.
  ///
  /// In en, this message translates to:
  /// **'Learned Capacity'**
  String get learnedCapacity;

  /// No description provided for @soc.
  ///
  /// In en, this message translates to:
  /// **'SOC'**
  String get soc;

  /// No description provided for @cycleCount.
  ///
  /// In en, this message translates to:
  /// **'Cycle Count'**
  String get cycleCount;

  /// No description provided for @productionDate.
  ///
  /// In en, this message translates to:
  /// **'Production Date'**
  String get productionDate;

  /// No description provided for @electrical.
  ///
  /// In en, this message translates to:
  /// **'Electrical'**
  String get electrical;

  /// No description provided for @packVoltage.
  ///
  /// In en, this message translates to:
  /// **'Pack Voltage'**
  String get packVoltage;

  /// No description provided for @packCurrent.
  ///
  /// In en, this message translates to:
  /// **'Pack Current'**
  String get packCurrent;

  /// No description provided for @power.
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get power;

  /// No description provided for @cellCount.
  ///
  /// In en, this message translates to:
  /// **'Cell Count'**
  String get cellCount;

  /// No description provided for @ntcCount.
  ///
  /// In en, this message translates to:
  /// **'NTC Count'**
  String get ntcCount;

  /// No description provided for @identity.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get identity;

  /// No description provided for @software.
  ///
  /// In en, this message translates to:
  /// **'Software'**
  String get software;

  /// No description provided for @hardware.
  ///
  /// In en, this message translates to:
  /// **'Hardware'**
  String get hardware;

  /// No description provided for @serialNumberShort.
  ///
  /// In en, this message translates to:
  /// **'Serial #'**
  String get serialNumberShort;

  /// No description provided for @barcode.
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get barcode;

  /// No description provided for @manufacturer.
  ///
  /// In en, this message translates to:
  /// **'Manufacturer'**
  String get manufacturer;

  /// No description provided for @batteryModel.
  ///
  /// In en, this message translates to:
  /// **'Battery Model'**
  String get batteryModel;

  /// No description provided for @bmsModel.
  ///
  /// In en, this message translates to:
  /// **'BMS Model'**
  String get bmsModel;

  /// No description provided for @bmsAddress.
  ///
  /// In en, this message translates to:
  /// **'BMS Address'**
  String get bmsAddress;

  /// No description provided for @ratings.
  ///
  /// In en, this message translates to:
  /// **'Ratings'**
  String get ratings;

  /// No description provided for @ratedCharge.
  ///
  /// In en, this message translates to:
  /// **'Rated Charge'**
  String get ratedCharge;

  /// No description provided for @ratedDischarge.
  ///
  /// In en, this message translates to:
  /// **'Rated Discharge'**
  String get ratedDischarge;

  /// No description provided for @ratedPower.
  ///
  /// In en, this message translates to:
  /// **'Rated Power'**
  String get ratedPower;

  /// No description provided for @malfunctions.
  ///
  /// In en, this message translates to:
  /// **'Malfunctions'**
  String get malfunctions;

  /// No description provided for @allSystemsNormal.
  ///
  /// In en, this message translates to:
  /// **'All systems normal'**
  String get allSystemsNormal;

  /// No description provided for @noMalfunctionsDetected.
  ///
  /// In en, this message translates to:
  /// **'No malfunctions or sensor faults detected.'**
  String get noMalfunctionsDetected;

  /// No description provided for @cellOvp.
  ///
  /// In en, this message translates to:
  /// **'Cell OVP'**
  String get cellOvp;

  /// No description provided for @cellUvp.
  ///
  /// In en, this message translates to:
  /// **'Cell UVP'**
  String get cellUvp;

  /// No description provided for @packOvp.
  ///
  /// In en, this message translates to:
  /// **'Pack OVP'**
  String get packOvp;

  /// No description provided for @packUvp.
  ///
  /// In en, this message translates to:
  /// **'Pack UVP'**
  String get packUvp;

  /// No description provided for @chargeOtp.
  ///
  /// In en, this message translates to:
  /// **'Charge OTP'**
  String get chargeOtp;

  /// No description provided for @chargeUtp.
  ///
  /// In en, this message translates to:
  /// **'Charge UTP'**
  String get chargeUtp;

  /// No description provided for @dischOtp.
  ///
  /// In en, this message translates to:
  /// **'Disch OTP'**
  String get dischOtp;

  /// No description provided for @dischUtp.
  ///
  /// In en, this message translates to:
  /// **'Disch UTP'**
  String get dischUtp;

  /// No description provided for @chargeOcp.
  ///
  /// In en, this message translates to:
  /// **'Charge OCP'**
  String get chargeOcp;

  /// No description provided for @dischOcp.
  ///
  /// In en, this message translates to:
  /// **'Disch OCP'**
  String get dischOcp;

  /// No description provided for @shortCkt.
  ///
  /// In en, this message translates to:
  /// **'Short Ckt'**
  String get shortCkt;

  /// No description provided for @icError.
  ///
  /// In en, this message translates to:
  /// **'IC Error'**
  String get icError;

  /// No description provided for @mosLock.
  ///
  /// In en, this message translates to:
  /// **'MOS Lock'**
  String get mosLock;

  /// No description provided for @overTemperature.
  ///
  /// In en, this message translates to:
  /// **'over temperature'**
  String get overTemperature;

  /// No description provided for @sensorFault.
  ///
  /// In en, this message translates to:
  /// **'sensor fault'**
  String get sensorFault;

  /// No description provided for @noReading.
  ///
  /// In en, this message translates to:
  /// **'no reading'**
  String get noReading;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
