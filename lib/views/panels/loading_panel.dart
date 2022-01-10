import 'package:flutter/material.dart';

class LoadingPanel extends StatelessWidget {
  const LoadingPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          SizedBox(
            width: 64,
            height: 64,
            child: CircularProgressIndicator(),
          ),
          SizedBox(height: 32),
          Flexible(child: Text('しばらくお待ちください')),
        ],
      ),
    );
  }
}
