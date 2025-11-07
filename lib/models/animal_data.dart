import 'package:flutter/material.dart';
import 'animal_sighting_model.dart'; // Import the AnimalType enum

// Helper class to hold static data for each animal type
class AnimalData {
  final AnimalType type;
  final Color color;
  final String imagePath; // Path to the custom image asset

  const AnimalData({
    required this.type,
    required this.color,
    required this.imagePath, // Include image path in constructor
  });

  // Map of animal enums to their specific data (Image Path and Color)
  static final Map<AnimalType, AnimalData> animalMap = {
    AnimalType.leopard: const AnimalData(
      type: AnimalType.leopard,
      color: Colors.deepOrange,
      imagePath: 'lib/images/animals/Leopard.png', // Update to your file name
    ),
    AnimalType.slothBear: const AnimalData(
      type: AnimalType.slothBear,
      color: Color(0xFF5D4037), // Brown for bear
      imagePath: 'lib/images/animals/Bear.png', // Update to your file name
    ),
    AnimalType.elephant: const AnimalData(
      type: AnimalType.elephant,
      color: Colors.blueGrey,
      imagePath: 'lib/images/animals/Elephant.png', // Update to your file name
    ),
    AnimalType.deer: const AnimalData(
      type: AnimalType.deer,
      color: Color.fromRGBO(139, 195, 74, 1), // Green/Camouflage
      imagePath: 'lib/images/animals/Deer.png', // Update to your file name
    ),
    AnimalType.peacock: const AnimalData(
      type: AnimalType.peacock,
      color: Colors.teal,
      imagePath: 'lib/images/animals/Peacock.png', // Update to your file name
    ),
    AnimalType.snakes: const AnimalData(
      type: AnimalType.snakes,
      color: Colors.green,
      imagePath: 'lib/images/animals/Snake.png', // Update to your file name
    ),
    AnimalType.other: const AnimalData(
      type: AnimalType.other,
      color: Colors.grey,
      imagePath: 'lib/images/animals/Other.png', // Fallback image
    ),
  };

  static AnimalData getAnimalData(AnimalType animalType) {
    return animalMap[animalType] ?? animalMap[AnimalType.other]!;
  }
}
