import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth_bloc.dart';
import '../../config/app_info.dart';
import '../../config/theme.dart';
import '../../config/validators.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/env.dart';
import '../theme_widgets/box_sliver.dart';
import '../theme_widgets/default_input_container.dart';
import '../theme_widgets/wrapped_row.dart';
import '../helpers/single_field_form_bloc.dart';

class SignInSliver extends StatelessWidget {
  const SignInSliver({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BoxSliver(
        children: [
          MultiBlocProvider(
            providers: [
              BlocProvider(create: (context) => EmailFieldFormBloc(context)),
              BlocProvider(create: (context) => PasswordFieldFormBloc(context)),
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
                            labelText: AppLocalizations.of(context)!.email,
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
                        child: Text(
                          AppLocalizations.of(context)!.siginInWithEmail,
                        ),
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
                            labelText: AppLocalizations.of(context)!.password,
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
                                        onSignInWithPassword(
                                          context,
                                          context
                                              .read<EmailFieldFormBloc>()
                                              .state
                                              .value,
                                        ),
                                        onErrorSinInWithPassword(context),
                                      ),
                                    );
                              }
                            : null,
                        child: Text(
                          AppLocalizations.of(context)!.siginInWithPasword,
                        ),
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

        String initValue =
            context.read<EmailFieldFormBloc>().state.initialValue;
        TextEditingController controller =
            context.read<EmailFieldFormBloc>().controller;

        controller.text = initValue;
        controller.selection = TextSelection(
          baseOffset: controller.text.length,
          extentOffset: controller.text.length,
        );
      };

  Future<void> Function(
    String,
    VoidCallback,
  ) onSendEmailLink(BuildContext context) => (
        String value,
        VoidCallback onError,
      ) async {
        await context.read<AuthBloc>().sendSignInLinkToEmail(value, onError);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.sentUrlForSignIn,
            ),
          ),
        );
      };

  Future<void> Function(
    String,
    VoidCallback,
  ) onSignInWithPassword(BuildContext context, String email) => (
        String value,
        VoidCallback onError,
      ) async {
        await context.read<AuthBloc>().signInWithEmailAndPassword(
              email,
              value,
              onError,
            );
      };

  VoidCallback onErrorSendEmailLink(BuildContext context) => () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.erroSendEmail,
            ),
          ),
        );
      };

  VoidCallback onErrorSinInWithPassword(BuildContext context) => () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.errorSignInWithPassword,
            ),
          ),
        );
      };

  Future<void> Function() onTestLogin(BuildContext context) => () async {
        await context.read<AuthBloc>().signInWithEmailAndPassword(
              'primary@example.com',
              'password',
              () {},
            );
      };
}

@visibleForTesting
class EmailFieldFormBloc extends SingleFieldFormBloc<String> {
  EmailFieldFormBloc(BuildContext context)
      : super('', validator: emailValidator(context));
}

@visibleForTesting
class PasswordFieldFormBloc extends SingleFieldFormBloc<String> {
  PasswordFieldFormBloc(BuildContext context) : super('');
}

@visibleForTesting
class ShowPasswordCubit extends Cubit<bool> {
  ShowPasswordCubit(bool initialState) : super(initialState);
  void toggle() => emit(!state);
}
