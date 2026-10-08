import 'dart:convert';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Network icon that inspects file bytes before choosing a decoder.
///
/// Category "SVG" URLs from the API are often mislabeled rasters (JPEG/PNG).
/// Feeding those to [SvgPicture.network] throws [XmlParserException] and, via
/// flutter_svg's cache, surfaces as an unhandled async error that Crashlytics
/// records as fatal — freezing the UI on the home categories strip.
class SafeNetworkIcon extends StatefulWidget {
  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget Function(BuildContext context) placeholderBuilder;
  final Widget Function(BuildContext context) errorBuilder;

  const SafeNetworkIcon({
    super.key,
    required this.url,
    required this.placeholderBuilder,
    required this.errorBuilder,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
  });

  @override
  State<SafeNetworkIcon> createState() => _SafeNetworkIconState();
}

enum _IconKind { loading, raster, svg, failed }

class _SafeNetworkIconState extends State<SafeNetworkIcon> {
  static final Map<String, _IconKind> _kindCache = {};
  static final Map<String, String> _svgCache = {};

  _IconKind _kind = _IconKind.loading;
  String? _svgXml;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(covariant SafeNetworkIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _resolve();
    }
  }

  Future<void> _resolve() async {
    final url = widget.url.trim();
    final cached = _kindCache[url];
    if (cached != null) {
      setState(() {
        _kind = cached;
        _svgXml = _svgCache[url];
      });
      return;
    }

    setState(() {
      _kind = _IconKind.loading;
      _svgXml = null;
    });

    try {
      final file = await DefaultCacheManager().getSingleFile(url);
      final bytes = Uint8List.fromList(await file.readAsBytes());
      if (!mounted || widget.url.trim() != url) return;

      if (_isRaster(bytes)) {
        _kindCache[url] = _IconKind.raster;
        setState(() => _kind = _IconKind.raster);
        return;
      }

      if (_looksLikeSvg(bytes)) {
        final xml = utf8.decode(bytes);
        _kindCache[url] = _IconKind.svg;
        _svgCache[url] = xml;
        setState(() {
          _kind = _IconKind.svg;
          _svgXml = xml;
        });
        return;
      }

      // Unknown payload — let CachedNetworkImage try (covers odd rasters).
      _kindCache[url] = _IconKind.raster;
      setState(() => _kind = _IconKind.raster);
    } catch (_) {
      if (!mounted || widget.url.trim() != url) return;
      _kindCache[url] = _IconKind.failed;
      setState(() => _kind = _IconKind.failed);
    }
  }

  static bool _isRaster(Uint8List bytes) {
    if (bytes.length < 12) return false;
    // JPEG
    if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
      return true;
    }
    // PNG
    if (bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return true;
    }
    // GIF
    if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46) {
      return true;
    }
    // WebP: RIFF....WEBP
    if (bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return true;
    }
    return false;
  }

  static bool _looksLikeSvg(Uint8List bytes) {
    // Skip BOM / leading whitespace; reject binary garbage early.
    final sampleLen = bytes.length < 512 ? bytes.length : 512;
    final sample = utf8.decode(
      bytes.sublist(0, sampleLen),
      allowMalformed: true,
    );
    final trimmed = sample.trimLeft();
    if (trimmed.isEmpty || trimmed.codeUnitAt(0) != 0x3C /* < */) {
      return false;
    }
    final lower = trimmed.toLowerCase();
    return lower.startsWith('<?xml') ||
        lower.startsWith('<svg') ||
        lower.contains('<svg');
  }

  @override
  Widget build(BuildContext context) {
    switch (_kind) {
      case _IconKind.loading:
        return widget.placeholderBuilder(context);
      case _IconKind.failed:
        return widget.errorBuilder(context);
      case _IconKind.raster:
        return CachedNetworkImage(
          imageUrl: widget.url,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          placeholder: (context, _) => widget.placeholderBuilder(context),
          errorWidget: (context, _, _) => widget.errorBuilder(context),
        );
      case _IconKind.svg:
        final xml = _svgXml;
        if (xml == null || xml.isEmpty) return widget.errorBuilder(context);
        return SvgPicture.string(
          xml,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          placeholderBuilder: widget.placeholderBuilder,
          errorBuilder: (context, _, _) => widget.errorBuilder(context),
        );
    }
  }
}
