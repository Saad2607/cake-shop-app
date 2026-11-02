import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import 'glass/glass_card.dart';

class OrderTrackingMap extends StatefulWidget {
  final String status;
  final String orderNumber;
  final String deliveryAddress;
  final String? riderName;
  final String? riderPhone;
  final String? deliveryOtp;

  const OrderTrackingMap({
    super.key,
    required this.status,
    required this.orderNumber,
    required this.deliveryAddress,
    this.riderName,
    this.riderPhone,
    this.deliveryOtp,
  });

  @override
  State<OrderTrackingMap> createState() => _OrderTrackingMapState();
}

class _OrderTrackingMapState extends State<OrderTrackingMap> with SingleTickerProviderStateMixin {
  // Bakery Central Kitchen (Alkapuri, Vadodara)
  static const LatLng _bakeryLocation = LatLng(22.3072, 73.1812);
  // Default Customer delivery pin (Fatehgunj / Sayajiganj area)
  static const LatLng _customerLocation = LatLng(22.3195, 73.1960);

  // Simulated route waypoints
  static const List<LatLng> _routePoints = [
    LatLng(22.3072, 73.1812), // Bakery
    LatLng(22.3090, 73.1840),
    LatLng(22.3120, 73.1880),
    LatLng(22.3150, 73.1915),
    LatLng(22.3175, 73.1935),
    LatLng(22.3195, 73.1960), // Customer
  ];

  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  LatLng _getRiderLocation() {
    if (widget.status == 'DELIVERED') {
      return _customerLocation;
    } else if (widget.status == 'OUT_FOR_DELIVERY') {
      // 65% way through route
      return const LatLng(22.3150, 73.1915);
    } else {
      // Still at bakery kitchen
      return _bakeryLocation;
    }
  }

  Future<void> _makeCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWhatsApp(String phone, String orderNo) async {
    final message = Uri.encodeComponent(
      'Hi Rahul, inquiring about my Sweet Delights cake delivery (Order #$orderNo).',
    );
    final uri = Uri.parse('https://wa.me/$phone?text=$message');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final riderPos = _getRiderLocation();
    final isOutForDelivery = widget.status == 'OUT_FOR_DELIVERY';

    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Map Header Pill
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.map_outlined,
                    color: AppTheme.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Live Route Navigation',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.titleMedium.copyWith(fontSize: 14),
                      ),
                      Text(
                        isOutForDelivery
                            ? 'Scooter moving towards delivery pin · ETA ~15 min'
                            : 'Kitchen dispatched via temperature-controlled box',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.bodySmall.copyWith(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isOutForDelivery
                        ? const Color(0xFF2E7D32).withValues(alpha: 0.15)
                        : AppTheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isOutForDelivery ? const Color(0xFF2E7D32) : AppTheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isOutForDelivery ? 'LIVE GPS' : 'READY',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isOutForDelivery ? const Color(0xFF2E7D32) : AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Interactive Map Container
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 220,
              child: FlutterMap(
                options: const MapOptions(
                  initialCenter: LatLng(22.3135, 73.1885),
                  initialZoom: 14.2,
                  interactionOptions: InteractionOptions(
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                ),
                children: [
                  // OpenStreetMap Raster Tiles
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.sweetdelights.cakeshop',
                    maxZoom: 19,
                  ),

                  // Route Polyline
                  PolylineLayer(
                    polylines: [
                      // Glow line
                      Polyline(
                        points: _routePoints,
                        strokeWidth: 8,
                        color: AppTheme.primary.withValues(alpha: 0.35),
                      ),
                      // Core dashed/solid line
                      Polyline(
                        points: _routePoints,
                        strokeWidth: 4,
                        color: AppTheme.primary,
                      ),
                    ],
                  ),

                  // Markers Layer
                  MarkerLayer(
                    markers: [
                      // Bakery Marker
                      Marker(
                        point: _bakeryLocation,
                        width: 44,
                        height: 44,
                        child: _mapPin(
                          icon: Icons.storefront_rounded,
                          color: AppTheme.primaryDark,
                          tooltip: 'Bakery',
                        ),
                      ),

                      // Customer Destination Marker
                      Marker(
                        point: _customerLocation,
                        width: 44,
                        height: 44,
                        child: _mapPin(
                          icon: Icons.home_rounded,
                          color: const Color(0xFF2E7D32),
                          tooltip: 'Home',
                        ),
                      ),

                      // Moving Delivery Rider Scooter Marker
                      Marker(
                        point: riderPos,
                        width: 50,
                        height: 50,
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            final scale = 1.0 + (_pulseController.value * 0.12);
                            return Transform.scale(
                              scale: scale,
                              child: child,
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.accent,
                              border: Border.all(color: Colors.white, width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.accent.withValues(alpha: 0.45),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.delivery_dining_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Delivery Partner Contact Card
          Padding(
            padding: const EdgeInsets.all(14),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                children: [
                  // Rider Avatar
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppTheme.primaryLight,
                        child: const Icon(
                          Icons.person_rounded,
                          color: AppTheme.primary,
                          size: 26,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Color(0xFF2E7D32),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check, size: 10, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  // Rider Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.riderName ?? 'Rahul Verma',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTheme.titleMedium.copyWith(fontSize: 13.5),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF8E1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFFFD54F)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star_rounded, size: 11, color: Color(0xFFFFA000)),
                                  SizedBox(width: 2),
                                  Text(
                                    '4.9',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFFA000),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Delivery Partner · Verified',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.bodySmall.copyWith(fontSize: 11, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                  // Call Action Button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => _makeCall(widget.riderPhone ?? '+919876543210'),
                      child: Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFA5D6A7)),
                        ),
                        child: const Icon(
                          Icons.phone_in_talk_rounded,
                          color: Color(0xFF2E7D32),
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // WhatsApp Action Button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => _openWhatsApp(widget.riderPhone ?? '919876543210', widget.orderNumber),
                      child: Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2F1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF80CBC4)),
                        ),
                        child: const Icon(
                          Icons.chat_bubble_rounded,
                          color: Color(0xFF00897B),
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapPin({
    required IconData icon,
    required Color color,
    required String tooltip,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
      ],
    );
  }
}
