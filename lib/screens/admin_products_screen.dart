import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// Administración del catálogo (solo administrador):
/// RF-07/RF-30 registrar, RF-31 consultar, RF-10/RF-32 modificar,
/// RF-11/RF-33 eliminar, RF-35 precios, RF-36 inventario,
/// RF-41 activar/desactivar y RF-15/RF-34 categorías.
class AdminProductsScreen extends StatelessWidget {
  const AdminProductsScreen({super.key});

  void _openForm(BuildContext context, [Product? product]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductFormScreen(product: product)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrar catálogo'),
        actions: [
          IconButton(
            tooltip: 'Categorías',
            icon: const Icon(Icons.category_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CategoriesScreen()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo producto'),
      ),
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, _) {
          final products = appState.products;
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 88),
            itemCount: products.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final p = products[i];
              return ListTile(
                onTap: () => _openForm(context, p),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: ProductImage(product: p, iconSize: 26),
                  ),
                ),
                title: Text(
                  p.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: p.active ? null : AppColors.softGrey,
                    decoration: p.active ? null : TextDecoration.lineThrough,
                  ),
                ),
                subtitle: Text(
                  '${p.code} · ${formatPrice(p.price)} · Stock: ${p.stock}'
                  '${p.available ? '' : ' (agotado)'}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: p.active,
                      onChanged: (v) {
                        appState.setActive(p, v);
                        showMessage(
                          context,
                          v ? '${p.name} activado' : '${p.name} desactivado',
                        );
                      },
                    ),
                    IconButton(
                      tooltip: 'Eliminar',
                      icon: const Icon(Icons.delete_outline, color: AppColors.soldOut),
                      onPressed: () async {
                        final ok = await confirmDialog(
                          context,
                          title: 'Eliminar producto',
                          message:
                              '¿Eliminar "${p.name}" definitivamente del catálogo?',
                          confirmLabel: 'Eliminar',
                        );
                        if (ok) {
                          appState.deleteProduct(p);
                          if (context.mounted) {
                            showMessage(context, 'Producto eliminado');
                          }
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Formulario para crear o editar un producto.
/// RF-39 valida campos obligatorios y RF-40 evita códigos duplicados.
class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.product});

  final Product? product;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _code;
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _price;
  late final TextEditingController _stock;
  String? _category;
  bool _active = true;

  bool get _isNew => widget.product == null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _code = TextEditingController(text: p?.code ?? '');
    _name = TextEditingController(text: p?.name ?? '');
    _description = TextEditingController(text: p?.description ?? '');
    _price = TextEditingController(text: p == null ? '' : '${p.price}');
    _stock = TextEditingController(text: p == null ? '' : '${p.stock}');
    _category = p?.category;
    _active = p?.active ?? true;
  }

  @override
  void dispose() {
    _code.dispose();
    _name.dispose();
    _description.dispose();
    _price.dispose();
    _stock.dispose();
    super.dispose();
  }

  String? _validateNumber(String? v, String field, {bool allowZero = false}) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return '$field es obligatorio';
    final n = int.tryParse(t);
    if (n == null) return '$field debe ser un número entero';
    if (n < 0 || (!allowZero && n == 0)) return '$field no es válido';
    return null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final category = _category;
    if (category == null) {
      showMessage(context, 'Selecciona una categoría', error: true);
      return;
    }
    final price = int.parse(_price.text.trim());
    final stock = int.parse(_stock.text.trim());

    final existing = widget.product;
    if (existing == null) {
      final error = appState.addProduct(
        Product(
          code: _code.text.trim().toUpperCase(),
          name: _name.text.trim(),
          description: _description.text.trim(),
          price: price,
          category: category,
          stock: stock,
          active: _active,
        ),
      );
      if (error != null) {
        showMessage(context, error, error: true);
        return;
      }
      showMessage(context, 'Producto registrado');
    } else {
      existing
        ..name = _name.text.trim()
        ..description = _description.text.trim()
        ..price = price
        ..category = category
        ..stock = stock
        ..active = _active;
      appState.productUpdated();
      showMessage(context, 'Producto actualizado');
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isNew ? 'Nuevo producto' : 'Editar producto')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _code,
              enabled: _isNew,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Código o referencia *',
                prefixIcon: Icon(Icons.qr_code_2),
              ),
              validator: (v) {
                final t = v?.trim() ?? '';
                if (t.isEmpty) return 'El código es obligatorio';
                if (_isNew && appState.codeExists(t)) {
                  return 'Ya existe un producto con ese código';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Nombre *',
                prefixIcon: Icon(Icons.label_outline),
              ),
              validator: (v) => validateRequired(v, 'El nombre'),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _description,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Descripción *',
                alignLabelWithHint: true,
              ),
              validator: (v) => validateRequired(v, 'La descripción'),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _price,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Precio (COP) *',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    validator: (v) => _validateNumber(v, 'El precio'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _stock,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Inventario *',
                      prefixIcon: Icon(Icons.inventory_outlined),
                    ),
                    validator: (v) =>
                        _validateNumber(v, 'El inventario', allowZero: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text('Categoría *', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final c in appState.categories)
                  ChoiceChip(
                    label: Text(c),
                    selected: _category == c,
                    onSelected: (_) => setState(() => _category = c),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Producto activo (visible en el catálogo)'),
              value: _active,
              onChanged: (v) => setState(() => _active = v),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                'La carga de imágenes (RF-38) se implementará en la siguiente entrega.',
                style: TextStyle(color: AppColors.softGrey, fontSize: 12),
              ),
            ),
            ElevatedButton(
              onPressed: _save,
              child: Text(_isNew ? 'Registrar producto' : 'Guardar cambios'),
            ),
          ],
        ),
      ),
    );
  }
}

/// RF-15 / RF-34 Gestionar categorías.
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  Future<String?> _askName(BuildContext context, {String initial = ''}) async {
    final controller = TextEditingController(text: initial);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(initial.isEmpty ? 'Nueva categoría' : 'Editar categoría'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nombre de la categoría'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categorías')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        tooltip: 'Nueva categoría',
        onPressed: () async {
          final name = await _askName(context);
          if (name == null) return;
          final error = appState.addCategory(name);
          if (context.mounted) {
            showMessage(context, error ?? 'Categoría creada', error: error != null);
          }
        },
        child: const Icon(Icons.add),
      ),
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(8),
          children: [
            for (final c in appState.categories)
              ListTile(
                leading: const Icon(Icons.label_outline, color: AppColors.primary),
                title: Text(c),
                subtitle: Text(
                  '${appState.products.where((p) => p.category == c).length} producto(s)',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Renombrar',
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () async {
                        final name = await _askName(context, initial: c);
                        if (name == null) return;
                        final error = appState.renameCategory(c, name);
                        if (context.mounted) {
                          showMessage(
                            context,
                            error ?? 'Categoría actualizada',
                            error: error != null,
                          );
                        }
                      },
                    ),
                    IconButton(
                      tooltip: 'Eliminar',
                      icon: const Icon(Icons.delete_outline, color: AppColors.soldOut),
                      onPressed: () {
                        final error = appState.deleteCategory(c);
                        showMessage(
                          context,
                          error ?? 'Categoría eliminada',
                          error: error != null,
                        );
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
