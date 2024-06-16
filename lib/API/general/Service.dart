abstract class Service {
  Future<List<Map<String, dynamic>>> getOptions(String query) async {
    throw UnimplementedError('getOptions method is not implemented');
  }

  Future<Map<String, dynamic>> getInfo(Map<String, dynamic> item) async {
    throw UnimplementedError('getInfo method is not implemented');
  }

  Future<List<Map<String, dynamic>>> getRecommendations(int id) async {
        throw UnimplementedError('getRecommendations method is not implemented');
  }
}
