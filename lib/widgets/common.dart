import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import '../screens/admin_products_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/login_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/orders_screen.dart';
import '../screens/profile_screen.dart';
import '../theme.dart';

// -----------------------------------------------------------------------------
// Utilidades
// -----------------------------------------------------------------------------

/// Formato de precio colombiano: 185000 -> "$ 185.000".
String formatPrice(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer(value < 0 ? '\$ -' : '\$ ');
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

String _two(int n) => n.toString().padLeft(2, '0');

String formatDate(DateTime d) =>
    '${_two(d.day)}/${_two(d.month)}/${d.year} ${_two(d.hour)}:${_two(d.minute)}';

final _emailRegExp = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

String? validateEmail(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'Ingresa tu correo electrónico';
  if (!_emailRegExp.hasMatch(v)) return 'Correo electrónico no válido';
  return null;
}

String? validateRequired(String? value, String field) {
  if (value == null || value.trim().isEmpty) return '$field es obligatorio';
  return null;
}

void showMessage(BuildContext context, String text, {bool error = false}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(text),
      backgroundColor: error ? AppColors.soldOut : null,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ),
  );
}

Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Aceptar',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

void logoutAndGoToLogin(BuildContext context) {
  appState.logout();
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginScreen()),
    (route) => false,
  );
}

// -----------------------------------------------------------------------------
// Imagen de producto
// -----------------------------------------------------------------------------

class ProductImage extends StatelessWidget {
  const ProductImage({super.key, required this.product, this.iconSize = 56});

  final Product product;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final asset = product.imageAsset;
    if (asset != null) {
      return Image.asset(asset, fit: BoxFit.contain);
    }
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF1E6FD), Color(0xFFDDBDF7)],
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        product.icon ?? Icons.inventory_2_outlined,
        size: iconSize,
        color: AppColors.primaryDark,
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Estrellas de calificación
// -----------------------------------------------------------------------------

class RatingStars extends StatelessWidget {
  const RatingStars({super.key, required this.rating, this.size = 16});

  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final IconData icon;
        if (rating >= i + 1) {
          icon = Icons.star;
        } else if (rating >= i + 0.5) {
          icon = Icons.star_half;
        } else {
          icon = Icons.star_border;
        }
        return Icon(icon, size: size, color: const Color(0xFFF5A623));
      }),
    );
  }
}

// -----------------------------------------------------------------------------
// Banner superior del mockup ("Todo lo que buscas, Más rápido!!")
// -----------------------------------------------------------------------------

class PromoBanner extends StatelessWidget {
  const PromoBanner({
    super.key,
    required this.buttonLabel,
    required this.buttonIcon,
    required this.onPressed,
  });

  final String buttonLabel;
  final IconData buttonIcon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      height: 132,
      decoration: BoxDecoration(
        color: AppColors.bannerBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 8,
            top: 30,
            bottom: 6,
            width: 120,
            child: Image.asset('assets/images/bag.png', fit: BoxFit.contain),
          ),
          Positioned(
            left: 4,
            top: 4,
            child: Material(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: Colors.black26),
              ),
              child: IconButton(
                icon: const Icon(Icons.menu, color: Colors.black87),
                tooltip: 'Menú',
                visualDensity: VisualDensity.compact,
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          ),
          Positioned(
            right: 12,
            top: 10,
            bottom: 10,
            left: 130,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Todo lo que buscas,',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                      color: Colors.black,
                    ),
                  ),
                ),
                const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Más rápido!!',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 36,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onPressed: onPressed,
                    icon: Icon(buttonIcon, size: 18),
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(buttonLabel),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Ícono con contador (carrito, notificaciones)
// -----------------------------------------------------------------------------

class CountBadgeIcon extends StatelessWidget {
  const CountBadgeIcon({super.key, required this.icon, required this.count});

  final IconData icon;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: count > 0,
      label: Text('$count'),
      child: Icon(icon),
    );
  }
}

