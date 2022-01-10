part of '../widgets.dart';

class TextForm extends StatefulWidget {
  final String label;
  final String? initialValue;
  final String? Function(String?)? validator;
  final Future<void> Function(String text) onSave;
  final bool monospace;

  const TextForm({
    Key? key,
    required this.label,
    this.initialValue,
    this.validator,
    required this.onSave,
    this.monospace = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TextFormState();
}

class _TextFormState extends State<TextForm> {
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
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    '保存できませんでした。'
                    '通信の状態を確認してやり直してください。',
                  ),
                ),
              );
            }
          };

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.always,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          WrappedRow(
            alignment: WrapAlignment.center,
            children: [
              DefaultInputContainer(
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
                  validator: widget.validator,
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
