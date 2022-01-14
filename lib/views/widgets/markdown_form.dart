import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'single_field_form_state.dart';
import 'wrapped_row.dart';

typedef _OnSaveCallBack = OnFormSaveCallBack<String>;
typedef _State = SingleFieldFormState<String>;

VoidCallback onChange(BuildContext context) => () {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
    };

VoidCallback onError(BuildContext context) => () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('保存できませんでした。通信の状態を確認してやり直してください。'),
        ),
      );
    };

void onTapLink(String text, String? href, String title) {
  if (href != null) launch(href);
}

class MarkdownForm extends StatelessWidget {
  final String label;
  final String initialValue;
  final bool editable;
  final _OnSaveCallBack _onSave;
  final TextStyle? style;
  final MarkdownStyleSheet? markdownStyleSheet;

  const MarkdownForm({
    Key? key,
    required this.label,
    required this.initialValue,
    required _OnSaveCallBack onSave,
    this.style,
    this.markdownStyleSheet,
    this.editable = false,
  })  : _onSave = onSave,
        super(key: key);

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        key: ValueKey('ProviderOf:$label:$initialValue'),
        create: (context) => _State(
          formKey: GlobalKey<FormState>(),
          initialValue: initialValue,
          onChange: onChange(context),
          withEditMode: true,
        ),
        child: Builder(
          builder: (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Visibility(
                visible: editable && context.watch<_State>().edit,
                child: Form(
                  key: context.read<_State>().formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WrappedRow(
                        alignment: WrapAlignment.end,
                        children: [
                          TextFormField(
                            initialValue: context.read<_State>().initialValue,
                            decoration: InputDecoration(labelText: label),
                            style: style,
                            onChanged: context.read<_State>().setValue,
                            maxLines: 12,
                          ),
                          ElevatedButton.icon(
                            onPressed: context.watch<_State>().save(
                                  onSave: _onSave,
                                  onError: onError(context),
                                ),
                            label: const Text('保存'),
                            icon: const Icon(Icons.save_alt),
                          ),
                          ElevatedButton.icon(
                            onPressed: context.read<_State>().disableEdit,
                            label: const Text('中止'),
                            icon: const Icon(Icons.cancel),
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
              Stack(
                children: [
                  MarkdownBody(
                    data: context.read<_State>().value,
                    selectable: true,
                    styleSheet: markdownStyleSheet,
                    onTapLink: onTapLink,
                  ),
                  Visibility(
                    visible: editable && !context.watch<_State>().edit,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: context.read<_State>().enableEdit,
                          icon: const Icon(Icons.edit),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}
