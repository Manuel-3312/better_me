import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:better_me/core/l10n/app_localizations.dart';
import 'package:better_me/core/utils/dialog_helper.dart';
import 'package:better_me/core/utils/snackbar_helper.dart';
import 'package:better_me/features/profile/domain/models/profile.dart';
import 'package:better_me/features/progress/domain/models/progress_entry.dart';
import 'package:better_me/features/progress/presentation/controllers/progress_timeline_controller.dart';
import 'add_progress_screen.dart';
import 'package:better_me/core/presentation/widgets/primary_gradient_button.dart';

/// Screen responsible for displaying the user's weight and visual progress in a chronological timeline.
class ProgressTimelineScreen extends StatefulWidget {
  final Profile profile;

  const ProgressTimelineScreen({super.key, required this.profile});

  @override
  State<ProgressTimelineScreen> createState() => _ProgressTimelineScreenState();
}

class _ProgressTimelineScreenState extends State<ProgressTimelineScreen> {
  late final ProgressTimelineController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ProgressTimelineController();
    if (widget.profile.idProfile != null) {
      _controller.loadEntries(widget.profile.idProfile!);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _deleteEntry(ProgressEntry entry, int index) async {
    final l10n = AppLocalizations.of(context)!;

    final bool confirm = await DialogHelper.showDeleteConfirmation(
      context: context,
      title: l10n.deleteEntryTitle,
      content: l10n.deleteEntryContent,
      cancelText: l10n.cancel,
      deleteText: l10n.delete,
    );

    if (!confirm || entry.id == null || !mounted) return;

    _controller.removeEntryLocally(index);

    final dateFormat = DateFormat('MMM dd');
    final snackBarController = SnackbarHelper.showUndoSnackbar(
      context: context,
      message: l10n.entryDeleted(dateFormat.format(entry.date)),
      undoLabel: l10n.undo,
    );

    final reason = await snackBarController.closed;

    if (reason == SnackBarClosedReason.action) {
      _controller.restoreEntryLocally(index, entry);
    } else {
      await _controller.deleteEntryPermanently(entry.id!);
    }
  }

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
    final l10n = AppLocalizations.of(context)!;
    final primaryColor = Colors.teal;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.progressTimelineTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              _controller.isLoading
                  ? Center(
                child: CircularProgressIndicator(color: primaryColor),
              )
                  : _controller.entries.isEmpty
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
                      l10n.noProgressLogged,
                      style: TextStyle(color: theme.hintColor),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.only(top: 24, bottom: 110),
                itemCount: _controller.entries.length,
                itemBuilder: (context, index) {
                  final entry = _controller.entries[index];
                  return _buildTimelineItem(
                    entry,
                    index,
                    theme,
                    primaryColor,
                  );
                },
              ),
              _buildAddProgressButton(context, theme, primaryColor, l10n),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAddProgressButton(
      BuildContext context,
      ThemeData theme,
      Color primaryColor,
      AppLocalizations l10n,
      ) {
    final isDarkMode = theme.brightness == Brightness.dark;

    return Positioned(
      bottom: 24,
      left: 0,
      right: 0,
      child: Center(
        child: PrimaryGradientButton(
          primaryColor: primaryColor,
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    AddProgressScreen(profile: widget.profile),
              ),
            );
            if (result == true && widget.profile.idProfile != null) {
              _controller.loadEntries(widget.profile.idProfile!);
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, color: isDarkMode ? primaryColor : Colors.white),
              const SizedBox(width: 8),
              Text(
                l10n.logProgress,
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
    );
  }

  Widget _buildTimelineItem(
      ProgressEntry entry,
      int index,
      ThemeData theme,
      Color primaryColor,
      ) {
    final isLast = index == _controller.entries.length - 1;
    final dateFormat = DateFormat('MMM dd, yyyy');

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                                  color: Colors.redAccent.withValues(
                                    alpha: 0.8,
                                  ),
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

/// A stateless widget responsible for displaying an image in full screen.
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