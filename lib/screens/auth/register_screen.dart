import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yoboulma_app/screens/livreur/batches_list_screen.dart';
import 'dart:io';
import 'package:yoboulma_app/services/auth_service.dart';
import 'package:yoboulma_app/screens/vendeur/orders_list_screen.dart';
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
  
  File? _idPhoto;
  File? _greyCardPhoto;

  // --- DESIGN ---
  static const Color _primaryOrange = Color(0xFFEE8E42);
  static const Color _secondaryBlue = Color(0xFF23529C);
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

  // --- VALIDATIONS ---
  bool _isValidCNI(String input) => RegExp(r'^\d{17}$').hasMatch(input);
  
  bool _isValidGreyCard(String input) {
    // Format: DK 1234 AB ou AA 1234 BC
    return RegExp(r'^[A-Z]{2}\s\d{4}\s[A-Z]{2}$').hasMatch(input.toUpperCase());
  }

  Future<void> _pickImage(bool isIdPhoto) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, 
      );

      if (image != null) {
        setState(() {
          if (isIdPhoto) {
            _idPhoto = File(image.path);
          } else {
            _greyCardPhoto = File(image.path);
          }
        });
      }
    } catch (e) {
      _showErrorSnackBar("Erreur lors de l'ouverture de la galerie.");
    }
  }

  void _handleRegister() async {
    // Validation de base
    if (_nameController.text.trim().isEmpty || _phoneController.text.trim().isEmpty) {
      _showErrorSnackBar("Veuillez remplir les champs obligatoires.");
      return;
    }

    if (_passwordController.text.length < 6) {
      _showErrorSnackBar("Le mot de passe doit faire au moins 6 caractères.");
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorSnackBar("Les mots de passe ne correspondent pas.");
      return;
    }

    // Validation spécifique Livreur
    if (_selectedRole == Role.LIVREUR) {
      if (!_isValidCNI(_idNumberController.text.trim())) {
        _showErrorSnackBar("La CNI doit comporter exactement 17 chiffres.");
        return;
      }
      if (!_isValidGreyCard(_greyCardController.text.trim())) {
        _showErrorSnackBar("Format Carte Grise invalide (ex: DK 1234 AB).");
        return;
      }
      if (_idPhoto == null || _greyCardPhoto == null) {
        _showErrorSnackBar("Veuillez charger les photos des documents.");
        return;
      }
      if (!_acceptPolicy) {
        _showErrorSnackBar("Veuillez accepter la charte de sécurité.");
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final newUser = User(
        id: "USR-${DateTime.now().millisecondsSinceEpoch}",
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        roles: [_selectedRole],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await AuthService.saveUser(newUser);

      if (!mounted) return;
      setState(() => _isLoading = false);

      Widget nextScreen = (_selectedRole == Role.LIVREUR) 
          ? const LivreurBatchesListScreen() 
          : const OrderListScreen();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => nextScreen),
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // --- LOGO ---
              Image.asset(
                'lib/images/YOBULMA LOGO_Plan de travail 1.png',
                height: 80,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),
              const Text("Rejoignez Nous", 
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: _secondaryBlue)),
              const SizedBox(height: 30),
              
              _buildRoleSelector(),
              const SizedBox(height: 32),
              
              _buildSectionTitle("Informations de connexion"),
              _buildInputField(_nameController, "Nom complet", Icons.person_outline),
              _buildInputField(_phoneController, "Téléphone", Icons.phone_android_outlined, keyboardType: TextInputType.phone),
              _buildInputField(_emailController, "Email (optionnel)", Icons.alternate_email),
              _buildInputField(_passwordController, "Mot de passe", Icons.lock_outline, isPassword: true),
              _buildInputField(_confirmPasswordController, "Confirmer le mot de passe", Icons.lock_reset, isPassword: true),

              if (_selectedRole == Role.LIVREUR) ...[
                const SizedBox(height: 24),
                _buildSectionTitle("Vérification d'identité"),
                _buildInputField(_idNumberController, "N° CNI (17 chiffres)", Icons.badge_outlined, keyboardType: TextInputType.number),
                _buildFilePicker("Photo CNI rectos/verso", Icons.camera_alt_outlined, _idPhoto, () => _pickImage(true)),
                
                const SizedBox(height: 10),
                _buildSectionTitle("Véhicule"),
                _buildInputField(_greyCardController, "Immatriculation (ex: DK 1234 AB)", Icons.motorcycle),
                _buildFilePicker("Photo Carte Grise", Icons.image_outlined, _greyCardPhoto, () => _pickImage(false)),
                
                _buildSecurityNotice(),
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

  Widget _buildSecurityNotice() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.gavel, size: 16, color: Colors.red.shade700),
              const SizedBox(width: 8),
              Text("RÈGLES DE SÉCURITÉ", 
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red.shade700)),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Tout vol, détournement ou dégradation volontaire de colis entraînera des poursuites judiciaires immédiates et le bannissement définitif. Vous êtes responsable du lot dès sa récupération.",
            style: TextStyle(fontSize: 11, color: Colors.black87),
          ),
        ],
      ),
    );
  }

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
        child: Container(
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
        style: const TextStyle(fontSize: 15),
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
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _secondaryBlue, width: 1)),
        ),
      ),
    );
  }

  Widget _buildFilePicker(String label, IconData icon, File? file, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _inputFill, 
            borderRadius: BorderRadius.circular(14), 
            border: Border.all(color: file != null ? _primaryOrange : Colors.transparent)
          ),
          child: Row(
            children: [
              Icon(icon, color: _secondaryBlue, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  file != null ? "Document chargé avec succès" : label, 
                  style: TextStyle(color: file != null ? _primaryOrange : Colors.grey.shade600, fontSize: 13)
                ),
              ),
              Icon(file != null ? Icons.check_circle : Icons.add_a_photo_outlined, color: file != null ? _primaryOrange : Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12, left: 4),
        child: Text(title.toUpperCase(), 
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: _primaryOrange, letterSpacing: 1.1)),
      ),
    );
  }

  Widget _buildPolicyCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _acceptPolicy, 
          activeColor: _secondaryBlue, 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          onChanged: (v) => setState(() => _acceptPolicy = v!)
        ),
        const Expanded(
          child: Text("Je certifie l'exactitude des infos et j'accepte la charte de sécurité.", 
            style: TextStyle(fontSize: 12, color: Colors.black54))
        ),
      ],
    );
  }

  Widget _buildSubmitButtons() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: _secondaryBlue, 
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
        ),
        child: _isLoading 
            ? const CircularProgressIndicator(color: Colors.white) 
            : const Text("Créer mon compte", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message), 
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      )
    );
  }
}