import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'donateBlood_page.dart';
import 'home_page.dart';
import 'needBlood_page.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  Map<String, dynamic> _userData = {};
  String userId = '';

  @override
  void initState() {
    super.initState();
    _fetchUserId();
  }

  Future<void> _fetchUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId') ?? '';
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final response = await http.get(
      Uri.parse('https://blood-donation-bd-backend.onrender.com/api/bloodDonors/$userId'),
    );

    if (response.statusCode == 200) {
      setState(() {
        _userData = jsonDecode(response.body);
      });
    } else {
      print('Failed to load user data');
    }
  }

  Future<void> _updateUserData(String field, String value) async {
    final response = await http.put(
      Uri.parse('https://blood-donation-bd-backend.onrender.com/api/bloodDonors/updateProfile'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'userId': userId,
        field: value,
      }),
    );

    if (response.statusCode == 200) {
      _fetchUserData();
    } else {
      print('Failed to update user data');
    }
  }

  void _showEditDialog(String field, String currentValue) {
    final TextEditingController _controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $field'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(labelText: field),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Save'),
              onPressed: () {
                Navigator.of(context).pop();
                _updateUserData(field, _controller.text);
              },
            ),
          ],
        );
      },
    );
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
        title: Text('My Profile'),
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
        child: SingleChildScrollView(
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
                  _buildProfileRow('Name', _userData['name']),
                  _buildProfileRow('Age', _userData['age']),
                  _buildProfileRow('Location', _userData['location']),
                  _buildProfileRow('Blood Group', _userData['blood_group']),
                  _buildProfileRow('Contact No', _userData['contact_no']),
                  _buildProfileRow('Profession', _userData['profession']),
                  _buildProfileRow('Email', _userData['email']),
                  _buildProfileRow('Donation Type', _userData['donation_type']),
                  _buildProfileRow('Disease', _userData['disease']),
                  _buildProfileRow('Password', '******', isPassword: true),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileRow(String label, dynamic value, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            '$label:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    value != null ? value.toString() : 'N/A',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.red),
                  onPressed: () {
                    _showEditDialog(label.toLowerCase(), value.toString());
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
