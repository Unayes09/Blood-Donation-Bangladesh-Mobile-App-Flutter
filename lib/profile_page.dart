import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_page.dart'; // Import your LoginPage widget here
import 'home_page.dart'; // Import your HomePage widget here
import 'profile_page.dart'; // Import your ProfilePage widget here
import 'needBlood_page.dart';
import 'donateBlood_page.dart';
import 'profile.dart';

class ProfilePage extends StatefulWidget {
  final String userId;

  ProfilePage({required this.userId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> _userData = {};

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final response = await http.get(
      Uri.parse(
          'https://blood-donation-bd-backend.onrender.com/api/bloodDonors/${widget.userId}'),
    );

    if (response.statusCode == 200) {
      setState(() {
        _userData = jsonDecode(response.body);
      });
    } else {
      // Handle the error
      print('Failed to load user data');
    }
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.red,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.red,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/Blood.jpg',
                    width: 100,
                    height: 80,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Blood Donation Bangladesh',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.bloodtype),
              title: Text('Need Blood?'),
              onTap: () {
                // Handle Need Blood option
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => NeedBloodPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.volunteer_activism),
              title: Text('Donate Blood?'),
              onTap: () {
                // Handle Donate Blood option
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => BloodDonorPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                // Handle Profile option
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => UserProfilePage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Log out'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: Center(
        child: Card(
          margin: EdgeInsets.all(16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 8.0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Text(
                    'Profile Information',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
                Divider(color: Colors.red),
                SizedBox(height: 10),
                _buildProfileRow('Name:', _userData['name']),
                _buildProfileRow('Age:', _userData['age']),
                _buildProfileRow('Location:', _userData['location']),
                _buildProfileRow('Blood Group:', _userData['blood_group']),
                _buildProfileRow('Contact No:', _userData['contact_no']),
                _buildProfileRow('Profession:', _userData['profession']),
                _buildProfileRow('Email:', _userData['email']),
                _buildProfileRow('Donation Type:', _userData['donation_type']),
                _buildProfileRow('Disease:', _userData['disease']),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          Flexible(
            child: Text(
              value != null ? value.toString() : 'N/A',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
