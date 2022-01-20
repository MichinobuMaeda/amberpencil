import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/route_bloc.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import '../deligates/sticky_header_delegate.dart';

class PageTitileSliver extends StatelessWidget {
  const PageTitileSliver({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MenuItem? menuItem;
    try {
      menuItem = menuItems.singleWhere((item) =>
          item.routeName == context.watch<RouteBloc>().state.history.last.name);
    } catch (e) {
      menuItem = null;
    }

    return SliverPersistentHeader(
      pinned: true,
      delegate: StickyHeaderDelegate(
        minHeight: baseFontSize * 2.5,
        maxHeight: baseFontSize * 3.5,
        child: ColoredBox(
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.grey.shade300
              : Colors.grey.shade700,
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: fontSizeH2 * 1.6,
                height: fontSizeH2 * 1.6,
                child: menuItem?.icon ?? const Icon(Icons.description),
              ),
              Text(
                menuItem?.label ?? '',
                style: const TextStyle(
                  fontSize: fontSizeH2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
