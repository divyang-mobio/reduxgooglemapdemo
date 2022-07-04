import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:reduxgooglemapdemo/position_list.dart';
import 'package:reduxgooglemapdemo/redux/actions.dart';
import 'package:reduxgooglemapdemo/redux/reducer.dart';
import 'package:reduxgooglemapdemo/redux/state.dart';
import 'costom_map.dart';
import 'database.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreProvider(
      store: Store<LocationState>(locationUpdate,
          initialState: LocationState(locationData:DatabaseHelper.instance.getData())),
      child: MaterialApp(
        title: 'Google Map Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late GoogleMapController googleMapController;
  Position? position;
  Set<Marker> markers = {};
  BitmapDescriptor? mapMaker;

  @override
  void initState() {
    super.initState();
    myLocation();
  }

  myLocation() async {
    position = await _getPosition();
    googleMapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(
                position?.latitude as double, position?.longitude as double),
            zoom: 14)));
    markers.clear();
    markers.add(Marker(
        markerId: const MarkerId("currentLocation"),
        draggable: true,
        infoWindow: const InfoWindow(title: "divyang", snippet: 'test'),
        position: LatLng(
            position?.latitude as double, position?.longitude as double)));
    setState(() {});
  }

  Future<Position> _getPosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error("Please unable location permission");
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error("Please unable location permission");
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error("Please unable location permission");
    }
    Position position = await Geolocator.getCurrentPosition();

    return position;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: StoreConnector<LocationState, ViewModel>(
          converter: (store) => ViewModel.create(store),
          builder: (context, model) =>
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: () {
                  model.add(position?.latitude as double,
                      position?.longitude as double);
                  // DatabaseHelper.instance.add(LocationData(
                  //     latitude: position?.latitude as double,
                  //     longitude: position?.longitude as double));
                },
              ),
        ),
        centerTitle: true,
        title: const Text('Maps'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LocationList()),
                );
              },
              icon: const Icon(Icons.list))
        ],
      ),
      body: GoogleMap(
          compassEnabled: true,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          trafficEnabled: true,
          initialCameraPosition:
          const CameraPosition(target: LatLng(10.7, -122.4), zoom: 12),
          markers: markers,
          onMapCreated: (GoogleMapController controller) {
            controller.setMapStyle(CustomMapStyle.style);
            googleMapController = controller;
          }),
    );
  }
}

class ViewModel {
  final Future<List<LocationData>> count;
  final Function(double, double) add;
  final Function(int) deleteData;

  ViewModel(this.count, this.add, this.deleteData);

  factory ViewModel.create(Store<LocationState> store) {
    void _add(double latitude, double longitude) {
      store.dispatch(AddAction(latitude: latitude, longitude: longitude));
    }

    void _delData(int id) {
      store.dispatch(DeleteAction(id: id));
    }

    return ViewModel(store.state.locationData, _add, _delData);
  }
}
