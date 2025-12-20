import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../app_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();
  
  bool _isPhoneLogin = true;
  bool _isLoading = false;
  String? _verificationId;
  bool _isOtpSent = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authService = AuthService();
    await authService.signInWithPhoneNumber(
      phoneNumber: _phoneController.text.trim(),
      onCodeSent: (verificationId) {
        setState(() {
          _verificationId = verificationId;
          _isOtpSent = true;
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Code OTP envoyé avec succès'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: AppBorderRadius.md,
            ),
          ),
        );
      },
      onError: (error) {
        setState(() {
          _isLoading = false;
          _errorMessage = error;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $error'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: AppBorderRadius.md,
            ),
          ),
        );
      },
    );
  }

  // Dans login_screen.dart, modifiez les méthodes de connexion :
Future<void> _verifyOTP() async {
  if (_otpController.text.length != 6) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Veuillez entrer un code OTP valide (6 chiffres)'),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.md,
        ),
      ),
    );
    return;
  }

  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  final authService = AuthService();
  final user = await authService.verifyOTP(
    verificationId: _verificationId!,
    smsCode: _otpController.text.trim(),
  );

  if (user != null && mounted) {
    // Mettre à jour l'état global après le build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final appState = context.read<AppState>();
      await appState.setUser(user);
      
      // Succès
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connexion réussie ! Bonjour ${user.displayName}'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    });
  } else {
    if (mounted) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Code OTP invalide';
      });
    }
  }
}

