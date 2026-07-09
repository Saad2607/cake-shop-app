import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

import '../screens/catalog/cake_detail_screen.dart';

/// Opens cake detail when the app is launched from a product link.
class DeepLinkHandler extends StatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  const DeepLinkHandler({
    super.key,
    required this.child,
    required this.navigatorKey,
  });

  @override
  State<DeepLinkHandler> createState() => _DeepLinkHandlerState();
}

class _DeepLinkHandlerState extends State<DeepLinkHandler> {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;

  @override
  void initState() {
    super.initState();
    _initLinks();
  }

  Future<void> _initLinks() async {
    final initial = await _appLinks.getInitialLink();
    if (initial != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openFromUri(initial);
      });
    }

    _subscription = _appLinks.uriLinkStream.listen(
      _openFromUri,
      onError: (_) {},
    );
  }

  void _openFromUri(Uri uri) {
    final cakeId = _cakeIdFromUri(uri);
    if (cakeId == null || cakeId.isEmpty) return;

    final nav = widget.navigatorKey.currentState;
    if (nav == null) return;

    nav.push(
      MaterialPageRoute(builder: (_) => CakeDetailScreen(cakeId: cakeId)),
    );
  }

  String? _cakeIdFromUri(Uri uri) {
    if (uri.scheme == 'sweetdelights' && uri.host == 'cake') {
      final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      if (segments.isNotEmpty) return segments.first;
      final trimmed = uri.path.replaceAll('/', '').trim();
      return trimmed.isEmpty ? null : trimmed;
    }

    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.length >= 2 && segments[segments.length - 2] == 'p') {
      return segments.last;
    }

    if (uri.path.contains('/p/')) {
      return uri.path.split('/p/').last.split('/').first.trim();
    }

    return null;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
