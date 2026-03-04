import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/constants/app_constants.dart';
import 'core/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase before app starts
  try {
    await FirebaseService().initialize();
  } catch (e) {
    debugPrint('Firebase initialization failed during startup: $e');
  }
  
  // Configure Windows window (desktop only) - temporarily disabled for web compatibility
  // if (!kIsWeb) {
  //   try {
  //     await windowManager.ensureInitialized();
      
  //     WindowOptions windowOptions = const WindowOptions(
  //       size: Size(1200, 800),
  //       center: true,
  //       backgroundColor: Colors.white,
  //       skipTaskbar: false,
  //       titleBarStyle: TitleBarStyle.hidden,
  //       title: AppConstants.appName,
  //     );
      
  //     await windowManager.waitUntilReadyToShow(windowOptions);
  //     await windowManager.show();
  //     await windowManager.focus();
  //   } catch (e) {
  //     // Window manager failed, continue without it
  //     print('Window manager initialization failed: $e');
  //   }
  // }

  runApp(
    const ProviderScope(
      child: SmartERPApp(),
    ),
  );
}

class SmartERPApp extends ConsumerWidget {
  const SmartERPApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: AppRouter.router,
      builder: (context, child) {
        return child ?? const SizedBox();
      },
    );
  }
}
