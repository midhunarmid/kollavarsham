import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Font family of the bundled Noto Sans Malayalam font.
const appFontFamily = 'NotoSansMalayalam';

/// Adds the bundled font's SIL Open Font License to the licence page.
void registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    final text = await rootBundle.loadString('assets/fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(const ['Noto Sans Malayalam'], text);
  });
}
