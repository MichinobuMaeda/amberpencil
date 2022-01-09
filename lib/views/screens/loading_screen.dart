import 'package:flutter/material.dart';
import '../widgets.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: CenteringColumn(
        children: [
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Flexible(
                child: Text(
                  'しばらくお待ちください',
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(),
              ),
              SizedBox(height: 16),
            ],
          ),
        ],
      ),
    );
  }
}
