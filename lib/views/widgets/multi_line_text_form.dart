import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

import 'single_field_form_bloc.dart';
import 'text_form.dart';
import 'wrapped_row.dart';

typedef _State = SingleFieldFormBloc<String>;

class MultiLineTextForm extends TextForm {
  final int inputMaxLines;
  // "withEditMode: false" is not yet supported.
  final bool withEditMode = true;
  final TextFormOnSave _onSave;
  final bool markdown;
  final MarkdownStyleSheet? markdownStyleSheet;

  const MultiLineTextForm({
    Key? key,
    required String label,
    String? initialValue,
    TextFormValidate? validator,
    required TextFormOnSave onSave,
    TextStyle? style,
    this.inputMaxLines = 12,
    this.markdown = false,
    this.markdownStyleSheet,
    // this.withEditMode = false,
  })  : _onSave = onSave,
        super(
          key: key,
          label: label,
          initialValue: initialValue,
          validator: validator,
          onSave: onSave,
          style: style,
        );

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: initialValue ?? '');

    return BlocProvider(
      key: ValueKey(
          'ProviderOf:MarkdownForm:${key.toString()}:${initialValue ?? ''}'),
      create: (context) => SingleFieldFormBloc<String>(
        initialValue ?? '',
        withEditMode: withEditMode,
      ),
      child: Builder(
        builder: (context) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Visibility(
              visible: withEditMode && context.watch<_State>().state.editMode,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WrappedRow(
                    alignment: WrapAlignment.end,
                    children: [
                      TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: label,
                          errorText:
                              context.watch<_State>().state.validationError,
                        ),
                        style: style,
                        onChanged: (value) {
                          context.read<_State>().add(
                                SingleFieldFormChanged(
                                  value,
                                  validator: validator,
                                  onValueChange: onChange(context),
                                ),
                              );
                        },
                        maxLines: 12,
                      ),
                      ElevatedButton.icon(
                        onPressed: context.watch<_State>().state.buttonEnabled
                            ? () {
                                context.read<_State>().add(
                                      SingleFieldFormSave(
                                        _onSave,
                                        onError(context),
                                      ),
                                    );
                              }
                            : null,
                        label: const Text('保存'),
                        icon: const Icon(Icons.save_alt),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<_State>().add(
                                SingleFieldFormReset(
                                  onReset(controller, initialValue ?? ''),
                                ),
                              );
                        },
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
            Stack(
              children: [
                markdown
                    ? MarkdownBody(
                        data: initialValue ?? '',
                        selectable: true,
                        styleSheet: markdownStyleSheet,
                        onTapLink: onTapLink,
                      )
                    : Text(
                        initialValue ?? '',
                        style: style,
                      ),
                Visibility(
                  visible:
                      withEditMode && !context.watch<_State>().state.editMode,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () {
                          context.read<_State>().add(
                                SingleFieldFormSetEditMode(),
                              );
                        },
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

  void onTapLink(String text, String? href, String title) {
    if (href != null) launch(href);
  }
}
