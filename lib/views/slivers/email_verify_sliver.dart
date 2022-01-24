import 'package:flutter/material.dart';
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
                  const WrappedRow(
                    width: fieldWidth,
                    children: [
                      Text(
                        '初めて使うメールアドレスの確認が必要です。'
                        '下の「送信」ボタンを押してください。'
                        '登録されたメールアドレスに確認のためのメールを送信しますので、'
                        'そのメールに記載された確認のためのボタンを押してください。',
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
                        label: const Text('送信'),
                        icon: const Icon(Icons.send),
                      ),
                    ],
                  ),
                  if (context.watch<SendCubit>().state)
                    const WrappedRow(
                      width: fieldWidth,
                      children: [
                        Text(
                          '確認のためのメールを送信しました。'
                          'そのメールに記載された確認のためのボタンを押しても'
                          'この表示が自動で切り替わらない場合は'
                          '下の「更新」ボタンを押してください。',
                        ),
                      ],
                    ),
                  if (context.watch<SendCubit>().state)
                    WrappedRow(
                      width: fieldWidth,
                      children: [
                        ElevatedButton(
                          onPressed: authUserReload(context),
                          child: const Text('更新'),
                        ),
                      ],
                    ),
                  const WrappedRow(
                    width: fieldWidth,
                    children: [
                      Text(
                        'メールアドレスを修正してやり直す場合はログアウトしてください。',
                      ),
                    ],
                  ),
                  WrappedRow(
                    width: fieldWidth,
                    children: [
                      ElevatedButton(
                        onPressed: () => context
                            .read<MyAccountBloc>()
                            .add(OnSingOutRequired()),
                        child: const Text('ログアウト'),
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
