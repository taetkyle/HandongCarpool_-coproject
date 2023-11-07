import 'package:flutter/material.dart';
import 'package:flutter_application_1/creating_party.dart';
import 'package:flutter_application_1/party_list.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'MyInfo.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'bottom_popup.dart';
import 'places_api.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  final Completer<GoogleMapController> _controller = Completer();
  TextEditingController _searchCon = TextEditingController();

  Set<Marker> _markers = Set<Marker>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(36.09826133580664, 129.387749655962),
    zoom: 14.4746,
  );

  Future<void> goToPlace(Map<String, dynamic> place) async {
    final double lat = place['places'][0]['location']['latitude'];
    final double lng = place['places'][0]['location']['longitude'];

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 13, tilt: 30)));
  }

  void _setMarker(Map<String, dynamic> place, i) {
    final double lat = place['latitude'];
    final double lng = place['longitude'];
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('marker$i'),
          position: LatLng(lat, lng),
          onTap: () {
            bottom_popup(context);
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          tooltip: 'Add', // used by assistive technologies
          onPressed: () {
            Get.to(() => creating_party());
          },
          backgroundColor: Colors.grey,
          child: Icon(
            Icons.add,
            color: Colors.black,
          ),
        ),
        body: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
                    child: TextFormField(
                      controller: _searchCon,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: 'Search by KeyWords',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    var place =
                        await places_api().get_place_id(_searchCon.text);
                    for (int i = 0; i <= 10; i++) {
                      if (place['places'][i] != null) {
                        _setMarker(place['places'][i]['location'], i);
                      } else {
                        break;
                      }
                    }
                    goToPlace(place);
                  },
                  icon: Icon(Icons.search),
                ),
              ],
            ),
            Expanded(
              child: GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: _kGooglePlex,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                markers: _markers,
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          color: const Color.fromARGB(255, 212, 212, 212),
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                  child: TextButton(
                      child: Text('파티 리스트',
                          style: TextStyle(color: Colors.black, fontSize: 20)),
                      onPressed: () {
                        Get.to(() => party_list());
                      })),
              VerticalDivider(
                color: Colors.white,
                thickness: 3,
              ),
              Expanded(
                  child: TextButton(
                      child: Text('내 정보',
                          style: TextStyle(color: Colors.black, fontSize: 20)),
                      onPressed: () {
                        Get.to(() => MyInfo());
                      }))
            ],
          ),
        ),
      ),
    );
  }
}
