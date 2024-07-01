import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:flutter_chat_ui/src/util.dart';
import 'package:solevato_client_sdk_flutter/ui/solevato_chat_theme.dart';
import 'package:flutter_link_previewer/src/utils.dart';
import 'package:flutter_link_previewer/src/widgets/link_preview.dart';
import 'package:solevato_client_sdk_flutter/util/photo_view.dart';

class CustomTextMessage extends StatelessWidget {
  final bool? isMe;
  final bool? showUsersName;
  final User? author;
  final String? message;
  final SolevatoChatTheme? theme;
  final List<dynamic>? attachment;

  const CustomTextMessage({
    this.isMe,
    this.showUsersName,
    this.author,
    this.message,
    this.attachment,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    String logoImage = 'assets/robot_assistant.png';
    String userName = author != null
        ? getUserName(author!).trim().isNotEmpty
            ? getUserName(author!)
            : 'Bot'
        : 'Bot';
    final urlRegexp = RegExp(REGEX_LINK);
    final matches = urlRegexp.allMatches((message ?? '').toLowerCase());
    List<RegExpMatch> matchesList = matches.toList();
    if (matches.isNotEmpty) {
      return _linkPreview(
        _width,
        matchesList,
        userName,
      );
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (author != null && userName == 'Bot') ...[
                    logoAsset(logoImage),
                    SizedBox(width: 8),
                  ] else ...[
                    if ((author?.imageUrl ?? '').trim().isNotEmpty) ...[
                      userImage(author!.imageUrl!),
                      SizedBox(width: 8),
                    ],
                  ],
                  Text(
                    userName,
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
                ],
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
          if ((attachment ?? []).isNotEmpty) ...[
            SizedBox(height: 5),
            attachment!.length > 1
                ? GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4.0,
                      mainAxisSpacing: 4.0,
                    ),
                    itemCount: attachment!.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return attachment![index]['file_type'] != null &&
                              attachment![index]['file_type'] == 'image' &&
                              attachment![index]['data_url'] != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: InkWell(
                                onTap: () {
                                  PhotoView.show(
                                    context: context,
                                    index: index,
                                    images: attachment!,
                                  );
                                },
                                child: Image.network(
                                  attachment![index]['data_url'],
                                  width: 150,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : SizedBox.shrink();
                    },
                  )
                : attachment![0]['file_type'] != null &&
                        attachment![0]['file_type'] == 'image' &&
                        attachment![0]['data_url'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          onTap: () {
                            PhotoView.show(
                              context: context,
                              index: 0,
                              images: attachment!,
                            );
                          },
                          child: Image.network(
                            attachment![0]['data_url'],
                            width: double.infinity,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : SizedBox.shrink()
          ],
        ],
      ),
    );
  }

  Widget _linkPreview(
    double width,
    List<RegExpMatch> matchesList,
    String userName,
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

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: LinkPreview(
        enableAnimation: true,
        header: showUsersName == true ? userName : '',
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
      ),
    );
  }

  Widget logoAsset(String logoImage) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: Image.asset(
        logoImage,
        package: 'solevato_client_sdk_flutter',
        width: 20,
        height: 20,
      ),
    );
  }

  Widget userImage(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: Image.network(
        url,
        width: 20,
        height: 20,
      ),
    );
  }
}
