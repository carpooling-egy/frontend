import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/profile_provider.dart';
import 'package:frontend/models/profile.dart';
import '../widgets/profile_image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch profiles when the screen loads
    Future.microtask(() => 
      context.read<ProfileProvider>().fetchAllProfiles()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profiles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showProfileForm(context),
          ),
        ],
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Text(
                'Error: ${provider.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (provider.profiles.isEmpty) {
            return const Center(
              child: Text('No profiles found'),
            );
          }

          return ListView.builder(
            itemCount: provider.profiles.length,
            itemBuilder: (context, index) {
              final profile = provider.profiles[index];
              return ProfileCard(
                profile: profile,
                onEdit: () => _showProfileForm(context, profile: profile),
                onDelete: () => _deleteProfile(context, profile),
              );
            },
          );
        },
      ),
    );
  }

  void _showProfileForm(BuildContext context, {Profile? profile}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ProfileForm(profile: profile),
    );
  }

  Future<void> _deleteProfile(BuildContext context, Profile profile) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Profile'),
        content: Text('Are you sure you want to delete ${profile.firstName}\'s profile?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await context.read<ProfileProvider>().deleteProfile(profile.userId);
    }
  }
}

class ProfileCard extends StatelessWidget {
  final Profile profile;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProfileCard({
    Key? key,
    required this.profile,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: profile.imageUrl != null
              ? NetworkImage(profile.imageUrl!)
              : null,
          child: profile.imageUrl == null
              ? Text(profile.firstName[0])
              : null,
        ),
        title: Text('${profile.firstName} ${profile.lastName}'),
        subtitle: Text(profile.email),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileForm extends StatefulWidget {
  final Profile? profile;

  const ProfileForm({Key? key, this.profile}) : super(key: key);

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  String _gender = 'MALE';

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.profile?.firstName);
    _lastNameController = TextEditingController(text: widget.profile?.lastName);
    _emailController = TextEditingController(text: widget.profile?.email);
    _phoneController = TextEditingController(text: widget.profile?.phoneNumber);
    _gender = widget.profile?.gender ?? 'MALE';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.profile == null ? 'Create Profile' : 'Edit Profile',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _firstNameController,
              decoration: const InputDecoration(labelText: 'First Name'),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'First name is required' : null,
            ),
            TextFormField(
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: 'Last Name'),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Last name is required' : null,
            ),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Email is required' : null,
            ),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Phone number is required' : null,
            ),
            DropdownButtonFormField<String>(
              value: _gender,
              decoration: const InputDecoration(labelText: 'Gender'),
              items: ['MALE', 'FEMALE', 'OTHER']
                  .map((gender) => DropdownMenuItem(
                        value: gender,
                        child: Text(gender),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _gender = value);
                }
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  final provider = context.read<ProfileProvider>();
                  try {
                    if (widget.profile == null) {
                      await provider.createProfile(
                        userId: FirebaseAuth.instance.currentUser!.uid,
                        firstName: _firstNameController.text,
                        lastName: _lastNameController.text,
                        email: _emailController.text,
                        phoneNumber: _phoneController.text,
                        gender: _gender,
                      );
                    } else {
                      await provider.updateProfile(
                        userId: widget.profile!.userId,
                        firstName: _firstNameController.text,
                        lastName: _lastNameController.text,
                        email: _emailController.text,
                        phoneNumber: _phoneController.text,
                        gender: _gender,
                      );
                    }
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile saved successfully')),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${e.toString()}')),
                      );
                    }
                  }
                }
              },
              child: Text(widget.profile == null ? 'Create' : 'Update'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
} 