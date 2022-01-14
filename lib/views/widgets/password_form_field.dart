import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PasswordFormState extends ChangeNotifier {
  bool hidePassword = true;

  void toggle() {
    hidePassword = !hidePassword;
    notifyListeners();
  }
}

class PasswordFormField extends StatelessWidget {
  final String labelText;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final TextStyle? style;

  const PasswordFormField({
    Key? key,
    required this.labelText,
    this.onChanged,
    this.validator,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PasswordFormState>(
      create: (context) => PasswordFormState(),
      child: Builder(
        builder: (context) => TextFormField(
          decoration: InputDecoration(
            labelText: labelText,
            suffixIcon: IconButton(
              icon: Icon(
                context.watch<PasswordFormState>().hidePassword
                    ? Icons.visibility_off
                    : Icons.visibility,
              ),
              onPressed: () {
                context.read<PasswordFormState>().toggle();
              },
            ),
          ),
          obscureText: context.watch<PasswordFormState>().hidePassword,
          style: style,
          onChanged: onChanged,
          validator: validator,
        ),
      ),
    );
  }
}
