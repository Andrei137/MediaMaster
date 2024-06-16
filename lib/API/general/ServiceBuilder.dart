import 'ServiceHandler.dart';
import '../books/GoodReads.dart';
import '../games/HowLongToBeat.dart';
import '../games/IGDB.dart';
import '../games/PcGamingWiki.dart';
import '../movies/TmdbMovies.dart';
import '../tv_series/TmdbSeries.dart';

class ServiceBuilder {
  static void setGoodReads() {
    ServiceHandler.setService(GoodReads.instance);
  }

  static void setHowLongToBeat() {
    ServiceHandler.setService(HowLongToBeat.instance);
  }

  static void setIgdb() {
    ServiceHandler.setService(IGDB.instance);
  }

  static void setPcGamingWiki() {
    ServiceHandler.setService(PcGamingWiki.instance);
  }

  static void setTmdbMovies() {
    ServiceHandler.setService(TmdbMovies.instance);
  }

  static void setTmdbSeries() {
    ServiceHandler.setService(TmdbSeries.instance);
  }
}
