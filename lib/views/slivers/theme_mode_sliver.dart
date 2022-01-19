import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../blocs/theme_mode_bloc.dart';
import '../theme_widgets/box_sliver.dart';

const List<String> themeModeList = ['自動', 'ライト', 'ダーク'];

class ThemeModeSliver extends StatelessWidget {
  const ThemeModeSliver({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BoxSliver(
        children: List<Widget>.generate(
          themeModeList.length,
          (int index) => ChoiceChip(
            label: Text(themeModeList[index]),
            selected: context.watch<ThemeModeBloc>().state == index,
            onSelected: (bool selected) {
              if (selected) {
                context.read<ThemeModeBloc>().add(ThemeModeChanged(index));
              }
            },
          ),
        ).toList(),
      );
}
