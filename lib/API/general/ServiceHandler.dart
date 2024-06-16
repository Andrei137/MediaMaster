import 'Service.dart';

class ServiceHandler {
  static Service? _service;

  static void setService(Service service) {
    _service = service;
  }

  static Future<List<Map<String, dynamic>>> getOptions(String query) {
    return _service?.getOptions(query) ?? Future.value([]);
  }

  static Future<Map<String, dynamic>> getInfo(Map<String, dynamic> item) {
    return _service?.getInfo(item) ?? Future.value({});
  }

  static Future<List<Map<String, dynamic>>> getRecommendations(int id) async {
    return _service?.getRecommendations(id) ?? Future.value([]);
  }
}
