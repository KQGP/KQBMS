// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'KQBMS';

  @override
  String get userName => 'خليل أنيس القيسي';

  @override
  String get about => 'حول';

  @override
  String get appDescriptionSubtitle => 'مرافق Jiabaida BMS';

  @override
  String get developedBy => 'تطوير';

  @override
  String get description => 'الوصف';

  @override
  String get longDescription =>
      'KQBMS هو تطبيق مرافق متعدد المنصات لأنظمة إدارة البطاريات Jiabaida (JBD). يتصل عبر Bluetooth Low Energy لعرض بيانات البطارية في الوقت الفعلي، والتحكم في ترانزستورات MOSFET للشحن/التفريغ، ومراقبة حالة الخلايا.';

  @override
  String get openSourceLicenses => 'تراخيص المصادر المفتوحة';

  @override
  String get batteryMonitor => 'مراقب البطارية';

  @override
  String get discoverDevices => 'اكتشاف الأجهزة';

  @override
  String get stop => 'إيقاف';

  @override
  String get scan => 'فحص';

  @override
  String get scanningForDevices => 'البحث عن أجهزة BMS...';

  @override
  String get noDevicesFound => 'لم يتم العثور على أجهزة';

  @override
  String get makeSureBmsPowered => 'تأكد من تشغيل الـ BMS\nوأنه في النطاق';

  @override
  String get retryScan => 'إعادة الفحص';

  @override
  String get unknownDevice => 'جهاز غير معروف';

  @override
  String get voltage => 'الجهد';

  @override
  String get current => 'التيار';

  @override
  String get cycles => 'الدورات';

  @override
  String get capacity => 'السعة';

  @override
  String get temp => 'الحرارة';

  @override
  String get charge => 'الشحن';

  @override
  String get discharge => 'التفريغ';

  @override
  String get timeToFull => 'الوقت حتى الامتلاء';

  @override
  String get timeRemaining => 'الوقت المتبقي';

  @override
  String get interface => 'الواجهة';

  @override
  String get device => 'الجهاز';

  @override
  String get settings => 'الإعدادات';

  @override
  String get system => 'النظام';

  @override
  String get light => 'فاتح';

  @override
  String get dark => 'داكن';

  @override
  String get temperature => 'درجة الحرارة';

  @override
  String get refreshInterval => 'فترة التحديث';

  @override
  String get autoReconnect => 'إعادة الاتصال التلقائية';

  @override
  String get details => 'التفاصيل';

  @override
  String get cells => 'الخلايا';

  @override
  String get status => 'الحالة';

  @override
  String get params => 'المعلمات';

  @override
  String get max => 'الأقصى';

  @override
  String get min => 'الأدنى';

  @override
  String get diff => 'الفرق';

  @override
  String get avg => 'المعدل';

  @override
  String get balancing => 'الموازنة';

  @override
  String get mosfetStatus => 'حالة MOSFET';

  @override
  String get protections => 'الحمايات';

  @override
  String get balanceStatus => 'حالة الموازنة';

  @override
  String get balancingCells => 'خلايا الموازنة';

  @override
  String get none => 'لا يوجد';

  @override
  String get balanceCurrent => 'تيار الموازنة';

  @override
  String get noData => 'لا توجد بيانات';

  @override
  String get noActiveProtections => 'لا توجد حمايات نشطة';

  @override
  String get battery => 'البطارية';

  @override
  String get nominalCapacity => 'السعة الاسمية';

  @override
  String get remaining => 'المتبقي';

  @override
  String get learnedCapacity => 'السعة المتعلمة';

  @override
  String get soc => 'مستوى الشحن';

  @override
  String get cycleCount => 'عدد الدورات';

  @override
  String get productionDate => 'تاريخ الإنتاج';

  @override
  String get electrical => 'الكهرباء';

  @override
  String get packVoltage => 'جهد الحزمة';

  @override
  String get packCurrent => 'تيار الحزمة';

  @override
  String get power => 'القدرة';

  @override
  String get cellCount => 'عدد الخلايا';

  @override
  String get ntcCount => 'عدد الحساسات';

  @override
  String get identity => 'الهوية';

  @override
  String get software => 'البرنامج';

  @override
  String get hardware => 'المكونات';

  @override
  String get serialNumberShort => 'الرقم التسلسلي';

  @override
  String get barcode => 'الباركود';

  @override
  String get manufacturer => 'المصنع';

  @override
  String get batteryModel => 'موديل البطارية';

  @override
  String get bmsModel => 'موديل BMS';

  @override
  String get bmsAddress => 'عنوان BMS';

  @override
  String get ratings => 'التقييمات';

  @override
  String get ratedCharge => 'الشحن المقدر';

  @override
  String get ratedDischarge => 'التفريغ المقدر';

  @override
  String get ratedPower => 'القدرة المقدرة';

  @override
  String get malfunctions => 'الأعطال';

  @override
  String get allSystemsNormal => 'جميع الأنظمة طبيعية';

  @override
  String get noMalfunctionsDetected =>
      'لم يتم اكتشاف أعطال أو أخطاء في الحساسات.';

  @override
  String get cellOvp => 'جهد خلية مرتفع';

  @override
  String get cellUvp => 'جهد خلية منخفض';

  @override
  String get packOvp => 'جهد حزمة مرتفع';

  @override
  String get packUvp => 'جهد حزمة منخفض';

  @override
  String get chargeOtp => 'حرارة شحن مرتفعة';

  @override
  String get chargeUtp => 'حرارة شحن منخفضة';

  @override
  String get dischOtp => 'حرارة تفريغ مرتفعة';

  @override
  String get dischUtp => 'حرارة تفريغ منخفضة';

  @override
  String get chargeOcp => 'تيار شحن زائد';

  @override
  String get dischOcp => 'تيار تفريغ زائد';

  @override
  String get shortCkt => 'دائرة قصر';

  @override
  String get icError => 'خطأ في IC';

  @override
  String get mosLock => 'قفل MOS';

  @override
  String get overTemperature => 'حرارة زائدة';

  @override
  String get sensorFault => 'عطل في الحساس';

  @override
  String get noReading => 'لا توجد قراءة';

  @override
  String get bluetooth => 'بلوتوث';

  @override
  String get wifi => 'واي فاي';

  @override
  String get wifiBridge => 'جسر KQBMS اللاسلكي';

  @override
  String get wifiBridgeSubtitle => 'اتصل بنظام البطارية عبر جسر ESP32';

  @override
  String get bridgeAddress => 'عنوان الجسر';

  @override
  String get bridgeAddressHint => 'kqbms-bridge.local أو عنوان IP';

  @override
  String get portLabel => 'المنفذ';

  @override
  String get autoDiscover => 'بحث تلقائي';

  @override
  String get bridgeFound => 'تم العثور على الجسر';

  @override
  String get bridgeNotFound => 'لم يتم العثور على الجسر في هذه الشبكة';

  @override
  String get connect => 'اتصال';

  @override
  String get connecting => 'جارٍ الاتصال...';

  @override
  String get connectionFailed => 'فشل الاتصال';

  @override
  String get enterBridgeAddress => 'أدخل عنوان الجسر';
}
