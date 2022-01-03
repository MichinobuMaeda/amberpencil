import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          SizedBox(
            width: 64,
            height: 64,
            child: CircularProgressIndicator(),
          ),
          SizedBox(height: 16),
          Flexible(
            child: Text(
              'システムの情報を取得しています',
            ),
          ),
          // ),
        ],
      ),
    );
  }
}
