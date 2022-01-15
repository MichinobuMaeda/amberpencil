import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ShowPasswordCubit extends Cubit<bool> {
  ShowPasswordCubit(bool initialState) : super(initialState);
  void toggle() => emit(!state);
}

class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final void Function(String)? onChanged;
  final TextStyle? style;
  final String? errorText;

  const PasswordField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.onChanged,
    this.style,
    this.errorText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ShowPasswordCubit>(
      create: (_) => ShowPasswordCubit(false),
      child: Builder(
        builder: (context) => TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: labelText,
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
            errorText: errorText,
          ),
          style: style,
          onChanged: onChanged,
          obscureText: !context.watch<ShowPasswordCubit>().state,
        ),
      ),
    );
  }
}
