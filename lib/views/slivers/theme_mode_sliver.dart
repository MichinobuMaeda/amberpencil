import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/theme_mode_provider.dart';
import '../widgets/box_sliver.dart';

const List<String> themeModeList = ['自動', 'ライト', 'ダーク'];

class ThemeModeSliver extends StatelessWidget {
  const ThemeModeSliver({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BoxSliver(
        children: List<Widget>.generate(
          themeModeList.length,
          (int index) {
            return ChoiceChip(
              label: Text(themeModeList[index]),
              selected: context.watch<ThemeModeProvider>().selected == index,
              onSelected: (bool selected) {
                if (selected) {
                  context.read<ThemeModeProvider>().selected = index;
                }
              },
            );
          },
        ).toList(),
      );
}
