import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/SignUpResponse.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  final User loggedUser;
  const ProfilePage({super.key, required this.loggedUser});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  File? _selectedImage;
  bool _isUpdating = false;
  late User currentUser;

  @override
  void initState() {
    super.initState();
    // Create a copy of the user data to work with
    currentUser = User(
      id: widget.loggedUser.id,
      name: widget.loggedUser.name,
      email: widget.loggedUser.email,
      profilePicture: widget.loggedUser.profilePicture,
    );
    
    _nameController.text = currentUser.name;
    _emailController.text = currentUser.email;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_isUpdating) return;
    setState(() {
      _isUpdating = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      // Convert File to MultipartFile
      MultipartFile? multipartImage;
      if (_selectedImage != null) {
        multipartImage = await MultipartFile.fromFile(_selectedImage!.path,
            filename: _selectedImage!.path.split('/').last);
      }

      // Make API call
      final response = await ApiService().editProfile(
        name: _nameController.text,
        email: _emailController.text,
        oldPassword: _oldPasswordController.text.isEmpty
            ? null
            : _oldPasswordController.text,
        newPassword: _newPasswordController.text.isEmpty
            ? null
            : _newPasswordController.text,
        profilePicture: multipartImage, 
        token: token,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(response['message'] ?? 'Profile updated successfully!')),
      );

      // Update the current user data
      setState(() {
        currentUser = User(
          id: currentUser.id,
          name: _nameController.text,
          email: currentUser.email,
          profilePicture: response['user'] != null && response['user']['profilePicture'] != null
              ? response['user']['profilePicture']
              : currentUser.profilePicture,
        );
      });

      // Clear password fields after successful update
      _oldPasswordController.clear();
      _newPasswordController.clear();
      
      if (Navigator.canPop(context)) {
        Navigator.pop(context); // Close dialog if open
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : currentUser.profilePicture == null
                            ? const AssetImage('asset/images/profile.png')
                                as ImageProvider<Object>?
                            : NetworkImage(ApiService.imageProfileLink(
                                    currentUser.profilePicture!))
                                as ImageProvider<Object>?,
                    backgroundColor: Colors.transparent,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              currentUser.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            _buildSectionTitle('Personal Information'),
            _buildEditableField('Name', currentUser.name),
            _buildEditableField('Email', currentUser.email),
            _buildEditableField('Password', '********'),
            const SizedBox(height: 20),
            _buildSectionTitle('Security'),
            _buildActionItem('Two-step verification'),
            const SizedBox(height: 20),
            _buildSectionTitle('Activity History'),
            _buildActionItem('Last sign in', subtitle: 'Dec 14, 2021'),
            _buildActionItem('Last password change', subtitle: 'Jan 2, 2022'),
            const SizedBox(height: 30),
            _isUpdating
                ? const CircularProgressIndicator()
                : TextButton(
                    onPressed: _logout,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 12),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    Navigator.pushReplacementNamed(context, '/signin');
  }

  void _showEditDialog(String field) {
    TextEditingController controllerToUse;
    
    if (field == 'Name') {
      controllerToUse = _nameController;
    } else if (field == 'Email') {
      controllerToUse = _emailController;
    } else {
      // Password field
      controllerToUse = _oldPasswordController;
    }
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit $field'),
          content: TextField(
            controller: controllerToUse,
            obscureText: field == 'Password',
            decoration: InputDecoration(
              labelText: field,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (field == 'Password') {
                  Navigator.pop(context);
                  _showConfirmPasswordDialog();
                } else {
                  _updateProfile();
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showConfirmPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm New Password'),
          content: TextField(
            controller: _newPasswordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'New Password'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _updateProfile();
                Navigator.pop(context);
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildEditableField(String label, String value) {
    return ListTile(
      title:
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      subtitle: Text(value, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.edit, color: Colors.grey),
      onTap: () => _showEditDialog(label),
    );
  }

  Widget _buildActionItem(String title, {String? subtitle}) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 16)),
      subtitle: subtitle != null
          ? Text(subtitle,
              style: const TextStyle(fontSize: 14, color: Colors.grey))
          : null,
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {
        // Implement navigation
      },
    );
  }
}