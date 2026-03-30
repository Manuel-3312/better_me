import 'package:flutter/material.dart';
import 'package:better_me/core/l10n/app_localizations.dart';
import '../../../profile/domain/models/profile.dart';
import '../../data/diet_repository.dart';
import '../../domain/models/diet.dart';
import 'create_diet_screen.dart';

/// Screen responsible for displaying all dietary plans associated with a specific profile.
class DietsScreen extends StatefulWidget {
  /// The active profile used to filter the diets.
  final Profile profile;

  const DietsScreen({super.key, required this.profile});

  @override
  State<DietsScreen> createState() => _DietsScreenState();
}

class _DietsScreenState extends State<DietsScreen> {
  /// Repository instance handling Diet database operations.
  final DietRepository _repository = DietRepository();

  /// Future that holds the list of diets for the active profile.
  late Future<List<Diet>> _dietsFuture;

  @override
  void initState() {
    super.initState();
    _loadDiets();
  }

  /// Initiates the database query to fetch diets associated with the current profile ID.
  void _loadDiets() {
    setState(() {
      // Ensure we only query diets belonging to the selected user
      _dietsFuture = _repository.getDietsByProfile(widget.profile.idProfile!);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Access localized strings dynamically based on the current system locale.
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          l10n.dietsTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<List<Diet>>(
        future: _dietsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noDietsMessage,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          final diets = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: diets.length,
            itemBuilder: (context, index) {
              final diet = diets[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange.withValues(alpha: 0.1),
                    child: const Icon(Icons.restaurant, color: Colors.orange),
                  ),
                  title: Text(
                    diet.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(diet.objective),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO: Navigate to diet details / days
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Wait for the result of the creation screen.
          // If true is returned, a new diet was created and we must reload the list.
          final bool? shouldRefresh = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateDietScreen(profile: widget.profile),
            ),
          );

          if (shouldRefresh == true) {
            _loadDiets();
          }
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          l10n.createDiet,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
