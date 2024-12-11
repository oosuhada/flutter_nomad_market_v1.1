import 'package:flutter/material.dart';
import 'package:flutter_market_app/core/snackbar_util.dart';
import 'package:flutter_market_app/ui/pages/home/_tab/home_tab/home_tab_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeTabAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // bottom 속성. 사용X. => Scaffold의 appBar사용 가능.
    return AppBar(
      title: Consumer(builder: (context, ref, child) {
        final homeTabState = ref.watch(homeTabViewModel);
        final target =
            homeTabState.addresses.where((e) => e.defaultYn ?? false).toList();
        final addr = target.isEmpty ? '' : target.first.displayName;
        return Text(addr);
      }),
      actions: [
        GestureDetector(
          onTap: () {
            SnackbarUtil.showSnackBar(context, '준비중입니다.');
          },
          child: Container(
            width: 50,
            height: 50,
            color: Colors.transparent,
            child: Icon(Icons.search),
          ),
        ),
      ],
    );
  }
}
