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

  static const TextStyle textStyle = TextStyle(color: Colors.white);

  Media(
      {this.id = -1,
      required this.originalName,
      required this.description,
      required this.releaseDate,
      required this.criticScore,
      required this.communityScore,
      required this.mediaType}) {
    if (id == -1) {
      id = nextId;
    }
    if (id >= nextId) {
      nextId = id + 1;
    }
  }

  @override
  bool operator ==(Object other) {
    if (runtimeType != other.runtimeType) {
      return false;
    }
    return id == (other as Media).id;
  }

  @override
  int get hashCode => id;

  HiveObject get media {
    if (_media == null) {
      if (mediaType == "Game") {
        Box<Game> box = Hive.box<Game>('games');
        for (int i = 0; i < box.length; ++i) {
          if (id == box.getAt(i)!.mediaId) {
            _media = box.getAt(i);
          }
        }
      }
      // TODO: Implement the other types
      if (_media == null) {
        throw Exception(
            "Media of id $id does not have an associated (concrete) Media object or mediaType value is wrong ($mediaType)");
      }
    }
    return _media!;
  }

  List<Publisher> get publishers {
    List<Publisher> ans = List.empty(growable: true);

    for (var mp in Hive.box<MediaPublisher>('media-publishers').values) {
      if (mp.mediaId == id) {
        ans.add(mp.publisher);
      }
    }

    return ans;
  }

  List<Creator> get creators {
    List<Creator> ans = List.empty(growable: true);

    for (var mc in Hive.box<MediaCreator>('media-creators').values) {
      if (mc.mediaId == id) {
        ans.add(mc.creator);
      }
    }

    return ans;
  }

  List<Platform> get platforms {
    List<Platform> ans = List.empty(growable: true);

    for (var mp in Hive.box<MediaPlatform>('media-platforms').values) {
      if (mp.mediaId == id) {
        ans.add(mp.platform);
      }
    }

    return ans;
  }

  Widget getListWidget(String title, List<String> items) {
    final ScrollController scrollController = ScrollController();

    return Card(
      color: Colors.grey[850],
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: textStyle.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Container(
              constraints: const BoxConstraints(
                maxHeight: 70.0,
              ),
              child: RawScrollbar(
                controller: scrollController,
                thumbColor: Colors.white,
                radius: const Radius.circular(8.0),
                thickness: 6.0,
                thumbVisibility: true,
                child: ListView.builder(
                  controller: scrollController,
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.label,
                            color: Colors.white70,
                            size: 14,
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              items[index],
                              style: textStyle.copyWith(
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getPublishersWidget() {
    var pubs = publishers.map((pub) => pub.name).toList();
    return getListWidget('Publisher${pubs.length <= 1 ? "" : "s"}', pubs.isEmpty ? List.of(["N/A"]) : pubs);
  }

  Widget getCreatorsWidget() {
    var crts = creators.map((crt) => crt.name).toList();
    return getListWidget('Creator${crts.length <= 1 ? "" : "s"}', crts.isEmpty ? List.of(["N/A"]) : crts);
  }

  Widget getPlatformsWidget() {
    var plts = platforms.map((plt) => plt.name).toList();
    return getListWidget('Platform${plts.length <= 1 ? "" : "s"}', plts.isEmpty ? List.of(["N/A"]) : plts);
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
