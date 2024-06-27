import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:invidious/comments/states/single_comment.dart';
import 'package:invidious/comments/views/components/comments.dart';
import 'package:invidious/router.dart';
import 'package:invidious/utils/views/components/text_linkified.dart';
import 'package:invidious/videos/views/components/video_thumbnail.dart';

import '../../../player/states/player.dart';
import '../../../utils/models/image_object.dart';
import '../../../videos/models/base_video.dart';
import '../../models/comment.dart';

class SingleCommentView extends StatelessWidget {
  final Comment comment;
  final BaseVideo video;

  const SingleCommentView(
      {super.key, required this.comment, required this.video});

  openChannel(BuildContext context, String authorId) {
    AutoRouter.of(context).push(ChannelRoute(channelId: authorId));
  }

  @override
  Widget build(BuildContext context) {
    var player = context.read<PlayerCubit>();
    var locals = AppLocalizations.of(context)!;
    ColorScheme colors = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;

    return BlocProvider(
      create: (context) =>
          SingleCommentCubit(SingleCommentState(comment: comment)),
      child: BlocBuilder<SingleCommentCubit, SingleCommentState>(
        builder: (context, state) {
          var cubit = context.read<SingleCommentCubit>();
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => openChannel(context, state.comment.authorId),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Thumbnail(
                      width: 20,
                      height: 20,
                      thumbnailUrl: ImageObject.getBestThumbnail(
                                  state.comment.authorThumbnails)
                              ?.url ??
                          '',
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () =>
                            openChannel(context, state.comment.authorId),
                        child: Text(
                          state.comment.author,
                          style: TextStyle(color: colors.secondary),
                        ),
                      ),
                      Row(
                        children: [
                          Visibility(
                            visible: state.comment.creatorHeart != null,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: colors.primaryContainer,
                                    borderRadius: BorderRadius.circular(20)),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 4.0, horizontal: 8),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.favorite,
                                        color: Colors.red,
                                        size: 15,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Image(
                                          image: NetworkImage(
                                            state.comment.creatorHeart
                                                    ?.creatorThumbnail ??
                                                '',
                                          ),
                                          width: 15,
                                          height: 15,
                                        ),
                                      ),
                                      Text(state.comment.creatorHeart
                                              ?.creatorName ??
                                          '')
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      TextLinkified(
                        text: state.comment.content,
                        video: video,
                        player: player,
                      ),
                      Row(
                        children: [
                          Visibility(
                              visible: state.comment.likeCount > 0,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 4.0),
                                child: Icon(Icons.thumb_up,
                                    size: 15, color: colors.secondary),
                              )),
                          Visibility(
                              visible: state.comment.likeCount > 0,
                              child: Text(state.comment.likeCount.toString())),
                          Expanded(
                              child: Text(
                            state.comment.publishedText,
                            textAlign: TextAlign.end,
                            style: TextStyle(color: colors.secondary),
                          )),
                        ],
                      ),
                      Visibility(
                          visible: state.comment.replies != null &&
                              !state.showingChildren,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: SizedBox(
                                height: 15,
                                child: FilledButton.tonal(
                                    onPressed: cubit.toggleShowChildren,
                                    child: Text(
                                      // locals.nReplies(comment.replies?.replyCount ?? 0).toString()),
                                      locals.nReplies(
                                          state.comment.replies?.replyCount ??
                                              0),
                                      style: TextStyle(
                                          fontSize:
                                              textTheme.labelSmall?.fontSize),
                                    ))),
                          )),
                      Visibility(
                          visible: state.showingChildren,
                          child: CommentsView(
                            key: ValueKey(
                                'children-of-${state.comment.commentId}'),
                            video: video,
                            continuation: state.comment.replies?.continuation,
                          ))
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
