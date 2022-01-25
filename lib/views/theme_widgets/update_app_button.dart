import 'package:amberpencil/config/theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/platform_bloc.dart';

class UpdateAppButton extends StatelessWidget {
  const UpdateAppButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialBanner(
        content: Text(
          AppLocalizations.of(context)!.updateApp,
          textAlign: TextAlign.right,
        ),
        actions: [
          IconButton(
            onPressed: () => context.read<PlatformBloc>().add(AppReloaded()),
            iconSize: baseFontSize * 2,
            icon: Ink(
              padding: const EdgeInsets.all(4.0),
              decoration: ShapeDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Theme.of(context).primaryColor,
                shape: const CircleBorder(),
              ),
              child: Icon(
                Icons.get_app,
                size: 24.0,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.amber.shade900
                    : Colors.white,
              ),
            ),
          )
        ],
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.amber.shade900
            : Colors.amber.shade400,
      );
}
