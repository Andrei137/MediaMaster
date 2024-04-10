class Utils {
  // There might already be a function that does this
  static String httpify(String query) {
    return query.replaceAll(' ', '+');
  }
}