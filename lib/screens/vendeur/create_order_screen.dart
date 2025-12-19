import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../repositories/order_repository.dart';
import '../../utils/constants.dart';
import '../../utils/enums.dart';

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
  
  String? _selectedQuartier;
  bool _isLoading = false;

  @override
  void dispose() {
    _clientNameController.dispose();
    _clientPhoneController.dispose();
    _deliveryAddressController.dispose();
    _descriptionController.dispose();
    _deliveryPriceController.dispose();
    super.dispose();
  }

  Future<void> _createOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedQuartier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un quartier')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      context.go('/login');
      return;
    }

    final orderRepo = Provider.of<OrderRepository>(context, listen: false);
    final deliveryPrice = double.tryParse(_deliveryPriceController.text) ?? 0.0;

    final orderId = await orderRepo.createOrder(
      vendeurId: user.uid,
      clientName: _clientNameController.text.trim(),
      clientPhone: _clientPhoneController.text.trim(),
      quartier: _selectedQuartier!,
      deliveryAddress: _deliveryAddressController.text.trim(),
      description: _descriptionController.text.trim(),
      deliveryPrice: deliveryPrice,
    );

    if (orderId != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Commande créée avec succès'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/vendeur/orders');
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la création de la commande'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle commande'),
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
                  'Créer une commande',
                  style: AppTextStyles.heading2,
                ),
                const SizedBox(height: AppSpacing.lg),
                TextFormField(
                  controller: _clientNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom du client *',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer le nom du client';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _clientPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Téléphone du client *',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer le téléphone du client';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String>(
                  value: _selectedQuartier,
                  decoration: const InputDecoration(
                    labelText: 'Quartier *',
                    prefixIcon: Icon(Icons.location_city),
                  ),
                  items: AppConstants.dakarQuartiers.map((quartier) {
                    return DropdownMenuItem(
                      value: quartier,
                      child: Text(quartier),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedQuartier = value);
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Veuillez sélectionner un quartier';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _deliveryAddressController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Adresse de livraison *',
                    prefixIcon: Icon(Icons.location_on),
                    hintText: 'Adresse textuelle complète',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer l\'adresse de livraison';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description du colis *',
                    prefixIcon: Icon(Icons.description),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer une description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _deliveryPriceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Prix de livraison (FCFA)',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: _isLoading ? null : _createOrder,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Créer la commande'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

