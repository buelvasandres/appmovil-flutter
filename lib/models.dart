import 'package:flutter/material.dart';

/// Rol del usuario dentro de la aplicación.
enum UserRole { cliente, admin }

/// Usuario registrado. Cada usuario tiene su propio carrito, favoritos,
/// pedidos y notificaciones.
class AppUser {
  AppUser({
    required this.name,
    required this.email,
    required this.password,
    this.phone = '',
    this.role = UserRole.cliente,
  });

  String name;
  String email;
  String password;
  String phone;
  UserRole role;

  final List<CartItem> cart = [];
  final Set<String> favorites = {};
  final List<Order> orders = [];
  final List<AppNotification> notifications = [];

  bool get isAdmin => role == UserRole.admin;
}

/// Calificación y comentario de un producto (RF-19).
class Review {
  Review({
    required this.author,
    required this.rating,
    required this.comment,
    required this.date,
  });

  final String author;
  final int rating;
  final String comment;
  final DateTime date;
}

/// Producto del catálogo.
class Product {
  Product({
    required this.code,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.stock,
    this.imageAsset,
    this.icon,
    this.active = true,
    List<Review>? reviews,
  }) : reviews = reviews ?? [];

  final String code;
  String name;
  String description;
  int price;
  String category;
  int stock;
  String? imageAsset;
  IconData? icon;
  bool active;
  final List<Review> reviews;

  /// RF-16 / RF-37: disponible o agotado según la cantidad en inventario.
  bool get available => stock > 0;

  double get rating {
    if (reviews.isEmpty) return 0;
    var sum = 0;
    for (final r in reviews) {
      sum += r.rating;
    }
    return sum / reviews.length;
  }
}

/// Ítem del carrito de compras.
class CartItem {
  CartItem({required this.product, this.quantity = 1});

  final Product product;
  int quantity;

  int get subtotal => product.price * quantity;
}

/// Estados posibles de un pedido.
enum OrderStatus { confirmado, enPreparacion, enviado, entregado, cancelado }

extension OrderStatusInfo on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.confirmado:
        return 'Confirmado';
      case OrderStatus.enPreparacion:
        return 'En preparación';
      case OrderStatus.enviado:
        return 'Enviado';
      case OrderStatus.entregado:
        return 'Entregado';
      case OrderStatus.cancelado:
        return 'Cancelado';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.confirmado:
        return const Color(0xFF7B3FE4);
      case OrderStatus.enPreparacion:
        return const Color(0xFFE08A00);
      case OrderStatus.enviado:
        return const Color(0xFF1E88E5);
      case OrderStatus.entregado:
        return const Color(0xFF2E7D32);
      case OrderStatus.cancelado:
        return const Color(0xFFC62828);
    }
  }
}

/// Pedido realizado por el usuario (RF-22, RF-23).
class Order {
  Order({
    required this.id,
    required this.date,
    required this.items,
    required this.address,
    required this.city,
    required this.paymentMethod,
    this.status = OrderStatus.confirmado,
  });

  final String id;
  final DateTime date;
  final List<CartItem> items;
  final String address;
  final String city;
  final String paymentMethod;
  OrderStatus status;

  int get total {
    var sum = 0;
    for (final i in items) {
      sum += i.subtotal;
    }
    return sum;
  }

  int get units {
    var sum = 0;
    for (final i in items) {
      sum += i.quantity;
    }
    return sum;
  }

  bool get isOpen =>
      status != OrderStatus.entregado && status != OrderStatus.cancelado;
}

/// Tipos de notificación (RF-24 a RF-29).
enum NotificationType { promocion, envio, general, novedad, compra }

extension NotificationTypeInfo on NotificationType {
  IconData get icon {
    switch (this) {
      case NotificationType.promocion:
        return Icons.card_giftcard_outlined;
      case NotificationType.envio:
        return Icons.local_shipping_outlined;
      case NotificationType.general:
        return Icons.notification_important_outlined;
      case NotificationType.novedad:
        return Icons.stars_outlined;
      case NotificationType.compra:
        return Icons.shopping_bag_outlined;
    }
  }
}

class AppNotification {
  AppNotification({
    required this.title,
    required this.message,
    required this.type,
    required this.date,
    this.read = false,
  });

  final String title;
  final String message;
  final NotificationType type;
  final DateTime date;
  bool read;
}
