import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// RF-09 detalle del producto, RF-16 disponibilidad, RF-18 favoritos,
/// RF-19 calificaciones y comentarios, RF-20 agregar al carrito.
class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  Product get p => widget.product;

  Future<void> _share() async {
    await Clipboard.setData(
      ClipboardData(
        text: '${p.name} - ${formatPrice(p.price)} en Catálogo Express',
      ),
    );
    if (mounted) showMessage(context, 'Información del producto copiada');
  }

  Future<void> _rate() async {
    var rating = 5;
    final comment = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: const Text('Calificar producto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (i) => IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () => setDialog(() => rating = i + 1),
                    icon: Icon(
                      i < rating ? Icons.star : Icons.star_border,
                      color: const Color(0xFFF5A623),
                      size: 30,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: comment,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Cuéntanos tu experiencia',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Publicar'),
            ),
          ],
        ),
      ),
    );
    final text = comment.text;
    if (saved != true) return;
    if (text.trim().isEmpty) {
      if (mounted) showMessage(context, 'Escribe un comentario', error: true);
      return;
    }
    appState.addReview(p, rating, text);
    if (mounted) showMessage(context, '¡Gracias por tu calificación!');
  }

  void _addToCart() {
    final error = appState.addToCart(p, quantity: _quantity);
    showMessage(
      context,
      error ?? '$_quantity x ${p.name} agregado al carrito',
      error: error != null,
    );
    if (error == null) setState(() => _quantity = 1);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final fav = appState.isFavorite(p);
        final maxQty = p.stock < 1 ? 1 : p.stock;
        if (_quantity > maxQty) _quantity = maxQty;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Detalle del producto'),
            actions: [
              IconButton(
                tooltip: 'Compartir',
                icon: const Icon(Icons.share_outlined),
                onPressed: _share,
              ),
              IconButton(
                tooltip: fav ? 'Quitar de favoritos' : 'Agregar a favoritos',
                icon: Icon(fav ? Icons.star : Icons.star_border),
                onPressed: () => appState.toggleFavorite(p),
              ),
              const CartAction(),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                height: 260,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD6D6D6)),
                ),
                clipBehavior: Clip.antiAlias,
                child: ProductImage(product: p, iconSize: 110),
              ),
              const SizedBox(height: 16),
              Text(
                p.name,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  RatingStars(rating: p.rating),
                  const SizedBox(width: 6),
                  Text(
                    p.reviews.isEmpty
                        ? 'Sin calificaciones'
                        : '${p.rating.toStringAsFixed(1)} (${p.reviews.length})',
                    style: const TextStyle(color: AppColors.softGrey),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                formatPrice(p.price),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    avatar: Icon(
                      p.available ? Icons.check_circle : Icons.cancel,
                      color: p.available ? AppColors.available : AppColors.soldOut,
                      size: 18,
                    ),
                    label: Text(
                      p.available
                          ? 'Disponible (${p.stock} unidades)'
                          : 'Agotado',
                    ),
                  ),
                  Chip(label: Text(p.category)),
                  Chip(label: Text('Código: ${p.code}')),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Descripción',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(p.description),
              const SizedBox(height: 20),
              if (p.available)
                Row(
                  children: [
                    const Text('Cantidad', style: TextStyle(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    IconButton.outlined(
                      onPressed: _quantity > 1
                          ? () => setState(() => _quantity--)
                          : null,
                      icon: const Icon(Icons.remove),
                    ),
                    SizedBox(
                      width: 40,
                      child: Text(
                        '$_quantity',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    IconButton.outlined(
                      onPressed: _quantity < maxQty
                          ? () => setState(() => _quantity++)
                          : null,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: p.available ? _addToCart : null,
                icon: const Icon(Icons.shopping_cart_outlined),
                label: Text(p.available ? 'Agregar al carrito' : 'Producto agotado'),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Calificaciones y comentarios',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _rate,
                    icon: const Icon(Icons.rate_review_outlined),
                    label: const Text('Calificar'),
                  ),
                ],
              ),
              if (p.reviews.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Este producto aún no tiene comentarios. ¡Sé el primero!',
                    style: TextStyle(color: AppColors.softGrey),
                  ),
                ),
              for (final r in p.reviews)
                Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                r.author,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            RatingStars(rating: r.rating.toDouble(), size: 14),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(r.comment),
                        const SizedBox(height: 4),
                        Text(
                          formatDate(r.date),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.softGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
