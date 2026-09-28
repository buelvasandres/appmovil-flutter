import 'package:flutter/material.dart';

import 'models.dart';

/// Orden de los resultados del catálogo.
enum SortOption { relevancia, menorPrecio, mayorPrecio }

/// Estado global de la aplicación.
///
/// En esta entrega los datos viven en memoria (no hay backend todavía):
/// al cerrar la app se reinician a los datos de ejemplo.
class AppState extends ChangeNotifier {
  AppState() {
    _seed();
  }

  final List<AppUser> _users = [];
  AppUser? currentUser;

  final List<String> categories = [];
  final List<Product> products = [];

  int _orderCounter = 1000;

  // ---------------------------------------------------------------------------
  // Gestión de usuarios (RF-01 a RF-06)
  // ---------------------------------------------------------------------------

  bool _emailExists(String email, {AppUser? except}) {
    final e = email.trim().toLowerCase();
    return _users.any((u) => u != except && u.email.toLowerCase() == e);
  }

  /// RF-01 y RF-04. Devuelve un mensaje de error o null si todo salió bien.
  String? register({
    required String name,
    required String email,
    required String password,
    String phone = '',
  }) {
    if (_emailExists(email)) {
      return 'Ya existe una cuenta registrada con ese correo.';
    }
    final user = AppUser(
      name: name.trim(),
      email: email.trim(),
      password: password,
      phone: phone.trim(),
    );
    _addWelcomeNotifications(user);
    _users.add(user);
    notifyListeners();
    return null;
  }

  /// RF-02. Devuelve un mensaje de error o null si el acceso es correcto.
  String? login(String email, String password) {
    final e = email.trim().toLowerCase();
    for (final u in _users) {
      if (u.email.toLowerCase() == e) {
        if (u.password == password) {
          currentUser = u;
          notifyListeners();
          return null;
        }
        return 'Contraseña incorrecta.';
      }
    }
    return 'No existe una cuenta con ese correo.';
  }

  /// RF-03.
  void logout() {
    currentUser = null;
    notifyListeners();
  }

  /// RF-06. Devuelve un mensaje de error o null.
  String? updateProfile({
    required String name,
    required String email,
    required String phone,
  }) {
    final user = currentUser;
    if (user == null) return 'No hay una sesión activa.';
    if (_emailExists(email, except: user)) {
      return 'Ese correo ya está en uso por otra cuenta.';
    }
    user
      ..name = name.trim()
      ..email = email.trim()
      ..phone = phone.trim();
    notifyListeners();
    return null;
  }

  // ---------------------------------------------------------------------------
  // Catálogo (RF-08, RF-13, RF-14, RF-16)
  // ---------------------------------------------------------------------------

  List<Product> searchProducts({
    String query = '',
    String? category,
    bool onlyAvailable = false,
    int? maxPrice,
    SortOption sort = SortOption.relevancia,
  }) {
    final q = query.trim().toLowerCase();
    final result = products.where((p) {
      if (!p.active) return false;
      if (category != null && p.category != category) return false;
      if (onlyAvailable && !p.available) return false;
      if (maxPrice != null && p.price > maxPrice) return false;
      if (q.isEmpty) return true;
      return p.name.toLowerCase().contains(q) ||
          p.code.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q);
    }).toList();

