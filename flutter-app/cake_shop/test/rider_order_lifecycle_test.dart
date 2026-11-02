import 'package:flutter_test/flutter_test.dart';
import 'package:cake_shop/models/user.dart';
import 'package:cake_shop/models/order.dart';
import 'package:cake_shop/utils/order_status.dart';

void main() {
  group('Unified Multi-Role & Delivery Lifecycle Tests', () {
    test('User model accurately parses roles (CUSTOMER, ADMIN, RIDER)', () {
      final customer = User(id: '1', name: 'Saad', email: 'saad@test.com', phone: '9876543210', role: 'CUSTOMER');
      final admin = User(id: '2', name: 'Admin', email: 'admin@cakeshop.com', phone: '9876543211', role: 'ADMIN');
      final rider = User(id: '3', name: 'Rahul', email: 'rider@cakeshop.com', phone: '9876543212', role: 'RIDER');

      expect(customer.isCustomer, isTrue);
      expect(customer.isAdmin, isFalse);
      expect(customer.isRider, isFalse);

      expect(admin.isAdmin, isTrue);
      expect(admin.isCustomer, isFalse);
      expect(admin.isRider, isFalse);

      expect(rider.isRider, isTrue);
      expect(rider.isCustomer, isFalse);
      expect(rider.isAdmin, isFalse);
    });

    test('Order model correctly serializes and deserializes OTP and Rider info', () {
      final json = {
        '_id': 'order_123',
        'orderNumber': 'ORD-98214',
        'userId': 'usr_1',
        'customerName': 'Saad',
        'customerEmail': 'saad@test.com',
        'customerPhone': '+91 99999 11111',
        'status': 'OUT_FOR_DELIVERY',
        'deliveryAddress': 'Alkapuri, Vadodara',
        'deliveryDate': 1762000000000,
        'paymentMethod': 'COD',
        'paymentStatus': 'PENDING',
        'subtotalAmount': 850.0,
        'discountAmount': 50.0,
        'totalAmount': 800.0,
        'deliveryPartnerId': 'rider_3',
        'deliveryPartnerName': 'Rahul Sharma (Express Rider)',
        'deliveryPartnerPhone': '+91 98765 43210',
        'deliveryOtp': '4821',
        'createdAt': 1761990000000,
        'updatedAt': 1761995000000,
      };

      final order = Order.fromJson(json);
      expect(order.status, 'OUT_FOR_DELIVERY');
      expect(order.deliveryPartnerId, 'rider_3');
      expect(order.deliveryPartnerName, 'Rahul Sharma (Express Rider)');
      expect(order.deliveryOtp, '4821');
    });

    test('OrderStatusFlow supports 6-stage lifecycle', () {
      expect(OrderStatusFlow.pipelineSteps, contains('OUT_FOR_DELIVERY'));
      expect(OrderStatusFlow.canTransition('READY', 'OUT_FOR_DELIVERY'), isTrue);
      expect(OrderStatusFlow.canTransition('OUT_FOR_DELIVERY', 'DELIVERED'), isTrue);
      expect(OrderStatusFlow.label('OUT_FOR_DELIVERY'), 'Out for Delivery');
    });
  });
}
