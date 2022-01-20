import 'package:flutter/material.dart';
// import '../theme_widgets/box_sliver.dart';

class AccountsSliver extends StatelessWidget {
  const AccountsSliver({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => SliverList(
        delegate: SliverChildListDelegate(
          [
            Container(height: 150.0),
            Container(color: Colors.grey, height: 150.0),
            Container(height: 150.0),
            Container(color: Colors.grey, height: 150.0),
            Container(height: 150.0),
          ],
        ),
      );
}
