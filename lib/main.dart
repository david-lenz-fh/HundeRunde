import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starter_flutter/controllers/dogwalk_controller.dart';
import 'package:starter_flutter/controllers/dogwalk_recorder.dart';
import 'package:starter_flutter/controllers/location_controller.dart';
import 'package:starter_flutter/controllers/theme_controller.dart';
import 'package:starter_flutter/controllers/weather_controller.dart';
import 'package:starter_flutter/screens/check_in_screen.dart';
import 'package:starter_flutter/screens/login_screen.dart';
import 'package:starter_flutter/screens/main_screen.dart';
import 'package:starter_flutter/services/pocketbase_service.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final themeController = await ThemeController.load(prefs);
  await PocketBaseService.instance.init();

  var hasCheckedIn = prefs.getBool('hasCheckedIn') ?? false;
  hasCheckedIn = false;
  runApp(MyApp(showCheckIn: !hasCheckedIn, themeController: themeController));
}

class MyApp extends StatelessWidget {
  final bool showCheckIn;
  final ThemeController themeController;
  const MyApp({super.key, required this.showCheckIn, required this.themeController});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => LocationController(),
        ),
        ChangeNotifierProvider(
          create: (context) => WeatherController(context.read<LocationController>()),
        ),
        
        ChangeNotifierProvider(
          create: (context) => DogWalkController(),
        ),

        ChangeNotifierProvider(
          create: (context) => DogWalkRecorder(),
        ),
        ChangeNotifierProvider.value(
          value: PocketBaseService.instance,
        ),
        ChangeNotifierProvider.value(
          value: themeController,
        ),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, _) => MaterialApp(
          title: 'Dog Walk App',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: const Color(0xFFF4F5F7),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.blue,
          ),
          themeMode: themeController.themeMode,
          home: Consumer2<PocketBaseService, DogWalkController>(
            builder: (context, pbService, dogwalkController, _) {
              if (!pbService.isLoggedIn) {
                return const LoginRegisterScreen();
              }
              if(dogwalkController.currentDog==null){
                return const DogCheckInScreen();
              }

              return const MainScreen();
            },
          ),
        ),
      ),
    );
  }
}
