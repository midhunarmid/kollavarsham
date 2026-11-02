import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';

const _ist = Duration(hours: 5, minutes: 30);

/// A Kerala city offered in the location setting.
class KeralaCity {
  const KeralaCity._(this.id, this.nameMl, this.location);

  /// Stable identifier stored in the settings.
  final String id;

  /// Name in Malayalam script.
  final String nameMl;

  /// Coordinates in Indian Standard Time; [ObserverLocation.name] is the
  /// English name.
  final ObserverLocation location;

  /// Name in English.
  String get nameEn => location.name!;

  /// The name in [script].
  String name(MalayalamScript script) =>
      script == MalayalamScript.malayalam ? nameMl : nameEn;
}

/// The 14 district headquarters, south to north.
///
/// Thiruvananthapuram, Kochi and Kozhikode reuse the engine's locations, so
/// Thiruvananthapuram keeps the precomputed month table. The others are
/// approximate city-centre coordinates: an error of 0.1° moves sunrise by
/// under 30 seconds.
const keralaCities = [
  KeralaCity._('thiruvananthapuram', 'തിരുവനന്തപുരം',
      ObserverLocation.thiruvananthapuram),
  KeralaCity._(
      'kollam',
      'കൊല്ലം',
      ObserverLocation(
          latitude: 8.8932,
          longitude: 76.6141,
          utcOffset: _ist,
          name: 'Kollam')),
  KeralaCity._(
      'pathanamthitta',
      'പത്തനംതിട്ട',
      ObserverLocation(
          latitude: 9.2648,
          longitude: 76.7870,
          utcOffset: _ist,
          name: 'Pathanamthitta')),
  KeralaCity._(
      'alappuzha',
      'ആലപ്പുഴ',
      ObserverLocation(
          latitude: 9.4981,
          longitude: 76.3388,
          utcOffset: _ist,
          name: 'Alappuzha')),
  KeralaCity._(
      'kottayam',
      'കോട്ടയം',
      ObserverLocation(
          latitude: 9.5916,
          longitude: 76.5222,
          utcOffset: _ist,
          name: 'Kottayam')),
  KeralaCity._(
      'idukki',
      'ഇടുക്കി',
      ObserverLocation(
          latitude: 9.8497,
          longitude: 76.9500,
          utcOffset: _ist,
          name: 'Idukki')),
  KeralaCity._('kochi', 'കൊച്ചി', ObserverLocation.kochi),
  KeralaCity._(
      'thrissur',
      'തൃശ്ശൂർ',
      ObserverLocation(
          latitude: 10.5276,
          longitude: 76.2144,
          utcOffset: _ist,
          name: 'Thrissur')),
  KeralaCity._(
      'palakkad',
      'പാലക്കാട്',
      ObserverLocation(
          latitude: 10.7867,
          longitude: 76.6548,
          utcOffset: _ist,
          name: 'Palakkad')),
  KeralaCity._(
      'malappuram',
      'മലപ്പുറം',
      ObserverLocation(
          latitude: 11.0510,
          longitude: 76.0711,
          utcOffset: _ist,
          name: 'Malappuram')),
  KeralaCity._('kozhikode', 'കോഴിക്കോട്', ObserverLocation.kozhikode),
  KeralaCity._(
      'wayanad',
      'വയനാട്',
      ObserverLocation(
          latitude: 11.6085,
          longitude: 76.0830,
          utcOffset: _ist,
          name: 'Wayanad')),
  KeralaCity._(
      'kannur',
      'കണ്ണൂർ',
      ObserverLocation(
          latitude: 11.8745,
          longitude: 75.3704,
          utcOffset: _ist,
          name: 'Kannur')),
  KeralaCity._(
      'kasaragod',
      'കാസർഗോഡ്',
      ObserverLocation(
          latitude: 12.4996,
          longitude: 74.9869,
          utcOffset: _ist,
          name: 'Kasaragod')),
];

/// The city with [id], or null.
KeralaCity? keralaCityById(String id) {
  for (final c in keralaCities) {
    if (c.id == id) return c;
  }
  return null;
}

/// The city at [location], or null for a manual location.
KeralaCity? keralaCityAt(ObserverLocation location) {
  for (final c in keralaCities) {
    if (c.location == location) return c;
  }
  return null;
}
