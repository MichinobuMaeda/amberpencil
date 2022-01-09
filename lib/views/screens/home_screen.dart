import 'package:flutter/material.dart';
import '../widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter(
      child: CenteringColumn(
        children: [
          Text('Home'),
        ],
      ),
    );
  }
}
