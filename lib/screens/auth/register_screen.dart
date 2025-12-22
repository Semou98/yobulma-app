import 'package:flutter/material.dart';
import 'package:yoboulma_app/services/auth_service.dart';
import 'package:yoboulma_app/screens/vendeur/orders_list_screen.dart'; // Import de votre écran cible
import '../../models/user_model.dart';
import '../../core/enums.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // --- CONTRÔLEURS ---
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _greyCardController = TextEditingController();

  // --- ÉTATS ---
  Role _selectedRole = Role.VENDEUR;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _acceptPolicy = false;

  // --- DESIGN ---
  static const Color _primaryOrange = Color(0xFFEE8E42);
  static const Color _secondaryBlue = Color(0xFF23529C);
  static const Color _bgColor = Colors.white;
  static const Color _inputFill = Color(0xFFF8F9FB);

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _idNumberController.dispose();
    _greyCardController.dispose();
    super.dispose();
  }

  // --- LOGIQUE D'INSCRIPTION ET CONNEXION DIRECTE ---
  void _handleRegister() async {
    // 1. Validations de base
    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      _showErrorSnackBar("Veuillez remplir les champs obligatoires.");
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorSnackBar("Les mots de passe ne correspondent pas.");
      return;
    }

    if (_selectedRole == Role.LIVREUR && !_acceptPolicy) {
      _showErrorSnackBar("Veuillez accepter la politique de confidentialité.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Création de l'objet utilisateur
      final newUser = User(
        id: "USR-${DateTime.now().millisecondsSinceEpoch}",
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        roles: [_selectedRole],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 3. SAUVEGARDE JSON via AuthService
      await AuthService.saveUser(newUser);

      if (!mounted) return;
      setState(() => _isLoading = false);

      // 4. REDIRECTION DIRECTE (L'utilisateur est "connecté")
      // On utilise pushAndRemoveUntil pour vider la pile (pas de retour en arrière possible)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const OrderListScreen()),
        (route) => false,
      );

    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar("Erreur lors de la création du compte.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: _secondaryBlue, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Inscription", style: TextStyle(color: _secondaryBlue, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Créer un compte",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: _secondaryBlue),
              ),
              const SizedBox(height: 8),
              Text(
                "Rejoignez la communauté Yobulma.",
                style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 30),

              _buildRoleSelector(),
              const SizedBox(height: 32),

              _buildSectionTitle("Informations personnelles"),
              _buildInputField(_nameController, "Nom complet", Icons.person_outline),
              _buildInputField(_phoneController, "Téléphone", Icons.phone_android_outlined, keyboardType: TextInputType.phone),
              _buildInputField(_emailController, "Email (optionnel)", Icons.alternate_email, keyboardType: TextInputType.emailAddress),
              _buildInputField(_passwordController, "Mot de passe", Icons.lock_outline, isPassword: true),
              _buildInputField(_confirmPasswordController, "Confirmation", Icons.lock_reset, isPassword: true),

              if (_selectedRole == Role.LIVREUR) ...[
                const SizedBox(height: 24),
                _buildSectionTitle("Documents requis"),
                _buildInputField(_idNumberController, "N° CNI ou Permis", Icons.badge_outlined),
                _buildFilePicker("Photo CNI / Permis", Icons.camera_alt_outlined),
                _buildInputField(_greyCardController, "N° Carte Grise", Icons.receipt_long_outlined),
                _buildFilePicker("Photo Carte Grise", Icons.image_outlined),
                const SizedBox(height: 12),
                _buildPolicyCheckbox(),
              ],

              const SizedBox(height: 40),
              _buildSubmitButtons(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // --- COMPOSANTS UI ---

  Widget _buildRoleSelector() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: _inputFill, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          _roleTab("Vendeur", Role.VENDEUR, Icons.storefront),
          _roleTab("Livreur", Role.LIVREUR, Icons.motorcycle),
        ],
      ),
    );
  }

  Widget _roleTab(String label, Role role, IconData icon) {
    bool isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? _secondaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isSelected ? Colors.white : Colors.grey),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String hint, IconData icon, {bool isPassword = false, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _obscurePassword : false,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: _secondaryBlue, size: 20),
          suffixIcon: isPassword 
              ? IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword))
              : null,
          filled: true,
          fillColor: _inputFill,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: _primaryOrange, letterSpacing: 1.2)),
    );
  }

  Widget _buildFilePicker(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(color: _inputFill, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade100)),
        child: Row(
          children: [
            Icon(icon, color: _secondaryBlue, size: 20),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
            const Spacer(),
            const Icon(Icons.add_circle_outline, color: _primaryOrange, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicyCheckbox() {
    return Row(
      children: [
        Checkbox(value: _acceptPolicy, activeColor: _primaryOrange, onChanged: (v) => setState(() => _acceptPolicy = v!)),
        const Expanded(child: Text("J'accepte les conditions d'utilisation", style: TextStyle(fontSize: 13, color: Colors.grey))),
      ],
    );
  }

  Widget _buildSubmitButtons() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleRegister,
        style: ElevatedButton.styleFrom(backgroundColor: _secondaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        child: _isLoading 
            ? const CircularProgressIndicator(color: Colors.white) 
            : const Text("Créer mon compte et continuer", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.redAccent));
  }
}