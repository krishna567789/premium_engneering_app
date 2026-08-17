import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:premium_engneering_app/features/auth/data/auth_repository.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:premium_engneering_app/features/auth/provider/auth_provider.dart';
import 'package:premium_engneering_app/features/home/provider/home_provider.dart';
import 'package:premium_engneering_app/features/home/data/home_repository.dart';

import 'core/theme.dart' show AppTheme;
import 'core/theme_provider.dart';
import 'core/network/api_client.dart';
import 'features/splash/splash_screen.dart';
import 'features/auth/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final apiClient = ApiClient(Dio());
  final authRepository = AuthRepository(apiClient);

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MyApp(authRepository: authRepository),
    ),
  );
}
class MyApp extends StatelessWidget {
  final AuthRepository authRepository;

  MyApp({super.key, required this.authRepository});
  final apiClient = ApiClient(Dio());

  @override
  Widget build(BuildContext context) {
    final homeRepository = HomeRepository(apiClient);
    return MultiProvider(
      providers: [
        Provider<AuthRepository>.value(value: authRepository),
        Provider<HomeRepository>.value(value: homeRepository),
        ChangeNotifierProvider(create: (_) => AuthProvider(authRepository)),
        ChangeNotifierProvider(
          create: (_) => HomeProvider(homeRepository, authRepository),
        ),
      ],

      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          final themeProvider = Provider.of<ThemeProvider>(context);
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Premium Engineering',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(),
              '/login': (context) => const LoginScreen(),
            },
          );
        },
      ),
    );
  }
}
