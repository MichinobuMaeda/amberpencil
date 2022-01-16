import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../config/theme.dart';
import '../../config/validators.dart';
import '../../models/app_state_provider.dart';
import '../widgets/box_sliver.dart';
import '../widgets/default_input_container.dart';
import '../widgets/wrapped_row.dart';
import '../widgets/single_field_form_bloc.dart';

class SignInSliver extends StatelessWidget {
  const SignInSliver({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BoxSliver(
      children: [
        MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => EmailFieldFormBloc()),
            BlocProvider(create: (_) => PasswordFieldFormBloc()),
            BlocProvider(create: (_) => ShowPasswordCubit(false)),
          ],
          child: Builder(
            builder: (context) => Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                WrappedRow(
                  children: [
                    DefaultInputContainer(
                      child: TextField(
                        controller:
                            context.read<EmailFieldFormBloc>().controller,
                        decoration: InputDecoration(
                          labelText: 'メールアドレス',
                          suffixIcon: IconButton(
                              icon: const Icon(Icons.cancel),
                              onPressed: () {
                                context
                                    .read<EmailFieldFormBloc>()
                                    .add(SingleFieldFormReset());
                                resetController(
                                  context.read<EmailFieldFormBloc>().controller,
                                  context
                                      .read<EmailFieldFormBloc>()
                                      .initialValue,
                                );
                              }),
                        ),
                        style: const TextStyle(fontFamily: fontFamilyMonoSpace),
                        onChanged: (value) {
                          context
                              .read<EmailFieldFormBloc>()
                              .add(SingleFieldFormChanged(value));
                          ScaffoldMessenger.of(context).removeCurrentSnackBar();
                        },
                      ),
                    ),
                  ],
                ),
                WrappedRow(
                  children: [
                    OutlinedButton(
                      onPressed: context
                              .watch<EmailFieldFormBloc>()
                              .state
                              .buttonEnabled
                          ? () {
                              context.read<EmailFieldFormBloc>().add(
                                    SingleFieldFormSave(
                                      (value) async {
                                        await context
                                            .read<AppStateProvider>()
                                            .authService
                                            .sendSignInLinkToEmail(value);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'ログイン用のリンクをメールで送信しました。',
                                            ),
                                          ),
                                        );
                                      },
                                      () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'メールが送信できませんでした。'
                                              '通信の状態を確認してやり直してください。',
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                            }
                          : null,
                      child: const Text('ログイン用のURLをメールで受け取る'),
                      style: ButtonStyle(minimumSize: buttonMinimumSize),
                    ),
                  ],
                ),
                WrappedRow(
                  children: [
                    DefaultInputContainer(
                      child: TextField(
                        controller:
                            context.read<PasswordFieldFormBloc>().controller,
                        decoration: InputDecoration(
                          labelText: 'パスワード',
                          suffixIcon: IconButton(
                            icon: Icon(
                              context.watch<ShowPasswordCubit>().state
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              context.read<ShowPasswordCubit>().toggle();
                            },
                          ),
                        ),
                        onChanged: (value) {
                          context
                              .read<PasswordFieldFormBloc>()
                              .add(SingleFieldFormChanged(value));
                          ScaffoldMessenger.of(context).removeCurrentSnackBar();
                        },
                        style: const TextStyle(fontFamily: fontFamilyMonoSpace),
                        obscureText: !context.watch<ShowPasswordCubit>().state,
                      ),
                    ),
                  ],
                ),
                WrappedRow(
                  children: [
                    OutlinedButton(
                      onPressed: context
                                  .watch<EmailFieldFormBloc>()
                                  .state
                                  .buttonEnabled &&
                              context
                                  .watch<PasswordFieldFormBloc>()
                                  .state
                                  .buttonEnabled
                          ? () {
                              context.read<PasswordFieldFormBloc>().add(
                                    SingleFieldFormSave(
                                      (value) => context
                                          .read<AppStateProvider>()
                                          .authService
                                          .signInWithEmailAndPassword(
                                            context
                                                .watch<EmailFieldFormBloc>()
                                                .state
                                                .value,
                                            value,
                                          ),
                                      () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'ログインできませんでした。'
                                              'メールアドレスとパスワードを確認してやり直してください。',
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                            }
                          : null,
                      child: const Text('メールアドレスとパスワードでログインする'),
                      style: ButtonStyle(minimumSize: buttonMinimumSize),
                    ),
                  ],
                ),
                if (context.read<AppStateProvider>().isTest)
                  WrappedRow(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await context
                              .read<AppStateProvider>()
                              .authService
                              .signInWithEmailAndPassword(
                                'primary@example.com',
                                'password',
                              );
                        },
                        child: const Text('Test'),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            Theme.of(context).colorScheme.secondary,
                          ),
                          foregroundColor: MaterialStateProperty.all<Color>(
                            Theme.of(context).colorScheme.onSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void resetController(
    TextEditingController controller,
    String initialValue,
  ) {
    controller.text = initialValue;
    controller.selection = TextSelection(
      baseOffset: controller.text.length,
      extentOffset: controller.text.length,
    );
  }
}

@visibleForTesting
class EmailFieldFormBloc extends SingleFieldFormBloc<String> {
  EmailFieldFormBloc() : super('', validator: emailValidator);
}

@visibleForTesting
class PasswordFieldFormBloc extends SingleFieldFormBloc<String> {
  PasswordFieldFormBloc() : super('');
}

@visibleForTesting
class ShowPasswordCubit extends Cubit<bool> {
  ShowPasswordCubit(bool initialState) : super(initialState);
  void toggle() => emit(!state);
}
