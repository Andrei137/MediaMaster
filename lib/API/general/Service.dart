abstract class Service {
  Future<List<Map<String, dynamic>>> getOptions(String query) async {
    throw UnimplementedError('getOptions method is not implemented');
  }

  Future<Map<String, dynamic>> search(Map<String, dynamic> item) async {
    throw UnimplementedError('search method is not implemented');
  }
}
