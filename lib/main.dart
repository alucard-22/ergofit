import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/database/app_database.dart';
import 'core/database/database_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Forzar orientación vertical
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar transparente con íconos claros
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor:           Colors.transparent,
      statusBarIconBrightness:  Brightness.light,
    ),
  );

  // Inicializar el servicio de notificaciones
  await NotificationService.instance.init();

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(AppDatabase()),
      ],
      child: const ErgoFitApp(),
    ),
  );
}

class ErgoFitApp extends StatelessWidget {
  const ErgoFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title:                    'ErgoFit',
      debugShowCheckedModeBanner: false,
      theme:                    AppTheme.darkTheme,
      routerConfig:             AppRouter.router,
    );
  }
}