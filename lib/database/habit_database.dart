import 'package:flutter/cupertino.dart';
import 'package:habbit_tracker/models/app_settings.dart';
import 'package:habbit_tracker/models/habit.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class HabitDatabase extends ChangeNotifier {
  static late Isar isar;

  // SETUP (Initialization)
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([
      HabitSchema,
      AppSettingsSchema,
    ], directory: dir.path);
  }

  // SAVE DATE OF FIRST OPEN
  Future<void> saveFirstLaunchDate() async {
    final existingSettings = await isar.appSettings.where().findFirst();

    if (existingSettings == null) {
      final settings = AppSettings()..firstLaunchDate = DateTime.now();
      await isar.writeTxn(() => isar.appSettings.put(settings));
    }
  }

  // GET DATE OF FIRST OPEN
  Future<DateTime?> getFirstLaunchDate() async {
    final settings = await isar.appSettings.where().findFirst();
    return settings?.firstLaunchDate;
  }

  // CRUD OPERATIONS

  // LIST OF HABITS
  final List<Habit> currentHabits = [];

  // CREATE HABIT
  Future<void> createHabit(String habitName) async {
    // create a new habit
    final newHabit = Habit()..name = habitName;

    // save it in database
    await isar.writeTxn(() => isar.habits.put(newHabit));

    // update the UI with latest list
    readHabits();
  }

  // READ HABIT
  Future<void> readHabits() async {
    // fetch all habits
    List<Habit> fetchedHabits = await isar.habits.where().findAll();

    // give it to current habits
    currentHabits.clear();
    currentHabits.addAll(fetchedHabits);

    // update UI
    notifyListeners();
  }

  // UPDATE HABIT (DONE / NOT DONE)
  Future<void> updateHabitCompletion(int id, bool isCompleted) async {
    // Find the specific habit using its ID
    final habit = await isar.habits.get(id);

    // Update its completion status
    if (habit != null) {
      await isar.writeTxn(() async {
        // Current date (without time)
        final today = DateTime.now();

        if (isCompleted) {
          // Check if today's date is already in the list
          final alreadyCompleted = habit.completedDays.any(
            (date) =>
                date.year == today.year &&
                date.month == today.month &&
                date.day == today.day,
          );

          // If not, add today's date
          if (!alreadyCompleted) {
            habit.completedDays.add(
              DateTime(today.year, today.month, today.day),
            );
          }
        } else {
          // Remove today's date if habit is unchecked
          habit.completedDays.removeWhere(
            (date) =>
                date.year == today.year &&
                date.month == today.month &&
                date.day == today.day,
          );
        }

        // Save changes to the database
        await isar.habits.put(habit);
      });
    }

    // re-read from DB
    readHabits();
  }

  // UPDATE HABIT NAME
  Future<void> updateHabitName(int id , String newName) async {
    // find the specific habit which needs to be updated
    final habit = await isar.habits.get(id);

    // update the habit name
    if( habit != null ) {
      await isar.writeTxn(() async {
        habit.name = newName;

        // save it in db
        await isar.habits.put(habit);
      });
    }

    // re-read from db
    readHabits();
  }

  // DELETE HABIT
  Future<void> deleteHabit(int id) async {
    // delete it
    await isar.writeTxn(() async {
      await isar.habits.delete(id);
    });

    // re read from DB
    readHabits();
  }
}
