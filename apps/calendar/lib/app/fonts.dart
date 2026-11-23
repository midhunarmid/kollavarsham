import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Font family of the bundled Noto Sans Malayalam font.
const appFontFamily = 'NotoSansMalayalam';

/// Adds the bundled fonts' licences to the licence page: the SIL Open
/// Font License (Noto Sans Malayalam) and Apache 2.0 (Roboto).
void registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    final ofl = await rootBundle.loadString('assets/fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(const ['Noto Sans Malayalam'], ofl);
    final apache =
        await rootBundle.loadString('assets/fonts/Roboto-LICENSE.txt');
    yield LicenseEntryWithLineBreaks(const ['Roboto'], apache);
  });
}
