import 'package:flutter/material.dart';
import 'dart:math';
import '../../models/order_model.dart';
import '../../models/location_model.dart';
import '../../data/mock_data.dart';
import '../../core/enums.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  // Charte graphique
  static const Color _primaryColor = Color(0xFFEE8E42); // Orange
  static const Color _secondaryColor = Color(0xFF23529C); // Bleu
  static const Color _backgroundColor = Colors.white;
  static const Color _textPrimary = Color(0xFF111827);
  static const Color _textSecondary = Color(0xFF6B7280);
  static const Color _borderColor = Color(0xFFE5E7EB);
  static const Color _successColor = Color(0xFF10B981);
  static const Color _errorColor = Color(0xFFEF4444);
  static const Color _cardColor = Color(0xFFF9FAFB);

  final LinearGradient _primaryGradient = const LinearGradient(
    colors: [_primaryColor, Color(0xFFFFA84C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  String _selectedQuartier = 'Plateau';
  final List<String> _quartiers = [
    'Plateau',
    'Medina',
    'Mermoz',
    'Almadies',
    'Guediawaye',
    'Pikine',
    'Dakar Plateau',
    'Yoff',
    'Ouakam',
    'Grand Dakar',
  ];

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    FocusScope.of(context).unfocus();

    // Simuler un délai d'envoi
    await Future.delayed(const Duration(milliseconds: 800));

    // Génération des données
    final String generatedOtp = (Random().nextInt(9000) + 1000).toString();
    final String orderId = "ORD-${DateTime.now().millisecondsSinceEpoch}";
    final String trackLink = "https://yobulma.sn/track/$orderId";

    // Création de la commande
    final newOrder = Order(
      id: orderId,
      vendeurId: 'vendeur-001',
      clientName: _nameController.text.trim(),
      clientPhone: _phoneController.text.trim(),
      deliveryLocation: Location(
        quartier: _selectedQuartier,
        adresse: _addressController.text.trim(),
        latitude: 14.716677 + (Random().nextDouble() - 0.5) * 0.02,
        longitude: -17.467686 + (Random().nextDouble() - 0.5) * 0.02,
      ),
      colisDescription: _descController.text.trim(),
      otp: generatedOtp,
      trackingLink: trackLink,
      status: OrderStatus.EN_ATTENTE_DE_LIVREUR,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Ajout aux données
    MockData.orders.add(newOrder);

    // Afficher le succès
    _showSuccessDialog(newOrder);
    setState(() => _isSubmitting = false);
  }

  void _showSuccessDialog(Order order) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: _buildSuccessDialogContent(order),
        );
      },
    );
  }

  Widget _buildSuccessDialogContent(Order order) {
    return Container(
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icône de succès
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: _primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Titre
            const Text(
              "Commande créée !",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: _textPrimary,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Sous-titre
            Text(
              "Votre expédition a été enregistrée avec succès",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: _textSecondary,
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Section OTP
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _secondaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _secondaryColor.withOpacity(0.1),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    "Code de sécurité à transmettre",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _secondaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    order.otp,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 8,
                      color: _secondaryColor,
                      fontFamily: 'Monospace',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "ID: ${order.id}",
                    style: TextStyle(
                      fontSize: 13,
                      color: _textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Note
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: _textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Ce code permettra au livreur de valider la livraison",
                      style: TextStyle(
                        fontSize: 13,
                        color: _textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context); // Fermer le dialog
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _secondaryColor,
                      side: BorderSide(
                        color: _secondaryColor.withOpacity(0.3),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      "Copier le code",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Fermer le dialog
                      Navigator.pop(context); // Retour à la liste
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _secondaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      "Terminer",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_rounded,
            color: _textPrimary,
          ),
        ),
        title: Text(
          "Nouvelle expédition",
          style: TextStyle(
            color: _textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.help_outline_rounded,
              color: _textSecondary,
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    
                    // En-tête avec étapes
                    _buildHeaderSteps(),
                    
                    const SizedBox(height: 32),
                    
                    // Formulaire
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section Informations Client
                          _buildSectionTitle(
                            title: "Informations client",
                            icon: Icons.person_outline_rounded,
                          ),
                          
                          const SizedBox(height: 20),
                          
                          _buildInputField(
                            controller: _nameController,
                            label: "Nom complet",
                            hintText: "Ex: Marie Diop",
                            prefixIcon: Icons.person_outline_rounded,
                            validator: (value) => value?.isEmpty == true 
                                ? "Veuillez entrer un nom" 
                                : null,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          _buildPhoneField(),
                          
                          const SizedBox(height: 32),
                          
                          // Section Livraison
                          _buildSectionTitle(
                            title: "Livraison",
                            icon: Icons.local_shipping_rounded,
                          ),
                          
                          const SizedBox(height: 20),
                          
                          _buildQuartierDropdown(),
                          
                          const SizedBox(height: 16),
                          
                          _buildInputField(
                            controller: _addressController,
                            label: "Adresse précise",
                            hintText: "Ex: Rue 12 x Rue 13, Immeuble Le Soleil",
                            prefixIcon: Icons.location_on_outlined,
                            validator: (value) => value?.isEmpty == true 
                                ? "Veuillez entrer une adresse" 
                                : null,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          _buildDescriptionField(),
                          
                          const SizedBox(height: 48),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bouton flottant en bas
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: [
                  const Spacer(),
                  Container(
                    color: _backgroundColor,
                    padding: const EdgeInsets.all(24),
                    child: _buildSubmitButton(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSteps() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Créer une expédition",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: _textPrimary,
            height: 1.2,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Remplissez les informations pour créer une nouvelle commande",
          style: TextStyle(
            fontSize: 15,
            color: _textSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),
        // Indicateur de progression
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _primaryColor,
                shape: BoxShape.circle,
              ),
            ),
            Container(
              height: 2,
              width: 40,
              color: _primaryColor,
            ),
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _primaryColor,
                shape: BoxShape.circle,
              ),
            ),
            Container(
              height: 2,
              width: 40,
              color: _borderColor,
            ),
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _borderColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Client",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _textPrimary,
              ),
            ),
            Text(
              "Livraison",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _textPrimary,
              ),
            ),
            Text(
              "Confirmation",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle({required String title, required IconData icon}) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _secondaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: _secondaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData prefixIcon,
    required String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _borderColor,
              width: 1.5,
            ),
          ),
          child: TextFormField(
            controller: controller,
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
                  color: _textSecondary.withOpacity(0.6),
                  size: 20,
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Téléphone",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _borderColor,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 16, right: 12),
                child: Icon(
                  Icons.phone_iphone_rounded,
                  color: _textSecondary.withOpacity(0.6),
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
                child: TextFormField(
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
                  validator: (value) {
                    if (value?.isEmpty == true) return "Veuillez entrer un numéro";
                    if (value!.length < 9) return "Numéro trop court";
                    if (!value.startsWith(RegExp(r'^7[0-9]'))) {
                      return "Numéro sénégalais invalide";
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuartierDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Quartier",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _borderColor,
              width: 1.5,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<String>(
              value: _selectedQuartier,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                prefixIcon: Icon(
                  Icons.map_outlined,
                  color: _textSecondary,
                ),
              ),
              icon: Icon(
                Icons.arrow_drop_down_rounded,
                color: _textSecondary,
              ),
              dropdownColor: _backgroundColor,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _textPrimary,
              ),
              items: _quartiers
                  .map((quartier) => DropdownMenuItem(
                        value: quartier,
                        child: Text(quartier),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedQuartier = value);
                }
              },
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Description du colis",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _borderColor,
              width: 1.5,
            ),
          ),
          child: TextFormField(
            controller: _descController,
            maxLines: 4,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
            decoration: InputDecoration(
              hintText: "Décrivez le contenu du colis, dimensions, précautions...",
              hintStyle: TextStyle(
                color: _textSecondary.withOpacity(0.6),
                fontWeight: FontWeight.w400,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            validator: (value) => value?.isEmpty == true 
                ? "Veuillez décrire le colis" 
                : null,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Aidez le livreur à mieux gérer votre colis",
          style: TextStyle(
            fontSize: 12,
            color: _textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: _primaryGradient,
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _isSubmitting ? null : _submitForm,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Center(
              child: _isSubmitting
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Créer l'expédition",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
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
                    ),
            ),
          ),
        ),
      ),
    );
  }
}