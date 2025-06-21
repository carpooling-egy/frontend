import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<String?> pickAndSaveImage() async {
    try {
      // Pick an image
      final XFile? imageFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Compress image to reduce size
      );

      if (imageFile != null) {
        // Get the directory to store the image
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String imagePath = '${appDir.path}/${DateTime.now().millisecondsSinceEpoch}.png';

        // Copy the image to the new path
        final File newImage = await File(imageFile.path).copy(imagePath);
        return newImage.path;
      }
      return null;
    } catch (e) {
      debugPrint('Failed to pick and save image: $e');
      return null;
    }
  }

  Future<String?> takeAndSavePhoto() async {
    try {
      // Take a photo
      final XFile? photoFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (photoFile != null) {
        // Get the directory to store the image
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String imagePath = '${appDir.path}/${DateTime.now().millisecondsSinceEpoch}.png';

        // Copy the image to the new path
        final File newImage = await File(photoFile.path).copy(imagePath);
        return newImage.path;
      }
      return null;
    } catch (e) {
      debugPrint('Failed to take and save photo: $e');
      return null;
    }
  }

  Future<void> deleteImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Failed to delete image: $e');
    }
  }
} 