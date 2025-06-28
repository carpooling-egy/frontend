import 'dart:io';
import 'package:flutter/material.dart';

import '../../services/image_service.dart';

class ImagePickerWidget extends StatefulWidget {
  final String? initialImagePath;
  final double size;
  final Function(String)? onImagePicked;
  final bool showCameraOption;

  const ImagePickerWidget({
    Key? key,
    this.initialImagePath,
    this.size = 100,
    this.onImagePicked,
    this.showCameraOption = true,
  }) : super(key: key);

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  String? _imagePath;
  final ImageService _imageService = ImageService();

  @override
  void initState() {
    super.initState();
    _imagePath = widget.initialImagePath;
  }

  Future<void> _pickImage() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pick from Gallery'),
                onTap: () => Navigator.pop(context, 'gallery'),
              ),
              if (widget.showCameraOption)
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take a Photo'),
                  onTap: () => Navigator.pop(context, 'camera'),
                ),
            ],
          ),
        );
      },
    );

    if (result == null) return;

    String? newImagePath;
    if (result == 'gallery') {
      newImagePath = await _imageService.pickAndSaveImage();
    } else if (result == 'camera') {
      newImagePath = await _imageService.takeAndSavePhoto();
    }

    if (newImagePath != null) {
      setState(() {
        _imagePath = newImagePath;
      });
      widget.onImagePicked?.call(newImagePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        children: [
          CircleAvatar(
            radius: widget.size / 2,
            backgroundImage: _imagePath != null
                ? FileImage(File(_imagePath!))
                : const AssetImage('lib/assets/images/avatar.png') as ImageProvider,
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
              child: Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: widget.size * 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 