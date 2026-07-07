import 'package:scmp_staff_app/core/services/api_service.dart';
import 'package:get_it/get_it.dart';
import 'package:scmp_staff_app/core/services/database_service.dart';
import 'package:scmp_staff_app/repositories/auth_repository.dart';
import 'package:scmp_staff_app/repositories/staff_repository.dart';
import 'package:scmp_staff_app/viewmodels/auth_viewmodel.dart';
import 'package:scmp_staff_app/viewmodels/staff_viewmodel.dart';

final getIt = GetIt.instance;

Future<void> setupInjection() async {
  // Services
  getIt.registerLazySingleton<ApiService>(() => ApiService());
  getIt.registerLazySingleton<DatabaseService>(() => DatabaseService());

  // Wait for database initialization
  await getIt<DatabaseService>().initDb();

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(dbService: getIt()),
  );
  getIt.registerLazySingleton<StaffRepository>(
    () => StaffRepository(apiService: getIt(), dbService: getIt()),
  );

  // ViewModels
  getIt.registerFactory<AuthViewModel>(
    () => AuthViewModel(authRepository: getIt()),
  );
  getIt.registerFactory<StaffViewModel>(
    () => StaffViewModel(staffRepository: getIt()),
  );
}
