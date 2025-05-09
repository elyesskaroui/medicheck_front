import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/SignUpResponse.dart';

class SettingsPage extends StatelessWidget {
  final bool isDarkMode;
  final Function(bool) onDarkModeChanged;
  late final User loggedUser;

  SettingsPage(
      {super.key,
      required this.isDarkMode,
      required this.onDarkModeChanged,
      required this.loggedUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removes the default back button
        title: const Text('Settings'), // Title of the AppBar
        backgroundColor: Colors.white, // Sets the background color to white
        elevation: 0, // Removes the shadow/elevation beneath the AppBar
        iconTheme: const IconThemeData(
            color: Colors
                .black), // Sets the color of the icons (e.g., menu or other icons)
        centerTitle: true, // Centers the title in the AppBar
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSwitchTile("Dark Mode", isDarkMode, onDarkModeChanged),
          const SizedBox(height: 20),
          _buildSectionTitle("Account"),
          _buildNavigationTile("Profile"),
          _buildInfoTile("Phone Number", "-- --- ---"),
          _buildInfoTile(
            "Email Address",loggedUser.email,
          ),
          const SizedBox(height: 20),
          _buildSectionTitle("Notifications"),
          _buildNavigationTile("In-app notifications"),
          _buildNavigationTile("Push notifications"),
          const SizedBox(height: 20),
          _buildSectionTitle("Support"),
          _buildNavigationTile("Help Center"),
          _buildNavigationTile("Terms of Service"),
          _buildNavigationTile("Privacy Policy"),
          _buildNavigationTile("Accessibility"),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildNavigationTile(String title) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {},
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      trailing: Text(value, style: const TextStyle(color: Colors.grey)),
    );
  }

  Widget _buildSwitchTile(
      String title, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ElevatedButton(
          onPressed: () {
            onChanged(!value);
          },
          child: Text(
            value ? "OFF" : "ON",
            style: TextStyle(color: value ? Colors.white : Colors.grey),
          ),
        ),
      ],
    );
  }
}
