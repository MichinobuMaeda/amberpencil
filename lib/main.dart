import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'config/firebase_options.dart';
import 'config/theme.dart';
import 'models/app_info.dart';
import 'models/theme_mode_provider.dart';
import 'models/app_state_provider.dart';
import 'services/sys_service.dart';
import 'services/auth_service.dart';
import 'services/accounts_service.dart';
import 'screens/base_screen.dart';
import 'utils/env.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // assets
  final AppInfo appInfo = AppInfo.fromJson(
    await rootBundle.loadString('assets/app_info.json'),
  );

  // Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await useFirebaseEmulators(
    appInfo.version,
    FirebaseAuth.instance,
    FirebaseFirestore.instance,
    FirebaseFunctions.instance,
    firebase_storage.FirebaseStorage.instance,
  );

  // Service providers
  SysService sysService = SysService(
    FirebaseFirestore.instance,
  );
  AuthService authService = AuthService(
    FirebaseAuth.instance,
    FirebaseFirestore.instance,
  );
  AccountsService accountsService = AccountsService(
    FirebaseFirestore.instance,
  );

  runApp(
    MultiProvider(
      // Change notifiers that listen service providers
      providers: [
        ChangeNotifierProvider(
          create: (context) => AppStateProvider(
            appInfo,
            sysService,
            authService,
            accountsService,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ThemeModeProvider(
            authService,
            accountsService,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModeProvider>(builder: (context, themeMode, child) {
      return Consumer<AppStateProvider>(builder: (context, appState, child) {
        return MaterialApp(
          title: appState.appInfo.name,
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
          themeMode: themeMode.themeMode,
          home: BaseScreen(
            key: ValueKey(appState.clientState.toString()),
            appState: appState,
          ),
        );
      });
    });
  }
}
