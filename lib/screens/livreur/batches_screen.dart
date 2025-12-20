import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/batch_model.dart';
import '../../repositories/batch_repository.dart';
import '../../utils/constants.dart';
import '../../utils/enums.dart';

class LivreurBatchesScreen extends StatefulWidget {
  const LivreurBatchesScreen({super.key});

  @override
  State<LivreurBatchesScreen> createState() => _LivreurBatchesScreenState();
}

class _LivreurBatchesScreenState extends State<LivreurBatchesScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _selectedTab = 0; // 0: Disponibles, 1: Mes batches, 2: Historique
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    
    if (user == null) {
      return _buildNotLoggedIn();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tournées de livraison'),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
            tooltip: 'Rafraîchir',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              context.go('/login');
            },
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: Column(
        children: [
          // Tabs
          _buildTabs(),
          
          // Contenu
          Expanded(
            child: _buildContent(user.uid),
          ),
        ],
      ),
    );
  }

  Widget _buildNotLoggedIn() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              'Non connecté',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('Se connecter'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          _buildTabButton('Disponibles', 0),
          _buildTabButton('Mes tournées', 1),
          _buildTabButton('Historique', 2),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.primary : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(String livreurId) {
    switch (_selectedTab) {
      case 0:
        return _buildAvailableBatches(livreurId);
      case 1:
        return _buildMyBatches(livreurId);
      case 2:
        return _buildHistory(livreurId);
      default:
        return const Center(child: Text('Onglet inconnu'));
    }
  }

  Widget _buildAvailableBatches(String livreurId) {
    final batchRepo = context.watch<BatchRepository>();

    return StreamBuilder<List<BatchModel>>(
      stream: batchRepo.getAvailableBatches(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Erreur: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final batches = snapshot.data ?? [];

        if (batches.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.delivery_dining,
                  size: 80,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Aucune tournée disponible',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Les nouvelles commandes apparaîtront ici',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: batches.length,
          itemBuilder: (context, index) {
            final batch = batches[index];
            return _buildBatchCard(batch, false);
          },
        );
      },
    );
  }

  Widget _buildMyBatches(String livreurId) {
    final batchRepo = context.watch<BatchRepository>();

    return StreamBuilder<List<BatchModel>>(
      stream: batchRepo.getBatchesByLivreur(livreurId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        final batches = snapshot.data ?? [];

        // Filtrer seulement les batches non terminés
        final activeBatches = batches
            .where((batch) => batch.status != BatchStatus.completed)
            .toList();

        if (activeBatches.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 80,
                  color: Colors.green[300],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Aucune tournée en cours',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Acceptez une tournée disponible pour commencer',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: activeBatches.length,
          itemBuilder: (context, index) {
            final batch = activeBatches[index];
            return _buildBatchCard(batch, true);
          },
        );
      },
    );
  }

  Widget _buildHistory(String livreurId) {
    final batchRepo = context.watch<BatchRepository>();

    return StreamBuilder<List<BatchModel>>(
      stream: batchRepo.getBatchesByLivreur(livreurId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final batches = snapshot.data ?? [];

        // Filtrer seulement les batches terminés
        final completedBatches = batches
            .where((batch) => batch.status == BatchStatus.completed)
            .toList();

        if (completedBatches.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 80,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Aucun historique',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Vos tournées terminées apparaîtront ici',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: completedBatches.length,
          itemBuilder: (context, index) {
            final batch = completedBatches[index];
            return _buildHistoryCard(batch);
          },
        );
      },
    );
  }

  Widget _buildBatchCard(BatchModel batch, bool isMyBatch) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getStatusColor(batch.status),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getStatusText(batch.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${batch.orderIds.length} commandes',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Distance et durée estimées
            if (batch.estimatedDistance != null && batch.estimatedDuration != null)
              Row(
                children: [
                  _buildInfoItem(
                    Icons.directions,
                    '${batch.estimatedDistance!.toStringAsFixed(1)} km',
                  ),
                  const SizedBox(width: 16),
                  _buildInfoItem(
                    Icons.timer,
                    '${_formatDuration(batch.estimatedDuration!)}',
                  ),
                ],
              ),
            
            const SizedBox(height: 12),
            
            // Localisation de départ
            if (batch.startLocation != null)
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Départ: ${batch.startLocation!.latitude.toStringAsFixed(4)}, '
                      '${batch.startLocation!.longitude.toStringAsFixed(4)}',
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            
            const SizedBox(height: 16),
            
            // Boutons d'action
            if (!isMyBatch)
              _buildActionButtons(batch)
            else
              _buildMyBatchButtons(batch),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(BatchModel batch) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      color: Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Terminée',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (batch.completedAt != null)
                  Text(
                    _formatDate(batch.completedAt!),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Text(
              '${batch.orderIds.length} commandes livrées',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            
            const SizedBox(height: 8),
            
            if (batch.estimatedDistance != null)
              Text(
                'Distance: ${batch.estimatedDistance!.toStringAsFixed(1)} km',
                style: const TextStyle(color: Colors.grey),
              ),
            
            if (batch.startedAt != null && batch.completedAt != null)
              Text(
                'Durée: ${_formatDuration(batch.completedAt!.difference(batch.startedAt!).inMinutes.toDouble())}',
                style: const TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BatchModel batch) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _acceptBatch(batch.id),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: const Text('Accepter la tournée'),
      ),
    );
  }

  Widget _buildMyBatchButtons(BatchModel batch) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _viewBatchDetails(batch.id),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.primary),
            ),
            child: const Text('Détails'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _startDelivery(batch.id),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Démarrer'),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
      ],
    );
  }

  Color _getStatusColor(BatchStatus status) {
    switch (status) {
      case BatchStatus.pending:
        return Colors.orange;
      case BatchStatus.priseEnCharge:
        return Colors.blue;
      case BatchStatus.enCours:
        return Colors.green;
      case BatchStatus.completed:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(BatchStatus status) {
    switch (status) {
      case BatchStatus.pending:
        return 'EN ATTENTE';
      case BatchStatus.priseEnCharge:
        return 'PRISE EN CHARGE';
      case BatchStatus.enCours:
        return 'EN COURS';
      case BatchStatus.completed:
        return 'TERMINÉE';
      default:
        return status.name.toUpperCase();
    }
  }

  String _formatDuration(double minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${remainingMinutes.toInt()}min';
    } else {
      return '${minutes.toInt()} min';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return 'Il y a ${difference.inDays} jours';
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours} heures';
    } else if (difference.inMinutes > 0) {
      return 'Il y a ${difference.inMinutes} minutes';
    } else {
      return 'À l\'instant';
    }
  }

  Future<void> _acceptBatch(String batchId) async {
    setState(() => _isLoading = true);
    
    try {
      final batchRepo = context.read<BatchRepository>();
      final livreurId = _auth.currentUser!.uid;
      
      final success = await batchRepo.acceptBatch(
        batchId: batchId,
        livreurId: livreurId,
      );
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tournée acceptée avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de l\'acceptation'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _startDelivery(String batchId) async {
    try {
      final batchRepo = context.read<BatchRepository>();
      final success = await batchRepo.startBatchDelivery(batchId);
      
      if (success) {
        // Naviguer vers l'écran de livraison
        context.go('/livreur/tour/$batchId');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors du démarrage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _viewBatchDetails(String batchId) async {
    // Naviguer vers l'écran de détails ou la carte
    context.go('/livreur/tour/$batchId');
  }
}