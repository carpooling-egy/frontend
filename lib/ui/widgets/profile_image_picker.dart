import 'package:flutter/material.dart';
import 'package:frontend/services/profile_image_service.dart';

class ProfileImagePicker extends StatelessWidget {
  final String email;
  final String? currentImageUrl;
  final Function(String) onImageUpdated;

  const ProfileImagePicker({
    Key? key,
    required this.email,
    this.currentImageUrl,
    required this.onImageUpdated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickImage(context),
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: currentImageUrl != null
                ? NetworkImage(currentImageUrl!)
                : null,
            child: currentImageUrl == null
                ? const Icon(Icons.person, size: 50)
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final imageService = ProfileImageService();
    final imageUrl = await imageService.pickAndUploadImage(email);
    
    if (imageUrl != null) {
      onImageUpdated(imageUrl);
    }
  }
} 