/// Places offered by the website's place picker: the 14 Kerala district
/// headquarters (the same coordinates as the app's city list, checked by
/// the app's tests) and cities with large Malayali communities in India and
/// abroad.
///
/// Times abroad change with daylight saving, so each place carries an IANA
/// time zone and the browser works out the UTC offset for each date.
class Place {
  /// A place with its names, coordinates and time zone.
  const Place(this.id, this.nameMl, this.nameEn, this.latitude, this.longitude,
      this.timeZone,
      {this.kerala = false});

  /// Stable identifier, stored in the visitor's browser.
  final String id;

  /// Name in Malayalam script.
  final String nameMl;

  /// Name in English.
  final String nameEn;

  /// Degrees north.
  final double latitude;

  /// Degrees east.
  final double longitude;

  /// IANA time zone, e.g. `Asia/Dubai`.
  final String timeZone;

  /// One of the Kerala district headquarters.
  final bool kerala;

  /// The place as plain data for the website.
  Map<String, Object> toJson() => {
        'id': id,
        'ml': nameMl,
        'en': nameEn,
        'lat': latitude,
        'lng': longitude,
        'tz': timeZone,
        if (kerala) 'kerala': true,
      };
}

const _ist = 'Asia/Kolkata';

/// The place the site's static pages are computed for.
const defaultPlaceId = 'thiruvananthapuram';

/// Every place, Kerala first (south to north), then India, then abroad.
const places = [
  Place('thiruvananthapuram', 'തിരുവനന്തപുരം', 'Thiruvananthapuram', 8.5241,
      76.9366, _ist,
      kerala: true),
  Place('kollam', 'കൊല്ലം', 'Kollam', 8.8932, 76.6141, _ist, kerala: true),
  Place(
      'pathanamthitta', 'പത്തനംതിട്ട', 'Pathanamthitta', 9.2648, 76.7870, _ist,
      kerala: true),
  Place('alappuzha', 'ആലപ്പുഴ', 'Alappuzha', 9.4981, 76.3388, _ist,
      kerala: true),
  Place('kottayam', 'കോട്ടയം', 'Kottayam', 9.5916, 76.5222, _ist, kerala: true),
  Place('idukki', 'ഇടുക്കി', 'Idukki', 9.8497, 76.9500, _ist, kerala: true),
  Place('kochi', 'കൊച്ചി', 'Kochi', 9.9312, 76.2673, _ist, kerala: true),
  Place('thrissur', 'തൃശ്ശൂർ', 'Thrissur', 10.5276, 76.2144, _ist,
      kerala: true),
  Place('palakkad', 'പാലക്കാട്', 'Palakkad', 10.7867, 76.6548, _ist,
      kerala: true),
  Place('malappuram', 'മലപ്പുറം', 'Malappuram', 11.0510, 76.0711, _ist,
      kerala: true),
  Place('kozhikode', 'കോഴിക്കോട്', 'Kozhikode', 11.2588, 75.7804, _ist,
      kerala: true),
  Place('wayanad', 'വയനാട്', 'Wayanad', 11.6085, 76.0830, _ist, kerala: true),
  Place('kannur', 'കണ്ണൂർ', 'Kannur', 11.8745, 75.3704, _ist, kerala: true),
  Place('kasaragod', 'കാസർഗോഡ്', 'Kasaragod', 12.4996, 74.9869, _ist,
      kerala: true),
  // India.
  Place('bengaluru', 'ബെംഗളൂരു', 'Bengaluru', 12.9716, 77.5946, _ist),
  Place('chennai', 'ചെന്നൈ', 'Chennai', 13.0827, 80.2707, _ist),
  Place('mumbai', 'മുംബൈ', 'Mumbai', 19.0760, 72.8777, _ist),
  Place('delhi', 'ഡൽഹി', 'Delhi', 28.6139, 77.2090, _ist),
  // The Gulf.
  Place('dubai', 'ദുബായ്', 'Dubai', 25.2048, 55.2708, 'Asia/Dubai'),
  Place('abu-dhabi', 'അബുദാബി', 'Abu Dhabi', 24.4539, 54.3773, 'Asia/Dubai'),
  Place('doha', 'ദോഹ', 'Doha', 25.2854, 51.5310, 'Asia/Qatar'),
  Place('muscat', 'മസ്കത്ത്', 'Muscat', 23.5880, 58.3829, 'Asia/Muscat'),
  Place('riyadh', 'റിയാദ്', 'Riyadh', 24.7136, 46.6753, 'Asia/Riyadh'),
  Place('kuwait', 'കുവൈത്ത്', 'Kuwait City', 29.3759, 47.9774, 'Asia/Kuwait'),
  Place('manama', 'മനാമ', 'Manama', 26.2285, 50.5860, 'Asia/Bahrain'),
  // Further abroad.
  Place('singapore', 'സിംഗപ്പൂർ', 'Singapore', 1.3521, 103.8198,
      'Asia/Singapore'),
  Place('london', 'ലണ്ടൻ', 'London', 51.5074, -0.1278, 'Europe/London'),
  Place('new-york', 'ന്യൂയോർക്ക്', 'New York', 40.7128, -74.0060,
      'America/New_York'),
  Place('toronto', 'ടൊറന്റോ', 'Toronto', 43.6532, -79.3832, 'America/Toronto'),
  Place('sydney', 'സിഡ്നി', 'Sydney', -33.8688, 151.2093, 'Australia/Sydney'),
];
