import 'package:amberpencil/config/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/ui_utils.dart';

class EditMarkdownPanel extends StatefulWidget {
  final String label;
  final String? initialValue;
  final bool editable;
  final Future<void> Function(String text) onSave;

  const EditMarkdownPanel({
    Key? key,
    required this.label,
    this.initialValue,
    required this.onSave,
    this.editable = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EditMarkdownState();
}

class _EditMarkdownState extends State<EditMarkdownPanel> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _value;
  bool _waiting = false;
  bool _edit = false;

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

    void Function()? onSave = (_waiting || _value == widget.initialValue)
        ? null
        : () async {
            setState(() {
              _waiting = true;
            });
            try {
              await widget.onSave(_value);
              setState(() {
                _waiting = false;
                _edit = false;
                _value = widget.initialValue ?? '';
              });
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.editable && _edit)
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WrappedRow(
                  alignment: WrapAlignment.end,
                  children: [
                    TextFormField(
                      initialValue: widget.initialValue ?? '',
                      decoration: InputDecoration(labelText: widget.label),
                      style: const TextStyle(fontFamily: fontFamilyMonoSpace),
                      onChanged: onValueChanged,
                      maxLines: 12,
                    ),
                    ElevatedButton.icon(
                      onPressed: onSave,
                      label: const Text('保存'),
                      icon: const Icon(Icons.save_alt),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _edit = false;
                          _value = widget.initialValue ?? '';
                        });
                      },
                      label: const Text('中止'),
                      icon: const Icon(Icons.cancel),
                      style: secondaryElevatedButtonStyle,
                    ),
                  ],
                ),
              ],
            ),
          ),
        Stack(
          children: [
            MarkdownBody(
              data: widget.initialValue ?? '',
              selectable: true,
              styleSheet: markdownStyleSheet,
              onTapLink: (String text, String? href, String title) {
                if (href != null) launch(href);
              },
            ),
            if (widget.editable && !_edit)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _edit = true;
                        _value = widget.initialValue ?? '';
                      });
                    },
                    icon: const Icon(Icons.edit),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
