import 'package:flutter/material.dart';
import '../models/animal_sighting_model.dart'; // Import the enum
import '../models/animal_data.dart'; // Needed for imagePath and color

class AnimalCard extends StatelessWidget {
  final AnimalType animalType;
  final bool isSelected;
  final VoidCallback onTap;

  const AnimalCard({
    super.key,
    required this.animalType,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Get the AnimalData object to access custom assets and colors
    final animalData = AnimalData.getAnimalData(animalType);

    // 2. Define colors based on selection state and animal data
    final cardColor = isSelected
        ? animalData.color.withOpacity(0.9) // Use animal's color when selected
        : Theme.of(context).cardTheme.color;

    final contentColor = isSelected
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: cardColor,
        elevation: isSelected ? 8 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: isSelected
              ? const BorderSide(
                  color: Colors.white, // Use white border for contrast
                  width: 3,
                )
              : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // CRITICAL FIX: The 'color' property is REMOVED below.
              Image.asset(
                animalData.imagePath, // Use the custom image path
                height: 40,
                width: 40,
                fit: BoxFit.contain,
                // The 'color: isSelected ? Colors.white : null' line is removed.
              ),
              const SizedBox(height: 8),
              Text(
                animalType.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: contentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
