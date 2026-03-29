import 'package:flutter/material.dart';
import 'package:better_me/core/l10n/app_localizations.dart';
import '../../domain/models/profile.dart';
import '../../data/profile_repository.dart';
import 'create_profile_screen.dart';

/// Screen responsible for displaying a list of previously created profiles.
/// It acts as the gateway to the main application dashboard.
class ChooseProfileScreen extends StatefulWidget {
  const ChooseProfileScreen({super.key});

  @override
  State<ChooseProfileScreen> createState() => _ChooseProfileScreenState();
}

class _ChooseProfileScreenState extends State<ChooseProfileScreen> {
  /// Repository instance handling SQLite database operations.
  final ProfileRepository _repository = ProfileRepository();

  /// Future that holds the list of profiles fetched from the local database.
  late Future<List<Profile>> _profilesFuture;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  /// Initiates the asynchronous request to fetch all profiles from the database
  /// and updates the UI state.
  void _loadProfiles() {
    setState(() {
      _profilesFuture = _repository.getAllProfiles();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Access localized strings dynamically based on the current system locale.
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            l10n.chooseProfileTitle,
            style: const TextStyle(fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
      ),
      // FutureBuilder constructs the UI based on the database query state
      body: FutureBuilder<List<Profile>>(
        future: _profilesFuture,
        builder: (context, snapshot) {
          // Display a loading indicator while data is being fetched
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Handle potential database errors gracefully
          else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          // Display a placeholder message if the database yields no profiles
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                l10n.noProfilesMessage,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          // Render the list of profiles once data is successfully retrieved
          final profiles = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: profiles.length,
            itemBuilder: (context, index) {
              final profile = profiles[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(
                      profile.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
                  ),
                  subtitle: Text('${profile.weight} kg - ${profile.height} cm'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO: Implement navigation to the main dashboard (Workouts / Diets)

                    // Display localized confirmation message with dynamic parameter
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.profileSelected(profile.name))),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      // Floating Action Button to navigate to the profile creation flow
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Await the return from the CreateProfileScreen to refresh the list
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateProfileScreen()),
          );
          // Reload profiles from the database to reflect newly added data
          _loadProfiles();
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
            l10n.createProfileButton,
            style: const TextStyle(color: Colors.white)
        ),
        backgroundColor: Colors.green,
      ),
    );
  }
}