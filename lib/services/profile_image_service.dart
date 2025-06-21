import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileImageService {
  final FirebaseStorage _storage;
  final ImagePicker _picker;
  static const String _imageFileName = 'profile_image.jpg';

  ProfileImageService()
      : _storage = FirebaseStorage.instance,
        _picker = ImagePicker();

  Future<String?> pickAndSaveImage() async {
    try {
      // Pick image from gallery
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image == null) return null;

      // Get the directory to store the image
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String imagePath = '${appDir.path}/$_imageFileName';
      
      // Copy the image to the new path
      final File newImage = await File(image.path).copy(imagePath);
      return newImage.path;
    } catch (e) {
      debugPrint('Error saving profile image: $e');
      return null;
    }
  }

  Future<String?> getSavedImagePath() async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String imagePath = '${appDir.path}/$_imageFileName';
      final File imageFile = File(imagePath);
      
      if (await imageFile.exists()) {
        return imagePath;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting saved image path: $e');
      return null;
    }
  }

  Future<String?> pickAndUploadImage(String email) async {
    try {
      // Pick image from gallery
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image == null) return null;

      // Upload to Firebase Storage
      final String fileName = 'profile_images/$email.jpg';
      final Reference storageRef = _storage.ref().child(fileName);
      
      // Upload the file
      await storageRef.putFile(File(image.path));
      
      // Get the download URL
      return await storageRef.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading profile image: $e');
      return null;
    }
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      print('Error deleting image: $e');
    }
  }
} 