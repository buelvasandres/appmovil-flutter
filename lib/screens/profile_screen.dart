import 'package:flutter/material.dart';

import '../app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// RF-05 consultar perfil, RF-06 modificar información y RF-03 cerrar sesión.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _help(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ayuda'),
        content: const Text(
          '• Busca y filtra productos desde el catálogo.\n'
          '• Toca la estrella para guardar un producto en favoritos.\n'
          '• Agrega productos al carrito y finaliza la compra.\n'
          '• Revisa tus pedidos en "Estado de Productos".\n'
          '• Consulta avisos y ofertas en "Notificaciones".\n\n'
          'Soporte: soporte@catalogoexpress.com',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, _) {
          final user = appState.currentUser;
          if (user == null) {
            return const Center(child: Text('No hay sesión activa'));
          }
          return Column(
            children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 24),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const Expanded(
                              child: Text(
                                'Mi Perfil',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 48),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                              ),
                              child: const Icon(
                                Icons.person_outline,
                                size: 88,
                                color: Colors.white,
                              ),
                            ),
                            Positioned(
                              right: 2,
                              bottom: 2,
                              child: GestureDetector(
                                onTap: () => showMessage(
                                  context,
                                  'Cambiar foto estará disponible en una próxima entrega.',
                                ),
                                child: const CircleAvatar(
                                  radius: 15,
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.photo_camera,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          user.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user.isAdmin ? 'Administrador' : 'Cliente',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                  children: [
                    _InfoRow(icon: Icons.mail_outline, label: 'Correo', value: user.email),
                    _InfoRow(
                      icon: Icons.phone_iphone,
                      label: 'Teléfono',
                      value: user.phone.isEmpty ? 'Sin registrar' : user.phone,
                    ),
                    _InfoRow(
                      icon: Icons.receipt_long_outlined,
                      label: 'Pedidos realizados',
                      value: '${user.orders.length}',
                    ),
                    const SizedBox(height: 16),
                    _OutlinedTile(
                      icon: Icons.person_outline,
                      label: 'Editar Perfil',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                      ),
                    ),
                    _OutlinedTile(
                      icon: Icons.sentiment_satisfied_alt_outlined,
                      label: 'Ayuda',
                      onTap: () => _help(context),
                    ),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.logoutBg,
                        foregroundColor: AppColors.logoutText,
                      ),
                      onPressed: () async {
                        final ok = await confirmDialog(
                          context,
                          title: 'Cerrar sesión',
                          message: '¿Seguro que quieres cerrar sesión?',
                          confirmLabel: 'Cerrar sesión',
                        );
                        if (ok && context.mounted) logoutAndGoToLogin(context);
                      },
                      child: const Text('Cerrar Sesión'),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(
            child: Text(value, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

class _OutlinedTile extends StatelessWidget {
  const _OutlinedTile({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          foregroundColor: const Color(0xFF6E6E6E),
        ),
        onPressed: onTap,
        child: Row(
          children: [
            Icon(icon),
            Expanded(
              child: Text(label, textAlign: TextAlign.center),
            ),
            const SizedBox(width: 24),
          ],
        ),
      ),
    );
  }
}

/// RF-06 Modificar información personal.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;

  @override
  void initState() {
    super.initState();
    final u = appState.currentUser;
    _name = TextEditingController(text: u?.name ?? '');
    _email = TextEditingController(text: u?.email ?? '');
    _phone = TextEditingController(text: u?.phone ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final error = appState.updateProfile(
      name: _name.text,
      email: _email.text,
      phone: _phone.text,
    );
    if (error != null) {
      showMessage(context, error, error: true);
      return;
    }
    showMessage(context, 'Perfil actualizado');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Nombre completo',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) => validateRequired(v, 'El nombre'),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                prefixIcon: Icon(Icons.mail_outline),
              ),
              validator: validateEmail,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                prefixIcon: Icon(Icons.phone_iphone),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              child: const Text('Guardar cambios'),
            ),
          ],
        ),
      ),
    );
  }
}
