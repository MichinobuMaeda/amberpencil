import 'package:amberpencil/config/theme.dart';
import 'package:flutter/material.dart';
import '../utils/ui_utils.dart';
import '../config/validators.dart';

class EditRequiredTextPanel extends StatefulWidget {
  final String label;
  final String? initialValue;
  final Future<void> Function(String text) onSave;
  final bool monospace;

  const EditRequiredTextPanel({
    Key? key,
    required this.label,
    this.initialValue,
    required this.onSave,
    this.monospace = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EditRequiredTextState();
}

class _EditRequiredTextState extends State<EditRequiredTextPanel> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _value;
  bool _waiting = false;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue ?? '';
  }

  @override
  Widget build(BuildContext context) {
    void onValueChanged(String value) {
      setState(() {
        _value = value;
        _waiting = false;
        closeMessageBar(context);
      });
    }

    void Function()? onSave = (_waiting ||
            _formKey.currentState?.validate() != true ||
            _value == widget.initialValue)
        ? null
        : () async {
            setState(() {
              _waiting = true;
            });
            try {
              await widget.onSave(_value);
            } catch (e) {
              setState(() {
                _waiting = false;
              });
              showMessageBar(
                context,
                '保存できませんでした。'
                '通信の状態を確認してやり直してください。',
                error: true,
              );
            }
          };

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.always,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WrappedRow(
            alignment: WrapAlignment.end,
            children: [
              InputContainer(
                child: TextFormField(
                  initialValue: widget.initialValue,
                  decoration: InputDecoration(
                    labelText: widget.label,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.cancel),
                      onPressed: () {
                        setState(() {
                          _formKey.currentState?.reset();
                          _value = widget.initialValue ?? '';
                        });
                      },
                    ),
                  ),
                  validator: (value) => requiredValidator(value),
                  style: widget.monospace
                      ? const TextStyle(fontFamily: fontFamilyMonoSpace)
                      : null,
                  onChanged: onValueChanged,
                ),
              ),
              ElevatedButton.icon(
                onPressed: onSave,
                label: const Text('保存'),
                icon: const Icon(Icons.save_alt),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
