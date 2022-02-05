import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../config/app_info.dart';
import '../../config/theme.dart';
import '../../blocs/my_account_bloc.dart';
import '../../blocs/platform_bloc.dart';
import '../../blocs/time_ticker_bloc.dart';
import '../../config/l10n.dart';
import '../../utils/env.dart';
import '../theme_widgets/box_sliver.dart';
import '../theme_widgets/wrapped_row.dart';
import '../panels/confirm_my_email_panel.dart';
import '../panels/confirm_my_password_panel.dart';
import '../panels/edit_my_email_panel.dart';
import '../panels/edit_my_password_panel.dart';

bool isExpired(
  int ticker,
  int reauthedAt,
  bool testMode,
) {
  // debugPrint('$ticker $reauthedAt $testMode');
  return ticker - reauthedAt > (testMode ? 10 * 1000 : 1800 * 1000);
}

class TestModeCubit extends Cubit<bool> {
  TestModeCubit(bool initialState) : super(initialState);
  void set(bool state) => emit(state);
}

class EditMyEmaiPasswordSliver extends StatelessWidget {
  const EditMyEmaiPasswordSliver({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BoxSliver(
        children: (context.watch<MyAccountBloc>().state.me?.email ?? '') == ''
            ? [
                Text(L10n.of(context)!.noEmailAndPassword),
              ]
            : [
                MultiBlocProvider(
                  providers: [
                    BlocProvider(create: (_) => TestModeCubit(false)),
                    BlocProvider(
                      create: (_) => TimeTickerBloc(
                        interval: const Duration(seconds: 10),
                      ),
                      lazy: false,
                    ),
                  ],
                  child: Builder(
                    builder: (context) => isExpired(
                      context
                          .watch<TimeTickerBloc>()
                          .state
                          .millisecondsSinceEpoch,
                      context.watch<PlatformBloc>().state.signedInAt,
                      context.watch<TestModeCubit>().state,
                    )
                        ? Column(
                            children: [
                              WrappedRow(
                                width: fieldWidth,
                                children: [
                                  Text(
                                    L10n.of(context)!.reauthRequired,
                                  ),
                                ],
                              ),
                              const ConfirmMyEmailPanel(),
                              const ConfirmMyPasswordPanel(),
                              const ExpirationTestSwitch(),
                            ],
                          )
                        : Column(
                            children: const [
                              EditMyEmailPanel(),
                              EditMyPasswordPanel(),
                              ExpirationTestSwitch(),
                            ],
                          ),
                  ),
                ),
              ],
      );
}

class ExpirationTestSwitch extends StatelessWidget {
  const ExpirationTestSwitch({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Visibility(
        visible: isTestMode(version),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Switch(
              value: context.watch<TestModeCubit>().state,
              onChanged: context.read<TestModeCubit>().set,
            ),
            const Text('Test'),
          ],
        ),
      );
}
