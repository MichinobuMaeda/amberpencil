import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth_bloc.dart';
import '../../blocs/repository_request_delegate_bloc.dart';
import '../../config/app_info.dart';
import '../../config/theme.dart';
import '../../config/validators.dart';
import '../../config/l10n.dart';
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
              BlocProvider(create: (context) => _EmailFieldFormBloc(context)),
              BlocProvider(
                  create: (context) => _PasswordFieldFormBloc(context)),
              BlocProvider(create: (_) => _ShowPasswordCubit(false)),
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
                              context.read<_EmailFieldFormBloc>().controller,
                          decoration: InputDecoration(
                            labelText: L10n.of(context)!.email,
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
                                    .watch<_EmailFieldFormBloc>()
                                    .state
                                    .ready &&
                                !context.watch<RepositoryRequestBloc>().state
                            ? () {
                                context.read<RepositoryRequestBloc>().add(
                                      RepositoryRequest(
                                        request: onSendEmailLink(
                                          context,
                                          context
                                              .read<_EmailFieldFormBloc>()
                                              .state
                                              .value,
                                        ),
                                        successMessage:
                                            L10n.of(context)!.sentUrlForSignIn,
                                        errorMessage:
                                            L10n.of(context)!.erroSendEmail,
                                      ),
                                    );
                              }
                            : null,
                        child: Text(
                          L10n.of(context)!.siginInWithEmail,
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
                              context.read<_PasswordFieldFormBloc>().controller,
                          decoration: InputDecoration(
                            labelText: L10n.of(context)!.password,
                            suffixIcon: IconButton(
                              icon: Icon(
                                context.watch<_ShowPasswordCubit>().state
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                context.read<_ShowPasswordCubit>().toggle();
                              },
                            ),
                          ),
                          onChanged: onPasswordChanged(context),
                          style:
                              const TextStyle(fontFamily: fontFamilyMonoSpace),
                          obscureText:
                              !context.watch<_ShowPasswordCubit>().state,
                        ),
                      ),
                    ],
                  ),
                  WrappedRow(
                    children: [
                      OutlinedButton(
                        onPressed: context
                                    .watch<_EmailFieldFormBloc>()
                                    .state
                                    .ready &&
                                context
                                    .watch<_PasswordFieldFormBloc>()
                                    .state
                                    .ready
                            ? () {
                                context.read<RepositoryRequestBloc>().add(
                                      RepositoryRequest(
                                        request: onSignInWithPassword(
                                          context,
                                          context
                                              .read<_EmailFieldFormBloc>()
                                              .state
                                              .value,
                                          context
                                              .read<_PasswordFieldFormBloc>()
                                              .state
                                              .value,
                                        ),
                                        onSuccess: () {},
                                        errorMessage: L10n.of(context)!
                                            .errorSignInWithPassword,
                                      ),
                                    );
                              }
                            : null,
                        child: Text(
                          L10n.of(context)!.siginInWithPasword,
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
        context.read<_EmailFieldFormBloc>().add(SingleFieldFormChanged(value));
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
      };

  void Function(String) onPasswordChanged(BuildContext context) =>
      (String value) {
        context
            .read<_PasswordFieldFormBloc>()
            .add(SingleFieldFormChanged(value));
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
      };

  VoidCallback onResetEmail(BuildContext context) => () {
        context.read<_EmailFieldFormBloc>().add(SingleFieldFormReset());

        String initValue =
            context.read<_EmailFieldFormBloc>().state.initialValue;
        TextEditingController controller =
            context.read<_EmailFieldFormBloc>().controller;

        controller.text = initValue;
        controller.selection = TextSelection(
          baseOffset: controller.text.length,
          extentOffset: controller.text.length,
        );
      };
}

Future<void> Function() onSendEmailLink(
  BuildContext context,
  String value,
) =>
    () => context.read<AuthBloc>().sendSignInLinkToEmail(value);

Future<void> Function() onSignInWithPassword(
  BuildContext context,
  String email,
  String value,
) =>
    () => context.read<AuthBloc>().signInWithEmailAndPassword(email, value);

class _EmailFieldFormBloc extends SingleFieldFormBloc<String> {
  _EmailFieldFormBloc(BuildContext context)
      : super('', validator: emailValidator(context));
}

class _PasswordFieldFormBloc extends SingleFieldFormBloc<String> {
  _PasswordFieldFormBloc(BuildContext context) : super('');
}

class _ShowPasswordCubit extends Cubit<bool> {
  _ShowPasswordCubit(bool initialState) : super(initialState);
  void toggle() => emit(!state);
}

Future<void> Function() onTestLogin(BuildContext context) => () async {
      await context.read<AuthBloc>().signInWithEmailAndPassword(
            'primary@example.com',
            'password',
          );
    };
