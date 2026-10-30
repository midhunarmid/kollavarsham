import 'package:kollavarsham/kollavarsham.dart';
import 'package:test/test.dart';

final cal = KollavarshamCalendar.standard;

/// Rule R3: the star present six nazhika (144 minutes) after sunrise.
bool passes(int dayNumber, Nakshatra star) => starAt(dayNumber) == star;

/// The star six nazhika (144 minutes) after sunrise on [dayNumber].
Nakshatra starAt(int dayNumber) {
  final sunrise = cal.sunrise(cal.dateOfDayNumber(dayNumber))!;
  return cal.nakshatraAt(sunrise.add(const Duration(minutes: 144)));
}

/// The day numbers of [month] in [year] that pass rule R3 for [star].
List<int> passingDays(int year, MalayalamMonth month, Nakshatra star) {
  final start = cal.dayNumberOf(year, month, 1);
  return [
    for (var n = start; n < start + cal.monthLength(year, month); n++)
      if (passes(n, star)) n,
  ];
}

/// Finds a (year, month, star) whose month has [count] days passing R3.
(int, MalayalamMonth, Nakshatra) findMonth(int count) {
  for (var year = 1200; year < 1210; year++) {
    for (final month in MalayalamMonth.values) {
      for (final star in Nakshatra.values) {
        if (passingDays(year, month, star).length == count) {
          return (year, month, star);
        }
      }
    }
  }
  throw StateError('No month with $count days');
}

/// The days of [month] in [year] on which [tithi] falls, using a rule that
/// keeps every day (absent days are skipped, so no neighbouring month leaks
/// in).
List<int> tithiDays(int year, MalayalamMonth month, Tithi tithi) {
  final first = TithiInMonth(tithi, month,
      duplicateRule: DuplicateRule.first, absentRule: AbsentRule.skip);
  final second = TithiInMonth(tithi, month, absentRule: AbsentRule.skip);
  final found = <int>{
    for (final r in [first, second])
      ...inYear(r, year).where((d) => d.month == month).map((d) => d.dayNumber),
  };
  return found.toList()..sort();
}

/// Finds a (year, month, tithi) whose month has [count] days of the tithi.
(int, MalayalamMonth, Tithi) findTithiMonth(int count) {
  for (var year = 1190; year < 1215; year++) {
    for (final month in MalayalamMonth.values) {
      for (var number = 1; number <= 30; number++) {
        final tithi = Tithi(number);
        if (tithiDays(year, month, tithi).length == count) {
          return (year, month, tithi);
        }
      }
    }
  }
  throw StateError('No month with $count days');
}

List<MalayalamDate> inYear(Recurrence r, int year) {
  final first = cal.toGregorian(year, MalayalamMonth.chingam, 1);
  final last = cal.toGregorian(year + 1, MalayalamMonth.chingam, 1).subtract(
        const Duration(days: 1),
      );
  return r.occurrencesBetween(first, last);
}

void expectSortedUnique(List<MalayalamDate> dates) {
  for (var i = 1; i < dates.length; i++) {
    expect(dates[i].dayNumber, greaterThan(dates[i - 1].dayNumber),
        reason: 'after ${dates[i - 1]}');
  }
}

