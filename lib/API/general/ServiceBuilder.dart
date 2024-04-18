import 'ServiceHandler.dart';
import '../games/HowLongToBeat.dart';

class ServiceBuilder {
  static void setHowLongToBeat() {
    ServiceHandler.setService(HowLongToBeat.instance);
  }
}
