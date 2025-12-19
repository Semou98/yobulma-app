import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../repositories/user_repository.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../utils/enums.dart';

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
  
  UserRole _selectedRole = UserRole.vendeur;
  bool _isLoading = false;

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

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Les mots de passe ne correspondent pas')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authService = AuthService();
    final user = await authService.register(
      phoneNumber: _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty 
          ? null 
          : _emailController.text.trim(),
      displayName: _nameController.text.trim(),
      role: _selectedRole,
      password: _passwordController.text,
      boutiqueName: _selectedRole == UserRole.vendeur 
          ? _boutiqueNameController.text.trim().isEmpty 
              ? null 
              : _boutiqueNameController.text.trim()
          : null,
      vehicleType: _selectedRole == UserRole.livreur
          ? _vehicleTypeController.text.trim().isEmpty
              ? null
              : _vehicleTypeController.text.trim()
          : null,
      vehicleNumber: _selectedRole == UserRole.livreur
          ? _vehicleNumberController.text.trim().isEmpty
              ? null
              : _vehicleNumberController.text.trim()
          : null,
    );

    if (user != null && mounted) {
      context.go('/');
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de l\'inscription')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Créer un compte',
                  style: AppTextStyles.heading2,
                ),
                const SizedBox(height: AppSpacing.lg),
                // Role selection
                DropdownButtonFormField<UserRole>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Type de compte',
                    prefixIcon: Icon(Icons.person),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: UserRole.vendeur,
                      child: Text('Vendeur'),
                    ),
                    DropdownMenuItem(
                      value: UserRole.livreur,
                      child: Text('Livreur'),
                    ),
                    DropdownMenuItem(
                      value: UserRole.client,
                      child: Text('Client'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedRole = value);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom complet',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre nom';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Numéro de téléphone',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre numéro';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email (optionnel)',
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un mot de passe';
                    }
                    if (value.length < 6) {
                      return 'Le mot de passe doit contenir au moins 6 caractères';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirmer le mot de passe',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez confirmer le mot de passe';
                    }
                    return null;
                  },
                ),
                if (_selectedRole == UserRole.vendeur) ...[
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _boutiqueNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom de la boutique (optionnel)',
                      prefixIcon: Icon(Icons.store),
                    ),
                  ),
                ],
                if (_selectedRole == UserRole.livreur) ...[
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _vehicleTypeController,
                    decoration: const InputDecoration(
                      labelText: 'Type de véhicule (optionnel)',
                      prefixIcon: Icon(Icons.two_wheeler),
                      hintText: 'Moto, Voiture, etc.',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _vehicleNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Numéro de véhicule (optionnel)',
                      prefixIcon: Icon(Icons.confirmation_number),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('S\'inscrire'),
                ),
                const SizedBox(height: AppSpacing.md),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Déjà un compte ? Se connecter'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

