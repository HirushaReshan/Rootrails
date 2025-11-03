import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rootrails/models/business.dart';
import 'package:rootrails/utils/custom_text_field.dart';
import 'package:rootrails/models/park.dart';

class BusinessProfilePage extends StatefulWidget {
  const BusinessProfilePage({super.key});

  @override
  State<BusinessProfilePage> createState() => _BusinessProfilePageState();
}

class _BusinessProfilePageState extends State<BusinessProfilePage> {
  final User? firebaseUser = FirebaseAuth.instance.currentUser;
  Business? _businessProfile;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  // For the park dropdown
  String? _selectedParkId;
  List<Park> _parksList = [];
  bool _isParkLoading = true;

  bool _isLoading = true;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _fetchBusinessProfile();
    _fetchParks();
  }

  Future<void> _fetchParks() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('parks')
          .get();
      _parksList = snapshot.docs.map((doc) => Park.fromFirestore(doc)).toList();
      setState(() {
        _isParkLoading = false;
      });
    } catch (e) {
      setState(() {
        _isParkLoading = false;
      });
      print("Error fetching parks: $e");
    }
  }

  Future<void> _fetchBusinessProfile() async {
    if (firebaseUser == null) return;

    //Get from 'drivers' collection
    final doc = await FirebaseFirestore.instance
        .collection('drivers') 
        .doc(firebaseUser!.uid)
        .get();
    if (doc.exists) {
      final business = Business.fromFirestore(doc);
      setState(() {
        _businessProfile = business;
        _nameController.text = business.businessName;
        _descriptionController.text = business.businessDescription;
        _priceController.text = business.pricePerSafari.toStringAsFixed(2);
        _locationController.text = business.locationInfo;
        _selectedParkId = business.parkId;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate() || firebaseUser == null) return;

    if (_selectedParkId == null || _selectedParkId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a park.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('drivers')
          .doc(firebaseUser!.uid)
          .update({
            'business_name': _nameController.text.trim(),
            'business_description': _descriptionController.text.trim(),
            'price_per_safari': double.parse(_priceController.text.trim()),
            'location_info': _locationController.text.trim(),
            'park_id': _selectedParkId,
            'updated_at': FieldValue.serverTimestamp(),
          });

      await _fetchBusinessProfile();

      if (mounted) {
        setState(() {
          _isEditing = false;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_businessProfile == null) {
      return const Center(
        child: Text(
          'Service data not found. Please re-register or contact support.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Service Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _updateProfile();
              } else {
                setState(() {
                  _isEditing = !_isEditing;
                });
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      _businessProfile!.businessImageUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: FloatingActionButton(
                        mini: true,
                        onPressed: () {
                          /* TODO: Image upload logic */
                        },
                        child: const Icon(Icons.photo_camera),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              Text(
                'Status: ${_businessProfile!.isOpen ? 'ONLINE' : 'OFFLINE'}',
                style: TextStyle(
                  color: _businessProfile!.isOpen ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(height: 40),

              CustomTextField(
                controller: _nameController,
                hintText: 'Business Name',
                validator: (v) => v!.isEmpty ? 'Name is required' : null,
                enabled: _isEditing,
              ),
              const SizedBox(height: 15),

              _isParkLoading
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                      value: _selectedParkId,
                      hint: const Text('Select Your Park'),
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.park),
                      ),
                      items: _parksList.map((Park park) {
                        return DropdownMenuItem<String>(
                          value: park.id,
                          child: Text(park.name),
                        );
                      }).toList(),
                      onChanged: _isEditing
                          ? (String? newValue) {
                              setState(() {
                                _selectedParkId = newValue;
                              });
                            }
                          : null,
                      validator: (value) =>
                          value == null ? 'Park is required' : null,
                    ),
              const SizedBox(height: 15),

              CustomTextField(
                controller: _locationController,
                hintText: 'Primary Pickup Location',
                enabled: _isEditing,
              ),
              const SizedBox(height: 15),
              CustomTextField(
                controller: _priceController,
                hintText: 'Price per Safari (\$)',
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty || double.tryParse(v) == null
                    ? 'Enter a valid price'
                    : null,
                enabled: _isEditing,
              ),
              const SizedBox(height: 15),
              CustomTextField(
                controller: _descriptionController,
                hintText: 'Full Service Description (Publicly visible)',
                maxLines: 5,
                enabled: _isEditing,
              ),
              const SizedBox(height: 30),
              if (_isLoading) const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}
