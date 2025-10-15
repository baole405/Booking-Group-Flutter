import 'package:booking_group_flutter/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _firstNameController =
      TextEditingController(text: 'Benjamin');
  final TextEditingController _lastNameController =
      TextEditingController(text: 'Jack');
  final TextEditingController _emailController =
      TextEditingController(text: 'gmail@gmail.com');
  final TextEditingController _phoneController =
      TextEditingController(text: '+100******00');

  bool _isEditing = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveChanges() {
    FocusScope.of(context).unfocus();
    setState(() {
      _isEditing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.of(context).maybePop();
          },
        ),
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _toggleEditing,
            child: Text(
              _isEditing ? 'Cancel' : 'Edit',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            const SizedBox(height: 12),
            _Avatar(isEditing: _isEditing),
            const SizedBox(height: 16),
            Text(
              '${_firstNameController.text} ${_lastNameController.text}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 32),
            _ProfileTextField(
              label: 'First name',
              controller: _firstNameController,
              enabled: _isEditing,
            ),
            const SizedBox(height: 16),
            _ProfileTextField(
              label: 'Last name',
              controller: _lastNameController,
              enabled: _isEditing,
            ),
            const SizedBox(height: 16),
            _ProfileTextField(
              label: 'Email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              enabled: _isEditing,
            ),
            const SizedBox(height: 16),
            _ProfileTextField(
              label: 'Phone number',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              enabled: _isEditing,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isEditing ? _saveChanges : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryDark,
                disabledBackgroundColor: Colors.grey.shade300,
                disabledForegroundColor: Colors.grey.shade600,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              child: const Text('Save Change'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.isEditing});

  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 48,
          backgroundColor: Colors.grey.shade200,
          child: Icon(
            Icons.person,
            size: 48,
            color: Colors.grey.shade600,
          ),
        ),
        Positioned(
          bottom: 4,
          right: 12,
          child: Container(
            height: 34,
            width: 34,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryDark,
            ),
            child: Icon(
              isEditing ? Icons.edit : Icons.lock,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  const _ProfileTextField({
    required this.label,
    required this.controller,
    required this.enabled,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final bool enabled;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: !enabled,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? Colors.grey.shade100 : Colors.grey.shade200,
          ),
        ),
      ],
    );
  }
}
