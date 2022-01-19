import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../config/app_info.dart';
import '../../config/theme.dart';
import '../../config/validators.dart';
import '../../repositories/auth_repository.dart';
import '../../utils/env.dart';
import '../theme_widgets/box_sliver.dart';
import '../theme_widgets/default_input_container.dart';
import '../theme_widgets/wrapped_row.dart';
import '../theme_widgets/single_field_form_bloc.dart';

class SignInSliver extends StatelessWidget {
  const SignInSliver({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BoxSliver(
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
                              onPressed: onResetEmail(context),
                            ),
                          ),
                          style:
                              const TextStyle(fontFamily: fontFamilyMonoSpace),
                          onChanged: onEmailChanged(context),
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
                                        onSendEmailLink(context),
                                        onErrorSendEmailLink(context),
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
                          onChanged: onPasswordChanged(context),
                          style:
                              const TextStyle(fontFamily: fontFamilyMonoSpace),
                          obscureText:
                              !context.watch<ShowPasswordCubit>().state,
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
                                        onSignInWithPassword(context),
                                        onErrorSinInWithPassword(context),
                                      ),
                                    );
                              }
                            : null,
                        child: const Text('メールアドレスとパスワードでログインする'),
                        style: ButtonStyle(minimumSize: buttonMinimumSize),
                      ),
                    ],
                  ),
                  if (isTestMode(version))
                    WrappedRow(
                      children: [
                        ElevatedButton(
                          onPressed: onTestLogin(context),
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

  void Function(String) onEmailChanged(BuildContext context) => (String value) {
        context.read<EmailFieldFormBloc>().add(SingleFieldFormChanged(value));
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
      };

  void Function(String) onPasswordChanged(BuildContext context) =>
      (String value) {
        context
            .read<PasswordFieldFormBloc>()
            .add(SingleFieldFormChanged(value));
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
      };

  VoidCallback onResetEmail(BuildContext context) => () {
        context.read<EmailFieldFormBloc>().add(SingleFieldFormReset());

        String initValue = context.read<EmailFieldFormBloc>().initialValue;
        TextEditingController controller =
            context.read<EmailFieldFormBloc>().controller;

        controller.text = initValue;
        controller.selection = TextSelection(
          baseOffset: controller.text.length,
          extentOffset: controller.text.length,
        );
      };

  Future<void> Function(String) onSendEmailLink(BuildContext context) =>
      (String value) async {
        await context.read<AuthRepository>().sendSignInLinkToEmail(value);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'ログイン用のリンクをメールで送信しました。',
            ),
          ),
        );
      };

  Future<void> Function(String) onSignInWithPassword(BuildContext context) =>
      (String value) async {
        await context.read<AuthRepository>().signInWithEmailAndPassword(
              context.watch<EmailFieldFormBloc>().state.value,
              value,
            );
      };

  VoidCallback onErrorSendEmailLink(BuildContext context) => () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'メールが送信できませんでした。'
              '通信の状態を確認してやり直してください。',
            ),
          ),
        );
      };

  VoidCallback onErrorSinInWithPassword(BuildContext context) => () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'ログインできませんでした。'
              'メールアドレスとパスワードを確認してやり直してください。',
            ),
          ),
        );
      };

  Future<void> Function() onTestLogin(BuildContext context) => () async {
        await context.read<AuthRepository>().signInWithEmailAndPassword(
              'primary@example.com',
              'password',
            );
      };
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
