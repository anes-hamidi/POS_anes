import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/image_picker_service.dart';

class ImagePickerField extends StatelessWidget {
  final String? initialImageUrl;
  final Function(File) onImagePicked;

  const ImagePickerField({
    super.key,
    this.initialImageUrl,
    required this.onImagePicked,
  });

  @override
  Widget build(BuildContext context) {
    final imagePickerService = Provider.of<ImagePickerService>(context, listen: false);
    final colorScheme = Theme.of(context).colorScheme;
    File? imageFile;

    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          GestureDetector(
            onTap: () async {
              final file = await imagePickerService.pickImageFromGallery();
              if (file != null) {
                onImagePicked(file);
              }
            },
            child: Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: imageFile != null
                    ? Image.file(imageFile, fit: BoxFit.cover)
                    : (initialImageUrl != null && initialImageUrl!.isNotEmpty && !initialImageUrl!.startsWith('/'))
                        ? Image.network(initialImageUrl!, fit: BoxFit.cover, errorBuilder: (c,e,s)=> const Icon(Icons.camera_alt_outlined, size: 50))
                        : const Icon(Icons.camera_alt_outlined, size: 50),
              ),
            ),
          ),
          FloatingActionButton(
            mini: true,
            onPressed: () async {
              final file = await imagePickerService.pickImageFromGallery();
              if (file != null) {
                onImagePicked(file);
              }
            },
            child: const Icon(Icons.edit, size: 20),
          ),
        ],
      ),
    );
  }
}
