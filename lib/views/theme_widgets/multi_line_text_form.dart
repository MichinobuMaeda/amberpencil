import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

import '../helpers/single_field_form_bloc.dart';
import 'text_form.dart';
import 'wrapped_row.dart';

typedef _Bloc = SingleFieldFormBloc<String>;

class MultiLineTextForm extends TextForm {
  final int inputMaxLines;
  final TextFormOnSave _onSave;
  final bool markdown;
  final MarkdownStyleSheet? markdownStyleSheet;

  const MultiLineTextForm({
    Key? key,
    required String label,
    required TextFormOnSave onSave,
    TextStyle? style,
    this.inputMaxLines = 12,
    this.markdown = false,
    this.markdownStyleSheet,
  })  : _onSave = onSave,
        super(
          key: key,
          label: label,
          onSave: onSave,
          style: style,
        );

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: context.watch<_Bloc>().state.editMode,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WrappedRow(
                  alignment: WrapAlignment.end,
                  children: [
                    TextField(
                      controller: context.read<_Bloc>().controller,
                      decoration: InputDecoration(
                        labelText: label,
                        errorText: context.watch<_Bloc>().state.validationError,
                      ),
                      style: style,
                      onChanged: (value) {
                        context
                            .read<_Bloc>()
                            .add(SingleFieldFormChanged(value));
                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      },
                      maxLines: 12,
                    ),
                    ElevatedButton.icon(
                      onPressed: context.watch<_Bloc>().state.buttonEnabled
                          ? () {
                              context.read<_Bloc>().add(
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
                        context.read<_Bloc>().controller.text =
                            context.read<_Bloc>().state.initialValue;
                        context.read<_Bloc>().add(SingleFieldFormReset());
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
                      data: context.read<_Bloc>().state.initialValue,
                      selectable: true,
                      styleSheet: markdownStyleSheet,
                      onTapLink: onTapLink,
                    )
                  : Text(
                      context.read<_Bloc>().state.initialValue,
                      style: style,
                    ),
              Visibility(
                visible: !context.watch<_Bloc>().state.editMode,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {
                        context.read<_Bloc>().add(
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
      );

  void onTapLink(String text, String? href, String title) {
    if (href != null) launch(href);
  }
}
