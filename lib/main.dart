import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'config/app_info.dart';
import 'config/firebase_options.dart';
import 'config/theme.dart';
import 'models/theme_mode_provider.dart';
import 'models/app_state_provider.dart';
import 'models/conf_provider.dart';
import 'services/conf_service.dart';
import 'services/auth_service.dart';
import 'services/accounts_service.dart';
import 'utils/env.dart';
import 'utils/platform_web.dart';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  final String deepLink = getCurrentUrl();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await useFirebaseEmulators(
    version,
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
            accountsService,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => AppStateProvider(
            confService,
            authService,
            accountsService,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ConfProvider(
            confService,
          ),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final AppRouterDelegate _routerDelegate = AppRouterDelegate();
  final AppRouteInformationParser _routeInformationParser =
      AppRouteInformationParser();

  @override
  Widget build(BuildContext context) {
    context.read<AppStateProvider>().routeStateListener = _routerDelegate;
    return MaterialApp.router(
      title: appName,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: context.watch<ThemeModeProvider>().themeMode,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('ja', ''),
      ],
      locale: const Locale('ja', 'JP'),
      routerDelegate: _routerDelegate,
      routeInformationParser: _routeInformationParser,
    );
  }
}
