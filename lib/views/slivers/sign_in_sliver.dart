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
              BlocProvider(create: (context) => _EmailFieldBloc(context)),
              BlocProvider(create: (context) => _PasswordFieldBloc(context)),
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
                              context.read<_EmailFieldBloc>().controller,
                          decoration: InputDecoration(
                            labelText: L10n.of(context)!.email,
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.cancel),
                              onPressed: () => context
                                  .read<_EmailFieldBloc>()
                                  .add(SingleFieldFormReset()),
                            ),
                          ),
                          style:
                              const TextStyle(fontFamily: fontFamilyMonoSpace),
                          onChanged: (value) => context
                              .read<_EmailFieldBloc>()
                              .add(SingleFieldFormChanged(value)),
                        ),
                      ),
                    ],
                  ),
                  WrappedRow(
                    children: [
                      OutlinedButton(
                        onPressed: onSendEmalLinkPressed(context),
                        child: Text(
                          L10n.of(context)!.siginInWithEmail,
                        ),
                        style: buttonStyle,
                      ),
                    ],
                  ),
                  WrappedRow(
                    children: [
                      DefaultInputContainer(
                        child: TextField(
                          controller:
                              context.read<_PasswordFieldBloc>().controller,
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
                          onChanged: (value) => context
                              .read<_PasswordFieldBloc>()
                              .add(SingleFieldFormChanged(value)),
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
                        onPressed: onSignInWithPasswordPressed(context),
                        child: Text(
                          L10n.of(context)!.siginInWithPasword,
                        ),
                        style: buttonStyle,
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
}

VoidCallback? onSendEmalLinkPressed(
  BuildContext context,
) =>
    context.watch<_EmailFieldBloc>().state.ready &&
            !context.watch<RepositoryRequestBloc>().state
        ? () {
            context.read<RepositoryRequestBloc>().add(
                  RepositoryRequest(
                    request: () =>
                        context.read<AuthBloc>().sendSignInLinkToEmail(
                              context.read<_EmailFieldBloc>().state.value,
                            ),
                    successMessage: L10n.of(context)!.sentUrlForSignIn,
                    errorMessage: L10n.of(context)!.erroSendEmail,
                  ),
                );
          }
        : null;

VoidCallback? onSignInWithPasswordPressed(
  BuildContext context,
) =>
    context.watch<_EmailFieldBloc>().state.ready &&
            context.watch<_PasswordFieldBloc>().state.ready
        ? () {
            context.read<RepositoryRequestBloc>().add(
                  RepositoryRequest(
                    request: () =>
                        context.read<AuthBloc>().signInWithEmailAndPassword(
                              context.read<_EmailFieldBloc>().state.value,
                              context.read<_PasswordFieldBloc>().state.value,
                            ),
                    onSuccess: () {},
                    errorMessage: L10n.of(context)!.errorSignInWithPassword,
                  ),
                );
          }
        : null;

class _EmailFieldBloc extends SingleFieldFormBloc<String> {
  _EmailFieldBloc(BuildContext context)
      : super('', validator: emailValidator(context));
}

class _PasswordFieldBloc extends SingleFieldFormBloc<String> {
  _PasswordFieldBloc(BuildContext context) : super('');
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
