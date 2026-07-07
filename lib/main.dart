import 'package:flutter/material.dart';
import 'package:scmp_staff_app/di/injection.dart';
import 'package:scmp_staff_app/views/assignment_showcase_view.dart';
import 'package:scmp_staff_app/views/login_view.dart';
import 'package:scmp_staff_app/views/staff_directory_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupInjection();
  runApp(const MyApp(initialRoute: '/login'));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SCMP Staff App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      initialRoute: initialRoute,
      routes: {
        '/showcase': (context) => const AssignmentShowcaseView(),
        '/login': (context) => const LoginView(),
        '/staff': (context) => const StaffDirectoryView(),
      },
    );
  }
}
