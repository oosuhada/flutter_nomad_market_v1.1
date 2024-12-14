import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_market_app/core/geolocator_helper.dart';
import 'package:flutter_market_app/ui/pages/address_search/address_search_view_model.dart';
import 'package:flutter_market_app/ui/pages/join/join_page.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';

const String mapTilerLight =
    'https://api.maptiler.com/maps/basic-v2/256/{z}/{x}/{y}.png?key=X8VVOmH05lH238brX29b';
const String mapTilerDark =
    'https://api.maptiler.com/maps/darkmatter/256/{z}/{x}/{y}.png?key=X8VVOmH05lH238brX29b';

class AddressSearchPage extends StatelessWidget {
  const AddressSearchPage({Key? key}) : super(key: key);

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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Consumer(builder: (context, ref, child) {
                    return Column(
                      children: [
                        const SizedBox(height: 5),
                        TextField(
                          decoration: const InputDecoration(
                            hintText: '도시, 국가로 검색 (ex. 서울, 한국)',
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 4, horizontal: 16),
                          ),
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Scaffold(
                                  appBar: AppBar(title: const Text('위치 선택')),
                                  body: FlutterLocationPicker(
                                    initPosition: LatLong(
                                      37.5665, // 기본 위치 (서울)
                                      126.9780,
                                    ),
                                    selectLocationButtonText: '위치 선택',
                                    onPicked: (PickedData pickedData) {
                                      Navigator.pop(context, {
                                        'latlong': pickedData.latLong,
                                        'address': pickedData.address,
                                      });
                                    },
                                  ),
                                ),
                              ),
                            );

                            if (result != null) {
                              final selectedLocation = result['latlong'];
                              final address = result['address'];

                              if (selectedLocation != null) {
                                ref
                                    .read(addressSearchViewModel.notifier)
                                    .searchByLocation(
                                      selectedLocation.latitude,
                                      selectedLocation.longitude,
                                    );
                              }
                            }
                          },
                          onChanged: (pattern) async {
                            if (pattern.isNotEmpty) {
                              await ref
                                  .read(addressSearchViewModel.notifier)
                                  .searchByName(pattern, context);
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
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return JoinPage(item.fullName);
                                }));
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
                                        fontSize: 14,
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
                padding: const EdgeInsets.all(10.0),
                child: Consumer(builder: (context, ref, child) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final position =
                                await GeolocatorHelper.getPosition();
                            if (position != null) {
                              final viewModel =
                                  ref.read(addressSearchViewModel.notifier);
                              viewModel.searchByLocation(
                                position.latitude,
                                position.longitude,
                              );
                            }
                          },
                          child: const Text('현재 위치로 찾기'),
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
}
