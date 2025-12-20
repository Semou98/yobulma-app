// lib/screens/auth/role_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../repositories/user_repository.dart';
import '../../utils/enums.dart';
import '../../utils/constants.dart';

class RoleSelectionScreen extends StatefulWidget {
  final User firebaseUser;
  
  const RoleSelectionScreen({
    super.key,
    required this.firebaseUser,
  });

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  UserRole? _selectedRole;
  bool _isLoading = false;

  Future<void> _saveRole() async {
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Veuillez sélectionner un rôle'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userRepository = context.read<UserRepository>();
      
      // Mettre à jour le rôle de l'utilisateur
      await userRepository.updateUserRole(
        userId: widget.firebaseUser.uid,
        role: _selectedRole!,
      );

      // Rediriger selon le rôle
      switch (_selectedRole!) {
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
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppBorderRadius.xl,
                  boxShadow: AppShadows.card,
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.person_add_alt_1_rounded,
                      size: 80,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Choisissez votre profil',
                      style: AppTextStyles.heading2.copyWith(
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Sélectionnez le type de compte qui correspond à votre activité',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSpacing.xl),
              
              // Sélection des rôles
              Column(
                children: [
                  _buildRoleCard(
                    role: UserRole.vendeur,
                    icon: Icons.store_rounded,
                    title: 'Vendeur',
                    description: 'Je vends des produits et je veux organiser mes livraisons',
                    isSelected: _selectedRole == UserRole.vendeur,
                  ),
                  
                  const SizedBox(height: AppSpacing.md),
                  
                  _buildRoleCard(
                    role: UserRole.livreur,
                    icon: Icons.delivery_dining_rounded,
                    title: 'Livreur',
                    description: 'Je livre des commandes et je veux optimiser mes tournées',
                    isSelected: _selectedRole == UserRole.livreur,
                  ),
                  
                  const SizedBox(height: AppSpacing.md),
                  
                  _buildRoleCard(
                    role: UserRole.client,
                    icon: Icons.shopping_bag_rounded,
                    title: 'Client',
                    description: 'Je commande des produits et je veux suivre mes livraisons',
                    isSelected: _selectedRole == UserRole.client,
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.xxl),
              
              // Bouton de confirmation
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveRole,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppBorderRadius.lg,
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Continuer',
                          style: AppTextStyles.button,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required UserRole role,
    required IconData icon,
    required String title,
    required String description,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
          borderRadius: AppBorderRadius.lg,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? AppShadows.card : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.background,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.textSecondary,
                size: 24,
              ),
            ),
            
            const SizedBox(width: AppSpacing.lg),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.heading3.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
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
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}