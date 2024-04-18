import 'package:mediamaster/API/general/Service.dart';

import 'ServiceHandler.dart';
import '../games/HowLongToBeat.dart';
import '../games/PcGamingWiki.dart';
import '../books/GoodReads.dart';

class ServiceBuilder {
  static void setHowLongToBeat() {
    ServiceHandler.setService(HowLongToBeat.instance);
  }

  static void setPcGamingWiki() {
    ServiceHandler.setService(PcGamingWiki.instance);
  }

  static void setGoodReads() {
    ServiceHandler.setService(GoodReads.instance);
  }
}
