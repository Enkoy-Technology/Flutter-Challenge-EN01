// ignore_for_file: use_build_context_synchronously

import 'dart:typed_data';

import 'package:enkoy_chat/ui/common/app_colors.dart';
import 'package:enkoy_chat/ui/common/dimension.dart';
import 'package:enkoy_chat/ui/common/icons.dart';
import 'package:enkoy_chat/ui/common/widgets/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ChatFileUploadPreview extends StatefulWidget {
  final XFile file;
  const ChatFileUploadPreview({
    super.key,
    required this.file,
  });

  @override
  State<ChatFileUploadPreview> createState() => _ChatFileUploadPreviewState();
}

class _ChatFileUploadPreviewState extends State<ChatFileUploadPreview> {
  Uint8List? imageBytes;
  TextEditingController messageTextController = TextEditingController();
  bool isProfileUploading = false;

  @override
  initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      imageBytes = await widget.file.readAsBytes();
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kdScreenHeight(context) * .8,
      child: Stack(
        children: [
          if (imageBytes != null)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  imageBytes!,
                  height: kdScreenHeight(context),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(color: kcPrimaryContainer(context)),
              child: TextFieldWidget(
                controller: messageTextController,
                validator: (value) {
                  return null;
                },
                onTap: () async {},
                hintText: "Add a caption...",
                suffixWidget: Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop({
                        "status": "send",
                        "caption": messageTextController.text,
                      });
                    },
                    child: Icon(
                      kiSend,
                      color: kcPrimary(context),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
