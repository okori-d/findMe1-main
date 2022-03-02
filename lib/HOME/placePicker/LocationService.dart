import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class LocationService {
  final String key = 'AIzaSyCX7vI-UAjpQsj4o2cjlm4VHKlwntoFXRs';

  Future<Map<String, dynamic>> getPlaceId(String input) async {
    final String url = '';

    var response = await http.get(Uri.parse(url));

    var json = convert.jsonDecode(response.body);

    var results = json['result'] as Map<String, dynamic>;

    print(results);
    return results;
  }

  getDirections(String origin, String destination) async {
    final String url = '';
    var response = await http.get(Uri.parse(url));

    var json = convert.jsonDecode(response.body);

    print(json);

  }
}