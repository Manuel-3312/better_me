import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Reusable UI component that renders a layered anatomical SVG.
class MuscleAnatomyWidget extends StatelessWidget {
  final int primaryMuscleId;
  final List<int> secondaryMuscleIds;
  final bool isFront;
  final Color highlightColor;
  final double size;

  const MuscleAnatomyWidget({
    super.key,
    required this.primaryMuscleId,
    this.secondaryMuscleIds = const [],
    this.isFront = true,
    this.highlightColor = Colors.cyanAccent,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    final String baseAsset = isFront
        ? 'assets/images/muscles/front.svg'
        : 'assets/images/muscles/back.svg';

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final Color bodyColor = isDarkMode ? Colors.white24 : Colors.black12;
    final Color secondaryColor = highlightColor.withValues(alpha: 0.4);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'ANATOMY',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: size,
          width: size,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.1),
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              SvgPicture.asset(
                baseAsset,
                colorFilter: ColorFilter.mode(bodyColor, BlendMode.srcIn),
              ),
              ...secondaryMuscleIds.map((id) => SvgPicture.asset(
                'assets/images/muscles/muscle-$id.svg',
                colorFilter: ColorFilter.mode(secondaryColor, BlendMode.srcIn),
              )),
              SvgPicture.asset(
                'assets/images/muscles/muscle-$primaryMuscleId.svg',
                colorFilter: ColorFilter.mode(highlightColor, BlendMode.srcIn),
              ),
            ],
          ),
        ),
      ],
    );
  }
}