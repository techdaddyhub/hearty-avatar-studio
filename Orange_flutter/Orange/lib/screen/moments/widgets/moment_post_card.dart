import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:orange_ui/screen/moments/moments_screen_view_model.dart';
import 'package:orange_ui/utils/color_res.dart';
import 'package:orange_ui/utils/const_res.dart';

class MomentPostCard extends StatefulWidget {
  final DecryptedMoment moment;
  final VoidCallback onLike;

  const MomentPostCard({
    super.key,
    required this.moment,
    required this.onLike,
  });

  @override
  State<MomentPostCard> createState() => _MomentPostCardState();
}

class _MomentPostCardState extends State<MomentPostCard> {
  bool _showActionPopup = false;

  @override
  Widget build(BuildContext context) {
    final moment = widget.moment;
    final dateStr = DateFormat('MM-dd HH:mm').format(
      DateTime.fromMillisecondsSinceEpoch(moment.timestamp),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.15), width: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Avatar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: 42,
              height: 42,
              color: ColorRes.themeColor.withValues(alpha: 0.15),
              child: moment.authorImage != null && moment.authorImage!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: moment.authorImage!.startsWith('http')
                          ? moment.authorImage!
                          : '${ConstRes.aImageBaseUrl}${moment.authorImage}',
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _buildAvatarLetter(moment.authorName),
                    )
                  : _buildAvatarLetter(moment.authorName),
            ),
          ),
          const SizedBox(width: 12),

          // Main Post Body
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author Name (WeChat Blue: #576B95)
                Row(
                  children: [
                    Text(
                      moment.authorName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF576B95),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.lock, size: 12, color: Colors.green),
                  ],
                ),
                const SizedBox(height: 6),

                // Post Content
                Text(
                  moment.content,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF191919),
                    height: 1.35,
                  ),
                ),

                // Media Grid (if any photos exist)
                if (moment.mediaUrls.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: _buildMediaGrid(moment.mediaUrls),
                  ),

                const SizedBox(height: 10),

                // Footer: Timestamp & WeChat 2-dot Action Pill
                Row(
                  children: [
                    Text(
                      dateStr,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const Spacer(),

                    // Floating WeChat Action Pill
                    if (_showActionPopup)
                      Container(
                        height: 32,
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4C5154),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() => _showActionPopup = false);
                                widget.onLike();
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    widget.moment.isLiked ? Icons.favorite : Icons.favorite_border,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.moment.isLiked ? 'Liked' : 'Like',
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(width: 0.5, height: 16, color: Colors.white24),
                            const SizedBox(width: 12),
                            InkWell(
                              onTap: () {
                                setState(() => _showActionPopup = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Comment feature ready')),
                                );
                              },
                              child: Row(
                                children: const [
                                  Icon(Icons.comment_outlined, color: Colors.white, size: 15),
                                  SizedBox(width: 4),
                                  Text('Comment', style: TextStyle(color: Colors.white, fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Trigger 2-dot icon button
                    GestureDetector(
                      onTap: () => setState(() => _showActionPopup = !_showActionPopup),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F7F7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.more_horiz, size: 18, color: Color(0xFF576B95)),
                      ),
                    ),
                  ],
                ),

                // Likes banner if liked
                if (moment.isLiked || moment.likeCount > 0)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.favorite_border, size: 13, color: Color(0xFF576B95)),
                        const SizedBox(width: 6),
                        Text(
                          moment.isLiked ? 'You liked this' : '${moment.likeCount} contacts liked',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF576B95),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaGrid(List<String> urls) {
    if (urls.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 180, maxHeight: 180),
          child: CachedNetworkImage(
            imageUrl: urls[0].startsWith('http') ? urls[0] : '${ConstRes.aImageBaseUrl}${urls[0]}',
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.grey),
          ),
        ),
      );
    }

    final count = urls.length > 9 ? 9 : urls.length;
    final cols = count <= 4 ? 2 : 3;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, idx) {
        final url = urls[idx];
        return ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: CachedNetworkImage(
            imageUrl: url.startsWith('http') ? url : '${ConstRes.aImageBaseUrl}$url',
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => Container(color: Colors.grey.shade200),
          ),
        );
      },
    );
  }

  Widget _buildAvatarLetter(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(
          color: ColorRes.themeColor,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}
