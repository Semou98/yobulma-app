import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../core/enums.dart';
import '../../data/mock_data.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  Role _selectedRole = Role.VENDEUR; // Par défaut [cite: 47]

  void _handleRegister() {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) return;

    // 1. Création de l'objet User
    final newUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      phoneNumber: _phoneController.text,
      roles: [_selectedRole],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // 2. Persistance en mémoire (Mock)
    MockData.addUser(newUser);

    // 3. Feedback et retour
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Compte créé avec succès ! Connectez-vous."),
      ),
    );
    Navigator.pop(context); // Retour au login ou welcome
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Créer un compte",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // Champ Nom
            _buildTextField(_nameController, "Nom complet", Icons.person),
            const SizedBox(height: 20),

            // Champ Téléphone
            _buildTextField(
              _phoneController,
              "Téléphone",
              Icons.phone,
              inputType: TextInputType.phone,
            ),
            const SizedBox(height: 20),

            // Sélection du Rôle (Important pour la démo)
            const Text(
              "Je suis un :",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                _roleOption("Vendeur", Role.VENDEUR),
                _roleOption("Livreur", Role.LIVREUR),
              ],
            ),
            const SizedBox(height: 40),

            // Bouton S'inscrire
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "S'inscrire",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType inputType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.black),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFF9800)),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _roleOption(String label, Role role) {
    return Expanded(
      child: RadioListTile<Role>(
        title: Text(label),
        value: role,
        groupValue: _selectedRole,
        activeColor: const Color(0xFFFF9800),
        onChanged: (val) => setState(() => _selectedRole = val!),
      ),
    );
  }
}
