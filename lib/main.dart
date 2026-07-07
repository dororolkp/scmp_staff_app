import 'package:flutter/material.dart';
import 'package:scmp_staff_app/di/injection.dart';
import 'package:scmp_staff_app/views/login_view.dart';
import 'package:scmp_staff_app/views/staff_directory_view.dart';
import 'package:scmp_staff_app/core/services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupInjection();
  
  final dbService = getIt<DatabaseService>();
  final token = await dbService.getToken();

  runApp(MyApp(initialRoute: token != null ? '/staff' : '/login'));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({Key? key, required this.initialRoute}) : super(key: key);

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
        '/login': (context) => const LoginView(),
        '/staff': (context) => const StaffDirectoryView(),
      },
    );
  }
}
