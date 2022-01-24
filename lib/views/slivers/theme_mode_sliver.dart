import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../blocs/platform_bloc.dart';
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
            selected: context.select<PlatformBloc, int>(
                    (bloc) => bloc.state.themeMode) ==
                index,
            onSelected: (bool selected) {
              if (selected) {
                context.read<PlatformBloc>().add(ThemeModeChanged(index));
              }
            },
          ),
        ).toList(),
      );
}
