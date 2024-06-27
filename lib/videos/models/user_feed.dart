import 'package:json_annotation/json_annotation.dart';

import 'video_in_list.dart';

part 'user_feed.g.dart';

@JsonSerializable()
class UserFeed {
  List<VideoInList>? notifications = [];
  List<VideoInList>? videos = [];

  UserFeed(this.notifications, this.videos);

  factory UserFeed.fromJson(Map<String, dynamic> json) =>
      _$UserFeedFromJson(json);

  Map<String, dynamic> toJson() => _$UserFeedToJson(this);
}
