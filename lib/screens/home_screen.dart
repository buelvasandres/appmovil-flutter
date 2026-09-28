import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'cart_screen.dart';
import 'product_detail_screen.dart';

/// Catálogo de productos: RF-08 consultar, RF-13 buscar, RF-14 filtrar,
/// RF-16 disponibilidad, RF-18 favoritos, RF-20 agregar al carrito.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _search = TextEditingController();
  String _query = '';
  String? _category;
  bool _onlyAvailable = false;
  int? _maxPrice;
  SortOption _sort = SortOption.relevancia;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool get _hasFilters =>
      _onlyAvailable || _maxPrice != null || _sort != SortOption.relevancia;

  void _openProduct(Product p) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p)),
    );
  }

  Future<void> _openFilters() async {
    var onlyAvailable = _onlyAvailable;
    var maxPrice = _maxPrice;
    var sort = _sort;

    final apply = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filtrar productos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Solo productos disponibles'),
                value: onlyAvailable,
                onChanged: (v) => setSheet(() => onlyAvailable = v),
              ),
              const Text('Precio', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Todos'),
                    selected: maxPrice == null,
                    onSelected: (_) => setSheet(() => maxPrice = null),
                  ),
                  ChoiceChip(
                    label: const Text('Hasta \$ 50.000'),
                    selected: maxPrice == 50000,
                    onSelected: (_) => setSheet(() => maxPrice = 50000),
                  ),
                  ChoiceChip(
                    label: const Text('Hasta \$ 150.000'),
                    selected: maxPrice == 150000,
                    onSelected: (_) => setSheet(() => maxPrice = 150000),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text('Ordenar por', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Relevancia'),
                    selected: sort == SortOption.relevancia,
                    onSelected: (_) =>
                        setSheet(() => sort = SortOption.relevancia),
                  ),
                  ChoiceChip(
                    label: const Text('Menor precio'),
                    selected: sort == SortOption.menorPrecio,
                    onSelected: (_) =>
                        setSheet(() => sort = SortOption.menorPrecio),
                  ),
                  ChoiceChip(
                    label: const Text('Mayor precio'),
                    selected: sort == SortOption.mayorPrecio,
                    onSelected: (_) =>
                        setSheet(() => sort = SortOption.mayorPrecio),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setSheet(() {
                          onlyAvailable = false;
                          maxPrice = null;
                          sort = SortOption.relevancia;
                        });
                      },
                      child: const Text('Limpiar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Aplicar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (apply == true) {
      setState(() {
        _onlyAvailable = onlyAvailable;
        _maxPrice = maxPrice;
        _sort = sort;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      floatingActionButton: AnimatedBuilder(
        animation: appState,
        builder: (context, _) => FloatingActionButton(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          tooltip: 'Carrito',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CartScreen()),
          ),
          child: CountBadgeIcon(
            icon: Icons.shopping_cart_outlined,
            count: appState.cartCount,
          ),
        ),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: appState,
          builder: (context, _) {
            final items = appState.searchProducts(
              query: _query,
              category: _category,
              onlyAvailable: _onlyAvailable,
              maxPrice: _maxPrice,
              sort: _sort,
            );
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: PromoBanner(
                    buttonLabel: 'Carrito De Compras',
                    buttonIcon: Icons.shopping_cart_outlined,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _search,
                            textInputAction: TextInputAction.search,
                            onChanged: (v) => setState(() => _query = v),
                            decoration: InputDecoration(
                              hintText: 'Buscar productos en el catálogo...',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: _query.isEmpty
                                  ? null
                                  : IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () {
                                        _search.clear();
                                        setState(() => _query = '');
                                      },
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.outlined(
                          tooltip: 'Filtros',
                          onPressed: _openFilters,
                          icon: Badge(
                            isLabelVisible: _hasFilters,
                            smallSize: 8,
                            child: const Icon(Icons.tune),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 48,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      children: [
                        _CategoryChip(
                          label: 'Todas',
                          selected: _category == null,
                          onTap: () => setState(() => _category = null),
                        ),
                        for (final c in appState.categories)
                          _CategoryChip(
                            label: c,
                            selected: _category == c,
                            onTap: () => setState(() => _category = c),
                          ),
                      ],
                    ),
                  ),
                ),
                if (items.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'No se encontraron productos con esos criterios.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.softGrey),
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 88),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.66,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => ProductCard(
                          product: items[i],
                          onOpen: () => _openProduct(items[i]),
                        ),
                        childCount: items.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Center(
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => onTap(),
        ),
      ),
    );
  }
}
