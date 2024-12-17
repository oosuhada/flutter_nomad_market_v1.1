import 'dart:async'; // Timer 클래스 사용을 위해 추가
import 'package:flutter/material.dart';
import 'package:flutter_market_app/ui/pages/currency_search/currency_search_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_market_app/core/geolocator_helper.dart';
import 'package:flutter_market_app/ui/pages/address_search/address_search_view_model.dart';
import 'package:flutter_market_app/data/model/address.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';

class AddressSearchPage extends ConsumerStatefulWidget {
  final String selectedLanguage;

  const AddressSearchPage({Key? key, required this.selectedLanguage})
      : super(key: key);

  @override
  ConsumerState<AddressSearchPage> createState() => _AddressSearchPageState();
}

class _AddressSearchPageState extends ConsumerState<AddressSearchPage> {
  OverlayEntry? _overlayEntry;
  Timer? _timer;

  void _showIOSStyleSnackbar(String message) {
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: MediaQuery.of(context).padding.bottom + 10,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.black.withOpacity(0.8),
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    _timer = Timer(const Duration(seconds: 5), () {
      _removeOverlay();
    });
  }

  void _removeOverlay() {
    _timer?.cancel();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _handleAddressSelection(Address address) {
    if (address.isServiceAvailable) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CurrencySearchPage(
            selectedLanguage: widget.selectedLanguage,
            selectedAddress: address.fullNameKR,
          ),
        ),
      );
    } else {
      _showIOSStyleSnackbar('해당 도시는 현재 서비스 불가 지역입니다');

      // 서비스 가능 지역 목록으로 상태 업데이트
      final serviceableAddresses = Address.serviceableAreas
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

      // updateAddresses 대신 state 직접 업데이트
      ref.read(addressSearchViewModel.notifier).state = serviceableAddresses;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
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
                    return Column(
                      children: [
                        const SizedBox(height: 12),
                        TextField(
                          decoration: InputDecoration(
                            hintText: '도시, 국가로 검색 (ex. 서울, 대한민국)',
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
                            debugPrint("Search field tapped");
                            try {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      _buildLocationPicker(context),
                                ),
                              );

                              if (result != null) {
                                final selectedLocation = result['latlong'];
                                final address = result['address'];
                                debugPrint(
                                    "Selected location: $selectedLocation, Address: $address");

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
                              debugPrint("Error during navigation: $e");
                            }
                          },
                          onChanged: (pattern) async {
                            debugPrint("Search pattern changed: $pattern");
                            if (pattern.isNotEmpty) {
                              try {
                                await ref
                                    .read(addressSearchViewModel.notifier)
                                    .searchByName(pattern, context);
                              } catch (e) {
                                debugPrint("Error during search: $e");
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
                        final addresses = ref.watch(addressSearchViewModel);
                        return ListView.builder(
                          itemCount: addresses.length,
                          itemBuilder: (context, index) {
                            final item = addresses[index];
                            return GestureDetector(
                              onTap: () => _handleAddressSelection(item),
                              child: Container(
                                height: 70,
                                width: double.infinity,
                                color: Colors.transparent,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      item.fullNameKR,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.fullNameEN,
                                      style: const TextStyle(
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
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: Theme.of(context).primaryColor,
                height: 100, // 높이 조절
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildCurrentLocationButton(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationPicker(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('위치 선택')),
      body: FlutterLocationPicker(
        initPosition: LatLong(37.560706, 126.910531), // 서울 초기 위치
        urlTemplate: Theme.of(context).brightness == Brightness.dark
            ? 'https://api.maptiler.com/maps/basic-v2/256/{z}/{x}/{y}.png?key=X8VVOmH05lH238brX29b'
            : 'https://api.maptiler.com/maps/basic-v2/256/{z}/{x}/{y}.png?key=X8VVOmH05lH238brX29b',
        searchBarHintText: 'Seoul, South Korea',
        searchBarBackgroundColor: getSearchBarBackgroundColor(context),
        searchBarTextColor: getSearchBarTextColor(context),
        searchBarHintColor: getSearchBarHintColor(context),
        locationButtonBackgroundColor:
            getLocationButtonBackgroundColor(context),
        locationButtonsColor: getLocationButtonIconColor(context),
        zoomButtonsBackgroundColor: getZoomButtonBackgroundColor(context),
        zoomButtonsColor: getZoomButtonIconColor(context),
        mapLoadingBackgroundColor: getMapLoadingBackgroundColor(context),
        selectLocationButtonText: '위치 선택',
        selectLocationButtonStyle: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.purple.shade900
              : Colors.purple.shade900,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          fixedSize: const Size(180, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        selectLocationButtonWidth: 340,
        selectLocationButtonHeight: 52,
        selectedLocationButtonTextStyle: const TextStyle(fontSize: 16),
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
  }

  Widget _buildCurrentLocationButton(BuildContext context) {
    return Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(0.0),
        child: Consumer(builder: (context, ref, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        final position = await GeolocatorHelper.getPosition();
                        if (position != null) {
                          debugPrint(
                              "Current location: ${position.latitude}, ${position.longitude}");
                          ref
                              .read(addressSearchViewModel.notifier)
                              .searchByLocation(
                                position.latitude,
                                position.longitude,
                              );
                        }
                      } catch (e) {
                        debugPrint("Error getting current location: $e");
                      }
                    },
                    child: const Text('현재 위치로 찾기'),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Find by current location',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 5),
            ],
          );
        }),
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
