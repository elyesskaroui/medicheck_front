import 'package:flutter/material.dart';
import 'package:flutter_application_1/Home1Screen.dart';
import 'package:flutter_application_1/models/SignUpResponse.dart';
import 'package:flutter_application_1/screens/Acceuil_page.dart';
import 'package:flutter_application_1/screens/chat_screen.dart';
import 'package:flutter_application_1/screens/profile_page.dart';
import 'package:flutter_application_1/screens/search_page.dart';
import 'package:flutter_application_1/screens/settings_page.dart';

class MainScreen extends StatefulWidget {
  final bool isDarkMode;
  final User? loggedUser;
  final Function(bool) onDarkModeChanged;

  const MainScreen({
    super.key,
    required this.isDarkMode,
    required this.onDarkModeChanged,
    required this.loggedUser,
  });

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      MedInfoVerifierHome(),
      SearchPage(),
      ProfilePage(loggedUser: widget.loggedUser!),
      ChatScreen(loggedUser: widget.loggedUser!),
      SettingsPage(
        isDarkMode: widget.isDarkMode,
        onDarkModeChanged: widget.onDarkModeChanged,
        loggedUser: widget.loggedUser!
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue, // Adjust color if needed
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.meeting_room), label: 'ChatRoom'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
