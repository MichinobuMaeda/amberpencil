import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'config/firebase_options.dart';
import 'config/theme.dart';
import 'config/version.dart';
import 'router.dart';
import 'models/theme_mode_model.dart';
import 'models/app_state_model.dart';
import 'services/sys_service.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (version == "0.0.0+0") {
    debugPrint('Use emulators.');
    try {
      await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
      FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
      FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
      await firebase_storage.FirebaseStorage.instance
          .useStorageEmulator('localhost', 9199);
    } catch (e) {
      debugPrint('Firestore has already been started.');
    }
  }

  SysService sysService = SysService();
  AuthService authService = AuthService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeModeModel()),
        ChangeNotifierProvider(
            create: (context) => AppStateModel(sysService, authService)),
      ],
      child: const App(),
    ),
  );
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _AppState();
}

class _AppState extends State<App> {
  final AppRouterDelegate _routerDelegate = AppRouterDelegate();
  final AppRouteInformationParser _routeInformationParser =
      AppRouteInformationParser();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateModel>(builder: (context, appStateModel, child) {
      _routerDelegate.guard(appStateModel);
      return Consumer<ThemeModeModel>(
          builder: (context, themeModeModel, child) {
        return MaterialApp.router(
          title: 'Amber pencil',
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: primarySwatchLight,
            fontFamily: fontFamilySansSerif,
            textTheme: textTheme,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: primarySwatchDark,
            fontFamily: fontFamilySansSerif,
            textTheme: textTheme,
          ),
          themeMode: themeModeModel.darkMode ? ThemeMode.dark : ThemeMode.light,
          routerDelegate: _routerDelegate,
          routeInformationParser: _routeInformationParser,
        );
      });
    });
  }
}
