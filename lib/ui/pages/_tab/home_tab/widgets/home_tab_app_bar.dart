import 'package:flutter/material.dart';
import 'package:flutter_market_app/core/snackbar_util.dart';
import 'package:flutter_market_app/ui/pages/_tab/home_tab/home_tab_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_market_app/data/model/address.dart';

class HomeTabAppBar extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> _updateAddress(String userId, Address newAddress) async {
    print('===== 주소 업데이트 시작 =====');
    print('userId: $userId');
    print('newAddress: ${newAddress.fullNameKR}');

    try {
      await firestore.collection('users').doc(userId).update({
        'defaultAddress': newAddress.fullNameKR,
        'cityKR': newAddress.cityKR,
        'countryKR': newAddress.countryKR,
      });
      print('Firebase 주소 업데이트 성공');
    } catch (e) {
      print('Firebase 주소 업데이트 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('===== HomeTabAppBar build 시작 =====');
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final List<Address> serviceableAddresses = Address.serviceableAreas
        .map((area) => Address(
              id: '',
              fullNameKR: '${area['cityKR']}, ${area['countryKR']}',
              fullNameEN: '${area['cityEN']}, ${area['countryEN']}',
              cityKR: area['cityKR']!,
              cityEN: area['cityEN']!,
              countryKR: area['countryKR']!,
              countryEN: area['countryEN']!,
              isServiceAvailable: true,
              defaultYn: false,
            ))
        .toList();

    return AppBar(
      automaticallyImplyLeading: false,
      title: Consumer(
        builder: (context, ref, child) {
          print('===== AppBar Consumer builder 호출 =====');
          final homeTabState = ref.watch(homeTabViewModel);

          final currentAddress = homeTabState.addresses
              .where((e) => e.defaultYn ?? false)
              .firstOrNull;

          print(
              '현재 주소 목록: ${homeTabState.addresses.map((e) => '${e.cityKR}(${e.defaultYn})')}');
          print('선택된 현재 주소: ${currentAddress?.cityKR}');

          final displayAddress = currentAddress != null
              ? '${currentAddress.cityKR}, ${currentAddress.countryKR}'
              : '';

          print('화면에 표시될 주소: $displayAddress');

          return Theme(
            data: Theme.of(context).copyWith(
              popupMenuTheme: PopupMenuThemeData(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                color: isDarkMode ? Colors.grey[850] : Colors.white,
              ),
            ),
            child: PopupMenuButton<Address>(
              position: PopupMenuPosition.under,
              offset: const Offset(0, 12),
              color: isDarkMode ? Colors.grey[850] : Colors.white,
              elevation: 8,
              shadowColor: Colors.black.withOpacity(0.2),
              surfaceTintColor: Colors.transparent,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayAddress,
                      style: TextStyle(
                        fontSize: 20,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ],
                ),
              ),
              onSelected: (Address selectedAddress) async {
                print('===== 주소 선택됨 =====');
                print('선택된 주소: ${selectedAddress.cityKR}');

                final userId = FirebaseAuth.instance.currentUser?.uid;

                if (userId == null) {
                  print('사용자 ID 없음');
                  SnackbarUtil.showSnackBar(context, '로그인이 필요합니다');
                  return;
                }

                print('현재 사용자 ID: $userId');

                // 선택된 주소로 업데이트
                final newAddress = selectedAddress.copyWith(
                  defaultYn: true,
                  isServiceAvailable: true,
                );

                print(
                    '새 주소 객체 생성: ${newAddress.cityKR} (defaultYn: ${newAddress.defaultYn})');

                // 파이어베이스 업데이트
                await _updateAddress(userId, newAddress);

                print('ViewModel 상태 업데이트 시작');
                // ViewModel 상태 업데이트
                ref.read(homeTabViewModel.notifier).updateDefaultAddress(
                      newAddress.cityKR,
                    );
                print('ViewModel 상태 업데이트 완료');

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '주소가 업데이트되었습니다: ${newAddress.fullNameKR}',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      backgroundColor:
                          isDarkMode ? Colors.grey[850] : Colors.white,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 8,
                      margin: EdgeInsets.all(16),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              itemBuilder: (BuildContext context) {
                print('PopupMenu itemBuilder 호출');
                return serviceableAddresses.map((address) {
                  return PopupMenuItem<Address>(
                    value: address,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            address.fullNameKR,
                            style: TextStyle(
                              fontSize: 16,
                              color: isDarkMode ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            address.fullNameEN,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList();
              },
            ),
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

  void _showSearchDialog(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 200),
          child: AlertDialog(
            backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            title: Text(
              '상품 검색',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            content: TextField(
              decoration: InputDecoration(
                hintText: "검색어를 입력하세요",
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Colors.purple.shade900,
                    width: 2,
                  ),
                ),
              ),
              cursorColor: Colors.purple.shade900,
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  '검색',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.purple.shade900,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text(
                  '취소',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
