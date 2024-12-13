import 'package:flutter/material.dart';
import 'package:flutter_market_app/core/snackbar_util.dart';
import 'package:flutter_market_app/ui/pages/home/_tab/home_tab/home_tab_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeTabAppBar extends StatelessWidget {
  void _showSearchDialog(BuildContext context) {
    String searchQuery = "";
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '상품검색',
            style: TextStyle(fontSize: 18),
          ),
          content: TextField(
            onChanged: (value) {
              searchQuery = value;
            },
            decoration: InputDecoration(
              hintText: '검색할 키워드 입력',
              hintStyle: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
                fontWeight: FontWeight.bold,
              ),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.grey[600]!,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.grey[400]!,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.red[300]!,
                  width: 2,
                ),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Search'),
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: 검색 로직 구현
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.purple.shade900,
              ),
            ),
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.purple.shade900,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Consumer(
        builder: (context, ref, child) {
          final homeTabState = ref.watch(homeTabViewModel);
          final target = homeTabState.addresses
              .where((e) => e.defaultYn ?? false)
              .toList();
          final addr = target.isEmpty ? '' : target.first.displayName;

          return PopupMenuButton<String>(
            position: PopupMenuPosition.under,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  addr,
                  style: TextStyle(fontSize: 20),
                  overflow: TextOverflow.ellipsis,
                ),
                Icon(Icons.keyboard_arrow_down, size: 20),
              ],
            ),
            onSelected: (String newCity) {
              // TODO: 도시 선택 로직 구현
            },
            itemBuilder: (BuildContext context) {
              return homeTabState.addresses.map((address) {
                return PopupMenuItem<String>(
                  value: address.displayName,
                  child: Text(address.displayName ?? ''),
                );
              }).toList();
            },
          );
        },
      ),
      actions: [
        IconButton(
          onPressed: () => _showSearchDialog(context),
          icon: const Icon(Icons.search, size: 30),
        ),
      ],
    );
  }
}

// class HomeTabAppBar extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     // bottom 속성. 사용X. => Scaffold의 appBar사용 가능.
//     return AppBar(
//       title: Consumer(builder: (context, ref, child) {
//         final homeTabState = ref.watch(homeTabViewModel);
//         final target =
//             homeTabState.addresses.where((e) => e.defaultYn ?? false).toList();
//         final addr = target.isEmpty ? '' : target.first.displayName;
//         return Text(addr);
//       }),
//       actions: [
//         GestureDetector(
//           onTap: () {
//             SnackbarUtil.showSnackBar(context, '준비중입니다.');
//           },
//           child: Container(
//             width: 50,
//             height: 50,
//             color: Colors.transparent,
//             child: Icon(Icons.search),
//           ),
//         ),
//       ],
//     );
//   }
// }
