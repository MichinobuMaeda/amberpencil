part of '../widgets.dart';

class PasswordFormField extends StatefulWidget {
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
  State<StatefulWidget> createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  bool _hidePassword = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: widget.labelText,
        suffixIcon: IconButton(
          icon: Icon(_hidePassword ? Icons.visibility_off : Icons.visibility),
          onPressed: () {
            setState(() {
              _hidePassword = !_hidePassword;
            });
          },
        ),
      ),
      obscureText: _hidePassword,
      style: widget.style,
      onChanged: widget.onChanged,
      validator: widget.validator,
    );
  }
}
