import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:godropme/services/appwrite/appwrite_client.dart';
import 'package:godropme/theme/colors.dart';

/// A widget that displays images from Appwrite storage with proper authentication.
/// 
/// Unlike CachedNetworkImage, this widget uses the Appwrite SDK to fetch images,
/// which automatically includes the session authentication cookies.
/// 
/// Usage:
/// ```dart
/// AppwriteImage(
///   imageUrl: 'https://fra.cloud.appwrite.io/v1/storage/buckets/profile_photos/files/abc123/view?project=xyz',
///   width: 100,
///   height: 100,
///   fit: BoxFit.cover,
/// )
/// ```
class AppwriteImage extends StatefulWidget {
  /// The full Appwrite storage URL or just the file ID
  final String imageUrl;
  
  /// Width of the image
  final double? width;
  
  /// Height of the image
  final double? height;
  
  /// How to fit the image
  final BoxFit fit;
  
  /// Widget to show while loading
  final Widget? placeholder;
  
  /// Widget to show on error
  final Widget? errorWidget;
  
  /// Border radius for the image
  final BorderRadius? borderRadius;

  const AppwriteImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  });

  @override
  State<AppwriteImage> createState() => _AppwriteImageState();
}

class _AppwriteImageState extends State<AppwriteImage> {
  Uint8List? _imageBytes;
  bool _isLoading = true;
  bool _hasError = false;
  
  // Simple in-memory cache
  static final Map<String, Uint8List> _cache = {};

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(AppwriteImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _loadImage();
    }
  }

  /// Extract bucket ID and file ID from Appwrite URL
  /// URL format: https://[endpoint]/v1/storage/buckets/[bucketId]/files/[fileId]/view
  (String? bucketId, String? fileId) _parseUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      
      // Find 'buckets' and 'files' indices
      final bucketsIdx = segments.indexOf('buckets');
      final filesIdx = segments.indexOf('files');
      
      if (bucketsIdx != -1 && filesIdx != -1 && 
          bucketsIdx + 1 < segments.length && 
          filesIdx + 1 < segments.length) {
        return (segments[bucketsIdx + 1], segments[filesIdx + 1]);
      }
    } catch (e) {
      debugPrint('❌ Failed to parse URL: $url');
    }
    return (null, null);
  }

  Future<void> _loadImage() async {
    if (widget.imageUrl.isEmpty) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      return;
    }

    // Check cache first
    if (_cache.containsKey(widget.imageUrl)) {
      setState(() {
        _imageBytes = _cache[widget.imageUrl];
        _isLoading = false;
        _hasError = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final (bucketId, fileId) = _parseUrl(widget.imageUrl);
      
      if (bucketId == null || fileId == null) {
        throw Exception('Invalid Appwrite storage URL');
      }

      final storage = AppwriteClient.storageService();
      
      // Use getFileView which handles authentication automatically
      final bytes = await storage.getFileView(
        bucketId: bucketId,
        fileId: fileId,
      );

      // Cache the result
      _cache[widget.imageUrl] = bytes;

      if (mounted) {
        setState(() {
          _imageBytes = bytes;
          _isLoading = false;
          _hasError = false;
        });
      }
    } catch (e) {
      debugPrint('❌ AppwriteImage error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  /// Clear the image cache (useful when images are updated)
  // static void clearCache() {
  //   _cache.clear();
  // }

  /// Remove a specific URL from cache
  // static void removeFromCache(String url) {
  //   _cache.remove(url);
  // }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (_isLoading) {
      imageWidget = widget.placeholder ?? _buildDefaultPlaceholder();
    } else if (_hasError || _imageBytes == null) {
      imageWidget = widget.errorWidget ?? _buildDefaultError();
    } else {
      imageWidget = Image.memory(
        _imageBytes!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        gaplessPlayback: true,
      );
    }

    if (widget.borderRadius != null) {
      return ClipRRect(
        borderRadius: widget.borderRadius!,
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: imageWidget,
        ),
      );
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: imageWidget,
    );
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: AppColors.grayLight,
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultError() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: AppColors.grayLight,
      child: Icon(
        Icons.broken_image_outlined,
        size: (widget.width ?? 40) * 0.4,
        color: AppColors.darkGray.withValues(alpha: 0.5),
      ),
    );
  }
}
