import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wifi_scan/wifi_scan.dart';

void main() {
  runApp(const AegisHomeApp());
}

// ==========================================
// BASE DE DATOS SIMULADA / ESTADO GLOBAL
// ==========================================
class BaseDatosSimulada {
  static Map<String, Map<String, dynamic>> pyerosRegistrados = {};
  static String usuarioActual = "@usuario";

  // Control de concurrencia de operador
  static bool robotEnUso = false;
  static String operadorActual = "@usuario";
}

class AegisHomeApp extends StatelessWidget {
  const AegisHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aegis Home',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFF800020),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF800020),
          secondary: Color(0xFFE53935),
          surface: Color(0xFF1C070B),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/': (context) => const AuthScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/detalle_robot': (context) => const DetalleRobotScreen(),
        '/control_camara': (context) => const ControlCamaraScreen(),
      },
    );
  }
}

// ==========================================
// 1. PANTALLA DE CARGA 
// ==========================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2D0A10), Color(0xFF121212)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE53935).withValues(alpha: 0.4),
                      blurRadius: 25,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Image.asset(
                    'assets/images/pyero_icono.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFF800020),
                        child: const Icon(Icons.shield_outlined, size: 80, color: Colors.white),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                "AEGIS HOME",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4.0,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Iniciando sistema de seguridad...",
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 40),
              const SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  color: Color(0xFFE53935),
                  strokeWidth: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 2. AUTENTICACIÓN (CONTRASEÑA 6 DÍGITOS)
