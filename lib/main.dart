import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "package:universal_html/html.dart" as html;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:go_router/go_router.dart';
import 'blocs/all_blocs_observer.dart';
import 'blocs/accounts_bloc.dart';
import 'blocs/auth_bloc.dart';
import 'blocs/conf_bloc.dart';
import 'blocs/groups_bloc.dart';
import 'blocs/user_bloc.dart';
import 'blocs/platform_bloc.dart';
import 'config/app_info.dart';
import 'config/firebase_options.dart';
import 'config/theme.dart';
import 'config/l10n.dart';
import 'utils/env.dart';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
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

  final SharedPreferences localPreferences =
      await SharedPreferences.getInstance();

  BlocOverrides.runZoned(
    () {
      runApp(
        MultiBlocProvider(
          providers: [
            BlocProvider(
                create: (_) => PlatformBloc(html.window, localPreferences),
                lazy: false),
            BlocProvider(create: (_) => ConfBloc(), lazy: false),
            BlocProvider(create: (_) => AuthBloc(), lazy: false),
            BlocProvider(create: (_) => UserBloc(), lazy: false),
            BlocProvider(create: (_) => AccountsBloc(), lazy: false),
            BlocProvider(create: (_) => GroupsBloc(), lazy: false),
          ],
          child: Builder(
            builder: (context) {
              context.read<ConfBloc>().add(ConfListenStart());
              context.read<AuthBloc>().add(AuthListenStart(context));

              return const MyApp();
            },
          ),
        ),
      );
    },
    blocObserver: AllBlocsObserver(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final UserBloc userBloc = context.read<UserBloc>();
    final router = GoRouter(
      routerNeglect: true,
      refreshListenable: GoRouterRefreshStream(userBloc.stream),
      initialLocation: routeLoading,
      routes: routes,
      errorBuilder: routeErrorBuilder,
      redirect: guard(userBloc),
    );

    return MaterialApp.router(
      title: appName,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: supportedThemeModes[context.select<PlatformBloc, int>(
        (bloc) => bloc.state.themeMode == 3 ? 0 : bloc.state.themeMode,
      )],
      localizationsDelegates: L10n.localizationsDelegates,
      supportedLocales: L10n.supportedLocales,
      locale: const Locale('ja', 'JP'),
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
    );
  }
}