void main() {
  group('NakshatraInMonth', () {
    // Onam is Thiruvonam in Chingam, the later day when the star falls twice:
    // the same rule as a pirannal (R1 second). Published dates as in
    // panchanga_test.dart; 2013 and 2024 are months with Thiruvonam twice.
    const onamDates = {
      1185: (2009, 9, 2),
      1186: (2010, 8, 23),
      1187: (2011, 9, 9),
      1188: (2012, 8, 29),
      1189: (2013, 9, 16),
      1190: (2014, 9, 7),
      1191: (2015, 8, 28),
      1193: (2017, 9, 4),
      1194: (2018, 8, 25),
      1195: (2019, 9, 11),
      1196: (2020, 8, 31),
      1197: (2021, 8, 21),
      1198: (2022, 9, 8),
      1199: (2023, 8, 29),
      1200: (2024, 9, 15),
      1201: (2025, 9, 5),
    };
    const onam = NakshatraInMonth(Nakshatra.thiruvonam, MalayalamMonth.chingam);
    for (final MapEntry(key: year, value: (y, m, d)) in onamDates.entries) {
      test('Thiruvonam in Chingam $year is Onam', () {
        final dates = inYear(onam, year);
        expect(dates, hasLength(1));
        expect(dates.single.toGregorian(), DateTime(y, m, d));
      });
    }

    test('a pirannal is one day a year that passes rule R3', () {
      const pirannal =
          NakshatraInMonth(Nakshatra.pooradam, MalayalamMonth.dhanu);
      for (var year = 1190; year <= 1215; year++) {
        final dates = inYear(pirannal, year);
        expect(dates, hasLength(1), reason: '$year');
        final date = dates.single;
        expect(passes(date.dayNumber, Nakshatra.pooradam), isTrue);
        expect(
            date.month, anyOf(MalayalamMonth.dhanu, MalayalamMonth.vrischikam));
      }
    });

    test('a star on two days uses the duplicate rule (R1)', () {
      final (year, month, star) = findMonth(2);
      final days = passingDays(year, month, star);
      final second = inYear(NakshatraInMonth(star, month), year);
      final first = inYear(
          NakshatraInMonth(star, month, duplicateRule: DuplicateRule.first),
          year);
      expect(second.single.dayNumber, days.last);
      expect(first.single.dayNumber, days.first);
    });

    test('a missing star uses the absent rule (R2)', () {
      final (year, month, star) = findMonth(0);
      final previousYear = month == MalayalamMonth.chingam ? year - 1 : year;
      final previousDays = passingDays(previousYear, month.previous, star);
      final nextYear = month == MalayalamMonth.karkidakam ? year + 1 : year;
      final nextDays = passingDays(nextYear, month.next, star);

      final byPrevious = NakshatraInMonth(star, month);
      final byNext =
          NakshatraInMonth(star, month, absentRule: AbsentRule.nextMonth);
      final bySkip = NakshatraInMonth(star, month, absentRule: AbsentRule.skip);
      final start = cal.toGregorian(year, month, 1);
      final end = cal.toGregorian(year, month, cal.monthLength(year, month));
      final window = (
        start.subtract(const Duration(days: 40)),
        end.add(const Duration(days: 40)),
      );

      expect(
          byPrevious
              .occurrencesBetween(window.$1, window.$2)
              .map((d) => d.dayNumber),
          contains(previousDays.last));
      expect(
          byNext
              .occurrencesBetween(window.$1, window.$2)
              .map((d) => d.dayNumber),
          contains(nextDays.first));
      expect(bySkip.occurrencesBetween(start, end), isEmpty);
    });

    test('one occurrence a year, in order, 1950-2100', () {
      const pirannal =
          NakshatraInMonth(Nakshatra.makayiram, MalayalamMonth.medam);
      final dates =
          pirannal.occurrencesBetween(DateTime(1950), DateTime(2100, 12, 31));
      expectSortedUnique(dates);
      expect(dates.length, inInclusiveRange(150, 151));
      // The day moves within the month (or to the previous month, R2) from
      // year to year, so consecutive dates are a year apart give or take
      // two months.
      for (var i = 1; i < dates.length; i++) {
        expect(dates[i - 1].daysUntil(dates[i]), inInclusiveRange(300, 430));
      }
    });
  });

  group('NakshatraMonthly', () {
    for (final star in [Nakshatra.pooradam, Nakshatra.ashwathi]) {
      test('${star.english}: sorted, complete, no long gaps, 1950-2100', () {
        final dates = NakshatraMonthly(star)
            .occurrencesBetween(DateTime(1950), DateTime(2100, 12, 31));
        expectSortedUnique(dates);
        // Each day has the star, or the star falls wholly between this day's
        // reading and the next (then the earlier day counts).
        final previous = Nakshatra.values[(star.index + 26) % 27];
        for (final date in dates) {
          final n = date.dayNumber;
          expect(
              passes(n, star) ||
                  (starAt(n) == previous && starAt(n + 1) == star.next),
              isTrue,
              reason: '$date');
        }
        for (var i = 1; i < dates.length; i++) {
          expect(dates[i - 1].daysUntil(dates[i]), lessThanOrEqualTo(30),
              reason: 'after ${dates[i - 1]}');
        }
        // About 13.4 star days a year.
        expect(dates.length, inInclusiveRange(151 * 13, 151 * 14));
        // Complete: every day of a sample year with the star is included.
        final sample = {
          for (final d in dates)
            if (d.year == 1202) d.dayNumber,
        };
        final start = cal.dayNumberOf(1202, MalayalamMonth.chingam, 1);
        final expected = {
          for (var n = start; n < start + cal.yearLength(1202); n++)
            if (passes(n, star)) n,
        };
        expect(sample.containsAll(expected), isTrue);
      });
    }
  });

  group('TithiInMonth', () {
    // Published shraddha days, New Delhi: drikpanchang.com/shraddha/tithi/.
    // The tithi covers the afternoon on one day, or more of it on the later
    // day (Ashtami 2022 is on both afternoons).
    final delhi = KollavarshamCalendar(
      location: const ObserverLocation(
        latitude: 28.6356,
        longitude: 77.2244,
        utcOffset: Duration(hours: 5, minutes: 30),
      ),
    );
    // Ashtami falls twice in Kanni 1198, so its row asks for the first.
    for (final (name, tithi, date, rule) in [
      ('Shashthi 2022', 21, DateTime(2022, 9, 15), DuplicateRule.second),
      ('Ashtami 2022', 23, DateTime(2022, 9, 18), DuplicateRule.first),
      ('Dwitiya 2025', 17, DateTime(2025, 9, 9), DuplicateRule.second),
    ]) {
      test('$name uses the day with more of the afternoon', () {
        final month = delhi.fromGregorian(date).month;
        final found = TithiInMonth(Tithi(tithi), month, duplicateRule: rule)
            .occurrencesBetween(
          date.subtract(const Duration(days: 12)),
          date.add(const Duration(days: 12)),
          calendar: delhi,
        );
        expect(found.map((d) => d.toGregorian()), [date]);
      });
    }

    test('Amavasya in Karkidakam against Karkidaka Vavu, 2015-2025', () {
      final vavu = TithiInMonth(Tithi(30), MalayalamMonth.karkidakam,
          duplicateRule: DuplicateRule.first);
      for (var year = 1190; year <= 1200; year++) {
        final date = inYear(vavu, year).single;
        if (year == 1199) {
          // Vavu was observed on 3 August 2024, though Amavasya covered only
          // the last minutes of that afternoon. See rule R4 for this open
          // difference between the festival and a shraddham.
          expect(date.toGregorian(), DateTime(2024, 8, 4));
          expect(cal.karkidakaVavu(year).toGregorian(), DateTime(2024, 8, 3));
        } else {
          expect(date, cal.karkidakaVavu(year), reason: '$year');
        }
      }
    });

    test('one a year in or next to its month, in order, 1950-2100', () {
      final shraddham = TithiInMonth(Tithi(26), MalayalamMonth.karkidakam);
      final dates =
          shraddham.occurrencesBetween(DateTime(1950), DateTime(2100, 12, 31));
      expectSortedUnique(dates);
      expect(dates.length, inInclusiveRange(150, 151));
      for (var i = 1; i < dates.length; i++) {
        expect(dates[i - 1].daysUntil(dates[i]), inInclusiveRange(320, 400));
      }
      for (final d in dates) {
        expect(
            d.month, anyOf(MalayalamMonth.karkidakam, MalayalamMonth.mithunam));
      }
    });

    test('a tithi twice in the month uses the duplicate rule (R1)', () {
      final (year, month, tithi) = findTithiMonth(2);
      final both = tithiDays(year, month, tithi);
      expect(
          inYear(TithiInMonth(tithi, month), year).single.dayNumber, both.last);
      expect(
          inYear(TithiInMonth(tithi, month, duplicateRule: DuplicateRule.first),
                  year)
              .single
              .dayNumber,
          both.first);
    });

    test('a missing tithi uses the absent rule (R2)', () {
      final (year, month, tithi) = findTithiMonth(0);
      final start = cal.toGregorian(year, month, 1);
      final end = cal.toGregorian(year, month, cal.monthLength(year, month));
      expect(
          TithiInMonth(tithi, month, absentRule: AbsentRule.skip)
              .occurrencesBetween(start, end),
          isEmpty);

      final before = TithiInMonth(tithi, month).occurrencesBetween(
          start.subtract(const Duration(days: 32)),
          start.subtract(const Duration(days: 1)));
      final after = TithiInMonth(tithi, month, absentRule: AbsentRule.nextMonth)
          .occurrencesBetween(end.add(const Duration(days: 1)),
              end.add(const Duration(days: 32)));
      expect(before.last.month, month.previous);
      expect(after.first.month, month.next);
    });
  });

  group('TithiEveryPaksha', () {
    /// The sunrise tithi number on [dayNumber].
    int tithiOn(int dayNumber) =>
        cal.tithiOn(cal.dateOfDayNumber(dayNumber)).number;

    test('every Ekadashi: one per fortnight, no gaps, 1950-2100', () {
      final dates = const TithiEveryPaksha(11)
          .occurrencesBetween(DateTime(1950), DateTime(2100, 12, 31));
      expectSortedUnique(dates);
      for (var i = 1; i < dates.length; i++) {
        expect(dates[i - 1].daysUntil(dates[i]), inInclusiveRange(13, 16),
            reason: 'after ${dates[i - 1]}');
      }
      // 151 years of 24.74 fortnights.
      expect(dates.length, inInclusiveRange(3730, 3740));
    });

    test('each day has the tithi at sunrise, or skips it', () {
      final dates = const TithiEveryPaksha(15, paksha: Paksha.shukla)
          .occurrencesBetween(DateTime(1990), DateTime(2030));
      for (final date in dates) {
        final n = date.dayNumber;
        expect(tithiOn(n) == 15 || (tithiOn(n) == 14 && tithiOn(n + 1) == 16),
            isTrue,
            reason: '$date');
      }
    });

    test('a tithi at two sunrises counts once, on the first', () {
      final start = cal.dayNumberOf(1190, MalayalamMonth.chingam, 1);
      final doubled = [
        for (var n = start; n < start + 3650; n++)
          if (tithiOn(n) == 11 && tithiOn(n + 1) == 11) n,
      ];
      expect(doubled, isNotEmpty);
      final days = const TithiEveryPaksha(11, paksha: Paksha.shukla)
          .occurrencesBetween(
              cal.dateOfDayNumber(start), cal.dateOfDayNumber(start + 3700))
          .map((d) => d.dayNumber)
          .toSet();
      for (final n in doubled) {
        expect(days, contains(n));
        expect(days, isNot(contains(n + 1)));
      }
    });

    test('a fortnight limits it to one tithi a lunar month', () {
      final dates = const TithiEveryPaksha(6, paksha: Paksha.shukla)
          .occurrencesBetween(DateTime(2026), DateTime(2026, 12, 31));
      expect(dates.length, inInclusiveRange(12, 13));
      for (var i = 1; i < dates.length; i++) {
        expect(dates[i - 1].daysUntil(dates[i]), inInclusiveRange(28, 31));
      }
    });

    test('Pournami and Amavasya are both day 15', () {
      final both = const TithiEveryPaksha(15)
          .occurrencesBetween(DateTime(2026), DateTime(2026, 12, 31));
      expect(both.length, inInclusiveRange(24, 25));
    });
  });

  group('MalayalamDateYearly', () {
    test('one occurrence a year on the same Malayalam date, 1950-2100', () {
      const r = MalayalamDateYearly(MalayalamMonth.thulam, 12);
      final dates =
          r.occurrencesBetween(DateTime(1950), DateTime(2100, 12, 31));
      expectSortedUnique(dates);
      expect(dates.length, inInclusiveRange(150, 151));
      for (final d in dates) {
        expect((d.month, d.day), (MalayalamMonth.thulam, 12));
      }
    });

    test('a day beyond a short month falls on its last day', () {
      const r = MalayalamDateYearly(MalayalamMonth.vrischikam, 31);
      for (var year = 1195; year < 1210; year++) {
        final d = inYear(r, year).single;
        expect(d.month, MalayalamMonth.vrischikam);
        expect(d.day, d.monthLength);
      }
    });
  });

  group('MalayalamDateMonthly', () {
    test('twelve a year, the last day of shorter months, no gaps', () {
      const r = MalayalamDateMonthly(32);
      final dates =
          r.occurrencesBetween(DateTime(1950), DateTime(2100, 12, 31));
      expectSortedUnique(dates);
      expect(inYear(r, 1202), hasLength(12));
      for (final d in dates) {
        expect(d.day, d.monthLength);
      }
      for (var i = 1; i < dates.length; i++) {
        expect(dates[i - 1].daysUntil(dates[i]), inInclusiveRange(29, 32));
      }
    });
  });

  group('GregorianYearly', () {
    test('29 February falls on 28 February in common years', () {
      const r = GregorianYearly(2, 29);
      final dates =
          r.occurrencesBetween(DateTime(2026), DateTime(2028, 12, 31));
      expect(dates.map((d) => d.toGregorian()), [
        DateTime(2026, 2, 28),
        DateTime(2027, 2, 28),
        DateTime(2028, 2, 29),
      ]);
    });

    test('one a year, 1950-2100', () {
      const r = GregorianYearly(10, 29);
      final dates =
          r.occurrencesBetween(DateTime(1950), DateTime(2100, 12, 31));
      expect(dates, hasLength(151));
      expectSortedUnique(dates);
    });
  });

  group('next', () {
    test('is the first occurrence strictly after the day', () {
      const r = NakshatraMonthly(Nakshatra.pooradam);
      final all = r.occurrencesBetween(DateTime(2026), DateTime(2026, 12, 31));
      final after = all[3].toGregorian();
      expect(r.next(after), all[4]);
      expect(r.next(after.subtract(const Duration(days: 1))), all[3]);
    });

    test('finds a yearly date', () {
      const r = GregorianYearly(1, 1);
      expect(r.next(DateTime(2026, 10, 30))!.toGregorian(), DateTime(2027));
    });
  });

  group('JSON', () {
    const recurrences = <Recurrence>[
      NakshatraInMonth(Nakshatra.pooradam, MalayalamMonth.dhanu),
      NakshatraInMonth(Nakshatra.revathi, MalayalamMonth.medam,
          duplicateRule: DuplicateRule.first, absentRule: AbsentRule.skip),
      NakshatraMonthly(Nakshatra.thiruvathira),
      TithiEveryPaksha(11),
      TithiEveryPaksha(6, paksha: Paksha.shukla),
      MalayalamDateYearly(MalayalamMonth.thulam, 12),
      MalayalamDateMonthly(1),
      GregorianYearly(2, 29),
    ];

    test('round trip tithiInMonth', () {
      final r = TithiInMonth(Tithi(26), MalayalamMonth.karkidakam,
          duplicateRule: DuplicateRule.first, absentRule: AbsentRule.nextMonth);
      expect(Recurrence.fromJson(r.toJson()), r);
      expect(Recurrence.fromJson(r.toJson()).hashCode, r.hashCode);
      expect(r.toJson()['tithi'], 26);
    });

    test('an out-of-range tithi throws FormatException', () {
      final json = TithiInMonth(Tithi(1), MalayalamMonth.medam).toJson();
      expect(() => Recurrence.fromJson({...json, 'tithi': 31}),
          throwsFormatException);
      expect(
          () => Recurrence.fromJson(
              {'type': 'tithiEveryPaksha', 'dayOfPaksha': 0}),
          throwsFormatException);
    });

    for (final r in recurrences) {
      test('round trip ${r.toJson()['type']}', () {
        final json = r.toJson();
        expect(Recurrence.fromJson(json), r);
        expect(Recurrence.fromJson(json).hashCode, r.hashCode);
      });
    }

    test('pirannal JSON shape', () {
      expect(recurrences.first.toJson(), {
        'type': 'nakshatraInMonth',
        'nakshatra': 'pooradam',
        'month': 'dhanu',
        'duplicateRule': 'second',
        'absentRule': 'previousMonth',
      });
    });

    test('different values are not equal', () {
      expect(recurrences[0], isNot(recurrences[1]));
      expect(const GregorianYearly(2, 29), isNot(const GregorianYearly(2, 28)));
    });

    test('bad input throws FormatException', () {
      expect(
          () => Recurrence.fromJson({'type': 'weekly'}), throwsFormatException);
      expect(
          () => Recurrence.fromJson(
              {'type': 'nakshatraMonthly', 'nakshatra': 'pluto'}),
          throwsFormatException);
      expect(
          () => Recurrence.fromJson(
              {'type': 'gregorianYearly', 'month': '2', 'day': 29}),
          throwsFormatException);
    });
  });
}
