import 'package:calendar/app/locations.dart';
import 'package:calendar_data/calendar_data.dart' as data;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the site offers the app\'s Kerala cities, with the same coordinates',
      () {
    final kerala = data.places.where((p) => p.kerala).toList();
    expect(kerala.map((p) => p.id), keralaCities.map((c) => c.id));
    for (final (i, city) in keralaCities.indexed) {
      final place = kerala[i];
      expect(place.nameMl, city.nameMl, reason: city.id);
      expect(place.nameEn, city.nameEn, reason: city.id);
      expect(place.latitude, city.location.latitude, reason: city.id);
      expect(place.longitude, city.location.longitude, reason: city.id);
      expect(place.timeZone, 'Asia/Kolkata', reason: city.id);
      expect(city.location.utcOffset, const Duration(hours: 5, minutes: 30));
    }
    expect(data.places.first.id, data.defaultPlaceId);
  });
}
