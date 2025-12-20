// screens/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../utils/enums.dart';
import '../../app_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _boutiqueNameController = TextEditingController();
  final _vehicleTypeController = TextEditingController();
  final _vehicleNumberController = TextEditingController();

  // CORRECTION ICI : Ne pas initialiser par défaut à vendeur
  UserRole? _selectedRole;
  bool _isLoading = false;
  String? _errorMessage;
  int _currentStep = 0;
  final List<String> _steps = ['Type de compte', 'Informations', 'Compte'];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _boutiqueNameController.dispose();
    _vehicleTypeController.dispose();
    _vehicleNumberController.dispose();
    super.dispose();
  }

  bool _validateStep(int step) {
    switch (step) {
      case 0: // Type de compte
        return _selectedRole != null; // IMPORTANT : doit être sélectionné
      case 1: // Informations
        return _nameController.text.isNotEmpty &&
            _phoneController.text.isNotEmpty;
      case 2: // Compte
        return _emailController.text.isNotEmpty &&
            _passwordController.text.isNotEmpty &&
            _passwordController.text == _confirmPasswordController.text;
      default:
        return false;
    }
  }

  // Dans register_screen.dart, modifiez la méthode _register :
  Future<void> _register() async {
    if (!_validateStep(_currentStep)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Veuillez remplir tous les champs obligatoires'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Les mots de passe ne correspondent pas'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = AuthService();
      final user = await authService.register(
        phoneNumber: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        displayName: _nameController.text.trim(),
        role: _selectedRole!, // Doit être non null
        password: _passwordController.text,
        boutiqueName: _selectedRole == UserRole.vendeur
            ? _boutiqueNameController.text.trim()
            : null,
        vehicleType: _selectedRole == UserRole.livreur
            ? _vehicleTypeController.text.trim()
            : null,
        vehicleNumber: _selectedRole == UserRole.livreur
            ? _vehicleNumberController.text.trim()
            : null,
      );

      if (user != null && mounted) {
        // 1. Mettre à jour l'état global après le build
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final appState = context.read<AppState>();
          await appState.setUser(user);

          // 2. Succès - Message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Compte ${user.role.name} créé avec succès !'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );

          // 3. Rediriger vers la sélection de rôle (si toujours nécessaire)
          // Note: Ici user est déjà créé avec un rôle, donc on peut directement rediriger
          // selon le rôle choisi
          await Future.delayed(const Duration(seconds: 2));

          // 4. Rediriger selon le rôle (au lieu de /role-selection)
          _redirectBasedOnRole(user.role);
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Erreur lors de la création du compte';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }
  // Dans register_screen.dart, ajoutez cette méthode après la méthode _register()

  void _redirectBasedOnRole(UserRole role) {
    // Petit délai pour laisser voir le message de succès
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      switch (role) {
        case UserRole.admin:
          context.go('/admin/dashboard');
          break;
        case UserRole.vendeur:
          context.go('/vendeur/orders');
          break;
        case UserRole.livreur:
          context.go('/livreur/batches');
          break;
        case UserRole.client:
          context.go('/');
          break;
        default:
          context.go('/');
      }
    });
  }

  void _nextStep() {
    if (_validateStep(_currentStep)) {
      if (_currentStep < _steps.length - 1) {
        setState(() => _currentStep++);
      } else {
        _register();
      }
      void _redirectBasedOnRole(UserRole role) {
        switch (role) {
          case UserRole.admin:
            context.go('/admin/dashboard');
            break;
          case UserRole.vendeur:
            context.go('/vendeur/orders');
            break;
          case UserRole.livreur:
            context.go('/livreur/batches');
            break;
          case UserRole.client:
            context.go('/'); // Page d'accueil client
            break;
          default:
            context.go('/');
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Veuillez remplir tous les champs obligatoires'),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              // En-tête
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Créer un compte',
                style: AppTextStyles.heading1.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Rejoignez Yoboulma en quelques étapes',
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Étapes
              _buildStepIndicator(),
              const SizedBox(height: AppSpacing.xl),

              // Formulaire
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (_currentStep == 0) _buildStep0(), // Type de compte
                    if (_currentStep == 1) _buildStep1(), // Informations
                    if (_currentStep == 2) _buildStep2(), // Compte
                    // Message d'erreur
                    if (_errorMessage != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: AppBorderRadius.sm,
                          border: Border.all(color: AppColors.error),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: AppColors.error,
                              size: 20,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: AppSpacing.xl),

                    // Boutons de navigation
                    Row(
                      children: [
                        if (_currentStep > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _previousStep,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.lg,
                                ),
                                side: BorderSide(color: AppColors.primary),
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppBorderRadius.lg,
                                ),
                              ),
                              child: Text(
                                'Précédent',
                                style: AppTextStyles.button.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        if (_currentStep > 0)
                          const SizedBox(width: AppSpacing.md),
                        Expanded(
                          flex: _currentStep > 0 ? 1 : 2,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _nextStep,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.lg,
                              ),
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: AppBorderRadius.lg,
                              ),
                              elevation: 0,
                              shadowColor: Colors.transparent,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    _currentStep == _steps.length - 1
                                        ? 'Créer le compte'
                                        : 'Continuer',
                                    style: AppTextStyles.button,
                                  ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Lien vers la connexion
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: RichText(
                        text: TextSpan(
                          text: 'Déjà un compte ? ',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          children: [
                            TextSpan(
                              text: 'Se connecter',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: _steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;

        return Expanded(
          child: Column(
            children: [
              // Cercle de l'étape
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: index <= _currentStep
                      ? AppColors.primary
                      : AppColors.textSecondary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: index <= _currentStep
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              // Nom de l'étape
              Text(
                step,
                style: AppTextStyles.caption.copyWith(
                  color: index <= _currentStep
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontWeight: index == _currentStep
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              // Ligne entre les étapes
              if (index < _steps.length - 1) ...[
                const SizedBox(height: AppSpacing.xs),
                Container(
                  height: 2,
                  color: index < _currentStep
                      ? AppColors.primary
                      : AppColors.textSecondary.withOpacity(0.2),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStep0() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choisissez votre type de compte *',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Cette sélection déterminera les fonctionnalités disponibles',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Options de rôle
        Column(
          children: [
            // Client
            _buildRoleCard(
              role: UserRole.client,
              title: 'Client',
              description: 'Je veux commander des produits',
              icon: Icons.person,
              isSelected: _selectedRole == UserRole.client,
              onTap: () => setState(() => _selectedRole = UserRole.client),
            ),

            const SizedBox(height: AppSpacing.md),

            // Vendeur
            _buildRoleCard(
              role: UserRole.vendeur,
              title: 'Vendeur',
              description: 'Je veux vendre mes produits',
              icon: Icons.store,
              isSelected: _selectedRole == UserRole.vendeur,
              onTap: () => setState(() => _selectedRole = UserRole.vendeur),
            ),

            const SizedBox(height: AppSpacing.md),

            // Livreur
            _buildRoleCard(
              role: UserRole.livreur,
              title: 'Livreur',
              description: 'Je veux livrer des commandes',
              icon: Icons.delivery_dining,
              isSelected: _selectedRole == UserRole.livreur,
              onTap: () => setState(() => _selectedRole = UserRole.livreur),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleCard({
    required UserRole role,
    required String title,
    required String description,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.surface,
          borderRadius: AppBorderRadius.lg,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? AppShadows.card : null,
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary.withOpacity(0.1),
                borderRadius: AppBorderRadius.md,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.textSecondary,
                size: 28,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.heading3.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.primary, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      children: [
        // Nom complet
        _buildTextField(
          controller: _nameController,
          label: 'Nom complet *',
          hintText: 'John Doe',
          icon: Icons.person_outline,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Ce champ est obligatoire';
            }
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.md),

        // Téléphone
        _buildTextField(
          controller: _phoneController,
          label: 'Numéro de téléphone *',
          hintText: '+221 77 123 45 67',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Ce champ est obligatoire';
            }
            if (value.length < 9) {
              return 'Numéro invalide';
            }
            return null;
          },
        ),

        // Champs spécifiques selon le rôle
        if (_selectedRole == UserRole.vendeur) ...[
          const SizedBox(height: AppSpacing.md),
          _buildTextField(
            controller: _boutiqueNameController,
            label: 'Nom de la boutique',
            hintText: 'Ma Boutique',
            icon: Icons.store_outlined,
          ),
        ],

        if (_selectedRole == UserRole.livreur) ...[
          const SizedBox(height: AppSpacing.md),
          _buildTextField(
            controller: _vehicleTypeController,
            label: 'Type de véhicule',
            hintText: 'Moto, Voiture, etc.',
            icon: Icons.two_wheeler,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildTextField(
            controller: _vehicleNumberController,
            label: 'Numéro de véhicule',
            hintText: 'AA-123-BB',
            icon: Icons.confirmation_number_outlined,
          ),
        ],
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      children: [
        // Email
        _buildTextField(
          controller: _emailController,
          label: 'Adresse email *',
          hintText: 'votre@email.com',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Ce champ est obligatoire';
            }
            if (!value.contains('@')) {
              return 'Email invalide';
            }
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.md),

        // Mot de passe
        _buildTextField(
          controller: _passwordController,
          label: 'Mot de passe *',
          hintText: '••••••••',
          icon: Icons.lock_outline,
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Ce champ est obligatoire';
            }
            if (value.length < 6) {
              return 'Minimum 6 caractères';
            }
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.md),

        // Confirmer le mot de passe
        _buildTextField(
          controller: _confirmPasswordController,
          label: 'Confirmer le mot de passe *',
          hintText: '••••••••',
          icon: Icons.lock_clock_outlined,
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Ce champ est obligatoire';
            }
            if (value != _passwordController.text) {
              return 'Les mots de passe ne correspondent pas';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: AppBorderRadius.md,
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
