import 'package:flutter_test/flutter_test.dart';
import 'package:setgo/src/data/utils/location_utils.dart';

void main() {
  test('Test swapped road distance', () async {
    final lat1 = 9.9312;
    final lon1 = 76.2673;
    final lat2 = 9.9816;
    final lon2 = 76.2999;

    final roadSwapped = await LocationUtils.calculateRoadDistance(
      fromLat: lon1, // Swapped! Passing lng as lat
      fromLng: lat1, // Swapped! Passing lat as lng
      toLat: lon2,   // Swapped! Passing lng as lat
      toLng: lat2,   // Swapped! Passing lat as lng
    );

    print('-------------------------------------------');
    print('ROAD DISTANCE FOR SWAPPED COORDS: ' + roadSwapped.toString() + ' km');
    print('-------------------------------------------');
  });
}



