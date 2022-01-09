import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_state_provider.dart';
import '../widgets.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          return const CenteringColumn(
            children: [
              Text('test'),
            ],
          );
        },
      ),
    );
  }
}
