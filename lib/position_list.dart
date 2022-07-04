import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:reduxgooglemapdemo/redux/state.dart';
import 'database.dart';
import 'main.dart';

class LocationList extends StatelessWidget {
  const LocationList({Key? key}) : super(key: key);
//
//   @override
//   State<LocationList> createState() => _LocationListState();
// }
//
// class _LocationListState extends State<LocationList> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios)),
        title: const Text('Saved Data'),
      ),

      ///without bloc
      body: StoreConnector<LocationState, ViewModel>(
        converter: (store) => ViewModel.create(store),
        builder: (context, model) => FutureBuilder<List<LocationData>>(
            future: model.count,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }
              return ListView.builder(
                  itemCount: snapshot.data?.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onDoubleTap: () {
                        model.deleteData(snapshot.data?[index].id as int);
                      },
                      child: Card(
                        elevation: 8,
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(
                                  "id: ${snapshot.data?[index].id.toString()}"),
                            ),
                            ListTile(
                              title: Text(
                                  "longitude: ${snapshot.data?[index].longitude.toString()}"),
                            ),
                            ListTile(
                              title: Text(
                                  "latitude: ${snapshot.data?[index].latitude.toString()}"),
                            ),
                          ],
                        ),
                      ),
                    );
                  });
            }),
      ),
    );
  }
}
