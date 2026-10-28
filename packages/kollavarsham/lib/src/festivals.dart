import 'calendar.dart';
import 'malayalam_date.dart';
import 'names.dart';
import 'panchanga.dart';

/// Dates of major Kerala festivals and seasons, by Kollavarsham year.
extension KeralaFestivals on KollavarshamCalendar {
  /// Vishu: Medam 1, the astronomical new year, of Kollavarsham [year].
  ///
  /// Medam of year 1200 falls in April 2025.
  MalayalamDate vishu(int year) =>
      MalayalamDate(year, MalayalamMonth.medam, 1, calendar: this);

  /// Thiruvonam (Onam) of Kollavarsham [year]: the day in Chingam with the
  /// Thiruvonam nakshatra at sunrise.
  ///
  /// Chingam is long enough (31 days) for the star to occur twice, once in
  /// its first days and again at its end; Onam is then celebrated on the
  /// later occurrence (e.g. 1189 → 2013-09-16, 1200 → 2024-09-15).
  MalayalamDate onam(int year) =>
      daysWithNakshatra(year, MalayalamMonth.chingam, Nakshatra.thiruvonam)
          .last;

  /// Atham, the first of the ten days of Onam, nine days before
  /// Thiruvonam. It may fall in Karkidakam.
  MalayalamDate atham(int year) => onam(year).addDays(-9);

  /// Start of the 41-day Mandala season: Vrischikam 1 of [year].
  MalayalamDate mandalaKalamStart(int year) =>
      MalayalamDate(year, MalayalamMonth.vrischikam, 1, calendar: this);

  /// Mandala Pooja, the 41st day of the Mandala season of [year].
  MalayalamDate mandalaPooja(int year) => mandalaKalamStart(year).addDays(40);

  /// Makaravilakku: Makaram 1 of Kollavarsham [year].
  ///
  /// Makaram of year 1200 falls in January 2025.
  MalayalamDate makaravilakku(int year) =>
      MalayalamDate(year, MalayalamMonth.makaram, 1, calendar: this);

  /// Start of the Karkidakam month (Ramayana month) of [year].
  MalayalamDate karkidakamStart(int year) =>
      MalayalamDate(year, MalayalamMonth.karkidakam, 1, calendar: this);
}
