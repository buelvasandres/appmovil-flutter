# Catálogo Express

Aplicación móvil de compras en línea desarrollada en **Flutter** para el curso de
Desarrollo de Aplicaciones Móviles (Politécnico Grancolombiano, grupo G10). Permite
consultar un catálogo de productos, guardarlos en favoritos, comprarlos, seguir el
estado de los pedidos y recibir notificaciones. Incluye un módulo para que el
administrador gestione el catálogo.

**Integrantes:** Andres Felipe Buelvas Rivera, Yair Alejandro Castaneda Vargas,
Alexis Carmona Pelaez, Daniel Castelblanco.

---

## 1. Estado actual del proyecto

La app ya es navegable de punta a punta y cubre la mayoría de requerimientos
funcionales del documento maestro. Por ahora los datos son de ejemplo y viven en la
memoria del celular: al cerrar la app todo vuelve a su estado inicial. Conectarla a una
base de datos es el siguiente paso.

| Módulo | Qué funciona hoy |
|---|---|
| Usuarios | Registro (sin correos repetidos), inicio y cierre de sesión, ver y editar perfil |
| Catálogo | Listado, detalle, búsqueda, filtros por categoría/precio/disponibilidad, productos agotados |
| Interacción | Favoritos, calificaciones y comentarios |
| Carrito y compras | Agregar, cambiar cantidades, eliminar, finalizar compra con dirección y pago simulado, historial de pedidos |
| Notificaciones | Compra confirmada, cambio de estado, cancelación, ofertas; marcar como leídas |
| Administración | Crear, editar, eliminar, activar/desactivar productos; precios, inventario y categorías |

**Pendiente:** base de datos o backend, carga de imágenes desde la galería (RF-38),
recuperación de contraseña y notificaciones push reales.

### Cuentas de prueba

| Rol | Correo | Contraseña |
|---|---|---|
| Cliente | demo@catalogo.com | 123456 |
| Administrador | admin@catalogo.com | admin123 |

Para probar un **pago rechazado**, paga con tarjeta usando 16 dígitos que terminen en `0000`.

---

## 2. Cómo se construyó

- **Tecnología:** Flutter y Dart, con componentes Material 3. No usa paquetes externos,
  solo el SDK de Flutter, para que sea fácil de ejecutar y compilar.
- **Diseño:** pantallas basadas en el mockup de Mockplus (login, registro, catálogo,
  menú lateral, perfil y notificaciones). El logo, las fotos de productos y el ícono de
  la app se tomaron del mismo mockup.
- **Lógica:** un único estado global (`AppState`) guarda usuarios, productos, carrito,
  pedidos y notificaciones, y avisa a las pantallas cuando algo cambia para que se
  actualicen solas.
- **APK:** se compila automáticamente en la nube con **GitHub Actions** cada vez que se
  suben cambios a `main`. No hace falta instalar Android Studio.

```
lib/
  main.dart               Punto de entrada
  theme.dart              Colores y estilos del mockup
  models.dart             Usuario, Producto, Carrito, Pedido, Notificación
  app_state.dart          Lógica de negocio y datos de ejemplo
  widgets/common.dart     Banner, menú lateral, tarjeta de producto, utilidades
  screens/                Una pantalla por archivo
assets/images/            Logo e imágenes de productos
branding/android_icons/   Ícono de la app
web/                      Archivos para ejecutarla en el navegador
.github/workflows/        Compilación automática del APK
```

---

## 3. Cómo ejecutarla

### Opción A — En el navegador, sin instalar nada (GitHub Codespaces)

1. En este repositorio: **Code → Codespaces → Create codespace on main**. Se abre VS Code
   en el navegador. (Si ya tienes uno creado, ábrelo desde la misma lista y salta al paso 3.)
2. En la **Terminal** de abajo, instala Flutter (solo la primera vez, tarda unos minutos):
   ```bash
   git clone https://github.com/flutter/flutter.git -b stable --depth 1 ~/flutter
   echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc && source ~/.bashrc
   flutter --version
   ```
3. Ejecuta la app:
   ```bash
   flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0
   ```
4. Ve a la pestaña **Puertos**, busca el **8080** y haz clic en el ícono del globo.
   Para verla con tamaño de celular: **F12** → ícono del teléfono.
5. Si cambias el código, presiona **R** en la terminal para recargar. **q** la detiene.

> Si la página queda en blanco, ejecuta el paso 3 agregando `--release`.

### Opción B — En el computador (requiere instalar Flutter)

1. Instala Flutter siguiendo https://docs.flutter.dev/get-started/install y la extensión
   **Flutter** de VS Code.
2. Clona el repositorio y entra a la carpeta:
   ```bash
   git clone https://github.com/buelvasandres/appmovil-flutter.git
   cd appmovil-flutter
   ```
3. Genera la carpeta de Android (solo la primera vez) y descarga dependencias:
   ```bash
   flutter create --platforms=android --project-name catalogo_express --org co.edu.poligran .
   flutter pub get
   ```
4. Ejecuta: `flutter run -d chrome` para el navegador, o `flutter run` con un celular
   conectado por USB (depuración USB activada) o un emulador.

### Opción C — Instalar el APK en un celular Android

1. Descarga `CatalogoExpress.apk` desde la sección **Releases** del repositorio
   (o desde **Actions → última ejecución → Artifacts**).
2. Ábrelo en el celular y permite "instalar apps de origen desconocido" si lo pide.

---

## 4. Cómo trabajamos en equipo

- `main` siempre debe funcionar: cada cambio que llega ahí genera un APK nuevo.
- Cada integrante trabaja en su propia rama, por ejemplo `feature/carrito`, y al terminar
  abre un **Pull Request** hacia `main` para que otro lo revise antes de unirlo.
- En Codespaces: clic en el nombre de la rama (abajo a la izquierda) → **Crear nueva rama**;
  haz tus cambios, **Confirmación** (commit) y **Publicar rama**. Luego en GitHub aparece
  el botón **Compare & pull request**.
