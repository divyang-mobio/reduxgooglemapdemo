import 'package:reduxgooglemapdemo/database.dart';
import 'package:reduxgooglemapdemo/redux/actions.dart';
import 'package:reduxgooglemapdemo/redux/state.dart';

LocationState locationUpdate(LocationState state, dynamic actions) {
  if(actions is AddAction) {
    DatabaseHelper.instance.add(
        LocationData(latitude: actions.latitude, longitude: actions.longitude));
    // return LocationState(locationData: []);
    return LocationState( locationData: DatabaseHelper.instance.getData(),);
  } else if (actions is DeleteAction) {
    DatabaseHelper.instance.delete(actions.id);
    // return LocationState(locationData: []);
    return LocationState(locationData:DatabaseHelper.instance.getData(),);
  } else {
    return state;
  }
}
Future<List<LocationData>> data() async {
  return await DatabaseHelper.instance.getData();
}