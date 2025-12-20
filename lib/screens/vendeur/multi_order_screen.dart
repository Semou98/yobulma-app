// lib/screens/vendeur/create_order_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../repositories/order_repository.dart';
import '../../models/location_model.dart';
import '../../utils/app_constants.dart';
import '../../utils/constants.dart';
import '../map/map_selection_screen.dart';
import '../../services/delivery_api_service.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clientNameController = TextEditingController();
  final _clientPhoneController = TextEditingController();
  final _deliveryAddressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _deliveryPriceController = TextEditingController();
  final _amountController = TextEditingController();
  final DeliveryApiService _deliveryApiService = DeliveryApiService();
  
  String? _selectedQuartier;
  bool _isLoading = false;
  bool _isCalculatingPrice = false;
  LocationPoint? _deliveryLocation;
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();

  @override
  void dispose() {
    _clientNameController.dispose();
    _clientPhoneController.dispose();
    _deliveryAddressController.dispose();
    _descriptionController.dispose();
    _deliveryPriceController.dispose();
    _amountController.dispose();
    _phoneFocus.dispose();
    _addressFocus.dispose();
    super.dispose();
  }

  Future<void> _selectLocationOnMap() async {
    if (_selectedQuartier == null) {
      _showErrorSnackbar('Veuillez d\'abord sélectionner un quartier');
      return;
    }

    final location = await Navigator.push<LocationPoint>(
      context,
      MaterialPageRoute(
        builder: (context) => MapSelectionScreen(
          initialLocation: _deliveryLocation,
          quartier: _selectedQuartier,
        ),
      ),
    );

    if (location != null) {
      setState(() {
        _deliveryLocation = location;
      });
      
      if (location.address != null && location.address!.isNotEmpty) {
        _deliveryAddressController.text = location.address!;
      } else {
        _deliveryAddressController.text = 
            'Lat: ${location.latitude.toStringAsFixed(6)}, '
            'Lng: ${location.longitude.toStringAsFixed(6)}';
      }
      
      // Estimer automatiquement le prix après la sélection de l'adresse
      if (_selectedQuartier != null && location.address != null) {
        _estimateDeliveryPrice();
      }
    }
  }

  Future<void> _estimateDeliveryPrice() async {
    if (_deliveryLocation == null || _selectedQuartier == null) return;
    
    // Vérifier si le montant est valide
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      _showErrorSnackbar('Veuillez d\'abord entrer un montant valide');
      return;
    }
    
    setState(() => _isCalculatingPrice = true);
    
    try {
      // Position par défaut du vendeur (à adapter selon votre logique)
      // Pour l'instant, on utilise une position centrale de Dakar
      const double vendeurLat = 14.716677;
      const double vendeurLng = -17.467686;
      
      // Calculer la distance avec l'API
      final distance = await _deliveryApiService.calculateDistance(
        startLat: vendeurLat,
        startLng: vendeurLng,
        endLat: _deliveryLocation!.latitude,
        endLng: _deliveryLocation!.longitude,
      );
      
      // Estimer le prix
      final estimatedPrice = await _deliveryApiService.estimateDeliveryPrice(
        distance: distance,
        quartier: _selectedQuartier!,
        orderAmount: amount,
      );
      
      setState(() {
        _deliveryPriceController.text = estimatedPrice.toStringAsFixed(0);
      });
      
      _showSuccessSnackbar('Prix estimé: ${estimatedPrice.toStringAsFixed(0)} FCFA');
      
    } catch (e) {
      print('Error estimating price: $e');
      _showErrorSnackbar('Impossible d\'estimer le prix automatiquement');
    } finally {
      setState(() => _isCalculatingPrice = false);
    }
  }

  Future<void> _createOrder() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedQuartier == null) {
      _showErrorSnackbar('Veuillez sélectionner un quartier');
      return;
    }
    
    if (_deliveryLocation == null) {
      _showErrorSnackbar('Veuillez sélectionner une adresse sur la carte');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => _isLoading = false);
        context.go('/login');
        return;
      }

      final orderRepo = context.read<OrderRepository>();
      final deliveryPrice = double.tryParse(_deliveryPriceController.text) ?? 0.0;
      final amount = double.tryParse(_amountController.text) ?? 0.0;

      final orderId = await orderRepo.createOrder(
        vendeurId: user.uid,
        clientId: null,
        clientName: _clientNameController.text.trim(),
        clientPhone: _clientPhoneController.text.trim(),
        quartier: _selectedQuartier!,
        deliveryAddress: _deliveryAddressController.text.trim(),
        deliveryLocation: GeoPoint(
          _deliveryLocation!.latitude,
          _deliveryLocation!.longitude,
        ),
        deliveryLocationPoint: _deliveryLocation!,
        description: _descriptionController.text.trim(),
        deliveryPrice: deliveryPrice,
        amount: amount,
      );

      if (orderId != null && mounted) {
        _showSuccessSnackbar('Commande créée avec succès');
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) context.go('/vendeur/orders');
        });
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
          _showErrorSnackbar('Erreur lors de la création de la commande');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackbar('Erreur: ${e.toString()}');
      }
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.md,
        ),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.md,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.go('/vendeur/orders'),
        ),
        title: Text(
          'Nouvelle commande',
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        shape: const Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              // Header avec icône
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.xl,
                  horizontal: AppSpacing.lg,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppBorderRadius.lg,
                  boxShadow: AppShadows.card,
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add_shopping_cart,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Créer une nouvelle commande',
                      style: AppTextStyles.heading2.copyWith(
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Remplissez les informations du client et de la livraison',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Formulaire
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppBorderRadius.lg,
                  boxShadow: AppShadows.card,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section titre
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: AppBorderRadius.sm,
                            ),
                            child: Text(
                              '1',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Informations du client',
                            style: AppTextStyles.heading3.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Champs client
                      _buildTextField(
                        controller: _clientNameController,
                        label: 'Nom complet du client',
                        hintText: 'Ex: Abdoulaye Ndiaye',
                        icon: Icons.person_outline,
                        isRequired: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer le nom du client';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),

                      _buildTextField(
                        controller: _clientPhoneController,
                        label: 'Numéro de téléphone',
                        hintText: 'Ex: +221 77 123 45 67',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        focusNode: _phoneFocus,
                        isRequired: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer le téléphone';
                          }
                          if (value.length < 9) {
                            return 'Numéro invalide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Montant de la commande
                      _buildTextField(
                        controller: _amountController,
                        label: 'Montant de la commande (FCFA)',
                        hintText: 'Ex: 5000',
                        icon: Icons.monetization_on_outlined,
                        keyboardType: TextInputType.number,
                        suffixText: 'FCFA',
                        isRequired: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer le montant';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null || amount <= 0) {
                            return 'Montant invalide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Section livraison
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: AppBorderRadius.sm,
                            ),
                            child: Text(
                              '2',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Détails de livraison',
                            style: AppTextStyles.heading3.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Sélection quartier
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quartier de livraison',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _selectedQuartier == null
                                    ? AppColors.textSecondary.withOpacity(0.3)
                                    : AppColors.primary.withOpacity(0.3),
                              ),
                              borderRadius: AppBorderRadius.md,
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedQuartier,
                                hint: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                  ),
                                  child: Text(
                                    'Sélectionnez un quartier',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                icon: Padding(
                                  padding: const EdgeInsets.only(
                                    right: AppSpacing.md,
                                  ),
                                  child: Icon(
                                    Icons.arrow_drop_down,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                isExpanded: true,
                                items: AppConstants.dakarQuartiers
                                    .map((quartier) {
                                  return DropdownMenuItem<String>(
                                    value: quartier,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.md,
                                      ),
                                      child: Text(
                                        quartier,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() => _selectedQuartier = value);
                                },
                              ),
                            ),
                          ),
                          if (_selectedQuartier == null &&
                              _formKey.currentState?.validate() == false)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: AppSpacing.xs,
                                left: AppSpacing.sm,
                              ),
                              child: Text(
                                'Veuillez sélectionner un quartier',
                                style: TextStyle(
                                  color: AppColors.error,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Bouton pour sélectionner l'adresse sur la carte
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Adresse de livraison',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          if (_deliveryLocation == null)
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.3),
                                  width: 2,
                                ),
                                borderRadius: AppBorderRadius.md,
                              ),
                              child: TextButton.icon(
                                onPressed: _selectedQuartier != null
                                    ? _selectLocationOnMap
                                    : null,
                                icon: Icon(
                                  Icons.map_outlined,
                                  color: _selectedQuartier != null
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                                label: Text(
                                  'Sélectionner sur la carte',
                                  style: TextStyle(
                                    color: _selectedQuartier != null
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.lg,
                                  ),
                                ),
                              ),
                            )
                          else
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.success.withOpacity(0.3),
                                ),
                                borderRadius: AppBorderRadius.md,
                                color: AppColors.success.withOpacity(0.1),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: AppColors.success,
                                        size: 20,
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Text(
                                        'Adresse sélectionnée',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.success,
                                        ),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          color: AppColors.primary,
                                          size: 20,
                                        ),
                                        onPressed: _selectLocationOnMap,
                                      ),
                                      if (_amountController.text.isNotEmpty)
                                        IconButton(
                                          icon: _isCalculatingPrice
                                              ? const SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                  ),
                                                )
                                              : Icon(
                                                  Icons.auto_awesome,
                                                  color: AppColors.primary,
                                                  size: 20,
                                                ),
                                          onPressed: _isCalculatingPrice
                                              ? null
                                              : _estimateDeliveryPrice,
                                          tooltip: 'Estimer le prix',
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    'Latitude: ${_deliveryLocation!.latitude.toStringAsFixed(6)}',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    'Longitude: ${_deliveryLocation!.longitude.toStringAsFixed(6)}',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (_deliveryLocation!.address != null && 
                                      _deliveryLocation!.address!.isNotEmpty) ...[
                                    const SizedBox(height: AppSpacing.sm),
                                    Text(
                                      _deliveryLocation!.address!,
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          if (_deliveryLocation == null &&
                              _formKey.currentState?.validate() == false)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: AppSpacing.xs,
                                left: AppSpacing.sm,
                              ),
                              child: Text(
                                'Veuillez sélectionner une adresse sur la carte',
                                style: TextStyle(
                                  color: AppColors.error,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Description du colis
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Description du colis',
                        hintText: 'Ex: Colis alimentaire, dimensions: 30x20x15cm',
                        icon: Icons.description_outlined,
                        maxLines: 3,
                        isRequired: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer une description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Prix de livraison avec bouton d'estimation
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _deliveryPriceController,
                                  label: 'Prix de livraison (FCFA)',
                                  hintText: 'Ex: 1500',
                                  icon: Icons.attach_money_outlined,
                                  keyboardType: TextInputType.number,
                                  suffixText: 'FCFA',
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty) {
                                      final price = double.tryParse(value);
                                      if (price == null || price < 0) {
                                        return 'Prix invalide';
                                      }
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              if (_deliveryLocation != null && 
                                  _selectedQuartier != null &&
                                  _amountController.text.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: AppSpacing.md,
                                    top: AppSpacing.lg,
                                  ),
                                  child: SizedBox(
                                    height: 56,
                                    child: ElevatedButton.icon(
                                      onPressed: _isCalculatingPrice
                                          ? null
                                          : _estimateDeliveryPrice,
                                      icon: _isCalculatingPrice
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Icon(Icons.auto_awesome, size: 20),
                                      label: const Text('Estimer'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: AppBorderRadius.md,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          if (_isCalculatingPrice)
                            Padding(
                              padding: const EdgeInsets.only(top: 8, left: 8),
                              child: Text(
                                'Estimation en cours...',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Bouton de soumission
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _createOrder,
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
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.check_circle_outline,
                                        size: 20),
                                    const SizedBox(width: AppSpacing.sm),
                                    Text(
                                      'Créer la commande',
                                      style: AppTextStyles.button,
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      // Lien retour
                      const SizedBox(height: AppSpacing.md),
                      Center(
                        child: TextButton(
                          onPressed: () => context.go('/vendeur/orders'),
                          child: Text(
                            'Retour aux commandes',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    bool isRequired = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    FocusNode? focusNode,
    String? suffixText,
    String? Function(String?)? validator,
  }) {
    final resolvedKeyboardType = maxLines > 1 
        ? TextInputType.multiline 
        : keyboardType;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            children: isRequired
                ? [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ]
                : [],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          maxLines: maxLines,
          keyboardType: resolvedKeyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
            prefixIcon: Icon(
              icon,
              color: AppColors.textSecondary,
            ),
            suffixText: suffixText,
            suffixStyle: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: AppBorderRadius.md,
              borderSide: BorderSide(
                color: AppColors.textSecondary.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppBorderRadius.md,
              borderSide: BorderSide(
                color: AppColors.textSecondary.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppBorderRadius.md,
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppBorderRadius.md,
              borderSide: BorderSide(
                color: AppColors.error,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: AppBorderRadius.md,
              borderSide: BorderSide(
                color: AppColors.error,
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: maxLines > 1 ? AppSpacing.md : 0,
            ),
          ),
          validator: validator,
          textInputAction: maxLines > 1
              ? TextInputAction.newline
              : TextInputAction.next,
        ),
      ],
    );
  }
}