// ==========================================
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _nameController = TextEditingController();
  String? _errorPassword;

  bool _validarPassword(String pass) {
    if (pass.length != 6) return false;
    RegExp regexAlfanumerico = RegExp(r'^[a-zA-Z0-9]{6}$');
    if (!regexAlfanumerico.hasMatch(pass)) return false;

    String primerCaracter = pass[0];
    RegExp esLetra = RegExp(r'^[a-zA-Z]$');
    if (esLetra.hasMatch(primerCaracter)) {
      if (primerCaracter != primerCaracter.toUpperCase()) {
        return false;
      }
    }
    return true;
  }

  void _procesarAutenticacion() {
    setState(() => _errorPassword = null);
    String pass = _passController.text.trim();

    if (!_validarPassword(pass)) {
      setState(() {
        _errorPassword =
            "La contraseña debe ser de 6 caracteres (letras y números).\nSi inicia con letra, la inicial debe ser MAYÚSCULA.";
      });
      return;
    }

    if (_emailController.text.isNotEmpty) {
      BaseDatosSimulada.usuarioActual = "@${_emailController.text.split('@').first}";
    }
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  void _iniciarSesionSocial(String proveedor) {
    BaseDatosSimulada.usuarioActual = "@${proveedor.toLowerCase()}_user";
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2D0A10), Color(0xFF121212)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shield_outlined, size: 75, color: Color(0xFFE53935)),
                const SizedBox(height: 8),
                const Text(
                  "AEGIS HOME",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 3.0, color: Colors.white),
                ),
                const Text("Sistema Antincendios Pyero", style: TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 30),
                if (!_isLogin) ...[
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration("usuario", Icons.person_outline),
                  ),
                  const SizedBox(height: 14),
                ],
                TextField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration("Correo Electrónico", Icons.email_outlined),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _passController,
                  obscureText: true,
                  maxLength: 6,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration("Contraseña (6 dígitos)", Icons.lock_outline),
                ),
                if (_errorPassword != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 8),
                    child: Text(
                      _errorPassword!,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 11),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF800020),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _procesarAutenticacion,
                    child: Text(
                      _isLogin ? "INICIAR SESIÓN" : "CREAR CUENTA",
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Colors.white24),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.g_mobiledata, color: Colors.white, size: 28),
                        label: const Text("Google", style: TextStyle(color: Colors.white)),
                        onPressed: () => _iniciarSesionSocial("Google"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Colors.white24),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.mail_outline, color: Colors.cyanAccent, size: 20),
                        label: const Text("Outlook", style: TextStyle(color: Colors.white)),
                        onPressed: () => _iniciarSesionSocial("Outlook"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () => setState(() => _isLogin = !_isLogin),
                  child: Text(
                    _isLogin ? "¿No tienes cuenta? Regístrate aquí" : "¿Ya tienes cuenta? Inicia sesión",
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      prefixIcon: Icon(icon, color: const Color(0xFFE53935)),
      filled: true,
      fillColor: Colors.black26,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

// ==========================================
// 3. DASHBOARD Y SOPORTE TÉCNICO
// ==========================================
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> _misRobots = [];

  @override
  void initState() {
    super.initState();
    _cargarRobots();
  }

  void _cargarRobots() {
    setState(() {
      _misRobots = BaseDatosSimulada.pyerosRegistrados.values.toList();
    });
  }

  void _abrirModalVincular() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const VincularPyeroModal(),
    );
    _cargarRobots();
  }

  void _abrirSoporteTecnico() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SoporteTecnicoModal(),
    );
  }

  void _simularAlerta() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TiempoReaccionDialog(
        tipoAlerta: "Humo / Fuego",
        onAtenderManual: () {
          Navigator.pushNamed(context, '/control_camara');
        },
        onModoAutonomoActivado: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("¡Pyero ha activado el Modo Autónomo de Extinción!"),
              backgroundColor: Colors.redAccent,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Panel de Control", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Usuario: ${BaseDatosSimulada.usuarioActual}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        backgroundColor: const Color(0xFF121212),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.cyanAccent),
            onPressed: _abrirSoporteTecnico,
          ),
          IconButton(
            icon: const Icon(Icons.notifications_active, color: Colors.amber),
            onPressed: _simularAlerta,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white54),
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Tus Dispositivos vinculados", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 15),
            Expanded(
              child: _misRobots.isEmpty
                  ? _buildEstadoVacio()
                  : ListView.builder(
                      itemCount: _misRobots.length,
                      itemBuilder: (context, index) {
                        final robot = _misRobots[index];
                        return Card(
                          color: const Color(0xFF1C070B),
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: const BorderSide(color: Color(0xFF800020)),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFF800020),
                              child: Icon(Icons.smart_toy, color: Colors.white),
                            ),
                            title: Text(robot['grupo'] ?? "Pyero ${robot['serie']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                            subtitle: Text(
                              "Serie: ${robot['serie']}\nWi-Fi Local: ${robot['wifi_ssid']}\nBatería: ${robot['bateria'] ?? '85%'}",
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            trailing: const Icon(Icons.chevron_right, color: Colors.white),
                            onTap: () {
                              Navigator.pushNamed(context, '/detalle_robot', arguments: robot);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFE53935),
        onPressed: _abrirModalVincular,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Vincular Pyero", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEstadoVacio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.devices_other, size: 70, color: Colors.grey[800]),
          const SizedBox(height: 15),
          const Text("No tienes ningún Pyero vinculado", style: TextStyle(fontSize: 16, color: Colors.white70, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Presiona 'Vincular Pyero' para registrar el número de serie y conectarlo al Wi-Fi del lugar.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 4. MODAL: VINCULACIÓN CON ESCANEO WI-FI REAL Y SELECCIÓN DE RED
// ==========================================
class VincularPyeroModal extends StatefulWidget {
  const VincularPyeroModal({super.key});

  @override
  State<VincularPyeroModal> createState() => _VincularPyeroModalState();
}

class _VincularPyeroModalState extends State<VincularPyeroModal> {
  final _serieController = TextEditingController();
  final _nombreGrupoController = TextEditingController();
  final _wifiPassController = TextEditingController();
  final _buscarUsuarioController = TextEditingController();

  List<String> _redesDisponibles = [];
  String? _redSeleccionada;
  bool _escaneandoWifi = false;

  final List<String> _miembrosGrupo = [];
  final int _limiteMaximo = 8;
  String? _mensajeNotificacion;

  @override
  void initState() {
    super.initState();
    _escanearRedesWifi();
  }

  // MÉTODO PARA ESCANEAR REDES WI-FI REALES EN EL ENTORNO
  Future<void> _escanearRedesWifi() async {
    setState(() => _escaneandoWifi = true);

    try {
      final canScan = await WiFiScan.instance.canStartScan();
      if (canScan == CanStartScan.yes) {
        await WiFiScan.instance.startScan();
        final results = await WiFiScan.instance.getScannedResults();
        
        List<String> ssids = results
            .map((e) => e.ssid)
            .where((ssid) => ssid.isNotEmpty)
            .toSet()
            .toList();

        setState(() {
          _redesDisponibles = ssids;
          if (_redesDisponibles.isNotEmpty) {
            _redSeleccionada = _redesDisponibles.first;
          }
        });
      } else {
        _usarRedesSimuladas();
      }
    } catch (e) {
      // Fallback para emuladores o si no hay permiso de ubicación/Wi-Fi
      _usarRedesSimuladas();
    } finally {
      if (mounted) setState(() => _escaneandoWifi = false);
    }
  }

  void _usarRedesSimuladas() {
    setState(() {
      _redesDisponibles = ["Infinitum_2.4G", "Totalplay_Fibra_5G", "Aegis_Home_WiFi", "Red_Trabajo"];
      _redSeleccionada = _redesDisponibles.first;
    });
  }

  void _agregarMiembro() {
    String usuario = _buscarUsuarioController.text.trim();
    if (usuario.isEmpty) return;

    if (_miembrosGrupo.length >= _limiteMaximo) {
      setState(() {
        _mensajeNotificacion = "Límite máximo alcanzado (máximo $_limiteMaximo miembros).";
      });
      return;
    }

    String nombreFormateado = usuario.startsWith('@') ? usuario : '@$usuario';

    if (!_miembrosGrupo.contains(nombreFormateado)) {
      setState(() {
        _miembrosGrupo.add(nombreFormateado);
        _buscarUsuarioController.clear();
        _mensajeNotificacion = null;
      });
    }
  }

  void _confirmarVinculacion() {
    String serie = _serieController.text.trim();
    if (serie.isEmpty) return;

    BaseDatosSimulada.pyerosRegistrados[serie] = {
      'serie': serie,
      'grupo': _nombreGrupoController.text.trim().isEmpty ? "Pyero ($serie)" : _nombreGrupoController.text.trim(),
      'wifi_ssid': _redSeleccionada ?? "Red Wi-Fi Desconocida",
      'miembros': List<String>.from(_miembrosGrupo),
      'bateria': '85%',
    };

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _serieController.dispose();
    _nombreGrupoController.dispose();
    _wifiPassController.dispose();
    _buscarUsuarioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 24,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1C070B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Vincular Pyero", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 15),
            TextField(
              controller: _serieController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Número de Serie",
                prefixIcon: const Icon(Icons.qr_code_scanner, color: Color(0xFFE53935)),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nombreGrupoController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Nombre de Grupo",
                prefixIcon: const Icon(Icons.label_outline, color: Colors.amberAccent),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Seleccionar Red Wi-Fi", style: TextStyle(color: Colors.cyanAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: _escaneandoWifi 
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.cyanAccent))
                      : const Icon(Icons.refresh, color: Colors.cyanAccent, size: 20),
                  onPressed: _escanearRedesWifi,
                )
              ],
            ),
            const SizedBox(height: 6),
            // MENÚ DESPLEGABLE CON LAS REDES DISPONIBLES ENCONTRADAS
            DropdownButtonFormField<String>(
              initialValue: _redSeleccionada,
              dropdownColor: const Color(0xFF121212),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Redes Wi-Fi",
                prefixIcon: const Icon(Icons.wifi, color: Colors.cyanAccent),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: _redesDisponibles.map((String ssid) {
                return DropdownMenuItem<String>(
                  value: ssid,
                  child: Text(ssid, style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (val) {
                setState(() => _redSeleccionada = val);
              },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _wifiPassController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Contraseña de la Red",
                prefixIcon: const Icon(Icons.wifi_password, color: Colors.cyanAccent),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 18),
            const Text("Añadir Miembros Autorizados", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _buscarUsuarioController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "@Nombre de usuario",
                      hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                      prefixIcon: const Icon(Icons.person_add_alt, color: Colors.white54),
                      filled: true,
                      fillColor: Colors.black26,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF800020),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                  ),
                  onPressed: _agregarMiembro,
                  child: const Text("Añadir", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            if (_mensajeNotificacion != null) ...[
              const SizedBox(height: 6),
              Text(_mensajeNotificacion!, style: const TextStyle(color: Colors.redAccent, fontSize: 11)),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: _miembrosGrupo
                  .map((miembro) => Chip(
                        label: Text(miembro, style: const TextStyle(color: Colors.white, fontSize: 12)),
                        backgroundColor: const Color(0xFF800020),
                        deleteIcon: const Icon(Icons.close, size: 14, color: Colors.white70),
                        onDeleted: () => setState(() => _miembrosGrupo.remove(miembro)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _confirmarVinculacion,
                child: const Text("Guardar y Vincular Pyero", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================
// 5. MODAL: SOPORTE TÉCNICO 
// ===========================
class SoporteTecnicoModal extends StatelessWidget {
  const SoporteTecnicoModal({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> faqList = [
      {
        "q": "1. ¿Cómo funciona el control remoto si estoy fuera de casa?",
        "a": "El Pyero se vincula a la red Wi-Fi de tu hogar/local y transmite datos a la nube. Esto te permite recibir alertas e interactuar con la cámara en vivo mediante tus datos móviles desde cualquier lugar."
      },
      {
        "q": "2. ¿Qué ocurre si la red Wi-Fi pierde conexión?",
        "a": "Si la señal de internet se interrumpe, el sistema de Pyero activará de forma autónoma sus sensores locales (MQ2 de humo y flama) para suprimir emergencias sin depender de la nube."
      },
      {
        "q": "3. ¿Cómo sé qué porcentaje de batería le queda a Pyero?",
        "a": "En el panel general y en la pantalla de detalles del robot verás el porcentaje de batería en tiempo real (por ejemplo, 85%). Al llegar al 20%, la app enviará una alerta de carga requerida."
      },
      {
        "q": "4. ¿Qué hago si la cámara ESP32-CAM no transmite video?",
        "a": "Asegúrate de que el robot se encuentre dentro del alcance del módem Wi-Fi configurado y verifica que el porcentaje de batería sea superior al 15%."
      },
      {
        "q": "5. ¿Pueden varias personas controlar el mismo robot al mismo tiempo?",
        "a": "No. Para evitar conflictos de comandos, la app cuenta con un bloqueo de operador único. Si un miembro está operando el robot, los demás verán un indicador de 'Robot Ocupado'."
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Color(0xFF1C070B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.help_center_outlined, color: Colors.cyanAccent),
                  SizedBox(width: 10),
                  Text("Soporte Técnico y FAQ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              IconButton(icon: const Icon(Icons.close, color: Colors.white54), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const Divider(color: Colors.white24),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: faqList.length,
              itemBuilder: (context, index) {
                return ExpansionTile(
                  iconColor: Colors.cyanAccent,
                  collapsedIconColor: Colors.white54,
                  title: Text(
                    faqList[index]["q"]!,
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        faqList[index]["a"]!,
                        style: const TextStyle(color: Colors.grey, fontSize: 12, height: 1.4),
                      ),
                    )
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ======================
// 6. DETALLE DEL ROBOT 
// ======================
class DetalleRobotScreen extends StatelessWidget {
  const DetalleRobotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? robot = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    String porcentajeBateria = robot?['bateria'] ?? "85%";

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(robot?['grupo'] ?? "Pyero Autómata"),
        backgroundColor: const Color(0xFF121212),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1C070B),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF800020)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.circle, color: Colors.greenAccent, size: 10),
                          SizedBox(width: 8),
                          Text("Sistema En Línea", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Text("SN: ${robot?['serie'] ?? 'PY-001-A1'}", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                    ],
                  ),
                  const Divider(height: 30, color: Colors.white24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(Icons.water_drop, "Tanque", "2.7 / 3.0 L", Colors.cyanAccent),
                      _buildStatItem(Icons.local_fire_department, "Sensores", "Normal", Colors.orangeAccent),
                      _buildStatItem(Icons.battery_5_bar_rounded, "Batería", porcentajeBateria, Colors.greenAccent),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                icon: const Icon(Icons.videocam, color: Colors.white),
                label: const Text("Abrir Cámara y Teleoperación", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                onPressed: () => Navigator.pushNamed(context, '/control_camara'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String val, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 2),
        Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }
}

// ==========================================
// 7. TELEOPERACIÓN CON BANNER DE OPERADOR CONCURRENTE
// ==========================================
class ControlCamaraScreen extends StatefulWidget {
  const ControlCamaraScreen({super.key});

  @override
  State<ControlCamaraScreen> createState() => _ControlCamaraScreenState();
}

class _ControlCamaraScreenState extends State<ControlCamaraScreen> {
  bool _bombaActiva = false;

  void _alternarSimulacionOcupado() {
    setState(() {
      BaseDatosSimulada.robotEnUso = !BaseDatosSimulada.robotEnUso;
      if (BaseDatosSimulada.robotEnUso) {
        BaseDatosSimulada.operadorActual = "@fanny";
      } else {
        BaseDatosSimulada.operadorActual = BaseDatosSimulada.usuarioActual;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool soyElOperador = (!BaseDatosSimulada.robotEnUso) ||
        (BaseDatosSimulada.operadorActual == BaseDatosSimulada.usuarioActual);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Control y Cámara en Vivo"),
        backgroundColor: const Color(0xFF121212),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: soyElOperador ? const Color(0xFF1E3A29) : const Color(0xFF3E1F1F),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: soyElOperador ? Colors.green : Colors.redAccent,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    soyElOperador ? Icons.check_circle_outline : Icons.block,
                    color: soyElOperador ? Colors.greenAccent : Colors.redAccent,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          soyElOperador ? "Tienes el Control del Robot" : "Robot Ocupado",
                          style: TextStyle(
                            color: soyElOperador ? Colors.greenAccent : Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Operando actualmente: ${soyElOperador ? BaseDatosSimulada.usuarioActual : BaseDatosSimulada.operadorActual}",
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _alternarSimulacionOcupado,
                    child: Text(
                      soyElOperador ? "Simular Ocupado" : "Liberar Control",
                      style: const TextStyle(color: Colors.amberAccent, fontSize: 11),
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF800020)),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.videocam_outlined, size: 50, color: Colors.white24),
                        SizedBox(height: 8),
                        Text("Transmisión ESP32-CAM en vivo...", style: TextStyle(color: Colors.white38, fontSize: 12)),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(6)),
                      child: const Text("REC 1080p", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: IgnorePointer(
              ignoring: !soyElOperador,
              child: Opacity(
                opacity: soyElOperador ? 1.0 : 0.4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C070B),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.water_drop, color: Colors.cyanAccent),
                                SizedBox(width: 8),
                                Text("Disparo de Bomba", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Switch(
                              value: _bombaActiva,
                              activeThumbColor: const Color(0xFFE53935),
                              onChanged: (val) => setState(() => _bombaActiva = val),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      Column(
                        children: [
                          IconButton(iconSize: 40, icon: const Icon(Icons.keyboard_arrow_up, color: Colors.white), onPressed: () {}),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(iconSize: 40, icon: const Icon(Icons.keyboard_arrow_left, color: Colors.white), onPressed: () {}),
                              const SizedBox(width: 30),
                              const Icon(Icons.stop_circle, color: Colors.redAccent, size: 36),
                              const SizedBox(width: 30),
                              IconButton(iconSize: 40, icon: const Icon(Icons.keyboard_arrow_right, color: Colors.white), onPressed: () {}),
                            ],
                          ),
                          IconButton(iconSize: 40, icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white), onPressed: () {}),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 8. DIÁLOGO DE REACCIÓN CON TIMER
// ==========================================
class TiempoReaccionDialog extends StatefulWidget {
  final String tipoAlerta;
  final VoidCallback onAtenderManual;
  final VoidCallback onModoAutonomoActivado;

  const TiempoReaccionDialog({
    super.key,
    required this.tipoAlerta,
    required this.onAtenderManual,
    required this.onModoAutonomoActivado,
  });

  @override
  State<TiempoReaccionDialog> createState() => _TiempoReaccionDialogState();
}

class _TiempoReaccionDialogState extends State<TiempoReaccionDialog> {
  int _conteoRegresivo = 15;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _iniciarCuentaRegresiva();
  }

  void _iniciarCuentaRegresiva() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_conteoRegresivo > 1) {
        setState(() => _conteoRegresivo--);
      } else {
        _timer?.cancel();
        widget.onModoAutonomoActivado();
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1C070B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE53935), width: 2),
      ),
      title: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFE53935), size: 28),
          const SizedBox(width: 8),
          Expanded(
            child: Text("¡ALERTA DE ${widget.tipoAlerta.toUpperCase()}!",
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Se ha detectado una anomalía. Si no responde, Pyero activará el modo autónomo.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 18),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 70,
                height: 70,
                child: CircularProgressIndicator(
                  value: _conteoRegresivo / 15,
                  color: const Color(0xFFE53935),
                  backgroundColor: Colors.white12,
                  strokeWidth: 5,
                ),
              ),
              Text(
                "$_conteoRegresivo s",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              )
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            _timer?.cancel();
            widget.onModoAutonomoActivado();
            Navigator.pop(context);
          },
          child: const Text("Activar Autónomo", style: TextStyle(color: Colors.grey, fontSize: 12)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE53935)),
          onPressed: () {
            _timer?.cancel();
            widget.onAtenderManual();
            Navigator.pop(context);
          },
          child: const Text("Tomar Control", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ],
    );
  }
}