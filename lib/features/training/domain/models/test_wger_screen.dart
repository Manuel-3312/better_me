import 'package:flutter/material.dart';
import '../../data/wger_repository.dart';
import '../../data/exercise_local_database.dart';
import '../../domain/models/wger_exercise.dart';

/// A testing and synchronization screen for the Wger API and local SQLite database.
class TestWgerScreen extends StatefulWidget {
  const TestWgerScreen({super.key});

  @override
  State<TestWgerScreen> createState() => _TestWgerScreenState();
}

class _TestWgerScreenState extends State<TestWgerScreen> {
  final WgerRepository _apiRepository = WgerRepository();
  final ExerciseLocalDatabase _localDb = ExerciseLocalDatabase();

  List<WgerExercise> _exercises = [];
  bool _isLoading = false;
  String? _error;
  String _statusMessage = 'Ready to load data.';

  @override
  void initState() {
    super.initState();
    _loadFromLocal();
  }

  /// Loads exercises directly from the local SQLite database.
  Future<void> _loadFromLocal() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _statusMessage = 'Loading from local database...';
    });

    try {
      final localData = await _localDb.getAllExercises();
      setState(() {
        _exercises = localData;
        _statusMessage = 'Showing ${localData.length} exercises from Local DB.';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Local DB Error: $e';
        _isLoading = false;
      });
    }
  }

  /// Fetches exercises from the API and saves them to the local database.
  Future<void> _syncFromApi(BuildContext context) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _statusMessage = 'Downloading from Wger API... This may take a moment.';
    });

    try {
      final String languageCode = Localizations.localeOf(context).languageCode;
      final int languageId = languageCode == 'es' ? 4 : 2;

      final apiData = await _apiRepository.getExercises(limit: 50, languageId: languageId);

      setState(() {
        _statusMessage = 'Saving ${apiData.length} exercises to Local DB...';
      });

      await _localDb.insertExercises(apiData);

      await _loadFromLocal();
    } catch (e) {
      setState(() {
        _error = 'API Sync Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Database Sync'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _loadFromLocal,
                  icon: const Icon(Icons.storage),
                  label: const Text('Load Local'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : () => _syncFromApi(context),
                  icon: const Icon(Icons.cloud_download),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  label: const Text('Sync API'),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              _statusMessage,
              style: TextStyle(
                color: _error != null ? Colors.red : Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const Divider(height: 32),

          if (_isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_exercises.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _exercises.length,
                itemBuilder: (context, index) {
                  final exercise = _exercises[index];
                  final cleanDescription = exercise.description
                      .replaceAll(RegExp(r'<[^>]*>'), '')
                      .trim();

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text(
                            exercise.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            cleanDescription.isNotEmpty
                                ? cleanDescription
                                : 'No description available.',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Chip(
                            label: Text(
                              exercise.categoryName,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),

                        // ACTUALIZADO: Leemos mainMuscleId en lugar de muscleImageUrl
                        if (exercise.mainMuscleId != null || exercise.exerciseImageUrl != null)
                          Container(
                            color: theme.brightness == Brightness.dark
                                ? Colors.black26
                                : Colors.grey.shade100,
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                if (exercise.mainMuscleId != null)
                                  _buildMusclePlaceholder(exercise.mainMuscleId!, 'Anatomy'),
                                if (exercise.exerciseImageUrl != null)
                                  _buildNetworkImage(exercise.exerciseImageUrl!, 'Execution'),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  /// Helper method to safely load network images with error handling.
  Widget _buildNetworkImage(String url, String label) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              url,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.broken_image,
                color: Colors.grey,
                size: 40,
              ),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ),
      ],
    );
  }

  /// En el futuro, aquí es donde usare Image.asset('assets/muscles/muscle_$id.png')
  Widget _buildMusclePlaceholder(int muscleId, String label) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Center(
            child: Text(
              'Muscle ID:\n$muscleId\n(Asset pending)',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}