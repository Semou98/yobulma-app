import 'package:flutter/material.dart';
import 'package:yoboulma_app/screens/admin/dashboard_screen.dart';
import 'package:yoboulma_app/screens/livreur/batches_list_screen.dart';
import 'package:yoboulma_app/screens/vendeur/orders_list_screen.dart';
import 'package:yoboulma_app/services/auth_service.dart';
import '../../models/user_model.dart';
import '../../data/mock_data.dart';
import '../../core/enums.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // --- CONTRÔLEURS ---
  // Initialisation stricte pour éviter l'erreur "Null is not a subtype of TextEditingController"
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _forgotPassController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  // --- CHARTE GRAPHIQUE ---
  static const Color _primaryBlue = Color(0xFF23529C);
  static const Color _primaryOrange = Color(0xFFEE8E42);

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _forgotPassController.dispose();
    super.dispose();
  }

  // --- MOT DE PASSE OUBLIÉ (BottomSheet) ---
  void _showForgotPasswordSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Pour l'arrondi personnalisé
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 25,
          right: 25,
          top: 30,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              "Récupération",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _primaryBlue),
            ),
            const SizedBox(height: 10),
            const Text(
              "Entrez votre identifiant pour recevoir un code de réinitialisation.",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 25),
            _buildTextField(
              controller: _forgotPassController,
              label: "Email ou Téléphone",
              hint: "Saisir ici...",
              icon: Icons.contact_mail_outlined,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  if (_forgotPassController.text.isNotEmpty) {
                    Navigator.pop(context);
                    _showSuccessSnackbar("Lien envoyé avec succès !");
                    _forgotPassController.clear();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryOrange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text("Envoyer", 
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- LOGIQUE DE CONNEXION ---
  void _handleLogin() async {
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text.trim();

    if (identifier.isEmpty || password.isEmpty) {
      _showErrorSnackbar("Veuillez remplir tous les champs");
      return;
    }

    setState(() => _isLoading = true);

    try {
      User? userToLogIn;
      User? registeredUser = await AuthService.getUser();

      if (registeredUser != null &&
          (registeredUser.phoneNumber == identifier || registeredUser.email == identifier)) {
        userToLogIn = registeredUser;
      } else {
        try {
          userToLogIn = MockData.users.firstWhere(
            (u) => u.phoneNumber == identifier || u.email == identifier
          );
        } catch (_) { userToLogIn = null; }
      }

      await Future.delayed(const Duration(milliseconds: 800));

      if (userToLogIn != null) {
        await AuthService.saveUser(userToLogIn);
        if (!mounted) return;
        _navigateToDashboard(userToLogIn);
      } else {
        if (!mounted) return;
        _showErrorSnackbar("Identifiants incorrects");
      }
    } catch (e) {
      _showErrorSnackbar("Une erreur est survenue");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToDashboard(User user) {
    Widget nextScreen;
    if (user.roles.contains(Role.ADMIN)) {
      nextScreen = const AdminDashboardScreen();
    } else if (user.roles.contains(Role.VENDEUR)) {
      nextScreen = const OrderListScreen();
    } else {
      nextScreen = const LivreurBatchesListScreen();
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => nextScreen),
      (route) => false,
    );
  }

  // --- SNACKBARS ---
  void _showErrorSnackbar(String message) {
    _showSnackbar(message, Colors.redAccent, Icons.error_outline);
  }

  void _showSuccessSnackbar(String message) {
    _showSnackbar(message, Colors.green, Icons.check_circle_outline);
  }

  void _showSnackbar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Text(message),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(15),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20),
            child: Column(
              children: [
                _buildLogo(),
                const SizedBox(height: 40),
                _buildTitleSection(),
                const SizedBox(height: 40),
                _buildFormSection(),
                const SizedBox(height: 40),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _primaryBlue.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ]
      ),
      child: Image.asset(
        'lib/images/YOBULMA LOGO_Plan de travail 1.png',
        height: 180,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.bolt_rounded, size: 80, color: _primaryBlue),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      children: const [
        Text(
          "Connexion",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _primaryBlue),
        ),
        SizedBox(height: 10),
        Text(
          "Heureux de vous revoir !",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildFormSection() {
    return Column(
      children: [
        _buildTextField(
          controller: _identifierController,
          label: "Identifiant",
          icon: Icons.person_outline,
          hint: "Email ou Téléphone",
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _passwordController,
          label: "Mot de passe",
          icon: Icons.lock_outline,
          isPassword: true,
          hint: "Votre mot de passe",
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _showForgotPasswordSheet,
            child: const Text(
              "Mot de passe oublié ?",
              style: TextStyle(color: _primaryBlue, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: _primaryBlue)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword ? _obscurePassword : false,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(icon, color: _primaryBlue, size: 20),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  )
                : null,
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade100),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: _primaryBlue, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text("Se connecter", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Annuler", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Nouveau ici ?", style: TextStyle(color: Colors.grey.shade600)),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: const Text("Créer un compte", style: TextStyle(color: _primaryOrange, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ],
    );
  }
}