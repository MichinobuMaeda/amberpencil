import 'package:flutter/material.dart';
import '../config/theme.dart';

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showMessageBar(
  BuildContext context,
  String message, {
  bool? error,
}) =>
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: TextButton.icon(
          label: Text(message),
          icon: const Icon(Icons.close),
          onPressed: () {
            closeMessageBar(context);
          },
          style: ButtonStyle(
            foregroundColor: error == true
                ? MaterialStateProperty.all<Color>(
                    Theme.of(context).colorScheme.error,
                  )
                : null,
          ),
        ),
        duration: const Duration(seconds: 30),
      ),
    );

void closeMessageBar(BuildContext context) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
}

class CenteringColumn extends StatelessWidget {
  final List<Widget> children;
  final double width;

  const CenteringColumn({
    Key? key,
    required this.children,
    this.width = 960.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.vertical,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints.tightFor(width: width),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}

class WrappedRow extends StatelessWidget {
  final List<Widget> children;
  final WrapAlignment alignment;
  final WrapCrossAlignment crossAxisAlignment;

  const WrappedRow({
    Key? key,
    required this.children,
    this.alignment = WrapAlignment.start,
    this.crossAxisAlignment = WrapCrossAlignment.center,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Wrap(
        spacing: 16.0,
        runSpacing: 16.0,
        alignment: alignment,
        crossAxisAlignment: crossAxisAlignment,
        children: children,
      ),
    );
  }
}

class InputContainer extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;

  const InputContainer({
    Key? key,
    required this.child,
    this.width = 480.0,
    this.height = 84.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.tight(Size(width, height)),
      child: child,
    );
  }
}

class PasswordFormField extends StatefulWidget {
  final String labelText;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;

  const PasswordFormField({
    Key? key,
    required this.labelText,
    this.onChanged,
    this.validator,
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
      style: const TextStyle(fontFamily: fontFamilyMonoSpace),
      onChanged: widget.onChanged,
      validator: widget.validator,
    );
  }
}
