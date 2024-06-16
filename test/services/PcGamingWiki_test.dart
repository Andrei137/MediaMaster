import 'dart:math';
import 'package:test/test.dart';
import '../../lib/API/general/ServiceHandler.dart';
import '../../lib/API/general/ServiceBuilder.dart';

double getHours(String time) {
  final hours = time.split(' ')[0];
  return double.parse(hours);
}

void main() {
  group('PcGamingWiki', () {
    final games = ['Hollow Knight', 'God of War', 'League of Legends', 'Minecraft']; 

    setUp(() {
      ServiceBuilder.setPcGamingWiki();
    });

    test('getOptions for several games', () async {
      for (var game in games) {
        final game_words = game.split(' ');
        final options = await ServiceHandler.getOptions(game);
        expect(options, isNotEmpty);
        for (var option in options) {
          for (var word in game_words) {
            expect(option['name'].toLowerCase(), contains(word.toLowerCase()));
          }
        }
      }
    });

    test('getOptions for invalid game', () async {
      final options = await ServiceHandler.getOptions('reddit');

      expect(options, isEmpty);
    });
    
    test('getInfo for a valid game', () async {
      final options = await ServiceHandler.getOptions('Hollow Knight');
      final game_info = await ServiceHandler.getInfo(options[0]);

      expect(game_info, isNotNull);
      expect(game_info['windows'], isNotNull);
      expect(game_info['windows']['OS'], isNotNull);
      expect(game_info['windows']['CPU'], isNotNull);
      expect(game_info['windows']['HDD'], isNotNull);
      expect(game_info['windows']['GPU'], isNotNull);

      expect(game_info['os_x'], isNotNull);
      expect(game_info['linux'], isNotNull);

      expect(game_info['windows']['OS']['minimum'], contains('7'));
      expect(game_info['windows']['OS']['recommended'], contains('10'));
    });
  });
}
