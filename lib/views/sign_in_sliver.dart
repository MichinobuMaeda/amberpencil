import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

import '../config/l10n.dart';

class SignInSliver extends ConsumerWidget {
  const SignInSliver({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bodyHeight = min<double>(
      max(
        MediaQuery.of(context).size.height - 192.0,
        96.0,
      ),
      320.0,
    );

    return SliverToBoxAdapter(
      child: SizedBox(
        height: bodyHeight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(child: Text(L10n.of(context)!.signIn)),
          ],
        ),
      ),
    );
  }
}
