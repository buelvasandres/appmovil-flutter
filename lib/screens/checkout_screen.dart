import 'package:flutter/material.dart';

import '../app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'orders_screen.dart';

/// RF-22 finalizar compra (dirección y método de pago) y RF-24 notificación.
/// El pago es simulado: una tarjeta que termina en 0000 se rechaza para
/// mostrar el manejo de errores en el pago (requerimiento no funcional 4).
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const _methods = ['Tarjeta de crédito', 'PSE', 'Contra entrega'];

  final _formKey = GlobalKey<FormState>();
  final _address = TextEditingController();
  final _city = TextEditingController(text: 'Bogotá');
  final _card = TextEditingController();
  String _method = _methods.first;
  bool _processing = false;

  @override
  void dispose() {
    _address.dispose();
    _city.dispose();
    _card.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (appState.cart.isEmpty) {
      showMessage(context, 'Tu carrito está vacío', error: true);
      return;
    }

    setState(() => _processing = true);
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _processing = false);

    final digits = _card.text.replaceAll(RegExp(r'\D'), '');
    if (_method == 'Tarjeta de crédito' && digits.endsWith('0000')) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.error_outline, color: AppColors.soldOut, size: 40),
          title: const Text('Pago rechazado'),
          content: const Text(
            'La entidad financiera rechazó la transacción. '
            'No se realizó ningún cobro. Verifica los datos o usa otro método de pago.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
      return;
    }

    final order = appState.placeOrder(
      address: _address.text,
      city: _city.text,
      paymentMethod: _method,
    );
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: AppColors.available, size: 48),
        title: const Text('¡Compra confirmada!'),
        content: Text(
          'Tu pedido ${order.id} por ${formatPrice(order.total)} fue registrado. '
          'Puedes seguir su estado en "Estado de Productos".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    final navigator = Navigator.of(context);
    navigator.popUntil((route) => route.isFirst);
    navigator.push(
      MaterialPageRoute(builder: (_) => const OrdersScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = appState.cart;
    return Scaffold(
      appBar: AppBar(title: const Text('Finalizar compra')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Resumen del pedido',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            for (final i in items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Expanded(child: Text('${i.quantity} x ${i.product.name}')),
                    Text(formatPrice(i.subtotal)),
                  ],
                ),
              ),
            const Divider(height: 24),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Total',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  formatPrice(appState.cartTotal),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Dirección de envío',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _address,
              decoration: const InputDecoration(
                hintText: 'Ej: Calle 123 # 45-67, apto 301',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              validator: (v) => validateRequired(v, 'La dirección'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _city,
              decoration: const InputDecoration(
                hintText: 'Ciudad',
                prefixIcon: Icon(Icons.location_city_outlined),
              ),
              validator: (v) => validateRequired(v, 'La ciudad'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Método de pago',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final m in _methods)
                  ChoiceChip(
                    label: Text(m),
                    selected: _method == m,
                    onSelected: (_) => setState(() => _method = m),
                  ),
              ],
            ),
            if (_method == 'Tarjeta de crédito') ...[
              const SizedBox(height: 10),
              TextFormField(
                controller: _card,
                keyboardType: TextInputType.number,
                maxLength: 19,
                decoration: const InputDecoration(
                  hintText: 'Número de tarjeta (16 dígitos)',
                  prefixIcon: Icon(Icons.credit_card),
                  helperText: 'Pago simulado. Una tarjeta que termine en 0000 será rechazada.',
                ),
                validator: (v) {
                  final d = (v ?? '').replaceAll(RegExp(r'\D'), '');
                  if (d.length != 16) return 'La tarjeta debe tener 16 dígitos';
                  return null;
                },
              ),
            ],
            if (_method == 'PSE')
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  'Serás redirigido al portal de tu banco (simulado en esta versión).',
                  style: TextStyle(color: AppColors.softGrey),
                ),
              ),
            if (_method == 'Contra entrega')
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  'Pagas en efectivo cuando recibas tu pedido.',
                  style: TextStyle(color: AppColors.softGrey),
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _processing ? null : _confirm,
              child: _processing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Confirmar compra'),
            ),
          ],
        ),
      ),
    );
  }
}
