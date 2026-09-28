import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// RF-27 historial de notificaciones, RF-28 marcar como leídas,
/// RF-29 ofertas y promociones.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: appState,
          builder: (context, _) {
            final list = appState.notifications;
            return Column(
              children: [
                PromoBanner(
                  buttonLabel: 'Marcar leídas',
                  buttonIcon: Icons.done_all,
                  onPressed: () {
                    appState.markAllRead();
                    showMessage(context, 'Todas las notificaciones quedaron leídas');
                  },
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'Volver',
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.maybePop(context),
                      ),
                      const Text(
                        'Notificaciones',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(
                        '${appState.unreadCount} sin leer',
                        style: const TextStyle(color: AppColors.softGrey),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: list.isEmpty
                      ? const Center(
                          child: Text(
                            'No tienes notificaciones',
                            style: TextStyle(color: AppColors.softGrey),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
                          itemCount: list.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, i) {
                            final n = list[i];
                            return ListTile(
                              onTap: () => appState.markRead(n),
                              leading: Icon(
                                n.type.icon,
                                size: 40,
                                color: const Color(0xFF6E6E6E),
                              ),
                              title: Text(
                                n.title,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight:
                                      n.read ? FontWeight.w500 : FontWeight.w800,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 2),
                                  Text(
                                    n.message,
                                    style: const TextStyle(color: Colors.black87),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    formatDate(n.date),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.softGrey,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: n.read
                                  ? null
                                  : Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                            );
                          },
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
