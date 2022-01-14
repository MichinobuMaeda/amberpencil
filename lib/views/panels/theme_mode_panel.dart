import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/theme_mode_provider.dart';
import '../widgets/box_sliver.dart';

const List<String> themeModeList = ['自動', 'ライト', 'ダーク'];

class ThemeModePanel extends StatelessWidget {
  const ThemeModePanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModeProvider>(builder: (context, themeMode, child) {
      return BoxSliver(
        children: List<Widget>.generate(
          themeModeList.length,
          (int index) {
            return ChoiceChip(
              label: Text(themeModeList[index]),
              selected: themeMode.selected == index,
              onSelected: (bool selected) {
                if (selected) {
                  themeMode.selected = index;
                }
              },
            );
          },
        ).toList(),
      );
    });
  }
}
