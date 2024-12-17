import 'package:flutter/material.dart';
import 'package:flutter_market_app/core/snackbar_util.dart';
import 'package:flutter_market_app/ui/pages/_tab/home_tab/home_tab_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_market_app/data/model/address.dart'; // Address 모델 import 추가

class HomeTabAppBar extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> _updateAddress(String userId, String newAddress) async {
    try {
      await firestore.collection('users').doc(userId).update({
        'defaultAddress': newAddress,
      });
    } catch (e) {
      print('주소 업데이트 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 서비스 가능 지역 리스트를 Address 객체로 변환
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
            ))
        .toList();

    return AppBar(
      automaticallyImplyLeading: false,
      title: Consumer(
        builder: (context, ref, child) {
          final homeTabState = ref.watch(homeTabViewModel);
          final target = homeTabState.addresses
              .where((e) => e.defaultYn ?? false)
              .toList();
          final addr = target.isEmpty
              ? ''
              : '${target.first.cityKR}, ${target.first.countryKR}';

          return PopupMenuButton<Address>(
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
            onSelected: (Address selectedAddress) async {
              final userId = FirebaseAuth.instance.currentUser?.uid;

              if (userId == null) {
                SnackbarUtil.showSnackBar(context, '로그인이 필요합니다');
                return;
              }

              final newAddress = selectedAddress.fullNameKR;
              await _updateAddress(userId, newAddress);

              ref
                  .read(homeTabViewModel.notifier)
                  .updateDefaultAddress(newAddress);

              SnackbarUtil.showSnackBar(
                  context, '주소가 업데이트되었습니다: ${selectedAddress.fullNameKR}');
            },
            itemBuilder: (BuildContext context) {
              return serviceableAddresses.map((address) {
                return PopupMenuItem<Address>(
                  value: address,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(address.fullNameKR),
                      Text(
                        address.fullNameEN,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
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

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade900
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            '상품 검색',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          content: TextField(
            decoration: InputDecoration(
              hintText: "검색어를 입력하세요",
              hintStyle: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                '검색',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              onPressed: () {
                // 검색 로직 구현
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                '취소',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
