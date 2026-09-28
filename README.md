# Catálogo Express

Aplicación móvil de comercio electrónico desarrollada en **Flutter** para el curso de
Desarrollo de Aplicaciones Móviles (Politécnico Grancolombiano, grupo G10).

La app permite consultar un catálogo de productos, buscarlos y filtrarlos, guardarlos en
favoritos, agregarlos al carrito, finalizar la compra, seguir el estado de los pedidos y
recibir notificaciones. Incluye un módulo de administración del catálogo.

## Cuentas de prueba

| Rol           | Correo               | Contraseña |
|---------------|----------------------|------------|
| Cliente       | demo@catalogo.com    | 123456     |
| Administrador | admin@catalogo.com   | admin123   |

También se puede crear una cuenta nueva desde "Regístrate aquí".

## Funciones implementadas en esta entrega

| Módulo | Requerimientos |
|---|---|
| Gestión de usuarios | RF-01 Registro, RF-02 Login, RF-03 Cerrar sesión, RF-04 Correo duplicado, RF-05 Ver perfil, RF-06 Editar perfil |
| Catálogo | RF-08 Consultar, RF-09 Detalle, RF-13 Buscar, RF-14 Filtrar (categoría, precio, disponibilidad, orden), RF-16 Disponible/agotado, RF-17 Actualización inmediata |
| Interacciones | RF-18 Favoritos, RF-19 Calificaciones y comentarios |
| Carrito y compras | RF-20 Agregar, RF-21 Editar cantidades/eliminar, RF-22 Finalizar compra (dirección y método de pago), RF-23 Historial de pedidos |
| Notificaciones | RF-24 Compra confirmada, RF-25 Cambio de estado, RF-26 Cancelación, RF-27 Historial, RF-28 Marcar como leídas, RF-29 Ofertas y novedades |
| Administración | RF-07/30 Registrar, RF-10/32 Modificar, RF-11/33 Eliminar, RF-12/40 Código duplicado, RF-15/34 Categorías, RF-31 Consultar, RF-35 Precios, RF-36 Inventario, RF-37 Estado según stock, RF-39 Validación, RF-41 Activar/desactivar, RF-42 Reflejo inmediato |

El pago es **simulado**. Para probar el manejo de errores en el pago, se puede usar una
tarjeta de 16 dígitos que termine en `0000`: la transacción se rechaza sin generar el pedido.

## Pendiente para próximas entregas

- Base de datos / backend (por ahora los datos viven en memoria y se reinician al cerrar la app).
- RF-38 Carga de imágenes de productos desde la galería.
- Recuperación de contraseña y notificaciones push reales.

## Estructura

```
lib/
  main.dart                 Punto de entrada
  theme.dart                Colores y estilos del mockup
  models.dart               Usuario, Producto, Carrito, Pedido, Notificación
  app_state.dart            Lógica de negocio y datos de ejemplo
  widgets/common.dart       Banner, menú lateral, tarjeta de producto, utilidades
  screens/                  Pantallas (login, registro, catálogo, detalle, carrito,
                            checkout, pedidos, notificaciones, perfil, favoritos, admin)
assets/images/              Logo e imágenes de productos
branding/android_icons/     Ícono de la app
.github/workflows/          Compilación automática del APK
```

## Cómo se genera el APK

El APK se compila automáticamente con **GitHub Actions** cada vez que se suben cambios a
la rama `main` (o manualmente desde la pestaña **Actions → Build APK → Run workflow**).
Al terminar, el archivo `CatalogoExpress.apk` queda disponible en la sección **Artifacts**
de la ejecución.

Para compilarlo localmente (requiere Flutter instalado):

```
flutter create --platforms=android --project-name catalogo_express --org co.edu.poligran .
flutter pub get
flutter build apk --release
```