    if (sort == SortOption.menorPrecio) {
      result.sort((a, b) => a.price.compareTo(b.price));
    } else if (sort == SortOption.mayorPrecio) {
      result.sort((a, b) => b.price.compareTo(a.price));
    }
    return result;
  }

  // ---------------------------------------------------------------------------
  // Favoritos y calificaciones (RF-18, RF-19)
  // ---------------------------------------------------------------------------

  bool isFavorite(Product p) =>
      currentUser?.favorites.contains(p.code) ?? false;

  void toggleFavorite(Product p) {
    final user = currentUser;
    if (user == null) return;
    if (!user.favorites.remove(p.code)) {
      user.favorites.add(p.code);
    }
    notifyListeners();
  }

  List<Product> get favoriteProducts {
    final user = currentUser;
    if (user == null) return [];
    return products
        .where((p) => p.active && user.favorites.contains(p.code))
        .toList();
  }

  void addReview(Product p, int rating, String comment) {
    p.reviews.insert(
      0,
      Review(
        author: currentUser?.name ?? 'Anónimo',
        rating: rating,
        comment: comment.trim(),
        date: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Carrito (RF-20, RF-21)
  // ---------------------------------------------------------------------------

  List<CartItem> get cart => currentUser?.cart ?? [];

  int get cartCount {
    var n = 0;
    for (final i in cart) {
      n += i.quantity;
    }
    return n;
  }

  int get cartTotal {
    var sum = 0;
    for (final i in cart) {
      sum += i.subtotal;
    }
    return sum;
  }

  CartItem? _cartItemFor(Product p) {
    for (final i in cart) {
      if (i.product.code == p.code) return i;
    }
    return null;
  }

  /// Devuelve un mensaje de error o null si se agregó correctamente.
  String? addToCart(Product p, {int quantity = 1}) {
    final user = currentUser;
    if (user == null) return 'Debes iniciar sesión.';
    if (!p.available) return '${p.name} está agotado.';
    final existing = _cartItemFor(p);
    final newQty = (existing?.quantity ?? 0) + quantity;
    if (newQty > p.stock) {
      return 'Solo hay ${p.stock} unidades disponibles de ${p.name}.';
    }
    if (existing == null) {
      user.cart.add(CartItem(product: p, quantity: quantity));
    } else {
      existing.quantity = newQty;
    }
    notifyListeners();
    return null;
  }

  /// Devuelve un mensaje de error o null.
  String? setQuantity(CartItem item, int quantity) {
    if (quantity < 1) {
      removeFromCart(item);
      return null;
    }
    if (quantity > item.product.stock) {
      return 'Solo hay ${item.product.stock} unidades disponibles.';
    }
    item.quantity = quantity;
    notifyListeners();
    return null;
  }

  void removeFromCart(CartItem item) {
    currentUser?.cart.remove(item);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Compras y pedidos (RF-22 a RF-26)
  // ---------------------------------------------------------------------------

  /// RF-22. Registra el pedido, descuenta inventario y notifica (RF-24).
  Order placeOrder({
    required String address,
    required String city,
    required String paymentMethod,
  }) {
    final user = currentUser!;
    _orderCounter++;
    final order = Order(
      id: 'PED-$_orderCounter',
      date: DateTime.now(),
      items: user.cart
          .map((i) => CartItem(product: i.product, quantity: i.quantity))
          .toList(),
      address: address.trim(),
      city: city.trim(),
      paymentMethod: paymentMethod,
    );
    for (final i in order.items) {
      i.product.stock -= i.quantity;
      if (i.product.stock < 0) i.product.stock = 0;
    }
    user.orders.insert(0, order);
    user.cart.clear();
    _notify(
      user,
      'Compra confirmada',
      'Tu pedido ${order.id} fue confirmado. Te avisaremos cuando cambie de estado.',
      NotificationType.compra,
    );
    notifyListeners();
    return order;
  }

  /// RF-25. Avanza el estado del pedido (simulado, en esta entrega no hay
  /// un backend que lo haga).
  void advanceOrder(Order order) {
    final user = currentUser;
    if (user == null || !order.isOpen) return;
    switch (order.status) {
      case OrderStatus.confirmado:
        order.status = OrderStatus.enPreparacion;
        break;
      case OrderStatus.enPreparacion:
        order.status = OrderStatus.enviado;
        break;
      case OrderStatus.enviado:
        order.status = OrderStatus.entregado;
        break;
      case OrderStatus.entregado:
      case OrderStatus.cancelado:
        return;
    }
    _notify(
      user,
      'Tu pedido cambió de estado',
      'El pedido ${order.id} ahora está: ${order.status.label}.',
      NotificationType.envio,
    );
    notifyListeners();
  }

  /// RF-26. Cancela el pedido, devuelve el inventario y notifica.
  void cancelOrder(Order order) {
    final user = currentUser;
    if (user == null || !order.isOpen) return;
    order.status = OrderStatus.cancelado;
    for (final i in order.items) {
      i.product.stock += i.quantity;
    }
    _notify(
      user,
      'Pedido cancelado',
      'El pedido ${order.id} fue cancelado.',
      NotificationType.compra,
    );
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Notificaciones (RF-27 a RF-29)
  // ---------------------------------------------------------------------------

  List<AppNotification> get notifications => currentUser?.notifications ?? [];

  int get unreadCount => notifications.where((n) => !n.read).length;

  void markRead(AppNotification n) {
    if (n.read) return;
    n.read = true;
    notifyListeners();
  }

  void markAllRead() {
    for (final n in notifications) {
      n.read = true;
    }
    notifyListeners();
  }

  void _notify(
    AppUser user,
    String title,
    String message,
    NotificationType type,
  ) {
    user.notifications.insert(
      0,
      AppNotification(
        title: title,
        message: message,
        type: type,
        date: DateTime.now(),
      ),
    );
  }

  void _addWelcomeNotifications(AppUser user) {
    final now = DateTime.now();
    user.notifications.addAll([
      AppNotification(
        title: 'Promociones',
        message: 'Aprovecha las ofertas por tiempo limitado. 🎉',
        type: NotificationType.promocion,
        date: now,
      ),
      AppNotification(
        title: 'Envíos',
        message: 'Tu envío llegó con éxito, que lo disfrutes. 😊',
        type: NotificationType.envio,
        date: now.subtract(const Duration(hours: 3)),
      ),
      AppNotification(
        title: 'Generales',
        message: 'Nuevas funciones disponibles en la app.',
        type: NotificationType.general,
        date: now.subtract(const Duration(days: 1)),
      ),
      AppNotification(
        title: 'Novedades',
        message: 'Pronto se acercan las temporadas de descuentos.',
        type: NotificationType.novedad,
        date: now.subtract(const Duration(days: 2)),
        read: true,
      ),
    ]);
  }

  // ---------------------------------------------------------------------------
  // Administración del catálogo (RF-07, RF-10 a RF-12, RF-15, RF-30 a RF-42)
  // ---------------------------------------------------------------------------

  bool codeExists(String code) {
    final c = code.trim().toLowerCase();
    return products.any((p) => p.code.toLowerCase() == c);
  }

  /// RF-07 / RF-30 con validación de duplicados (RF-12 / RF-40).
  String? addProduct(Product p) {
    if (codeExists(p.code)) {
      return 'Ya existe un producto con el código ${p.code}.';
    }
    products.add(p);
    // RF-29: aviso de novedades a todos los clientes.
    for (final u in _users) {
      if (!u.isAdmin) {
        _notify(
          u,
          'Nuevo producto',
          '${p.name} ya está disponible en el catálogo.',
          NotificationType.novedad,
        );
      }
    }
    notifyListeners();
    return null;
  }

  /// RF-10 / RF-32 / RF-35 / RF-36: los cambios se reflejan de inmediato
  /// en el catálogo (RF-17 / RF-42).
  void productUpdated() => notifyListeners();

  /// RF-11 / RF-33.
  void deleteProduct(Product p) {
    products.remove(p);
    for (final u in _users) {
      u.cart.removeWhere((i) => i.product.code == p.code);
      u.favorites.remove(p.code);
    }
    notifyListeners();
  }

  /// RF-41.
  void setActive(Product p, bool active) {
    p.active = active;
    notifyListeners();
  }

  /// RF-15 / RF-34.
  String? addCategory(String name) {
    final n = name.trim();
    if (n.isEmpty) return 'Escribe un nombre.';
    if (categories.any((c) => c.toLowerCase() == n.toLowerCase())) {
      return 'La categoría ya existe.';
    }
    categories.add(n);
    notifyListeners();
    return null;
  }

  String? renameCategory(String oldName, String newName) {
    final n = newName.trim();
    if (n.isEmpty) return 'Escribe un nombre.';
    if (n.toLowerCase() != oldName.toLowerCase() &&
        categories.any((c) => c.toLowerCase() == n.toLowerCase())) {
      return 'La categoría ya existe.';
    }
    final index = categories.indexOf(oldName);
    if (index < 0) return 'La categoría no existe.';
    categories[index] = n;
    for (final p in products) {
      if (p.category == oldName) p.category = n;
    }
    notifyListeners();
    return null;
  }

  String? deleteCategory(String name) {
    final inUse = products.where((p) => p.category == name).length;
    if (inUse > 0) {
      return 'No se puede eliminar: $inUse producto(s) usan esta categoría.';
    }
    categories.remove(name);
    notifyListeners();
    return null;
  }

  // ---------------------------------------------------------------------------
  // Datos de ejemplo
  // ---------------------------------------------------------------------------

  void _seed() {
    categories.addAll(['Tecnología', 'Ropa', 'Calzado', 'Accesorios', 'Hogar']);

    final now = DateTime.now();
    products.addAll([
      Product(
        code: 'P001',
        name: 'Audífonos',
        description:
            'Audífonos inalámbricos con cancelación de ruido, batería de hasta 30 horas y conexión Bluetooth 5.3.',
        price: 85000,
        category: 'Tecnología',
        stock: 12,
        imageAsset: 'assets/images/audifonos.png',
        reviews: [
          Review(
            author: 'Laura M.',
            rating: 5,
            comment: 'Suenan muy bien y la batería dura bastante.',
            date: now.subtract(const Duration(days: 4)),
          ),
          Review(
            author: 'Carlos R.',
            rating: 4,
            comment: 'Buena calidad por el precio.',
            date: now.subtract(const Duration(days: 9)),
          ),
        ],
      ),
      Product(
        code: 'P002',
        name: 'Camiseta Negra',
        description:
            'Camiseta básica de algodón 100 %, corte clásico. Disponible en tallas S a XL.',
        price: 105000,
        category: 'Ropa',
        stock: 20,
        imageAsset: 'assets/images/camiseta.png',
      ),
      Product(
        code: 'P003',
        name: 'Zapatillas Blancas',
        description:
            'Zapatillas urbanas de cuero sintético, suela antideslizante y plantilla acolchada.',
        price: 185000,
        category: 'Calzado',
        stock: 8,
        imageAsset: 'assets/images/zapatillas.png',
        reviews: [
          Review(
            author: 'Andrea P.',
            rating: 5,
            comment: 'Muy cómodas, las uso todos los días.',
            date: now.subtract(const Duration(days: 2)),
          ),
        ],
      ),
      Product(
        code: 'P004',
        name: 'Mouse para computador',
        description:
            'Mouse gamer inalámbrico con iluminación RGB, 6 botones y sensor de 7200 DPI.',
        price: 45000,
        category: 'Tecnología',
        stock: 15,
        imageAsset: 'assets/images/mouse.png',
      ),
      Product(
        code: 'P005',
        name: 'Teclado mecánico',
        description:
            'Teclado mecánico compacto con switches rojos e iluminación RGB.',
        price: 159000,
        category: 'Tecnología',
        stock: 0,
        icon: Icons.keyboard_alt_outlined,
      ),
      Product(
        code: 'P006',
        name: 'Reloj inteligente',
        description:
            'Smartwatch con monitor de ritmo cardiaco, pasos y notificaciones del celular.',
        price: 249000,
        category: 'Tecnología',
        stock: 5,
        icon: Icons.watch_outlined,
      ),
      Product(
        code: 'P007',
        name: 'Chaqueta impermeable',
        description: 'Chaqueta liviana impermeable con capota y bolsillos con cierre.',
        price: 139000,
        category: 'Ropa',
        stock: 7,
        icon: Icons.checkroom_outlined,
      ),
      Product(
        code: 'P008',
        name: 'Morral urbano',
        description:
            'Morral con compartimento acolchado para portátil de hasta 15,6 pulgadas.',
        price: 120000,
        category: 'Accesorios',
        stock: 0,
        icon: Icons.backpack_outlined,
      ),
      Product(
        code: 'P009',
        name: 'Lámpara LED de escritorio',
        description: 'Lámpara LED con tres tonos de luz y brazo flexible.',
        price: 68000,
        category: 'Hogar',
        stock: 10,
        icon: Icons.light_outlined,
      ),
      Product(
        code: 'P010',
        name: 'Botella térmica',
        description:
            'Botella de acero inoxidable de 750 ml, mantiene la temperatura por 12 horas.',
        price: 42000,
        category: 'Hogar',
        stock: 30,
        icon: Icons.local_drink_outlined,
      ),
    ]);

    final demo = AppUser(
      name: 'Usuario Demo',
      email: 'demo@catalogo.com',
      password: '123456',
      phone: '3001234567',
    );
    _addWelcomeNotifications(demo);
    demo.favorites.add('P003');

    final admin = AppUser(
      name: 'Administrador',
      email: 'admin@catalogo.com',
      password: 'admin123',
      role: UserRole.admin,
    );

    _users.addAll([demo, admin]);
  }
}

/// Instancia única del estado de la aplicación.
final appState = AppState();
