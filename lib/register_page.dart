import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _bloodGroupController = TextEditingController();
  final TextEditingController _contactNoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _professionController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _diseaseController = TextEditingController();
  String _donationType = 'Not a donor'; // Default value
  String _disease = ''; // Initial value for disease field

  String _errorMessage = '';

  Future<void> _register() async {
    final String name = _nameController.text;
    final int age = int.tryParse(_ageController.text) ?? 0;
    final String location = _locationController.text;
    final String bloodGroup = _bloodGroupController.text;
    final String contactNo = _contactNoController.text;
    final String password = _passwordController.text;
    final String profession = _professionController.text;
    final String email = _emailController.text;
    final String donationType = _donationType;
    final String disease = _disease;

    final response = await http.post(
      Uri.parse('https://blood-donation-bd-backend.onrender.com/api/auth/register'), // Replace with the actual URL of your registration endpoint
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'name': name,
        'age': age,
        'location': location,
        'blood_group': bloodGroup,
        'contact_no': contactNo,
        'password': password,
        'profession': profession,
        'email': email,
        'donation_type': donationType,
        'disease': disease,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // Save user data to shared preferences if needed
      // Navigate to the next screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } else {
      setState(() {
        _errorMessage = 'Registration failed. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Location'),
              ),
              TextFormField(
                controller: _bloodGroupController,
                decoration: InputDecoration(labelText: 'Blood Group'),
              ),
              TextFormField(
                controller: _contactNoController,
                decoration: InputDecoration(labelText: 'Contact Number'),
                keyboardType: TextInputType.phone,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              TextFormField(
                controller: _professionController,
                decoration: InputDecoration(labelText: 'Profession'),
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              DropdownButtonFormField<String>(
                value: _donationType,
                decoration: InputDecoration(labelText: 'Donation Type'),
                items: <String>['Not a donor', 'Paid', 'Free'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _donationType = newValue!;
                  });
                },
              ),
              TextFormField(
                controller: _diseaseController,
                decoration: InputDecoration(labelText: 'Disease', hintText: 'No disease'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _register,
                child: Text('Register'),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                ),
              ),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
