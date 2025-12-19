import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../models/order_model.dart';
import '../models/batch_model.dart';
import '../utils/constants.dart';

class RoutingService {
  // Calculate distance between two points (Haversine formula)
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Radius in kilometers
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  static double _toRadians(double degrees) {
    return degrees * (pi / 180);
  }

  // Group orders into batches using nearest neighbor algorithm
  // Note: This method is not used anymore as we group by quartier in BatchingService
  // Kept for potential future use with GPS-based grouping
  static List<List<OrderModel>> groupOrdersIntoBatches(
    List<OrderModel> orders,
  ) {
    if (orders.isEmpty) return [];

    // Filter orders with valid locations
    final ordersWithLocation = orders.where((order) => order.deliveryLocation != null).toList();
    if (ordersWithLocation.isEmpty) return [];

    final List<List<OrderModel>> batches = [];
    final List<OrderModel> remainingOrders = List.from(ordersWithLocation);

    while (remainingOrders.isNotEmpty) {
      final List<OrderModel> currentBatch = [];
      OrderModel? currentOrder = remainingOrders.removeAt(0);
      if (currentOrder.deliveryLocation == null) continue;
      currentBatch.add(currentOrder);

      // Find nearby orders within radius
      final List<OrderModel> nearbyOrders = remainingOrders.where((order) {
        if (order.deliveryLocation == null || currentOrder.deliveryLocation == null) return false;
        final distance = calculateDistance(
          currentOrder.deliveryLocation!.latitude,
          currentOrder.deliveryLocation!.longitude,
          order.deliveryLocation!.latitude,
          order.deliveryLocation!.longitude,
        );
        return distance <= AppConstants.maxBatchRadiusKm;
      }).toList();

      // Sort by distance and add to batch
      nearbyOrders.sort((a, b) {
        if (a.deliveryLocation == null || b.deliveryLocation == null || 
            currentOrder.deliveryLocation == null) return 0;
        final distA = calculateDistance(
          currentOrder.deliveryLocation!.latitude,
          currentOrder.deliveryLocation!.longitude,
          a.deliveryLocation!.latitude,
          a.deliveryLocation!.longitude,
        );
        final distB = calculateDistance(
          currentOrder.deliveryLocation!.latitude,
          currentOrder.deliveryLocation!.longitude,
          b.deliveryLocation!.latitude,
          b.deliveryLocation!.longitude,
        );
        return distA.compareTo(distB);
      });

      // Add orders to batch until max capacity
      int added = 0;
      for (final order in nearbyOrders) {
        if (added >= AppConstants.maxOrdersPerBatch - 1) break;
        currentBatch.add(order);
        remainingOrders.remove(order);
        added++;
      }

      batches.add(currentBatch);
    }

    return batches;
  }

  // Optimize route using Nearest Neighbor algorithm (Plus court chemin)
  static List<GeoPoint> optimizeRoute(List<GeoPoint> locations) {
    if (locations.length <= 2) return locations;

    final List<GeoPoint> optimizedRoute = [];
    final List<GeoPoint> remaining = List.from(locations);
    
    // Start from first location
    GeoPoint current = remaining.removeAt(0);
    optimizedRoute.add(current);

    // Find nearest neighbor for each step
    while (remaining.isNotEmpty) {
      double minDistance = double.infinity;
      int nearestIndex = 0;

      for (int i = 0; i < remaining.length; i++) {
        final distance = calculateDistance(
          current.latitude,
          current.longitude,
          remaining[i].latitude,
          remaining[i].longitude,
        );
        if (distance < minDistance) {
          minDistance = distance;
          nearestIndex = i;
        }
      }

      current = remaining.removeAt(nearestIndex);
      optimizedRoute.add(current);
    }

    return optimizedRoute;
  }

  // Calculate total distance for a route
  static double calculateRouteDistance(List<GeoPoint> route) {
    if (route.length < 2) return 0.0;

    double totalDistance = 0.0;
    for (int i = 0; i < route.length - 1; i++) {
      totalDistance += calculateDistance(
        route[i].latitude,
        route[i].longitude,
        route[i + 1].latitude,
        route[i + 1].longitude,
      );
    }
    return totalDistance;
  }

  // Estimate delivery price based on distance
  static double estimateDeliveryPrice(double distanceKm) {
    return AppConstants.baseDeliveryPrice +
        (distanceKm * AppConstants.pricePerKm);
  }

  // Estimate duration based on distance (assuming average speed in Dakar)
  static double estimateDuration(double distanceKm) {
    // Average speed in Dakar: ~30 km/h (considering traffic)
    const double averageSpeedKmh = 30.0;
    return (distanceKm / averageSpeedKmh) * 60; // Duration in minutes
  }
}

