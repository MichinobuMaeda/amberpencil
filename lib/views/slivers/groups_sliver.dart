import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/accounts_bloc.dart';
import '../../blocs/groups_bloc.dart';
import '../../config/l10n.dart';
import '../../config/theme.dart';
import '../../config/validators.dart';
import '../../models/group.dart';
import '../theme_widgets/toggle_delete_restore_button.dart';
import '../theme_widgets/toggle_edit_button.dart';
import '../theme_widgets/text_form_dialog.dart';

class GroupsSliver extends StatelessWidget {
  const GroupsSliver({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => _DeleteModeCubit()),
          BlocProvider(create: (_) => _EditModeCubit()),
        ],
        child: Builder(
          builder: (context) => SliverFixedExtentList(
            itemExtent: baseFontSize * 3,
            delegate: SliverChildListDelegate([
              Row(
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: Text(L10n.of(context)!.add),
                    onPressed: onAdd(context),
                  ),
                  const Spacer(),
                  Text(L10n.of(context)!.deleteOrRestor),
                  Switch(
                    value: context.watch<_DeleteModeCubit>().state,
                    onChanged: (bool value) {
                      context.read<_EditModeCubit>().reset();
                      context.read<_DeleteModeCubit>().set(value);
                    },
                  ),
                ],
              ),
              ...context
                  .watch<GroupsBloc>()
                  .state
                  .where(
                    (group) =>
                        context.watch<_DeleteModeCubit>().state ||
                        group.deletedAt == null,
                  )
                  .toList()
                  .asMap()
                  .entries
                  .map(
                    (item) => Container(
                      color: item.key % 2 == 0 ? listOddEvenItemColor : null,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Center(
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: baseFontSize,
                            children: buildRow(
                              context: context,
                              group: item.value,
                              deleteMode:
                                  context.watch<_DeleteModeCubit>().state,
                              editMode: context.watch<_EditModeCubit>().state ==
                                  item.value.id,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ]),
          ),
        ),
      );

  List<Widget> buildRow({
    required BuildContext context,
    required Group group,
    required bool deleteMode,
    required bool editMode,
  }) =>
      [
        deleteMode
            ? ToggleDeleteRestoreButton(
                deleted: group.deletedAt != null,
                collection: L10n.of(context)!.group,
                item: group.name,
                onDelete: () async {
                  await context.read<GroupsBloc>().delete(group.id);
                  Navigator.of(context).pop();
                },
                onRestore: () async {
                  await context.read<GroupsBloc>().restore(group.id);
                  Navigator.of(context).pop();
                },
              )
            : ToggleEditButton(
                editMode: !editMode,
                onEdit: () => context.read<_EditModeCubit>().set(group.id),
                onClose: () => context.read<_EditModeCubit>().reset(),
              ),
        ToggleEditButton(
          editMode: editMode,
          icon: const Icon(Icons.group),
          onEdit: onEditName(context, group),
        ),
        Text(group.name),
        ToggleEditButton(
          editMode: editMode,
          icon: const Icon(Icons.description),
          onEdit: onEditDesc(context, group),
        ),
        Text(group.desc),
        ToggleEditButton(
          editMode: editMode,
          icon: const Icon(Icons.person),
          onEdit: () {},
        ),
        ...context
            .watch<AccountsBloc>()
            .state
            .where((account) => group.accounts.contains(account.id))
            .map((account) => Text(account.name))
            .toList(),
      ];
}

VoidCallback onAdd(
  BuildContext context,
) =>
    () {
      context.read<_EditModeCubit>().reset();
      showDialog(
        context: context,
        builder: (context) => TextFormDialog(
          initialValue: '',
          label: L10n.of(context)!.group,
          validator: requiredValidator(context),
          onSave: (value) => () => context.read<GroupsBloc>().create(
                {Group.fieldName: value},
              ),
        ),
      );
    };

VoidCallback onEditName(
  BuildContext context,
  Group group,
) =>
    () => showDialog(
          context: context,
          builder: (context) => TextFormDialog(
            initialValue: group.name,
            label: L10n.of(context)!.group,
            validator: requiredValidator(context),
            onSave: (value) => () => context.read<GroupsBloc>().update(
                  group.id,
                  {Group.fieldName: value},
                ),
          ),
        );

VoidCallback onEditDesc(
  BuildContext context,
  Group group,
) =>
    () => showDialog(
          context: context,
          builder: (context) => TextFormDialog(
            initialValue: group.desc,
            label: L10n.of(context)!.group,
            onSave: (value) => () => context.read<GroupsBloc>().update(
                  group.id,
                  {Group.fieldDesc: value},
                ),
          ),
        );

class _DeleteModeCubit extends Cubit<bool> {
  _DeleteModeCubit() : super(false);
  set(bool value) => emit(value);
}

class _EditModeCubit extends Cubit<String?> {
  _EditModeCubit() : super(null);
  set(String value) => emit(value);
  reset() => emit(null);
}