Future<void> _loginWithEmail() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  final authService = AuthService();
  final user = await authService.signInWithEmail(
    email: _emailController.text.trim(),
    password: _passwordController.text,
  );

  if (user != null && mounted) {
    // Mettre à jour l'état global après le build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final appState = context.read<AppState>();
      await appState.setUser(user);
      
      // Succès
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connexion réussie ! Bonjour ${user.displayName}'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    });
  } else {
    if (mounted) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Email ou mot de passe incorrect';
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header avec logo et slogan
              _buildHeader(),
              
              const SizedBox(height: AppSpacing.xxl),
              
              // Carte principale avec tout le contenu
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppBorderRadius.xl,
                  boxShadow: AppShadows.card,
                ),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Titre de la section
                    Text(
                      'Connexion',
                      style: AppTextStyles.heading2.copyWith(
                        color: AppColors.secondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: AppSpacing.md),
                    
                    // Sous-titre
                    Text(
                      'Accédez à votre compte Yoboulma',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: AppSpacing.xl),
                    
                    // Toggle switch moderne
                    _buildLoginToggle(),
                    
                    const SizedBox(height: AppSpacing.xl),
                    
                    // Formulaire
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!_isOtpSent) ...[
                            if (_isPhoneLogin)
                              _buildPhoneField()
                            else ...[
                              _buildEmailField(),
                              const SizedBox(height: AppSpacing.lg),
                              _buildPasswordField(),
                            ],
                          ] else ...[
                            _buildOtpField(),
                          ],
                          
                          // Message d'erreur
                          if (_errorMessage != null) ...[
                            const SizedBox(height: AppSpacing.lg),
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.08),
                                borderRadius: AppBorderRadius.md,
                                border: Border.all(
                                  color: AppColors.error.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline_rounded,
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
                          
                          // Bouton principal avec dégradé orange
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: AppBorderRadius.lg,
                              gradient: AppColors.primaryGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : (_isOtpSent
                                      ? _verifyOTP
                                      : (_isPhoneLogin ? _sendOTP : _loginWithEmail)),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.lg,
                                ),
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppBorderRadius.lg,
                                ),
                                elevation: 0,
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
                                      _isOtpSent
                                          ? 'Vérifier le code'
                                          : (_isPhoneLogin
                                              ? 'Envoyer le code OTP'
                                              : 'Se connecter'),
                                      style: AppTextStyles.button,
                                    ),
                            ),
                          ),
                          
                          if (_isPhoneLogin && _isOtpSent) ...[
                            const SizedBox(height: AppSpacing.md),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isOtpSent = false;
                                  _otpController.clear();
                                });
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.textSecondary,
                                padding: EdgeInsets.zero,
                              ),
                              child: Text(
                                'Changer de numéro',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.secondary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                          
                          const SizedBox(height: AppSpacing.xl),
                          
                          // Séparateur
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: AppColors.divider,
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                ),
                                child: Text(
                                  'Nouveau chez nous ?',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: AppColors.divider,
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: AppSpacing.lg),
                          
                          // Bouton d'inscription avec contour bleu
                          OutlinedButton(
                            onPressed: () => context.go('/register'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.lg,
                              ),
                              side: BorderSide(
                                color: AppColors.secondary,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: AppBorderRadius.lg,
                              ),
                              foregroundColor: AppColors.secondary,
                            ),
                            child: Text(
                              'Créer un compte',
                              style: AppTextStyles.buttonSecondary,
                            ),
                          ),
                          
                          const SizedBox(height: AppSpacing.lg),
                          
                          // Lien vers les conditions
                          TextButton(
                            onPressed: () {
                              // TODO: Naviguer vers les conditions
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.textSecondary,
                            ),
                            child: RichText(
                              text: TextSpan(
                                text: 'En vous connectant, vous acceptez nos ',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Conditions d\'utilisation',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.secondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSpacing.xxl),
              
              // Footer
              Text(
                '© 2024 Yoboulma. Tous droits réservés.',
                style: AppTextStyles.overline.copyWith(
                  color: AppColors.textHint,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo circulaire avec ombre
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: AppBorderRadius.full,
            gradient: AppColors.secondaryGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppBorderRadius.full,
                boxShadow: AppShadows.card,
              ),
              child: ClipRRect(
                borderRadius: AppBorderRadius.full,
                child: Image.asset(
                  'assets/images/logo_yoboulma.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.delivery_dining_rounded,
                      size: 40,
                      color: AppColors.secondary,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: AppSpacing.lg),
        
        // Titre principal
        Text(
          'Yoboulma',
          style: AppTextStyles.heading1.copyWith(
            color: AppColors.secondary,
          ),
        ),
        
        const SizedBox(height: AppSpacing.xs),
        
        // Slogan
        Text(
          'Livraison intelligente, satisfaction garantie',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppBorderRadius.lg,
        border: Border.all(
          color: AppColors.border,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!_isPhoneLogin) {
                  setState(() {
                    _isPhoneLogin = true;
                    _isOtpSent = false;
                    _errorMessage = null;
                  });
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.md,
                  horizontal: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: _isPhoneLogin ? AppColors.primary : Colors.transparent,
                  borderRadius: AppBorderRadius.lg,
                  gradient: _isPhoneLogin ? AppColors.primaryGradient : null,
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.phone_android_rounded,
                      color: _isPhoneLogin ? Colors.white : AppColors.textSecondary,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Téléphone',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _isPhoneLogin ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_isPhoneLogin) {
                  setState(() {
                    _isPhoneLogin = false;
                    _isOtpSent = false;
                    _errorMessage = null;
                  });
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.md,
                  horizontal: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: !_isPhoneLogin ? AppColors.secondary : Colors.transparent,
                  borderRadius: AppBorderRadius.lg,
                  gradient: !_isPhoneLogin ? AppColors.secondaryGradient : null,
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.email_rounded,
                      color: !_isPhoneLogin ? Colors.white : AppColors.textSecondary,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: !_isPhoneLogin ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Numéro de téléphone',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            borderRadius: AppBorderRadius.lg,
            border: Border.all(
              color: AppColors.border,
              width: 1.5,
            ),
          ),
          child: TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: '+221 77 123 45 67',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textHint,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 16, right: 8),
                child: Icon(
                  Icons.phone_android_rounded,
                  color: AppColors.secondary,
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre numéro';
              }
              if (value.length < 9) {
                return 'Numéro invalide';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Adresse email',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            borderRadius: AppBorderRadius.lg,
            border: Border.all(
              color: AppColors.border,
              width: 1.5,
            ),
          ),
          child: TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'votre@email.com',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textHint,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 16, right: 8),
                child: Icon(
                  Icons.email_rounded,
                  color: AppColors.secondary,
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre email';
              }
              if (!value.contains('@')) {
                return 'Email invalide';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mot de passe',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            borderRadius: AppBorderRadius.lg,
            border: Border.all(
              color: AppColors.border,
              width: 1.5,
            ),
          ),
          child: TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                letterSpacing: 2,
                color: AppColors.textHint,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 16, right: 8),
                child: Icon(
                  Icons.lock_rounded,
                  color: AppColors.secondary,
                ),
              ),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre mot de passe';
              }
              if (value.length < 6) {
                return 'Minimum 6 caractères';
              }
              return null;
            },
          ),
        ),
        
        const SizedBox(height: AppSpacing.md),
        
        // Lien mot de passe oublié
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              // TODO: Implémenter mot de passe oublié
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              foregroundColor: AppColors.secondary,
            ),
            child: Text(
              'Mot de passe oublié ?',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Code de vérification',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        
        const SizedBox(height: AppSpacing.sm),
        
        Text(
          'Entrez le code à 6 chiffres envoyé par SMS',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        
        const SizedBox(height: AppSpacing.lg),
        
        // Champ OTP avec style moderne
        Container(
          decoration: BoxDecoration(
            borderRadius: AppBorderRadius.lg,
            border: Border.all(
              color: AppColors.secondary.withOpacity(0.3),
              width: 1.5,
            ),
            gradient: LinearGradient(
              colors: [
                AppColors.secondary.withOpacity(0.05),
                Colors.white,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                  letterSpacing: 12,
                  height: 1.2,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  counterText: '',
                  contentPadding: EdgeInsets.zero,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le code';
                  }
                  if (value.length != 6) {
                    return 'Code invalide (6 chiffres)';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              // Indicateur de minuteur (optionnel)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    color: AppColors.textSecondary,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Code valide pendant 5 minutes',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: AppSpacing.md),
        
        // Option de renvoi de code
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _isLoading ? null : _sendOTP,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              foregroundColor: AppColors.secondary,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.refresh_rounded,
                  color: AppColors.secondary,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Renvoyer le code',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}