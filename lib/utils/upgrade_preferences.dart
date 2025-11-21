import 'package:shared_preferences/shared_preferences.dart';

class UpgradePreferences {
static const _mealKey = 'upgrade_meal_keys';
static const _dayKey = 'upgrade_day_keys';
static const _weekKey = 'upgrade_week_active';
static const _monthKey = 'upgrade_month_active';

static Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

static String _normalizeDay(String day) => day.trim().toUpperCase();
static String _normalizeMeal(String meal) => meal.trim().toUpperCase();
static String _mealEntry(String day, String meal) =>
    '${_normalizeDay(day)}|${_normalizeMeal(meal)}';

static Future<Set<String>> getMealUpgrades() async {
  final prefs = await _prefs();
  return (prefs.getStringList(_mealKey) ?? const <String>[]).toSet();
}

static Future<Set<String>> getDayUpgrades() async {
  final prefs = await _prefs();
  return (prefs.getStringList(_dayKey) ?? const <String>[]).toSet();
}

static Future<bool> isMealUpgraded(String day, String meal) async {
  final set = await getMealUpgrades();
  return set.contains(_mealEntry(day, meal));
}

static Future<bool> isDayUpgraded(String day) async {
  final set = await getDayUpgrades();
  return set.contains(_normalizeDay(day));
}

static Future<void> addMealUpgrade(String day, String meal) async {
  final prefs = await _prefs();
  final set = await getMealUpgrades();
  set.add(_mealEntry(day, meal));
  await prefs.setStringList(_mealKey, set.toList());
}

static Future<void> addDayUpgrade(String day) async {
  final prefs = await _prefs();
  final set = await getDayUpgrades();
  set.add(_normalizeDay(day));
  await prefs.setStringList(_dayKey, set.toList());
}

static Future<void> setWeekUpgrade(bool value) async {
  final prefs = await _prefs();
  await prefs.setBool(_weekKey, value);
}

static Future<void> setMonthUpgrade(bool value) async {
  final prefs = await _prefs();
  await prefs.setBool(_monthKey, value);
}

static Future<bool> isWeekUpgraded() async {
  final prefs = await _prefs();
  return prefs.getBool(_weekKey) ?? false;
}

static Future<bool> isMonthUpgraded() async {
  final prefs = await _prefs();
  return prefs.getBool(_monthKey) ?? false;
}

static Future<void> resetAll() async {
  final prefs = await _prefs();
  await prefs.remove(_mealKey);
  await prefs.remove(_dayKey);
  await prefs.remove(_weekKey);
  await prefs.remove(_monthKey);
}
}

