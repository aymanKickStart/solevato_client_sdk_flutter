import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:flutter_chat_ui/src/util.dart';
import 'package:solevato_client_sdk_flutter/ui/solevato_chat_theme.dart';
import 'package:flutter_link_previewer/src/utils.dart';
import 'package:flutter_link_previewer/src/widgets/link_preview.dart';

class CustomTextMessage extends StatelessWidget {
  final bool? isMe;
  final bool? showUsersName;
  final User? author;
  final String? message;
  final SolevatoChatTheme? theme;

  const CustomTextMessage({
    this.isMe,
    this.showUsersName,
    this.author,
    this.message,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;

    final urlRegexp = RegExp(REGEX_LINK);
    final matches = urlRegexp.allMatches((message ?? '').toLowerCase());
    List<RegExpMatch> matchesList = matches.toList();

    if (matches.isNotEmpty) {
      return _linkPreview(_width, matchesList);
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: EdgeInsetsDirectional.only(
        bottom: 15,
      ),
      child: Column(
        crossAxisAlignment:
            (isMe ?? false) ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if ((showUsersName ?? false) == true && (isMe ?? false) == false) ...[
            Padding(
              padding: const EdgeInsets.only(
                bottom: 6.0,
                top: 10,
              ),
              child: Text(
                author != null ? getUserName(author!) : '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme != null && author != null
                    ? theme!.userNameTextStyle.copyWith(
                        color: getUserAvatarNameColor(
                          author!,
                          theme!.userAvatarNameColors,
                        ),
                      )
                    : null,
              ),
            ),
          ] else ...[
            SizedBox(height: 15),
          ],
          Text(
            message ?? '',
            style: (isMe ?? false)
                ? theme?.sentMessageBodyTextStyle
                : theme?.receivedMessageBodyTextStyle,
          ),
        ],
      ),
    );
  }

  Widget _linkPreview(
    double width,
    List<RegExpMatch> matchesList,
  ) {
    final bodyTextStyle = (isMe ?? false)
        ? theme?.sentMessageBodyTextStyle
        : theme?.receivedMessageBodyTextStyle;
    final linkDescriptionTextStyle = (isMe ?? false)
        ? theme?.sentMessageLinkDescriptionTextStyle
        : theme?.receivedMessageLinkDescriptionTextStyle;
    final linkTitleTextStyle = (isMe ?? false)
        ? theme?.sentMessageLinkTitleTextStyle
        : theme?.receivedMessageLinkTitleTextStyle;

    final color = getUserAvatarNameColor(
      author!,
      theme!.userAvatarNameColors,
    );
    final name = getUserName(author!);

    return LinkPreview(
      enableAnimation: true,
      header: showUsersName == true ? name : null,
      headerStyle: theme?.userNameTextStyle.copyWith(color: color),
      linkStyle: bodyTextStyle,
      metadataTextStyle: linkDescriptionTextStyle,
      metadataTitleStyle: linkTitleTextStyle,
      padding: EdgeInsets.only(
        bottom: 15,
        left: 15,
        right: 15,
      ),
      text: message ?? '',
      textStyle: bodyTextStyle,
      width: width,
      onPreviewDataFetched: (data) {},
      previewData: PreviewData(),
    );
  }
}
