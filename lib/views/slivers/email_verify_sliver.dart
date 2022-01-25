import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/time_ticker_bloc.dart';
import '../../blocs/my_account_bloc.dart';
import '../../config/theme.dart';
import '../../blocs/auth_bloc.dart';
import '../theme_widgets/box_sliver.dart';
import '../theme_widgets/wrapped_row.dart';

class SendCubit extends Cubit<bool> {
  SendCubit(bool initialState) : super(initialState);
  void set(bool state) => emit(state);
}

class EmailVerifySliver extends StatelessWidget {
  const EmailVerifySliver({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BoxSliver(
        children: [
          MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => SendCubit(false)),
              BlocProvider(
                create: (context) => TimeTickerBloc(
                  interval: const Duration(seconds: 1),
                  onTick: authUserReload(context),
                  start: false,
                ),
                lazy: false,
              ),
            ],
            child: Builder(
              builder: (context) => Column(
                children: [
                  WrappedRow(
                    width: fieldWidth,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.emailVerificationRequired,
                      ),
                    ],
                  ),
                  WrappedRow(
                    width: fieldWidth,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          await context
                              .read<AuthBloc>()
                              .sendEmailVerification();
                          context.read<SendCubit>().set(true);
                          context.read<TimeTickerBloc>().activate();
                        },
                        label: Text(AppLocalizations.of(context)!.send),
                        icon: const Icon(Icons.send),
                      ),
                    ],
                  ),
                  if (context.watch<SendCubit>().state)
                    WrappedRow(
                      width: fieldWidth,
                      children: [
                        Text(AppLocalizations.of(context)!.sentUrlToVerify),
                      ],
                    ),
                  if (context.watch<SendCubit>().state)
                    WrappedRow(
                      width: fieldWidth,
                      children: [
                        ElevatedButton(
                          onPressed: authUserReload(context),
                          child: Text(AppLocalizations.of(context)!.update),
                        ),
                      ],
                    ),
                  WrappedRow(
                    width: fieldWidth,
                    children: [
                      Text(AppLocalizations.of(context)!.sighOutForRetry),
                    ],
                  ),
                  WrappedRow(
                    width: fieldWidth,
                    children: [
                      ElevatedButton(
                        onPressed: () => context
                            .read<MyAccountBloc>()
                            .add(OnSingOutRequired()),
                        child: Text(AppLocalizations.of(context)!.signOut),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      );

  VoidCallback authUserReload(BuildContext context) =>
      () => context.read<AuthBloc>().add(AuthUserReloaded());
}
