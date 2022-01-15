import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/app_state_provider.dart';
import '../../utils/time_ticker_bloc.dart';
import '../widgets/box_sliver.dart';
import 'reauthentication_panel.dart';
import 'edit_my_email_section.dart';
import 'edit_my_password_section.dart';

bool isExpired(
  DateTime ticker,
  DateTime reauthedAt,
  bool testMode,
) =>
    ticker.difference(reauthedAt).inMilliseconds >
    (testMode ? 10 * 1000 : 1800 * 1000);

class TestModeCubit extends Cubit<bool> {
  TestModeCubit(bool initialState) : super(initialState);
  void set(bool state) => emit(state);
}

class EditMyEmaiPasswordPanel extends StatelessWidget {
  const EditMyEmaiPasswordPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BoxSliver(
        children: (context.watch<AppStateProvider>().me?.email ?? '') == ''
            ? [
                const Text('メールアドレスとパスワードは設定されていません。'),
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
                      context.watch<TimeTickerBloc>().state,
                      context.watch<AppStateProvider>().reauthedAt ??
                          DateTime(2000),
                      context.watch<TestModeCubit>().state,
                    )
                        ? Column(children: const [
                            ReauthenticationPanel(),
                          ])
                        : Column(children: const [
                            EditMyEmailSection(),
                            EditMyPasswordSection(),
                          ]),
                  ),
                ),
              ],
      );
  //             Visibility(
  //               visible: context.watch<AppStateProvider>().isTest,
  //               child: Wrap(
  //                 crossAxisAlignment: WrapCrossAlignment.center,
  //                 children: [
  //                   Switch(
  //                     value: context.watch<TestModeCubit>().state,
  //                     onChanged: context.read<TestModeCubit>().set,
  //                   ),
  //                   const Text('Test'),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   ],

}
