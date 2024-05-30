import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'login_page.dart';
import 'home_page.dart';
import 'donateBlood_page.dart';
import 'profile.dart';

class NeedBloodPage extends StatefulWidget {
  @override
  _NeedBloodPageState createState() => _NeedBloodPageState();
}

class _NeedBloodPageState extends State<NeedBloodPage> {
  List<dynamic> _bloodNeeders = [];
  String _searchQuery = '';
  String userId = '';
  bool _isLoading = false;
  final TextEditingController _bloodGroupController = TextEditingController();
  final TextEditingController _bloodNeedingTimeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _amountOfBagNeededController = TextEditingController();
  final TextEditingController _contactNoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId') ?? '';
    });
    _fetchBloodNeeders();
  }

  Future<void> _fetchBloodNeeders([String query = '']) async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.get(
      Uri.parse('https://blood-donation-bd-backend.onrender.com/api/bloodNeeders/all${query.isNotEmpty ? '?query=$query' : ''}'),
    );

    if (response.statusCode == 200) {
      setState(() {
        _bloodNeeders = jsonDecode(response.body);
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      // Handle the error
      print('Failed to load blood needers');
    }
  }

  Future<void> _addBloodNeed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId') ?? '';

    final response = await http.post(
      Uri.parse('https://blood-donation-bd-backend.onrender.com/api/bloodNeeders/add'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'needer_id': userId,
        'blood_group': _bloodGroupController.text,
        'blood_needing_time': _bloodNeedingTimeController.text,
        'location': _locationController.text,
        'amount_of_bag_needed': int.parse(_amountOfBagNeededController.text),
        'contact_no': _contactNoController.text,
      }),
    );

    if (response.statusCode == 201) {
      Navigator.of(context).pop();
      _fetchBloodNeeders();
    } else {
      // Handle the error
      print('Failed to add blood need');
    }
  }

  Future<void> _markAsCompleted(String id) async {
    final response = await http.post(
      Uri.parse('https://blood-donation-bd-backend.onrender.com/api/bloodNeeders/complete'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'id': id}),
    );

    if (response.statusCode == 200) {
      _fetchBloodNeeders();
    } else {
      // Handle the error
      print('Failed to mark as completed');
    }
  }

  void _showAddBloodNeedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Need Blood?'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  controller: _bloodGroupController,
                  decoration: InputDecoration(labelText: 'Blood Group'),
                ),
                TextField(
                  controller: _bloodNeedingTimeController,
                  decoration: InputDecoration(labelText: 'Date & Time (dd mm,yyyy hh:mm xm)'),
                ),
                TextField(
                  controller: _locationController,
                  decoration: InputDecoration(labelText: 'Location'),
                ),
                TextField(
                  controller: _amountOfBagNeededController,
                  decoration: InputDecoration(labelText: 'Amount of Bag Needed'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _contactNoController,
                  decoration: InputDecoration(labelText: 'Contact No'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Post'),
              onPressed: _addBloodNeed,
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
        title: Text('Blood Donation Bangladesh'),
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Need Blood?',
                  style: TextStyle(fontSize: 20),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _showAddBloodNeedDialog,
                ),
              ],
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Search',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _fetchBloodNeeders(_searchQuery);
                  },
                ),
              ),
              onChanged: (value) {
                _searchQuery = value;
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _bloodNeeders.length,
                itemBuilder: (context, index) {
                  final bloodNeeder = _bloodNeeders[index];
                  return Card(
                    child: ListTile(
                      title: Text(bloodNeeder['name']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Blood Group: ${bloodNeeder['blood_group']}'),
                          Text('Location: ${bloodNeeder['location']}'),
                          Text('Needed Time: ${bloodNeeder['blood_needing_time']}'),
                          Text('Amount of Bag Needed: ${bloodNeeder['amount_of_bag_needed']}'),
                          Text('Contact No: ${bloodNeeder['contact_no']}'),
                          SizedBox(height: 8),
                          if (bloodNeeder['needer_id'] == userId)
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                textStyle: TextStyle(color: Colors.white),
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Confirmation'),
                                      content: Text('Are you sure that it is completed?'),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text('No'),
                                          onPressed: () {
                                            Navigator.of(context).pop(); // Close the dialog
                                          },
                                        ),
                                        TextButton(
                                          child: Text('Yes'),
                                          onPressed: () {
                                            Navigator.of(context).pop(); // Close the dialog
                                            _markAsCompleted(bloodNeeder['_id']); // Perform the action
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Text('Mark as Completed'),
                            ),
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
