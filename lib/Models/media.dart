import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:flutter/material.dart';

import 'creator.dart';
import 'game.dart';
import 'media_creator.dart';
import 'media_platform.dart';
import 'media_publisher.dart';
import 'platform.dart';
import 'publisher.dart';

// Don't change the number below (typeId).
// For information regarding what can be modified check out https://docs.hivedb.dev/#/custom-objects/generate_adapter
class Media extends HiveObject {
  // Hive fields
  int id;
  String originalName;
  String description;
  DateTime releaseDate;
  int criticScore;
  int communityScore;
  String mediaType;

  // For ease of use
  HiveObject? _media;

  // Automatic id generator
  static int nextId = 0;

  Media(
      {this.id = -1,
      required this.originalName,
      required this.description,
      required this.releaseDate,
      required this.criticScore,
      required this.communityScore,
      required this.mediaType}) {
        if(id == -1) {
          id = nextId;
        }
        if(id >= nextId) {
          nextId = id + 1;
        }
      }

  @override
  bool operator==(Object other) {
    if(runtimeType != other.runtimeType) {
      return false;
    }
    return id == (other as Media).id;
  }
  
  @override
  int get hashCode => id;

  HiveObject get media {
    if(_media == null) {
      if(mediaType == "Game") {
        Box<Game> box = Hive.box<Game>('games');
        for(int i = 0;i < box.length;++i) {
          if(id == box.getAt(i)!.mediaId) {
            _media = box.getAt(i);
          }
        }
      }
      // TODO: Implement the other types
      if(_media == null) {
        throw Exception("Media of id $id does not have an associated (concrete) Media object or mediaType value is wrong ($mediaType)");
      }
    }
    return _media!;
  }

  List<Publisher> get publishers {
    List<Publisher> ans = List.empty();
    
    for(var mp in Hive.box<MediaPublisher>('media-publishers').values) {
      if(mp.mediaId == id) {
        ans.add(mp.publisher);
      }
    }

    return ans;
  }

  Widget getPublishersWidget() {
    var pubs = publishers;

    return Column(
      children: [
        Text(
          'Publisher${pubs.length <= 1 ? "" : "s"}',
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        for(var pub in pubs)
          Text(
            pub.name,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
      ],
    );
  }

  List<Creator> get creators {
    List<Creator> ans = List.empty();
    
    for(var mc in Hive.box<MediaCreator>('media-creators').values) {
      if(mc.mediaId == id) {
        ans.add(mc.creator);
      }
    }

    return ans;
  }

  Widget getCreatorsWidget() {
    var crts = creators;

    return Column(
      children: [
        Text(
          'Creator${crts.length <= 1 ? "" : "s"}',
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        for(var crt in crts)
          Text(
            crt.name,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
      ],
    );
  }

  List<Platform> get platforms {
    List<Platform> ans = List.empty();
    
    for(var mp in Hive.box<MediaPlatform>('media-platforms').values) {
      if(mp.mediaId == id) {
        ans.add(mp.platform);
      }
    }

    return ans;
  }

  Widget getPlatformsWidget() {
    var plts = platforms;

    return Column(
      children: [
        Text(
          'Platform${plts.length <= 1 ? "" : "s"}',
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        for(var plt in plts)
          Text(
            plt.name,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
      ],
    );
  }
}

class MediaAdapter extends TypeAdapter<Media> {
  @override
  final int typeId = 3;

  @override
  Media read(BinaryReader reader) {
    return Media(
      id: reader.readInt(),
      originalName: reader.readString(),
      description: reader.readString(),
      releaseDate: reader.read(),
      criticScore: reader.readInt(),
      communityScore: reader.readInt(),
      mediaType: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Media obj) {
    writer.writeInt(obj.id);
    writer.writeString(obj.originalName);
    writer.writeString(obj.description);
    writer.write(obj.releaseDate);
    writer.writeInt(obj.criticScore);
    writer.writeInt(obj.communityScore);
    writer.writeString(obj.mediaType);
  }
}
