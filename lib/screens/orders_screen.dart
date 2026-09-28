import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// "Estado de Productos": RF-23 historial de pedidos, RF-25 cambio de estado
/// y RF-26 cancelación.
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estado de Productos')),
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, _) {
          final orders = appState.currentUser?.orders ?? <Order>[];
          if (orders.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 80, color: AppColors.border),
                    SizedBox(height: 12),
                    Text(
                      'Aún no tienes pedidos',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Cuando finalices una compra aparecerá aquí con su estado.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.softGrey),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (context, i) => _OrderCard(order: orders[i]),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final steps = [
      OrderStatus.confirmado,
      OrderStatus.enPreparacion,
      OrderStatus.enviado,
      OrderStatus.entregado,
    ];
    final currentStep = steps.indexOf(order.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.id,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: order.status.color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.status.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${formatDate(order.date)} · ${order.units} producto(s) · ${order.paymentMethod}',
              style: const TextStyle(color: AppColors.softGrey, fontSize: 12),
            ),
            Text(
              'Envío a: ${order.address}, ${order.city}',
              style: const TextStyle(color: AppColors.softGrey, fontSize: 12),
            ),
            if (order.status != OrderStatus.cancelado) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  for (var s = 0; s < steps.length; s++) ...[
                    Expanded(
                      child: Column(
                        children: [
                          Icon(
                            s <= currentStep
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            size: 20,
                            color: s <= currentStep
                                ? AppColors.primary
                                : const Color(0xFFBDBDBD),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            steps[s].label,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
            const Divider(height: 20),
            for (final i in order.items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Expanded(child: Text('${i.quantity} x ${i.product.name}')),
                    Text(formatPrice(i.subtotal)),
                  ],
                ),
              ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Expanded(
                  child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Text(
                  formatPrice(order.total),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            if (order.isOpen) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () async {
                      final ok = await confirmDialog(
                        context,
                        title: 'Cancelar pedido',
                        message: '¿Seguro que quieres cancelar el pedido ${order.id}?',
                        confirmLabel: 'Sí, cancelar',
                      );
                      if (ok) appState.cancelOrder(order);
                    },
                    child: const Text(
                      'Cancelar pedido',
                      style: TextStyle(color: AppColors.soldOut),
                    ),
                  ),
                  const SizedBox(width: 4),
                  OutlinedButton(
                    onPressed: () => appState.advanceOrder(order),
                    child: const Text('Simular avance'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
