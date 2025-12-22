import 'package:flutter/material.dart';
import 'package:yoboulma_app/screens/livreur/batches_list_screen.dart';
import 'package:yoboulma_app/screens/vendeur/orders_list_screen.dart';
import 'package:yoboulma_app/services/auth_service.dart';
import '../../models/user_model.dart';
import '../../core/enums.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  Role _selectedRole = Role.VENDEUR;
  bool _isLoading = false;
  bool _isNameValid = false;
  bool _isPhoneValid = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  static const Color _primaryColor = Color(0xFFEE8E42);
  static const Color _secondaryColor = Color(0xFF23529C);
  static const Color _backgroundColor = Colors.white;
  static const Color _textPrimary = Color(0xFF111827);
  static const Color _textSecondary = Color(0xFF6B7280);
  static const Color _borderColor = Color(0xFFE5E7EB);
  static const Color _successColor = Color(0xFF10B981);
  static const Color _errorColor = Color(0xFFEF4444);
  static const Color _cardColor = Color(0xFFF9FAFB);

  final LinearGradient _secondaryGradient = const LinearGradient(
    colors: [_secondaryColor, Color(0xFF2D63CC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _scaleAnimation = Tween<double>(begin: 0.98, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();
    _nameController.addListener(() => _validateName());
    _phoneController.addListener(() => _validatePhone());
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _validateName() {
    final isValid = _nameController.text.trim().length >= 3;
    if (_isNameValid != isValid) setState(() => _isNameValid = isValid);
  }

  void _validatePhone() {
    final phone = _phoneController.text.trim();
    final isValid = phone.length == 9 &&
        (phone.startsWith('77') || phone.startsWith('78') || phone.startsWith('76') || phone.startsWith('70'));
    if (_isPhoneValid != isValid) setState(() => _isPhoneValid = isValid);
  }

  bool get _isFormValid => _isNameValid && _isPhoneValid;

  // --- LOGIQUE DE CONNEXION DIRECTE ---
  void _handleRegister() async {
    if (!_isFormValid) return;
    setState(() => _isLoading = true);

    try {
      final newUser = User(
        id: "USER_${DateTime.now().millisecondsSinceEpoch}",
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        roles: [_selectedRole],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 1. Sauvegarde dans le JSON/MockData
      await AuthService.saveUser(newUser);
      
      // 2. Initialisation de la session (Connexion automatique)
      await AuthService.login(newUser); // Assurez-vous que cette méthode existe dans votre service

      if (!mounted) return;

      // 3. Redirection directe selon le rôle
      Widget nextScreen = (_selectedRole == Role.VENDEUR) 
          ? const OrderListScreen() 
          : const LivreurBatchesListScreen();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => nextScreen),
        (route) => false, // Supprime tout l'historique (empêche le retour en arrière)
      );

      _showSuccessSnackBar("Bienvenue sur Yobulma, ${newUser.name} !");
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar("Erreur lors de l'inscription. Veuillez réessayer.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 30),
                  _buildTitleSection(),
                  const SizedBox(height: 40),
                  _buildFormSection(),
                  const SizedBox(height: 30),
                  _buildRoleSection(),
                  const SizedBox(height: 40),
                  _buildRegisterButton(),
                  const SizedBox(height: 20),
                  _buildLoginLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- UI COMPONENTS (Gardés tels quels mais intégrés au nouveau flux) ---

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(gradient: _secondaryGradient, borderRadius: BorderRadius.circular(12)),
          child: const Row(
            children: [
              Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text("YOBULMA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
            ],
          ),
        ),
        const Spacer(),
        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, color: _textSecondary)),
      ],
    );
  }

  Widget _buildTitleSection() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Inscription", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: _textPrimary)),
        SizedBox(height: 8),
        Text("Rejoignez la révolution de la livraison au Sénégal.", style: TextStyle(fontSize: 16, color: _textSecondary)),
      ],
    );
  }

  Widget _buildFormSection() {
    return Column(
      children: [
        _buildInputField(
          controller: _nameController,
          hintText: "Nom complet",
          prefixIcon: Icons.person_outline_rounded,
          isValid: _isNameValid,
        ),
        const SizedBox(height: 20),
        _buildPhoneField(),
      ],
    );
  }

  Widget _buildInputField({required TextEditingController controller, required String hintText, required IconData prefixIcon, required bool isValid}) {
    return TextField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(prefixIcon, color: isValid ? _secondaryColor : _textSecondary),
        filled: true,
        fillColor: _cardColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(color: _cardColor, borderRadius: BorderRadius.circular(16)),
          child: const Text("🇸🇳 +221", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: "77 000 00 00",
              filled: true,
              fillColor: _cardColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Je suis un :", style: TextStyle(fontWeight: FontWeight.bold, color: _textPrimary)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildRoleCard("Vendeur", Role.VENDEUR, Icons.storefront)),
            const SizedBox(width: 15),
            Expanded(child: _buildRoleCard("Livreur", Role.LIVREUR, Icons.motorcycle)),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleCard(String label, Role role, IconData icon) {
    bool selected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? _secondaryColor : _cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? _secondaryColor : _borderColor),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? Colors.white : _secondaryColor),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: selected ? Colors.white : _textPrimary, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: (_isFormValid && !_isLoading) ? _handleRegister : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          disabledBackgroundColor: _borderColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text("Créer mon compte", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text("Déjà un compte ? Connectez-vous", style: TextStyle(color: _secondaryColor, fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: _successColor, behavior: SnackBarBehavior.floating),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: _errorColor, behavior: SnackBarBehavior.floating),
    );
  }
}