import 'package:digistore/src/data/services/image_services.dart';
import 'package:flutter/material.dart';
import 'package:digistore/src/data/services/snackbar_service.dart';

Future<void> downloadImage(String imageUrl, BuildContext context) async {
  try {
    await FileDownloadService().downloadFile(url: imageUrl);

    SnackbarService snackbarService = SnackbarService();
    snackbarService.showSnackBar(context, 'Image saved');
  } catch (e) {
    SnackbarService snackbarService = SnackbarService();
    snackbarService.showSnackBar(context, 'Failed to download image');
  }
}
