import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../core/enums.dart';
import '../../data/mock_data.dart';

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

  // Charte graphique améliorée
  static const Color _primaryColor = Color(0xFFEE8E42); // Orange
  static const Color _secondaryColor = Color(0xFF23529C); // Bleu
  static const Color _backgroundColor = Colors.white; // Blanc (couleur principale)
  static const Color _textPrimary = Color(0xFF111827); // Noir presque pur
  static const Color _textSecondary = Color(0xFF6B7280); // Gris
  static const Color _borderColor = Color(0xFFE5E7EB);
  static const Color _successColor = Color(0xFF10B981);
  static const Color _errorColor = Color(0xFFEF4444);
  static const Color _cardColor = Color(0xFFF9FAFB);
  
  // Nouvelle palette avec dégradés
  final LinearGradient _primaryGradient = const LinearGradient(
    colors: [_primaryColor, Color(0xFFFFA84C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  final LinearGradient _secondaryGradient = const LinearGradient(
    colors: [_secondaryColor, Color(0xFF2D63CC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutBack),
      ),
    );
    
    _animationController.forward();
    
    // Écouteurs pour la validation en temps réel
    _nameController.addListener(_validateName);
    _phoneController.addListener(_validatePhone);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.removeListener(_validateName);
    _phoneController.removeListener(_validatePhone);
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _validateName() {
    final isValid = _nameController.text.trim().length >= 2;
    if (_isNameValid != isValid) {
      setState(() => _isNameValid = isValid);
    }
  }

  void _validatePhone() {
    final phone = _phoneController.text.trim();
    final isValid = phone.length >= 9 && phone.startsWith(RegExp(r'^7[0-9]'));
    if (_isPhoneValid != isValid) {
      setState(() => _isPhoneValid = isValid);
    }
  }

  bool get _isFormValid => _isNameValid && _isPhoneValid;

  void _handleRegister() {
    if (!_isFormValid) {
      _showErrorSnackBar("Veuillez corriger les erreurs dans le formulaire");
      return;
    }

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    Future.delayed(const Duration(seconds: 1), () {
      try {
        final newUser = User(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          roles: [_selectedRole],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        MockData.addUser(newUser);
        
        setState(() => _isLoading = false);
        _showSuccessDialog();
      } catch (e) {
        setState(() => _isLoading = false);
        _showErrorSnackBar("Une erreur s'est produite. Réessayez.");
      }
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: Container(
          decoration: BoxDecoration(
            color: _backgroundColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: _primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Compte créé !",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Votre compte ${_selectedRole == Role.VENDEUR ? 'Vendeur' : 'Livreur'} a été créé avec succès.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: _textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _secondaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Se connecter",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: _errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: SafeArea(
                  minimum: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header avec logo
                      _buildHeader(),
                      const SizedBox(height: 40),
                      
                      // Formulaire d'inscription
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTitleSection(),
                            const SizedBox(height: 48),
                            
                            // Formulaire avec animations séquentielles
                            _buildFormSection(),
                            const SizedBox(height: 32),
                            
                            _buildRoleSection(),
                          ],
                        ),
                      ),
                      
                      // Bouton d'inscription
                      _buildRegisterButton(),
                      const SizedBox(height: 24),
                      
                      // Lien de connexion
                      _buildLoginLink(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Logo YOBULMA
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: _secondaryGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.local_shipping_rounded,
                color: Colors.white,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                "YOBULMA",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        
        const Spacer(),
        
        // Bouton retour stylisé
        IconButton(
          onPressed: () => Navigator.pop(context),
          style: IconButton.styleFrom(
            backgroundColor: _cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(12),
          ),
          icon: Icon(
            Icons.close_rounded,
            color: _textSecondary,
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Commencer",
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w900,
            color: _textPrimary,
            height: 1.1,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: "Créez votre compte ",
                style: TextStyle(
                  fontSize: 16,
                  color: _textSecondary,
                  height: 1.5,
                ),
              ),
              TextSpan(
                text: "YOBULMA",
                style: TextStyle(
                  fontSize: 16,
                  color: _secondaryColor,
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormSection() {
    return Column(
      children: [
        // Champ Nom
        AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Row(
                  children: [
                    Text(
                      "Nom complet",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    if (_isNameValid)
                      Icon(
                        Icons.check_circle,
                        color: _successColor,
                        size: 14,
                      ),
                  ],
                ),
              ),
              _buildInputField(
                controller: _nameController,
                hintText: "Votre nom complet",
                prefixIcon: Icons.person_outline_rounded,
                keyboardType: TextInputType.name,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Champ Téléphone
        AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Row(
                  children: [
                    Text(
                      "Numéro de téléphone",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    if (_isPhoneValid)
                      Icon(
                        Icons.check_circle,
                        color: _successColor,
                        size: 14,
                      ),
                  ],
                ),
              ),
              _buildPhoneField(),
              if (_phoneController.text.isNotEmpty && !_isPhoneValid)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 4),
                  child: Text(
                    "Veuillez entrer un numéro sénégalais valide",
                    style: TextStyle(
                      color: _errorColor,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: controller.text.isEmpty 
            ? _borderColor 
            : _isNameValid ? _successColor.withOpacity(0.3) : _errorColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: controller.text.isNotEmpty
            ? [
                BoxShadow(
                  color: (controller == _nameController ? _isNameValid : _isPhoneValid)
                      ? _successColor.withOpacity(0.1)
                      : _errorColor.withOpacity(0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: _textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: _textSecondary.withOpacity(0.6),
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.only(left: 16, right: 12),
            child: Icon(
              prefixIcon,
              color: controller.text.isEmpty
                  ? _textSecondary.withOpacity(0.6)
                  : _secondaryColor,
              size: 20,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _phoneController.text.isEmpty 
            ? _borderColor 
            : _isPhoneValid ? _successColor.withOpacity(0.3) : _errorColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: _phoneController.text.isNotEmpty
            ? [
                BoxShadow(
                  color: _isPhoneValid
                      ? _successColor.withOpacity(0.1)
                      : _errorColor.withOpacity(0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.only(left: 16, right: 12),
            child: Icon(
              Icons.phone_iphone_rounded,
              color: _phoneController.text.isEmpty
                  ? _textSecondary.withOpacity(0.6)
                  : _secondaryColor,
              size: 20,
            ),
          ),
          Container(
            width: 1,
            height: 24,
            color: _borderColor,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Text(
                  "🇸🇳",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 6),
                Text(
                  "+221",
                  style: TextStyle(
                    color: _textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _textPrimary,
              ),
              decoration: const InputDecoration(
                hintText: "77 123 45 67",
                hintStyle: TextStyle(
                  color: _textSecondary,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Type de compte",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildRoleCard("Vendeur", Role.VENDEUR)),
            const SizedBox(width: 12),
            Expanded(child: _buildRoleCard("Livreur", Role.LIVREUR)),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleCard(String title, Role role) {
    final isSelected = _selectedRole == role;
    final icon = role == Role.VENDEUR 
        ? Icons.storefront_rounded 
        : Icons.local_shipping_rounded;
    final description = role == Role.VENDEUR
        ? "Gérez vos commandes et produits"
        : "Effectuez des livraisons";
    
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? _secondaryColor : _cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _secondaryColor : _borderColor,
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _secondaryColor.withOpacity(0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : _secondaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? _secondaryColor : _secondaryColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : _textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white.withOpacity(0.8) : _textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.white : _borderColor,
                  width: 2,
                ),
                color: isSelected ? Colors.white : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 14,
                      color: _secondaryColor,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: _isFormValid && !_isLoading ? _primaryGradient : null,
        color: !_isFormValid || _isLoading ? _borderColor : null,
        boxShadow: _isFormValid && !_isLoading
            ? [
                BoxShadow(
                  color: _primaryColor.withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _isFormValid && !_isLoading ? _handleRegister : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Center(
              child: _isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _isFormValid ? Colors.white : _textSecondary,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Créer mon compte",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _isFormValid ? Colors.white : _textSecondary,
                          ),
                        ),
                        if (_isFormValid) ...[
                          const SizedBox(width: 12),
                          Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: _primaryColor,
                              size: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "Vous avez un compte ? ",
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 14,
                ),
              ),
              TextSpan(
                text: "Se connecter",
                style: TextStyle(
                  color: _secondaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                  decorationColor: _secondaryColor.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}