import 'package:better_me/core/l10n/app_localizations.dart';

/// Provides utility extensions for integer values representing weekdays.
extension WeekdayExtension on int {
  String toLocalizedWeekdayName(AppLocalizations l10n) {
    final int normalizedDay = ((this - 1) % 7) + 1;
    switch (normalizedDay) {
      case 1:
        return l10n.monday;
      case 2:
        return l10n.tuesday;
      case 3:
        return l10n.wednesday;
      case 4:
        return l10n.thursday;
      case 5:
        return l10n.friday;
      case 6:
        return l10n.saturday;
      case 7:
        return l10n.sunday;
      default:
        return '';
    }
  }
}
