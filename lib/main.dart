import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/theme/scratch_theme.dart';
import 'providers/connection_provider.dart';
import 'providers/robot_provider.dart';
import 'providers/control_provider.dart';
import 'providers/tuning_provider.dart';
import 'screens/garage_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to landscape orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  runApp(const RobotControllerApp());
}

class RobotControllerApp extends StatelessWidget {
  const RobotControllerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(844, 390), // iPhone 14 Pro landscape
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ConnectionProvider()),
            ChangeNotifierProvider(create: (_) => RobotProvider()),
            ChangeNotifierProvider(create: (_) => ControlProvider()),
            ChangeNotifierProvider(create: (_) => TuningProvider()),
          ],
          child: MaterialApp(
            title: 'Robot Controller - Scratch Edition',
            debugShowCheckedModeBanner: false,
            theme: ScratchTheme.lightTheme,
            home: const GarageScreen(),
          ),
        );
      },
    );
  }
}