/// Botón de carrito para las AppBar.
class CartAction extends StatelessWidget {
  const CartAction({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) => IconButton(
        tooltip: 'Carrito',
        icon: CountBadgeIcon(
          icon: Icons.shopping_cart_outlined,
          count: appState.cartCount,
        ),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CartScreen()),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Menú lateral (mockup "Bienvenido Usuario")
// -----------------------------------------------------------------------------

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _open(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: AnimatedBuilder(
        animation: appState,
        builder: (context, _) {
          final user = appState.currentUser;
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                height: 150,
                color: AppColors.primary,
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.fromLTRB(16, 32, 16, 12),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset('assets/images/logo.png', height: 90),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: CircleAvatar(
                  radius: 38,
                  backgroundColor: Color(0xFF757575),
                  child: Icon(Icons.person, size: 52, color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  'Bienvenido ${user?.name ?? 'Usuario'}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              if (user != null && user.isAdmin)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      'Administrador',
                      style: TextStyle(color: AppColors.primary, fontSize: 12),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              _DrawerTile(
                icon: Icons.person_outline,
                label: 'Mi Perfil',
                onTap: () => _open(context, const ProfileScreen()),
              ),
              _DrawerTile(
                icon: Icons.shopping_cart_outlined,
                label: 'Carrito de Compras',
                count: appState.cartCount,
                onTap: () => _open(context, const CartScreen()),
              ),
              _DrawerTile(
                icon: Icons.star_border,
                label: 'Favoritos',
                onTap: () => _open(context, const FavoritesScreen()),
              ),
              _DrawerTile(
                icon: Icons.inventory_2_outlined,
                label: 'Estado de Productos',
                onTap: () => _open(context, const OrdersScreen()),
              ),
              _DrawerTile(
                icon: Icons.notifications_none,
                label: 'Notificaciones',
                count: appState.unreadCount,
                onTap: () => _open(context, const NotificationsScreen()),
              ),
              if (user != null && user.isAdmin)
                _DrawerTile(
                  icon: Icons.admin_panel_settings_outlined,
                  label: 'Administrar catálogo',
                  onTap: () => _open(context, const AdminProductsScreen()),
                ),
              _DrawerTile(
                icon: Icons.power_settings_new,
                label: 'Cerrar Sesión',
                onTap: () async {
                  final ok = await confirmDialog(
                    context,
                    title: 'Cerrar sesión',
                    message: '¿Seguro que quieres cerrar sesión?',
                    confirmLabel: 'Cerrar sesión',
                  );
                  if (ok && context.mounted) logoutAndGoToLogin(context);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.count = 0,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: Color(0xFFBDBDBD)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                CountBadgeIcon(icon: icon, count: count),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Color(0xFF6E6E6E),
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Tarjeta de producto del catálogo (mockup "Audífonos / Agregar al carrito")
// -----------------------------------------------------------------------------

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, required this.onOpen});

  final Product product;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final fav = appState.isFavorite(product);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFBDBDBD)),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onOpen,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFD6D6D6)),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: ProductImage(product: product),
                    ),
                  ),
                  if (!product.available)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.soldOut,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Agotado',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: onOpen,
            child: Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: Text(
                  formatPrice(product.price),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              InkWell(
                customBorder: const CircleBorder(),
                onTap: () => appState.toggleFavorite(product),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    fav ? Icons.star : Icons.star_border,
                    color: fav ? const Color(0xFF6E6E6E) : Colors.black54,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 34,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              onPressed: product.available
                  ? () {
                      final error = appState.addToCart(product);
                      showMessage(
                        context,
                        error ?? '${product.name} agregado al carrito',
                        error: error != null,
                      );
                    }
                  : null,
              icon: const Icon(Icons.shopping_cart_outlined, size: 18),
              label: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  product.available ? 'Agregar al carrito' : 'Agotado',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
