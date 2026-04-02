import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:better_me/features/profile/domain/models/profile.dart';
import 'package:better_me/features/progress/data/progress_repository.dart';
import 'package:better_me/features/progress/domain/models/progress_entry.dart';
import 'add_progress_screen.dart';

/// Screen displaying the user's weight and visual progress in a chronological timeline.
class ProgressTimelineScreen extends StatefulWidget {
  final Profile profile;

  const ProgressTimelineScreen({super.key, required this.profile});

  @override
  State<ProgressTimelineScreen> createState() => _ProgressTimelineScreenState();
}

class _ProgressTimelineScreenState extends State<ProgressTimelineScreen> {
  final ProgressRepository _repository = ProgressRepository();
  List<ProgressEntry> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    if (widget.profile.idProfile == null) return;

    setState(() => _isLoading = true);
    try {
      final entries = await _repository.getProgressEntries(
        widget.profile.idProfile!,
      );
      if (mounted) {
        setState(() {
          _entries = entries;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading progress entries: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Handles the deletion of an entry with an Undo option via SnackBar.
  Future<void> _deleteEntry(ProgressEntry entry, int index) async {
    // 1. Ask for confirmation first
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Entry',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to delete this progress log?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true || entry.id == null) return;

    // 2. Optimistic update: remove from UI immediately
    setState(() {
      _entries.removeAt(index);
    });

    if (!mounted) return;
    final dateFormat = DateFormat('MMM dd');

    // 3. Show SnackBar with Undo action
    final snackBarController = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Entry from ${dateFormat.format(entry.date)} deleted'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Colors.tealAccent,
          onPressed: () {
            // Handled by logic below when closed with action
          },
        ),
        duration: const Duration(seconds: 4),
      ),
    );

    // 4. Wait for SnackBar to close to decide whether to delete permanently
    final reason = await snackBarController.closed;

    if (reason == SnackBarClosedReason.action) {
      // User pressed UNDO, restore the item in UI
      if (mounted) {
        setState(() {
          _entries.insert(index, entry);
        });
      }
    } else {
      // SnackBar timed out or closed otherwise, perform permanent deletion
      try {
        await _repository.deleteProgressEntry(entry.id!);
      } catch (e) {
        debugPrint('Error deleting entry from DB: $e');
        // If DB deletion fails, restore UI and show error
        _loadEntries();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete entry from database.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  /// Opens the photo in a full-screen view.
  void _openFullScreenImage(String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImageViewer(imagePath: imagePath),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final primaryColor = Colors.teal; // Matching the Profile banner color

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Progress Timeline',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Stack(
        children: [
          _isLoading
              ? Center(child: CircularProgressIndicator(color: primaryColor))
              : _entries.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.timeline,
                  size: 80,
                  color: theme.hintColor.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No progress logged yet.',
                  style: TextStyle(color: theme.hintColor),
                ),
              ],
            ),
          )
              : ListView.builder(
            // Top padding for the line, bottom padding for the button
            padding: const EdgeInsets.only(top: 24, bottom: 110),
            itemCount: _entries.length,
            itemBuilder: (context, index) {
              final entry = _entries[index];
              return _buildTimelineItem(
                entry,
                index,
                theme,
                primaryColor,
              );
            },
          ),
          _buildAddProgressButton(context, theme, primaryColor, isDarkMode),
        ],
      ),
    );
  }

  /// Replicates the modern gradient button design from Diets/Training screens.
  Widget _buildAddProgressButton(
      BuildContext context,
      ThemeData theme,
      Color primaryColor,
      bool isDarkMode,
      ) {
    return Positioned(
      bottom: 24,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDarkMode
                  ? [
                theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.8,
                ),
                theme.colorScheme.surface.withValues(alpha: 0.9),
              ]
                  : [primaryColor, primaryColor.withValues(alpha: 0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: isDarkMode
                ? Border.all(color: primaryColor.withValues(alpha: 0.3))
                : null,
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddProgressScreen(
                      profile: widget.profile,
                    ),
                  ),
                );
                if (result == true) _loadEntries();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add,
                      color: isDarkMode ? primaryColor : Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Log Progress',
                      style: TextStyle(
                        color: isDarkMode ? primaryColor : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
      ProgressEntry entry,
      int index,
      ThemeData theme,
      Color primaryColor,
      ) {
    final isLast = index == _entries.length - 1;
    final dateFormat = DateFormat('MMM dd, yyyy');

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline indicator column
          SizedBox(
            width: 60,
            child: Column(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.scaffoldBackgroundColor,
                      width: 3,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: primaryColor.withValues(alpha: 0.3),
                    ),
                  ),
              ],
            ),
          ),
          // Content card column
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32.0, right: 16.0),
              child: Card(
                elevation: 0,
                color: theme.cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.1),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dateFormat.format(entry.date),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '${entry.weight} kg',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: primaryColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => _deleteEntry(entry, index),
                                child: Icon(
                                  Icons.delete_outline,
                                  size: 20,
                                  color: Colors.redAccent.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (entry.photoPaths.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: entry.photoPaths.length,
                            itemBuilder: (context, photoIndex) {
                              final imagePath = entry.photoPaths[photoIndex];
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: GestureDetector(
                                  onTap: () => _openFullScreenImage(imagePath),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      File(imagePath),
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple stateless widget to display an image in full screen.
class FullScreenImageViewer extends StatelessWidget {
  final String imagePath;

  const FullScreenImageViewer({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: const CloseButton(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 4,
          child: Image.file(
            File(imagePath),
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  }
}