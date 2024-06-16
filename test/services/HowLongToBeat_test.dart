import 'dart:math';
import 'package:test/test.dart';
import '../../lib/API/general/ServiceHandler.dart';
import '../../lib/API/general/ServiceBuilder.dart';

double getHours(String time) {
  final hours = time.split(' ')[0];
  return double.parse(hours);
}

void main() {
  group('HowLongToBeat', () {
    final games = ['Hollow Knight', 'God of War', 'League of Legends', 'Minecraft']; 

    setUp(() {
      ServiceBuilder.setHowLongToBeat();
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
          expect(option['link'], isNotEmpty);
        }
      }
    });

    test('getOptions for invalid game', () async {
      final options = await ServiceHandler.getOptions('reddit');

      expect(options, isEmpty);
    });

    test('getInfo for a singleplayer game', () async {
      final options = await ServiceHandler.getOptions('Hollow Knight');
      final game_info = await ServiceHandler.getInfo(options[0]);

      expect(game_info, isNotNull);
      expect(game_info['Main Story'], isNotNull);
      expect(game_info['Main + Sides'], isNotNull);
      expect(game_info['Completionist'], isNotNull);
      expect(game_info['All Styles'], isNotNull);

      expect(getHours(game_info['Main Story']), greaterThan(20));
      expect(getHours(game_info['Main + Sides']), greaterThan(40));
      expect(getHours(game_info['Completionist']), greaterThan(60));
    });

    test('getInfo for a multiplayer game', () async {
      final options = await ServiceHandler.getOptions('League of Legends');
      final game_info = await ServiceHandler.getInfo(options[0]);

      expect(game_info, isNotNull);
      expect(game_info['Main Story'], isNull);
      expect(game_info['Main + Sides'], isNull);
      expect(game_info['Completionist'], isNull);

      expect(game_info['Co-Op'], isNotNull);
      expect(game_info['Vs.'], isNotNull);

      expect(getHours(game_info['Co-Op']), greaterThan(1000));
      expect(getHours(game_info['Vs.']), greaterThan(1000));
    });

    test('getInfo for a game with no data', () async {
      final options = await ServiceHandler.getOptions('Heroes of Myths - Warriors of Gods');
      final game_info = await ServiceHandler.getInfo(options[0]);

      expect(game_info, isNotNull);
      expect(game_info, isEmpty);
    });

  });
}
