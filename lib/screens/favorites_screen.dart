import 'package:flutter/material.dart';

import '../app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'product_detail_screen.dart';

/// RF-18 Lista de favoritos.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
        actions: const [CartAction()],
      ),
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, _) {
          final items = appState.favoriteProducts;
          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Aún no tienes favoritos.\nToca la estrella de un producto para guardarlo aquí.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.softGrey),
                ),
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.66,
            ),
            itemCount: items.length,
            itemBuilder: (context, i) => ProductCard(
              product: items[i],
              onOpen: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailScreen(product: items[i]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
