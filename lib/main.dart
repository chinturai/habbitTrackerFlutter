import 'package:flutter/material.dart';
import 'package:habbit_tracker/database/habit_database.dart';
import 'package:habbit_tracker/pages/home_page.dart';
import 'package:habbit_tracker/themes/theme_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize data base
  await HabitDatabase.initialize();
  await HabitDatabase().saveFirstLaunchDate();

  runApp(
    MultiProvider(providers: [
      // Habit DB Provider
      ChangeNotifierProvider(create: (context) => HabitDatabase()) ,
      // Theme Provider
      ChangeNotifierProvider(create: (context) => ThemeProvider())
    ],
    child: const MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      theme: Provider.of<ThemeProvider>(context).themeData ,
    );
  }
}

