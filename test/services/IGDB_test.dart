import 'dart:math';
import 'package:test/test.dart';
import '../../lib/API/general/ServiceHandler.dart';
import '../../lib/API/general/ServiceBuilder.dart';

void main() {
  group('IGDB', () {
    final games = ['Hollow Knight', 'God of War', 'League of Legends', 'Minecraft']; 

    setUp(() {
      ServiceBuilder.setIgdb();
    });

    test('getOptions for several valid games', () async {
      for (var game in games) {
        final game_words = game.split(' ');
        final options = await ServiceHandler.getOptions(game);
        expect(options, isNotEmpty);
        for (var option in options) {
          for (var word in game_words) {
            expect(option['name'].toLowerCase(), contains(word.toLowerCase()));
          }
          expect(option['url'], isNotEmpty);
        }
      }
    });

    test('getOptions for invalid game', () async {
      final options = await ServiceHandler.getOptions('reddit');

      expect(options, hasLength(1));
      expect(options[0]['error'], isNotEmpty);
    });

    test('getInfo for a game', () async {
      final options = await ServiceHandler.getOptions('Hollow Knight');
      final game_info = await ServiceHandler.getInfo(options[0]);

      expect(game_info, isNotNull);
      expect(game_info['dlcs'], isNotEmpty);
      expect(game_info['url'], 'https://www.igdb.com/games/hollow-knight');
      expect(game_info['developers'], contains('Team Cherry'));
      expect(game_info['publishers'], contains('Team Cherry'));
    });
  });
}
