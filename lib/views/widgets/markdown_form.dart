import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

import 'single_field_form_bloc.dart';
import 'wrapped_row.dart';

typedef _State = SingleFieldFormBloc<String>;

typedef MarkdownFormValidate = SingleFieldValidate<String>;
typedef MarkdownFormOnSave = SingleFieldOnSave<String>;

VoidCallback onChange(
  BuildContext context,
) =>
    () {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
    };

VoidCallback onReset(
  TextEditingController controller,
  String initialValue,
) =>
    () {
      controller.text = initialValue;
      controller.selection = TextSelection(
        baseOffset: controller.text.length,
        extentOffset: controller.text.length,
      );
    };

VoidCallback onError(
  BuildContext context,
) =>
    () {
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
  final String? initialValue;
  final MarkdownFormValidate? validator;
  final bool editable;
  final MarkdownFormOnSave _onSave;
  final TextStyle? style;
  final MarkdownStyleSheet? markdownStyleSheet;

  const MarkdownForm({
    Key? key,
    required this.label,
    this.initialValue,
    this.validator,
    required MarkdownFormOnSave onSave,
    this.style,
    this.markdownStyleSheet,
    this.editable = false,
  })  : _onSave = onSave,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: initialValue ?? '');

    return BlocProvider(
      key: ValueKey(
          'ProviderOf:MarkdownForm:${key.toString()}:${initialValue ?? ''}'),
      create: (context) => SingleFieldFormBloc<String>(
        initialValue ?? '',
        withEditMode: true,
      ),
      // withEditMode: true,
      child: Builder(
        builder: (context) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Visibility(
              visible: editable && context.watch<_State>().state.editMode,
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
                          errorText: context
                              .watch<_State>()
                              .state
                              .validationErrorMessage,
                        ),
                        style: style,
                        onChanged: (value) {
                          context.read<_State>().add(
                                SingleFieldFormChanged(
                                  value,
                                  validate: validator,
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
                MarkdownBody(
                  data: initialValue ?? '',
                  selectable: true,
                  styleSheet: markdownStyleSheet,
                  onTapLink: onTapLink,
                ),
                Visibility(
                  visible: editable && !context.watch<_State>().state.editMode,
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
}
