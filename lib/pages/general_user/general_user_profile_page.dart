import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rootrails/utils/custom_text_field.dart';

class GeneralUserProfilePage extends StatefulWidget {
  const GeneralUserProfilePage({super.key});

  @override
  State<GeneralUserProfilePage> createState() => _GeneralUserProfilePageState();
}

class _GeneralUserProfilePageState extends State<GeneralUserProfilePage> {
  final User? firebaseUser = FirebaseAuth.instance.currentUser;
  GeneralUser? _userProfile;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  bool _isLoading = true;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    if (firebaseUser == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser!.uid)
        .get();
    if (doc.exists) {
      final user = GeneralUser.fromFirestore(doc);
      setState(() {
        _userProfile = user;
        _nameController.text = user.fullName;
        _phoneController.text = user.phoneNumber;
        _bioController.text = user.bio;
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

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser!.uid)
          .update({
            'full_name': _nameController.text.trim(),
            'phone_number': _phoneController.text.trim(),
            'bio': _bioController.text.trim(),
            'updated_at': FieldValue.serverTimestamp(),
          });

      // Update local model
      await _fetchUserProfile();

      if (mounted) {
        setState(() {
          _isEditing = false;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
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

    if (_userProfile == null) {
      return const Center(child: Text('Profile data not found.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _updateProfile();
              }
              setState(() {
                _isEditing = !_isEditing;
              });
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
              // Avatar Section
              Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(
                      _userProfile!.profileImageUrl,
                    ),
                    onBackgroundImageError: (e, s) =>
                        const Icon(Icons.person, size: 60),
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        radius: 20,
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              Text(
                _userProfile!.email,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 30),

              // Form Fields
              _isEditing
                  ? Column(
                      children: [
                        CustomTextField(
                          controller: _nameController,
                          hintText: 'Full Name',
                          validator: (v) =>
                              v!.isEmpty ? 'Name is required' : null,
                          enabled: _isEditing,
                        ),
                        const SizedBox(height: 15),
                        CustomTextField(
                          controller: _phoneController,
                          hintText: 'Phone Number',
                          keyboardType: TextInputType.phone,
                          enabled: _isEditing,
                        ),
                        const SizedBox(height: 15),
                        CustomTextField(
                          controller: _bioController,
                          hintText: 'Bio / About Me',
                          maxLines: 3,
                          enabled: _isEditing,
                        ),
                        const SizedBox(height: 30),
                        if (_isLoading)
                          const Center(child: CircularProgressIndicator()),
                      ],
                    )
                  : _buildReadOnlyFields(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailTile(
          context,
          Icons.person,
          'Full Name',
          _userProfile!.fullName,
        ),
        _buildDetailTile(
          context,
          Icons.phone,
          'Phone',
          _userProfile!.phoneNumber,
        ),
        _buildDetailTile(context, Icons.info_outline, 'Bio', _userProfile!.bio),
      ],
    );
  }

  Widget _buildDetailTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: Theme.of(context).textTheme.titleSmall),
      subtitle: Text(
        subtitle.isEmpty ? 'N/A' : subtitle,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}
