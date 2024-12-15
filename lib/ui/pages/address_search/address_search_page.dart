import 'package:flutter/material.dart';
import 'package:flutter_market_app/ui/pages/currency_search/currency_search_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_market_app/core/geolocator_helper.dart';
import 'package:flutter_market_app/ui/pages/address_search/address_search_view_model.dart';
import 'package:flutter_market_app/ui/pages/join/join_page.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';

class AddressSearchPage extends StatelessWidget {
  final String selectedLanguage;

  const AddressSearchPage({Key? key, required this.selectedLanguage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint("Building AddressSearchPage widget"); // 디버깅 메시지 추가

    return GestureDetector(
      onTap: () {
        debugPrint("Unfocusing any active text fields"); // 디버깅 메시지 추가
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('도시 선택')),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Consumer(builder: (context, ref, child) {
                    debugPrint(
                        "Initializing search field and search logic"); // 디버깅 메시지 추가
                    return Column(
                      children: [
                        const SizedBox(height: 12),
                        TextField(
                          decoration: InputDecoration(
                            hintText: '도시, 국가로 검색 (ex. 서울, 한국)', // 필요에 따라 변경
                            prefixIcon: const Icon(Icons.search),
                            border: const OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade300,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 20),
                          ),
                          onTap: () async {
                            debugPrint("Search field tapped"); // 디버깅 메시지 추가

                            try {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    debugPrint(
                                        "Navigating to FlutterLocationPicker"); // 디버깅 메시지 추가
                                    return Scaffold(
                                      appBar:
                                          AppBar(title: const Text('위치 선택')),
                                      body: FlutterLocationPicker(
                                        initPosition: LatLong(
                                          37.560706, // 기본 위치 (서울)
                                          126.910531,
                                        ),
                                        urlTemplate: Theme.of(context)
                                                    .brightness ==
                                                Brightness.dark
                                            ? 'https://api.maptiler.com/maps/darkmatter/256/{z}/{x}/{y}.png?key=X8VVOmH05lH238brX29b'
                                            : 'https://api.maptiler.com/maps/basic-v2/256/{z}/{x}/{y}.png?key=X8VVOmH05lH238brX29b', // 테마에 따라 지도 스타일 변경
                                        searchBarHintText:
                                            'Seoul, South Korea', // 힌트 텍스트 수정
                                        searchBarBackgroundColor:
                                            getSearchBarBackgroundColor(
                                                context),
                                        searchBarTextColor:
                                            getSearchBarTextColor(context),
                                        searchBarHintColor:
                                            getSearchBarHintColor(context),
                                        locationButtonBackgroundColor:
                                            getLocationButtonBackgroundColor(
                                                context),
                                        locationButtonsColor:
                                            getLocationButtonIconColor(context),
                                        zoomButtonsBackgroundColor:
                                            getZoomButtonBackgroundColor(
                                                context),
                                        zoomButtonsColor:
                                            getZoomButtonIconColor(context),
                                        mapLoadingBackgroundColor:
                                            getMapLoadingBackgroundColor(
                                                context),
                                        selectLocationButtonStyle:
                                            ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Theme.of(context).brightness ==
                                                      Brightness.dark
                                                  ? Colors.purple.shade900
                                                  : Colors.purple
                                                      .shade900, // 배경색 설정
                                          foregroundColor:
                                              Colors.white, // 텍스트 색상
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 12), // 내부 여백 설정
                                          fixedSize: const Size(180,
                                              60), // 버튼의 고정 크기 (가로 200, 세로 50)
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                6), // 모서리 둥글게 설정
                                          ),
                                        ),

                                        selectLocationButtonText: '위치 선택',
                                        selectLocationButtonWidth: 340,
                                        selectLocationButtonHeight: 52,
                                        selectedLocationButtonTextStyle:
                                            TextStyle(fontSize: 16),
                                        selectLocationButtonPositionRight: 0,
                                        selectLocationButtonPositionLeft: 0,
                                        selectLocationButtonPositionBottom: 0,
                                        onPicked: (PickedData pickedData) {
                                          debugPrint(
                                              "Location picked: ${pickedData.latLong} - ${pickedData.address}");
                                          Navigator.pop(context, {
                                            'latlong': pickedData.latLong,
                                            'address': pickedData.address,
                                          });
                                        },
                                      ),
                                    );
                                  },
                                ),
                              );

                              if (result != null) {
                                final selectedLocation = result['latlong'];
                                final address = result['address'];

                                debugPrint(
                                    "Selected location: $selectedLocation, Address: $address"); // 디버깅 메시지 추가

                                if (selectedLocation != null) {
                                  ref
                                      .read(addressSearchViewModel.notifier)
                                      .searchByLocation(
                                        selectedLocation.latitude,
                                        selectedLocation.longitude,
                                      );
                                }
                              }
                            } catch (e) {
                              debugPrint(
                                  "Error during navigation: $e"); // 디버깅 메시지 추가
                            }
                          },
                          onChanged: (pattern) async {
                            debugPrint(
                                "Search pattern changed: $pattern"); // 디버깅 메시지 추가
                            if (pattern.isNotEmpty) {
                              try {
                                await ref
                                    .read(addressSearchViewModel.notifier)
                                    .searchByName(pattern, context);
                              } catch (e) {
                                debugPrint(
                                    "Error during search: $e"); // 디버깅 메시지 추가
                              }
                            }
                          },
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Consumer(
                      builder: (context, ref, child) {
                        debugPrint("Building search result list"); // 디버깅 메시지 추가
                        final addresses = ref.watch(addressSearchViewModel);
                        return ListView.builder(
                          itemCount: addresses.length,
                          itemBuilder: (context, index) {
                            final item = addresses[index];
                            debugPrint(
                                "Displaying address: ${item.displayNameKR}, ${item.displayNameEN}"); // 디버깅 메시지 추가
                            return GestureDetector(
                              onTap: () {
                                debugPrint(
                                    "Address tapped: ${item.fullName}"); // 디버깅 메시지 추가
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CurrencySearchPage(
                                      selectedLanguage: selectedLanguage,
                                      selectedAddress: item.fullName,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                height: 70,
                                width: double.infinity,
                                color: Colors.transparent,
                                alignment: Alignment.centerLeft,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      item.displayNameKR,
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      item.displayNameEN,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(0.0),
                child: Consumer(builder: (context, ref, child) {
                  debugPrint(
                      "Initializing current location search button"); // 디버깅 메시지 추가
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              debugPrint(
                                  "Current location button pressed"); // 디버깅 메시지 추가
                              try {
                                final position =
                                    await GeolocatorHelper.getPosition();
                                if (position != null) {
                                  debugPrint(
                                      "Current location: ${position.latitude}, ${position.longitude}"); // 디버깅 메시지 추가
                                  final viewModel =
                                      ref.read(addressSearchViewModel.notifier);
                                  viewModel.searchByLocation(
                                    position.latitude,
                                    position.longitude,
                                  );
                                }
                              } catch (e) {
                                debugPrint(
                                    "Error getting current location: $e"); // 디버깅 메시지 추가
                              }
                            },
                            child: const Text('현재 위치로 찾기'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Align(
                        alignment: Alignment.center,
                        child: const Text(
                          'Find by current location',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 5),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

// FlutterLocationPicker 테마별 UI 디자인 함수
  Color getSearchBarBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.black87
        : Colors.white;
  }

  Color getSearchBarTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black87;
  }

  Color getSearchBarHintColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade400
        : Colors.grey.shade600;
  }

  Color getLocationButtonBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.blueGrey.shade100;
  }

  Color getLocationButtonIconColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black87;
  }

  Color getZoomButtonBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.blueGrey.shade100;
  }

  Color getZoomButtonIconColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black87;
  }

  Color getMapLoadingBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.black87
        : Colors.white;
  }
}
