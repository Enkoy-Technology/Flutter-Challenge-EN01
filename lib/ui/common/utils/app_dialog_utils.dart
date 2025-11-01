import 'dart:io';

import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:enkoy_chat/ui/common/app_colors.dart';
import 'package:enkoy_chat/ui/common/app_constant.dart';
import 'package:enkoy_chat/ui/common/dimension.dart';
import 'package:enkoy_chat/ui/common/font.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class AppDialogUtils {
  /// Shows a bottom modal sheet with flexible height.

  static Future<dynamic> showBottomModalSheet(
      {required Widget child,
      required BuildContext context,
      Color? backgroundColor,
      String? titleText,
      double? initHeight,
      double? minHeight,
      double? maxHeight,
      bool isDismissible = true,
      Color? titleColor,
      bool isCollapsible = true}) async {
    return await showFlexibleBottomSheet(
        initHeight: initHeight ?? minHeight ?? 0.3,
        minHeight: minHeight,
        maxHeight: maxHeight ?? 0.9,
        isCollapsible: isCollapsible,
        context: context,
        isExpand: true,
        isDismissible: isDismissible,
        bottomSheetColor: Colors.transparent,
        builder: (
          BuildContext context,
          ScrollController scrollController,
          double bottomSheetOffset,
        ) {
          return Container(
              width: kdScreenWidth(context),
              decoration: BoxDecoration(
                  color: backgroundColor ?? kcBackground(context),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25))),
              child: Padding(
                padding: const EdgeInsets.all(kdPadding),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                width: 80,
                                height: 7,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        kdContainerRadius),
                                    color: kcVeryLightGreyish(context)),
                              ),
                            ),
                            if (titleText != null) ...[
                              SizedBox(
                                width: kdScreenWidth(context),
                                child: Text(
                                  titleText,
                                  textAlign: TextAlign.center,
                                  style: kfBodyMedium(context,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              const Divider(),
                              kdSpaceSmall.height,
                            ],
                            child,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ));
        });
  }

  static Future<XFile?> pickFromGallery() async {
    bool hasPermission = await _photoPickerPermission();
    if (hasPermission) {
      XFile? file =
          await getFile(FileType.image, quality: IMAGE_COMPRESSION_QUALITY);
      return file;
    } else {
      Fluttertoast.showToast(msg: "Permission Denied");
      if (await Permission.storage.status.isPermanentlyDenied ||
          await Permission.photos.status.isPermanentlyDenied) {
        openAppSettings();
      }
    }
    return null;
  }

  static Future<bool> _photoPickerPermission() async {
    try {
      bool hasPermission = false;
      if (Platform.isAndroid) {
        final deviceInfoPlugin = DeviceInfoPlugin();
        final androidInfo = await deviceInfoPlugin.androidInfo;
        final int sdkInt = androidInfo.version.sdkInt;
        // API <=33+
        if (sdkInt > 32) {
          PermissionStatus status = await Permission.photos.status;
          if (status.isDenied) {
            status = await Permission.photos.request();
          }
          hasPermission = status == PermissionStatus.granted;
        } else {
          // API <=32
          PermissionStatus status = await Permission.storage.status;
          if (status.isDenied) {
            status = await Permission.storage.request();
          }
          hasPermission = status == PermissionStatus.granted;
        }
      } else {
        // iOS or other: Fallback to photos
        PermissionStatus status = await Permission.photos.status;
        if (status.isDenied) {
          status = await Permission.photos.request();
        }
        hasPermission = status == PermissionStatus.granted;
      }
      return hasPermission;
    } catch (e) {
      //
      return false;
    }
  }

  static captureFromCamera({int quality = IMAGE_COMPRESSION_QUALITY}) async {
    final ImagePicker picker = ImagePicker();

    final XFile? photo = await picker.pickImage(
        source: ImageSource.camera, imageQuality: quality);
    if (photo != null) {
      return photo;
    }
  }

  static getFile(FileType fileType,
      {int quality = IMAGE_COMPRESSION_QUALITY}) async {
    final ImagePicker picker = ImagePicker();
    if (fileType == FileType.image) {
      final XFile? photo = await picker.pickImage(
          source: ImageSource.gallery, imageQuality: quality);
      if (photo != null) {
        return photo;
      }
    } else {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: fileType,
      );
      if (result != null) {
        XFile selectedFile = XFile(result.paths.first!);

        String ext =
            XFile(result.paths.first!).name.split(".").last.toLowerCase();
        if (["jpg", "jpeg", "gif", "png"].contains(ext)) {
          var compressedBytes = (await FlutterImageCompress.compressWithFile(
              selectedFile.path,
              quality: quality))!;
          File compressedFile = File(selectedFile.path);
          await compressedFile.writeAsBytes(compressedBytes);
        }
        return selectedFile;
      }
    }
  }
}
