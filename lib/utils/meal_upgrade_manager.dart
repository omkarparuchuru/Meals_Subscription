import 'package:shared_preferences/shared_preferences.dart';

class MealUpgradeManager {
  // Check if a meal is upgraded to non-veg for a specific date
  static Future<bool> isMealUpgradedForDate(String meal, DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    
    for (final key in keys) {
      if (key.startsWith('upgrade_$meal')) {
        final upgradeData = prefs.getString(key);
        if (upgradeData != null) {
          final parts = upgradeData.split('|');
          if (parts.length >= 4) {
            final mealName = parts[0];
            final upgradeType = parts[1]; // 'upgrade' or diet type
            final duration = parts[2]; // 'day', 'week', 'month'
            final targetDay = parts.length > 3 ? parts[3] : '';
            
            if (mealName == meal && upgradeType == 'upgrade') {
              // Extract timestamp from key
              final timestamp = int.tryParse(key.split('_').last);
              if (timestamp != null) {
                final upgradeDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
                
                if (duration == 'day') {
                  // Check if it's the same day and same day of week
                  if (targetDay.isNotEmpty) {
                    final dayOfWeek = _getDayOfWeek(date);
                    if (dayOfWeek == targetDay) {
                      // Check if upgrade is still active (within 30 days of upgrade date)
                      final daysDiff = date.difference(upgradeDate).inDays;
                      if (daysDiff >= 0 && daysDiff < 30) {
                        return true;
                      }
                    }
                  }
                } else if (duration == 'week') {
                  // Check if within the week of upgrade
                  final daysDiff = date.difference(upgradeDate).inDays;
                  if (daysDiff >= 0 && daysDiff < 7) {
                    return true;
                  }
                } else if (duration == 'month') {
                  // Check if within the month of upgrade
                  final daysDiff = date.difference(upgradeDate).inDays;
                  if (daysDiff >= 0 && daysDiff < 30) {
                    return true;
                  }
                }
              }
            }
          }
        }
      }
    }
    
    return false;
  }
  
  // Check if a meal is added (not in base subscription) for a specific date
  static Future<bool> isMealAddedForDate(String meal, DateTime date, List<String> baseMeals) async {
    if (baseMeals.contains(meal)) return false; // Already in base subscription
    
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    
    for (final key in keys) {
      if (key.startsWith('upgrade_$meal')) {
        final upgradeData = prefs.getString(key);
        if (upgradeData != null) {
          final parts = upgradeData.split('|');
          if (parts.length >= 4) {
            final mealName = parts[0];
            final dietType = parts[1]; // 'vegetarian' or 'non-vegetarian'
            final duration = parts[2]; // 'day', 'week', 'month'
            final targetDay = parts.length > 3 ? parts[3] : '';
            
            if (mealName == meal && (dietType == 'vegetarian' || dietType == 'non-vegetarian')) {
              final timestamp = int.tryParse(key.split('_').last);
              if (timestamp != null) {
                final upgradeDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
                
                if (duration == 'day') {
                  if (targetDay.isNotEmpty) {
                    final dayOfWeek = _getDayOfWeek(date);
                    if (dayOfWeek == targetDay) {
                      final daysDiff = date.difference(upgradeDate).inDays;
                      if (daysDiff >= 0 && daysDiff < 30) {
                        return true;
                      }
                    }
                  }
                } else if (duration == 'week') {
                  final daysDiff = date.difference(upgradeDate).inDays;
                  if (daysDiff >= 0 && daysDiff < 7) {
                    return true;
                  }
                } else if (duration == 'month') {
                  final daysDiff = date.difference(upgradeDate).inDays;
                  if (daysDiff >= 0 && daysDiff < 30) {
                    return true;
                  }
                }
              }
            }
          }
        }
      }
    }
    
    return false;
  }
  
  // Get diet type for a meal on a specific date
  static Future<String> getMealDietType(String meal, DateTime date, String baseDietType, List<String> baseMeals) async {
    // Check if meal is upgraded to non-veg
    final isUpgraded = await isMealUpgradedForDate(meal, date);
    if (isUpgraded) return 'non-vegetarian';
    
    // Check if meal is added with specific diet type
    if (!baseMeals.contains(meal)) {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      for (final key in keys) {
        if (key.startsWith('upgrade_$meal')) {
          final upgradeData = prefs.getString(key);
          if (upgradeData != null) {
            final parts = upgradeData.split('|');
            if (parts.length >= 2) {
              final dietType = parts[1];
              if (dietType == 'vegetarian' || dietType == 'non-vegetarian') {
                return dietType;
              }
            }
          }
        }
      }
    }
    
    // Return base diet type
    return baseDietType;
  }
  
  // Get list of meals available for a specific date
  static Future<List<String>> getMealsForDate(DateTime date, List<String> baseMeals) async {
    final meals = List<String>.from(baseMeals);
    final allPossibleMeals = ['Tiffin', 'Lunch', 'Snacks', 'Dinner'];
    
    // Check for added meals
    for (final meal in allPossibleMeals) {
      if (!meals.contains(meal)) {
        final isAdded = await isMealAddedForDate(meal, date, baseMeals);
        if (isAdded) {
          meals.add(meal);
        }
      }
    }
    
    return meals;
  }
  
  static String _getDayOfWeek(DateTime date) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[date.weekday - 1];
  }
}
