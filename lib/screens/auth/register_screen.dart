import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart'; 
import 'package:yoboulma_app/services/auth_service.dart';
import 'package:yoboulma_app/screens/auth/login_screen.dart'; 
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

  // Séparation des conditions Vendeur pour acceptation individuelle
  bool _acceptSellerPolicy1 = false;
  bool _acceptSellerPolicy2 = false;
  
  bool _acceptLivreurData = false;
  bool _acceptLivreurContract = false;

  File? _profilePhoto;
  File? _idPhoto;
  File? _greyCardPhoto;

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

  void _handleRegister() async {
    if (_profilePhoto == null) {
      _showErrorSnackBar("Veuillez ajouter une photo de profil.");
      return;
    }
    
    if (_selectedRole == Role.VENDEUR) {
      if (!_acceptSellerPolicy1 || !_acceptSellerPolicy2) {
        _showErrorSnackBar("Veuillez accepter toutes les conditions de vente.");
        return;
      }
    }

    if (_selectedRole == Role.LIVREUR && (!_acceptLivreurData || !_acceptLivreurContract)) {
      _showErrorSnackBar("Veuillez accepter les contrats livreur.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final newUser = User(
        id: "USR-${now.millisecondsSinceEpoch}",
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        roles: [_selectedRole],
        createdAt: now,
        updatedAt: now,
      );

      await AuthService.saveUser(newUser);
      
      // On déconnecte pour forcer la validation admin
      await AuthService.logout(); 

      if (!mounted) return;
      setState(() => _isLoading = false);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const RegistrationPendingScreen()),
        (route) => false,
      );

    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar("Erreur lors de l'inscription. Veuillez réessayer.");
    }
  }

  Future<void> _pickImage(String type) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) {
      setState(() {
        if (type == 'profile') _profilePhoto = File(image.path);
        if (type == 'id') _idPhoto = File(image.path);
        if (type == 'greyCard') _greyCardPhoto = File(image.path);
      });
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
            children: [
              const SizedBox(height: 20),
              
              // LOGO CLIQUABLE VERS CONNEXION
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: Image.asset(
                  'lib/images/YOBULMA LOGO_Plan de travail 1.png',
                  height: 60,
                ),
              ),

              const SizedBox(height: 20),
              _buildProfilePicker(),
              const SizedBox(height: 20),
              _buildRoleSelector(),
              const SizedBox(height: 32),

              _buildSectionTitle("Informations personnelles"),
              _buildInputField(_nameController, "Nom complet", Icons.person_outline),
              _buildInputField(_phoneController, "Téléphone", Icons.phone_android_outlined, keyboardType: TextInputType.phone),
              _buildInputField(_emailController, "Email", Icons.alternate_email),
              _buildInputField(_passwordController, "Mot de passe", Icons.lock_outline, isPassword: true),
              _buildInputField(_confirmPasswordController, "Confirmer le mot de passe", Icons.lock_reset, isPassword: true),

              if (_selectedRole == Role.LIVREUR) ...[
                const SizedBox(height: 24),
                _buildSectionTitle("Documents du livreur"),
                _buildInputField(_idNumberController, "N° CNI (17 chiffres)", Icons.badge_outlined, keyboardType: TextInputType.number),
                _buildFilePicker("Photo CNI", Icons.camera_alt_outlined, _idPhoto, () => _pickImage('id')),
                _buildInputField(_greyCardController, "Immatriculation", Icons.motorcycle),
                _buildFilePicker("Photo Carte Grise", Icons.image_outlined, _greyCardPhoto, () => _pickImage('greyCard')),
                
                _buildLegalBlock(
                  title: "Sécurité et Protection de vos Données",
                  text: "Pour rejoindre le réseau YOBULMA, nous devons vérifier votre identité. Les informations collectées (Nom, CNI, Photo) sont stockées de manière sécurisée et ne sont utilisées que pour garantir la confiance entre vous et les vendeurs. En tant que plateforme de mise en relation, nous conservons ces données pour assurer un suivi précis de chaque mission. En cas dincident ou de litige, ces informations constituent une garantie de transparence pour toutes les parties.Vous acceptez que YOBULMA traite ces données conformément à sa politique de confidentialité.",
                  value: _acceptLivreurData,
                  onChanged: (v) => setState(() => _acceptLivreurData = v!),
                ),
                _buildLegalBlock(
                  title: "Contrat de Partenariat YOBULMA",
                  text: "YOBULMA agit exclusivement comme intermédiaire technique vous mettant en relation avec des vendeurs. Vous restez un prestataire indépendant responsable de l'exécution de vos courses.Responsabilité et Intégrité : Vous vous engagez à livrer les colis dans leur état d'origine. YOBULMA n'est pas responsable des vols ou dommages, mais en cas de litige, la plateforme coopérera pleinement avec les autorités. Vos données d'identité et votre historique de tracking GPS seront transmis pour toute poursuite judiciaire nécessaire.Sécurisation OTP : La saisie du code OTP client est obligatoire pour clôturer une mission. Elle constitue la preuve légale de votre livraison.Commissions : Pour chaque course réussie, YOBULMA prélève une commission de 5% sur le tarif affiché.Je reconnais avoir pris connaissance du rôle de YOBULMA et j'accepte d'exercer mon activité de livreur avec probité et transparence",
                  value: _acceptLivreurContract,
                  onChanged: (v) => setState(() => _acceptLivreurContract = v!),
                ),
              ],

              if (_selectedRole == Role.VENDEUR) ...[
                const SizedBox(height: 20),
                _buildLegalBlock(
                  title: "Engagement de Responsabilité du Vendeur",
                  text: "YOBULMA agit exclusivement en tant que plateforme de mise en relation entre vendeurs et livreurs. En utilisant nos services, vous reconnaissez être l'unique responsable du contenu de vos colis. Il est strictement interdit de transporter des produits illicites (drogues, armes, contrefaçons) selon la loi sénégalaise. Vous certifiez que votre envoi est conforme à la législation en vigueur et dégagez expressément YOBULMA de toute responsabilité pénale liée au contenu du colis transporté.",
                  value: _acceptSellerPolicy1,
                  onChanged: (v) => setState(() => _acceptSellerPolicy1 = v!),
                ),
                _buildLegalBlock(
                  title: "Garantie de Transparence et Suivi",
                  text: "Bien que la plateforme ne soit pas directement responsable des actes de tiers, elle s'engage dans une démarche de responsabilité solidaire en cas d'incident. Grâce à la collecte rigoureuse de l'identité et au tracking GPS de chaque prestataire, YOBULMA garantit la transmission immédiate de toutes les preuves et informations nécessaires aux autorités compétentes pour engager des poursuites judiciaires en cas de vol ou d'infraction. Nous mettons la technologie au service de votre sécurité pour assurer la traçabilité totale de vos échanges.",
                  value: _acceptSellerPolicy2,
                  onChanged: (v) => setState(() => _acceptSellerPolicy2 = v!),
                ),
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

  // --- UI COMPONENTS (Gardés tels quels mais intégrés au nouveau flux) ---

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(gradient: _secondaryGradient, borderRadius: BorderRadius.circular(12)),
          child: const Row(
  Widget _buildProfilePicker() {
    return GestureDetector(
      onTap: () => _pickImage('profile'),
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: _inputFill,
            backgroundImage: _profilePhoto != null ? FileImage(_profilePhoto!) : null,
            child: _profilePhoto == null 
                ? const Icon(Icons.person, size: 50, color: Colors.grey) 
                : null,
          ),
          Positioned(
            bottom: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: _primaryOrange, shape: BoxShape.circle),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
            ),
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
              Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text("YOBULMA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
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
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: _secondaryBlue, size: 20),
          filled: true,
          fillColor: _inputFill,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildFilePicker(String label, IconData icon, File? file, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: _inputFill, borderRadius: BorderRadius.circular(14)),
          child: Row(
            children: [
              Icon(icon, color: _secondaryBlue),
              const SizedBox(width: 12),
              Text(file != null ? "Document chargé" : label, style: const TextStyle(fontSize: 13)),
              const Spacer(),
              Icon(file != null ? Icons.check_circle : Icons.add_a_photo, color: file != null ? _primaryOrange : Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegalBlock({required String title, required String text, required bool value, required ValueChanged<bool?> onChanged}) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: _inputFill, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _secondaryBlue)),
          const SizedBox(height: 4),
          Text(text, style: const TextStyle(fontSize: 10, color: Colors.black54)),
          Row(
            children: [
              Checkbox(value: value, onChanged: onChanged, activeColor: _secondaryBlue),
              const Text("J'accepte", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _primaryOrange)),
      ),
    );
  }

  Widget _buildSubmitButtons() {
    return Column(
      children: [
        const Text("Je suis un :", style: TextStyle(fontWeight: FontWeight.bold, color: _textPrimary)),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleRegister,
            style: ElevatedButton.styleFrom(backgroundColor: _secondaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Créer mon compte", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildRoleCard("Vendeur", Role.VENDEUR, Icons.storefront)),
            const SizedBox(width: 15),
            Expanded(child: _buildRoleCard("Livreur", Role.LIVREUR, Icons.motorcycle)),
          ],
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Annuler", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }
}

class RegistrationPendingScreen extends StatelessWidget {
  const RegistrationPendingScreen({super.key});

  Future<void> _launchWhatsApp() async {
    final Uri url = Uri.parse("https://wa.me/221778370001?text=Bonjour Yobulma, je viens de m'inscrire et je souhaite suivre la validation de mon compte.");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Erreur WhatsApp');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hourglass_top_rounded, size: 80, color: Color(0xFFEE8E42)),
            const SizedBox(height: 30),
            const Text(
              "Demande en cours de traitement",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF23529C)),
            ),
            const SizedBox(height: 20),
            const Text(
              "votre demande de création de compte est en cour de traitement vous recevrez une notification par email ou par message une fois valider",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.black87, height: 1.5),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                   Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()), 
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF23529C),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Se connecter", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 15),
            TextButton.icon(
              onPressed: _launchWhatsApp,
              icon: const Icon(Icons.chat, color: Colors.green),
              label: const Text("Contacter le support WhatsApp", style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}