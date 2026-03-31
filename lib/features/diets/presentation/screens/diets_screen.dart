import 'package:flutter/material.dart';
import 'package:better_me/core/l10n/app_localizations.dart';
import '../../../profile/domain/models/profile.dart';
import '../../data/diet_repository.dart';
import '../../domain/models/diet.dart';
import 'create_diet_screen.dart';
import 'package:better_me/features/diets/presentation/screens/diet_detail_screen.dart';

/// Screen responsible for displaying all dietary plans associated with a specific profile.
/// Refactored to support dynamic theming and high-contrast accessibility.
class DietsScreen extends StatefulWidget {
  final Profile profile;

  const DietsScreen({super.key, required this.profile});

  @override
  State<DietsScreen> createState() => _DietsScreenState();
}

class _DietsScreenState extends State<DietsScreen> {
  final DietRepository _repository = DietRepository();
  late Future<List<Diet>> _dietsFuture;

  @override
  void initState() {
    super.initState();
    _loadDiets();
  }

  void _loadDiets() {
    setState(() {
      _dietsFuture = _repository.getDietsByProfile(widget.profile.idProfile!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      // Uses the theme's background color (White/Grey or Deep Grey/Black)
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.dietsTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
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
                    // Subtle icon color that adapts to the theme
                    color: theme.hintColor.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noDietsMessage,
                    style: TextStyle(fontSize: 16, color: theme.hintColor),
                  ),
                ],
              ),
            );
          }

          final diets = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: diets.length,
            itemBuilder: (context, index) {
              final diet = diets[index];
              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                color: theme.cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  // Subtle border for definition in Dark Mode
                  side: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.restaurant,
                      color: Colors.orangeAccent,
                      size: 28,
                    ),
                  ),
                  title: Text(
                    diet.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      diet.objective,
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: theme.hintColor,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DietDetailScreen(
                          diet: diet,
                          profile: widget.profile,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
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
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        // OrangeAccent looks much better and more vivid in Night Mode
        backgroundColor: Colors.orangeAccent,
      ),
    );
  }
}