import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_page.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'needBlood_page.dart';
import 'profile.dart';

class BloodDonorPage extends StatefulWidget {
  @override
  _BloodDonorPageState createState() => _BloodDonorPageState();
}

class _BloodDonorPageState extends State<BloodDonorPage> {
  List<dynamic> _bloodDonors = [];
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchBloodDonors();
  }

  Future<void> _fetchBloodDonors([String query = '']) async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.get(
      Uri.parse(
          'https://blood-donation-bd-backend.onrender.com/api/bloodDonors/all${query.isNotEmpty ? '?query=$query' : ''}'),
    );

    if (response.statusCode == 200) {
      setState(() {
        _bloodDonors = jsonDecode(response.body);
        _isLoading = false;
      });
    } else {
      // Handle the error
      print('Failed to load blood donors');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToProfile(String id) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage(userId: id)),
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
        title: Text('Blood Donors'),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                labelText: 'Search',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _fetchBloodDonors(_searchQuery);
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            _isLoading
                ? Center(
              child: CircularProgressIndicator(),
            )
                : Expanded(
              child: ListView.builder(
                itemCount: _bloodDonors.length,
                itemBuilder: (context, index) {
                  final bloodDonor = _bloodDonors[index];
                  return Card(
                    child: ListTile(
                      title: InkWell(
                        onTap: () {
                          _navigateToProfile(bloodDonor['_id']);
                        },
                        child: Text(bloodDonor['name']),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Blood Group: ${bloodDonor['blood_group']}'),
                          Text('Location: ${
                              bloodDonor['location']}'),
                          Text('Donation type: ${bloodDonor['donation_type']}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
