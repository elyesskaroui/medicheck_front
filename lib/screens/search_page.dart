import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // To encode/decode the list

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  List<String> previousSearches = [];

  @override
  void initState() {
    super.initState();
    _loadSearchHistory(); // Load saved search history when the page loads
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Center(
            child: const Text('Search'),
          ),
          automaticallyImplyLeading: false,
          actions: [],
        ),
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              // Search Bar with Clear Button
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(Icons.search),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Rechercher des articles ...',
                          fillColor: Colors.grey[200],
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (text) {
                          setState(() {});
                        },
                        onEditingComplete: () {
                          _saveSearch(searchController.text);
                          searchController.clear();
                        },
                      ),
                    ),
                    // Clear Button next to search bar
                    TextButton(
                      onPressed: _clearSearchHistory,
                      child: const Text(
                        'Clear',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Previous Searches
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: ListView.builder(
                    itemCount: previousSearches.length,
                    itemBuilder: (context, index) => _previousSearchItem(index),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Load search history from SharedPreferences
  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedSearches = prefs.getString('previousSearches');
    
    if (savedSearches != null) {
      setState(() {
        previousSearches = List<String>.from(jsonDecode(savedSearches));
      });
    }
  }

  // Save search to history in SharedPreferences
  Future<void> _saveSearch(String query) async {
    if (query.isNotEmpty) {
      setState(() {
        previousSearches.insert(0, query);
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('previousSearches', jsonEncode(previousSearches));
    }
  }

  // Clear search history in SharedPreferences
  Future<void> _clearSearchHistory() async {
    setState(() {
      previousSearches.clear();
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('previousSearches');
  }

  // Display previous search items
  Widget _previousSearchItem(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: InkWell(
        onTap: () {},
        child: Dismissible(
          key: Key(previousSearches[index]),
          onDismissed: (DismissDirection direction) {
            setState(() {
              previousSearches.removeAt(index);
            });

            final prefs = SharedPreferences.getInstance();
            prefs.then((value) {
              value.setString('previousSearches', jsonEncode(previousSearches));
            });
          },
          child: Row(
            children: [
              const Icon(
                IconlyLight.time_circle,
                color: Colors.grey,
              ),
              const SizedBox(width: 10),
              Text(
                previousSearches[index],
                style: const TextStyle(color: Colors.black),
              ),
              const Spacer(),
              const Icon(
                Icons.call_made_outlined,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
