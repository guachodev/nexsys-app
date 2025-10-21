import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nexsys_app/core/constants/constants.dart';

import 'base_card.dart';

class PhotoViewerWithActions extends StatefulWidget {
  final String? initialImageUrl;
  final VoidCallback? onTakePhoto;
  final VoidCallback? onDeletePhoto;
  final bool showDeleteButton;

  const PhotoViewerWithActions({
    super.key,
    this.initialImageUrl,
    required this.onTakePhoto,
    required this.onDeletePhoto,
    this.showDeleteButton = false,
  });

  @override
  State<PhotoViewerWithActions> createState() => _PhotoViewerWithActionsState();
}

class _PhotoViewerWithActionsState extends State<PhotoViewerWithActions> {
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    _currentImageUrl = widget.initialImageUrl;
  }

  @override
  void didUpdateWidget(covariant PhotoViewerWithActions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialImageUrl != oldWidget.initialImageUrl) {
      _currentImageUrl = widget.initialImageUrl;
    }
  }

  void _handleDeletePhoto() {
    setState(() {
      _currentImageUrl = null;
    });
    widget.onDeletePhoto?.call();
  }

  void _showImageDialog(BuildContext context) {
    if (_currentImageUrl == null) return;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        //backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            _ImageViewer(
              image: _currentImageUrl!,
              height: MediaQuery.of(context).size.height * 0.6,
              width: MediaQuery.of(context).size.width * 0.9,
              fit: BoxFit.fitHeight,
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.grey.shade600),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                  padding: const EdgeInsets.all(8),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTakePhotoButton(),
        const SizedBox(height: AppDesignTokens.spacingS),
        Stack(
          children: [
            BaseCard(
              backgroundColor: Colors.grey.shade200,
              padding: EdgeInsets.zero,
              child: SizedBox(
                height: 200,
                width: double.infinity,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildImageContent(),
                ),
              ),
            ),
            if (_currentImageUrl != null)
              Positioned(bottom: 8, left: 8, child: _buildPhotoBadge()),
          ],
        ),
      ],
    );
  }

  Widget _buildImageContent() {
    if (_currentImageUrl == null || _currentImageUrl!.isEmpty) {
      return _buildEmptyState();
    }

    return _ImageViewer(
      image: _currentImageUrl!,
      height: 200,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.camera_alt_outlined, size: 56, color: Colors.grey.shade400),
        const SizedBox(height: 12),
        Text(
          'Toca para tomar foto',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'La foto es obligatoria para el registro',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPhotoBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.shade500,
        borderRadius: AppDesignTokens.borderRadiusSmall,
        boxShadow: [AppDesignTokens.shadowSmall],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          const Text(
            'Foto tomada',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTakePhotoButton() {
    return Row(
      children: [
        Expanded(
          child: FilledButton.tonal(
            onPressed: widget.onTakePhoto,
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              backgroundColor: _currentImageUrl == null
                  ? Colors.indigo.shade50
                  : Colors.indigo.shade50,
              foregroundColor: _currentImageUrl == null
                  ? Colors.indigo.shade700
                  : Colors.indigo.shade700,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _currentImageUrl == null
                      ? Icons.camera_alt
                      : Icons.camera_alt_outlined,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  _currentImageUrl == null ? 'Tomar foto' : 'Cambiar foto',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        if (_currentImageUrl != null) ...[
          const SizedBox(width: 8),
          IconButton(
            onPressed: _handleDeletePhoto,
            icon: Icon(Icons.delete_outline, color: Colors.red.shade600),
            style: IconButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              padding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _showImageDialog(context),
            icon: const Icon(Icons.photo_rounded, color: Colors.indigo),
            style: IconButton.styleFrom(
              backgroundColor: Colors.indigo.shade50,
              padding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ],
    );
  }
}

class _ImageViewer extends StatelessWidget {
  final String image;
  final double? height;
  final double? width;
  final BoxFit? fit;
  const _ImageViewer({
    required this.image,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: image.isEmpty ? _buildPlaceholder() : _buildImage(fit),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        borderRadius: AppDesignTokens.borderRadiusMedium,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_camera_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            'Sin imagen',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(BoxFit? fit) {
    return FadeInImage(
      fit: fit,
      height: height,
      width: width,
      //fadeOutDuration: const Duration(milliseconds: 100),
      //fadeInDuration: const Duration(milliseconds: 200),
      image: FileImage(File(image)),
      placeholder: const AssetImage('assets/images/loading-image.webp'),
    );
  }
}
