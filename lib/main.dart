import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import "package:universal_html/html.dart" as html;
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'blocs/conf_bloc.dart';
import 'blocs/my_account_bloc.dart';
import 'blocs/route_bloc.dart';
import 'blocs/theme_mode_bloc.dart';
import 'config/app_info.dart';
import 'config/firebase_options.dart';
import 'config/theme.dart';
import 'models/account.dart';
import 'models/auth_user.dart';
import 'models/conf.dart';
import 'models/group.dart';
import 'repositories/accounts_repository.dart';
import 'repositories/auth_repository.dart';
import 'repositories/conf_repository.dart';
import 'repositories/groups_repository.dart';
import 'repositories/platform_repository.dart';
import 'utils/env.dart';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  final String deepLink = PlatformRepository.getCurrentUrl();
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

  runApp(
    MultiProvider(
      providers: [
        Provider(
          create: (_) => PlatformRepository(
            window: html.window,
            deepLink: deepLink,
          ),
        ),
        Provider(
          create: (_) => ConfRepository(
            db: FirebaseFirestore.instance,
          ),
        ),
        Provider(
          create: (_) => AuthRepository(
            auth: FirebaseAuth.instance,
          ),
        ),
        Provider(
          create: (_) => AccountsRepository(
            db: FirebaseFirestore.instance,
          ),
        ),
        Provider(
          create: (_) => GroupsRepository(
            db: FirebaseFirestore.instance,
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => VersionCubit()),
          BlocProvider(create: (_) => UrlCubit()),
          BlocProvider(create: (_) => PolicyCubit()),
          BlocProvider(create: (context) => ThemeModeBloc(context)),
          BlocProvider(create: (context) => RouteBloc(context)),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => MyAccountBloc(context)),
          ],
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (context) => AppRouterDelegate(context),
              ),
              Provider(
                create: (_) => AppRouteInformationParser(),
              ),
            ],
            child: Builder(
              builder: (context) {
                context.read<AuthRepository>().start(
                  (AuthUser? authUser) {
                    context
                        .read<MyAccountBloc>()
                        .add(OnAuthUserUpdated(authUser));
                  },
                  context.read<PlatformRepository>(),
                );

                context.read<ConfRepository>().start(
                  (Conf? conf) {
                    context.read<VersionCubit>().set(conf?.version);
                    context.read<UrlCubit>().set(conf?.url);
                    context.read<PolicyCubit>().set(conf?.policy);
                    context.read<AuthRepository>().url = conf?.url;
                    context.read<RouteBloc>().add(OnConfUpdated(conf));
                  },
                );

                context.read<AccountsRepository>().start(
                  (List<Account> accounts) {
                    context
                        .read<MyAccountBloc>()
                        .add(OnAccountsUpdated(accounts));
                  },
                );

                context.read<GroupsRepository>().start(
                      (List<Group> accounts) {},
                    );
                return const MyApp();
              },
            ),
          ),
        ),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: appName,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: supportedThemeModes[context.watch<ThemeModeBloc>().state],
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
        routerDelegate: context.read<AppRouterDelegate>(),
        routeInformationParser: context.read<AppRouteInformationParser>(),
      );
}
