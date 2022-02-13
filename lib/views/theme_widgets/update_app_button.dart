import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/platform_bloc.dart';
import '../../config/theme.dart';
import '../../config/l10n.dart';

class UpdateAppButton extends StatelessWidget {
  const UpdateAppButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialBanner(
        content: Text(
          L10n.of(context)!.updateApp,
          textAlign: TextAlign.right,
          style: TextStyle(color: Theme.of(context).colorScheme.onError),
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        actions: [
          IconButton(
            onPressed: () => context.read<PlatformBloc>().add(AppReloaded()),
            iconSize: baseFontSize * 2,
            icon: Ink(
              padding: const EdgeInsets.all(spacing / 4),
              decoration: ShapeDecoration(
                color: Theme.of(context).colorScheme.onError,
                shape: const CircleBorder(),
              ),
              child: Icon(
                Icons.get_app,
                size: baseFontSize * 1.5,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          )
        ],
      );
}
