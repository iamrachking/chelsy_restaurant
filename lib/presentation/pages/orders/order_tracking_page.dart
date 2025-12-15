import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:chelsy_restaurant/core/theme/app_colors.dart';
import 'package:chelsy_restaurant/presentation/controllers/tracking_controller.dart';
import 'package:chelsy_restaurant/presentation/controllers/order_controller.dart';
import 'package:chelsy_restaurant/presentation/widgets/loading_widget.dart';

class OrderTrackingPage extends StatefulWidget {
  final int orderId;

  const OrderTrackingPage({super.key, required this.orderId});

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  final TrackingController _trackingController = Get.find<TrackingController>();
  final OrderController _orderController = Get.find<OrderController>();
  GoogleMapController? _mapController;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _startTracking();
    _loadOrder();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  void _startTracking() {
    _trackingController.startTracking(widget.orderId);
    
    // Auto refresh every 5 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _trackingController.refreshTracking(widget.orderId);
    });
  }

  Future<void> _loadOrder() async {
    await _orderController.getOrder(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suivi de la commande'),
      ),
      body: Obx(
        () {
          final order = _orderController.selectedOrder.value;

          if (order == null) {
            return const LoadingWidget();
          }

          if (order.status != 'out_for_delivery' && order.status != 'ready') {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_shipping_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Le suivi n\'est pas disponible',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Le livreur n\'a pas encore pris la route',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          final driverPosition = _trackingController.driverPosition;
          final driverInfo = _trackingController.driverInfo;
          final etaMinutes = _trackingController.etaMinutes;
          final distanceKm = _trackingController.distanceKm;

          LatLng? driverLatLng;
          LatLng? destinationLatLng;

          if (driverPosition != null) {
            driverLatLng = LatLng(
              (driverPosition['latitude'] as num).toDouble(),
              (driverPosition['longitude'] as num).toDouble(),
            );
          }

          if (order.address != null) {
            destinationLatLng = LatLng(
              order.address!.latitude,
              order.address!.longitude,
            );
          }

          return Column(
            children: [
              // Map
              Expanded(
                flex: 2,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: driverLatLng ?? destinationLatLng ?? const LatLng(6.372477, 2.354006),
                    zoom: 14,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  markers: {
                    if (driverLatLng != null)
                      Marker(
                        markerId: const MarkerId('driver'),
                        position: driverLatLng,
                        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                        infoWindow: const InfoWindow(title: 'Livreur'),
                      ),
                    if (destinationLatLng != null)
                      Marker(
                        markerId: const MarkerId('destination'),
                        position: destinationLatLng,
                        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                        infoWindow: InfoWindow(
                          title: order.address?.label ?? 'Destination',
                          snippet: order.address?.fullAddress,
                        ),
                      ),
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),
              ),
              // Info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order status
                    Row(
                      children: [
                        Icon(
                          Icons.local_shipping,
                          color: AppColors.orderStatusOutForDelivery,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'En livraison',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        Text(
                          order.orderNumber,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Driver info
                    if (driverInfo != null) ...[
                      Row(
                        children: [
                          const Icon(Icons.person, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            driverInfo['name'] ?? 'Livreur',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    // ETA and distance
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        if (etaMinutes != null) ...[
                          Column(
                            children: [
                              Icon(Icons.access_time, color: AppColors.primary),
                              const SizedBox(height: 4),
                              Text(
                                '$etaMinutes min',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                'Temps estimé',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                        if (distanceKm != null) ...[
                          Column(
                            children: [
                              Icon(Icons.straighten, color: AppColors.primary),
                              const SizedBox(height: 4),
                              Text(
                                '${distanceKm.toStringAsFixed(1)} km',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                'Distance',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

