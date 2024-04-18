import 'ServiceHandler.dart';
import '../games/HowLongToBeat.dart';
import '../games/PcGamingWiki.dart';

class ServiceBuilder {
  static void setHowLongToBeat() {
    ServiceHandler.setService(HowLongToBeat.instance);
  }

  static void setPcGamingWiki() {
    ServiceHandler.setService(PcGamingWiki.instance);
  }
}
