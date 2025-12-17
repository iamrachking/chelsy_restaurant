import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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
  late final TrackingController _trackingController;
  late final OrderController _orderController;

  @override
  void initState() {
    super.initState();

    _trackingController = Get.find<TrackingController>();
    _orderController = Get.find<OrderController>();

    Future.microtask(() {
      _orderController.getOrder(widget.orderId);
      _trackingController.startTracking(widget.orderId);
    });
  }

  @override
  void dispose() {
    _trackingController.stopTracking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Suivi de la commande')),
      body: Obx(() {
        final order = _orderController.selectedOrder.value;

        //  Chargement
        if (order == null) {
          return const LoadingWidget();
        }

        //  Pas encore en livraison
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

        //  Données de tracking
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

        //  Pas encore de position
        if (driverLatLng == null && destinationLatLng == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _trackingController.isLoading.value
                    ? const CircularProgressIndicator()
                    : const Icon(Icons.location_off, size: 80),
                const SizedBox(height: 16),
                Text(
                  _trackingController.errorMessage.value.isEmpty
                      ? 'En attente de la position du livreur...'
                      : 'Erreur : ${_trackingController.errorMessage.value}',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final center =
            driverLatLng ??
            destinationLatLng ??
            const LatLng(6.372477, 2.354006);

        // Carte + Infos
        return Column(
          children: [
            ///  CARTE OPENSTREETMAP
            Expanded(
              flex: 2,
              child: FlutterMap(
                options: MapOptions(initialCenter: center, initialZoom: 15),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.chelsy_restaurant',
                  ),
                  MarkerLayer(
                    markers: [
                      if (driverLatLng != null)
                        Marker(
                          point: driverLatLng,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.delivery_dining,
                            color: Colors.blue,
                            size: 36,
                          ),
                        ),
                      if (destinationLatLng != null)
                        Marker(
                          point: destinationLatLng,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 36,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            ///  INFORMATIONS
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
                  Row(
                    children: [
                      Icon(Icons.local_shipping, color: AppColors.primary),
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
                    const SizedBox(height: 12),
                  ],

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Icon(Icons.access_time, color: AppColors.primary),
                          const SizedBox(height: 4),
                          Text(
                            etaMinutes != null ? '$etaMinutes min' : '--',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const Text('Temps estimé'),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(Icons.straighten, color: AppColors.primary),
                          const SizedBox(height: 4),
                          Text(
                            distanceKm != null
                                ? '${distanceKm.toStringAsFixed(1)} km'
                                : '--',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const Text('Distance'),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _trackingController.refreshTracking(widget.orderId);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Rafraîchir'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
