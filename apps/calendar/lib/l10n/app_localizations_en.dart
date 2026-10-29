// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Malayalam Calendar';

  @override
  String get today => 'Today';

  @override
  String get todayHeading => 'Today';

  @override
  String get festivals => 'Festivals';

  @override
  String get noFestivals => 'No festivals on this day';
}
