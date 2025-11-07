import 'package:flutter/material.dart';
// NOTE: Make sure these paths are correct in your project
import 'package:rootrails/widgets/custom_form_feild.dart';
import '../models/animal_sighting_model.dart';
import '../models/animal_data.dart'; // NEW: Import AnimalData for color mapping
import 'animal_card.dart';

class ReportSightingModal extends StatefulWidget {
  // Use AnimalType directly, not as a nullable parameter in the callback
  final Function(AnimalType, String?, bool) onReportConfirmed;

  const ReportSightingModal({super.key, required this.onReportConfirmed});

  @override
  State<ReportSightingModal> createState() => _ReportSightingModalState();
}

class _ReportSightingModalState extends State<ReportSightingModal> {
  // Initialize with a default animal type to ensure the button is enabled initially
  AnimalType _selectedAnimal = AnimalType.leopard;
  final TextEditingController _noteController = TextEditingController();
  bool _isInjured = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  // Helper to get the color for the confirm button
  Color _getConfirmColor(BuildContext context) {
    if (_selectedAnimal == null) {
      return Theme.of(context).colorScheme.primary;
    }
    // Use the color mapped to the currently selected animal
    return AnimalData.getAnimalData(_selectedAnimal!).color;
  }

  @override
  Widget build(BuildContext context) {
    final confirmColor = _getConfirmColor(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Report Animal Sighting',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // --- Animal Grid Selection ---
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.0,
              ),
              itemCount: AnimalType.values.length,
              itemBuilder: (context, index) {
                final animal = AnimalType.values[index];

                // Exclude 'other' if you don't want it explicitly selectable
                // if (animal == AnimalType.other) return const SizedBox.shrink();

                return AnimalCard(
                  animalType: animal,
                  isSelected: _selectedAnimal == animal,
                  onTap: () {
                    setState(() {
                      _selectedAnimal = animal;
                    });
                  },
                  // Pass the animal's unique color to the AnimalCard if needed for styling
                  // cardColor: AnimalData.getAnimalData(animal).color,
                );
              },
            ),
            const SizedBox(height: 20),

            // --- Note Field ---
            CustomFormField(
              controller: _noteController,
              labelText: 'Add a note (Optional)',
              icon: Icons.notes,
              maxLines: 3,
            ),
            const SizedBox(height: 10),

            // --- INJURED STATUS TOGGLE CARD (The required improvement) ---
            GestureDetector(
              onTap: () {
                setState(() {
                  _isInjured = !_isInjured;
                });
              },
              child: Card(
                elevation: _isInjured ? 4 : 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: _isInjured
                        ? Colors.red.shade700
                        : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                color: _isInjured ? Colors.red.shade100 : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15.0,
                    horizontal: 20.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Is the animal injured?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: _isInjured
                              ? Colors.red.shade900
                              : Colors.black87,
                        ),
                      ),
                      Icon(
                        _isInjured ? Icons.healing : Icons.favorite_border,
                        color: _isInjured ? Colors.red.shade900 : Colors.grey,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- Action Buttons ---
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _selectedAnimal == null
                        ? null
                        : () {
                            widget.onReportConfirmed(
                              _selectedAnimal!,
                              _noteController.text.isNotEmpty
                                  ? _noteController.text
                                  : null,
                              _isInjured,
                            );
                            Navigator.pop(context);
                          },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Confirm'),
                    style: ElevatedButton.styleFrom(
                      // Use the selected animal's color
                      backgroundColor: confirmColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
