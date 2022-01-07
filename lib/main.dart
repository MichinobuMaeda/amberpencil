import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
import 'models/app_info_provider.dart';
import 'services/conf_service.dart';
import 'services/auth_service.dart';
import 'services/accounts_service.dart';
import 'views/base_screen.dart';
import 'utils/env.dart';
import 'utils/platform_web.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // assets
  final AppStaticInfo appInfo = AppStaticInfo.fromJson(
    await rootBundle.loadString('app_info.json'),
  );

  // Firebase
  final String deepLink = getCurrentUrl();
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
  ConfService confService = ConfService(
    FirebaseFirestore.instance,
  );
  AuthService authService = AuthService(
    FirebaseAuth.instance,
    FirebaseFirestore.instance,
    deepLink,
  );
  AccountsService accountsService = AccountsService(
    FirebaseFirestore.instance,
  );

  runApp(
    MultiProvider(
      // Change notifiers that listen service providers
      providers: [
        ChangeNotifierProvider(
          create: (context) => ThemeModeProvider(
            authService,
            accountsService,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => AppStateProvider(
            appInfo,
            confService,
            authService,
            accountsService,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => AppInfoProvider(
            appInfo,
            confService,
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
        AppInfoProvider appInfoProvider =
            Provider.of<AppInfoProvider>(context, listen: false);

        return MaterialApp(
          title: appInfoProvider.data.name,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeMode.themeMode,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
            Locale('ja', ''),
          ],
          home: BaseScreen(
            key: ValueKey(appState.clientState.toString()),
            appState: appState,
          ),
        );
      });
    });
  }
}
