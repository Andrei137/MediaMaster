import 'package:mediamaster/API/general/Service.dart';

import 'ServiceHandler.dart';
import '../books/GoodReads.dart';
import '../games/HowLongToBeat.dart';
import '../games/PcGamingWiki.dart';
import '../movies/TmdbMovies.dart';

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

  static void setTmdbMovies() {
    ServiceHandler.setService(TmdbMovies.instance);
  }
}
