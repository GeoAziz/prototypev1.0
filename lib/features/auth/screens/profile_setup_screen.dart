import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen>
    with SingleTickerProviderStateMixin {
  String? _photoUrl;
  final _formKey = GlobalKey<FormState>();
  String? _avatarPath;
  String? _fullName;
  String? _email;
  String? _phone;
  String? _bio;
  String? _address;
  String? _language = 'English';
  bool _notificationsEnabled = true;
  String? _location = 'Current Location';
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future<void> _pickAndUploadImage() async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final ref = FirebaseStorage.instance.ref().child(
            'user_profiles/${user.uid}/profile.jpg',
          );
          await ref.putData(await pickedFile.readAsBytes());
          final url = await ref.getDownloadURL();
          setState(() {
            _photoUrl = url;
          });
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({'photoUrl': url}, SetOptions(merge: true));
        }
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile')),
      body: FadeTransition(
        opacity: _animation,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _pickAndUploadImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundImage: _photoUrl != null
                              ? NetworkImage(_photoUrl!)
                              : null,
                          child: _photoUrl == null
                              ? Icon(Icons.person, size: 45)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.blue,
                            child: Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  initialValue: _fullName,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) => _fullName = val,
                ),
                SizedBox(height: 16),
                TextFormField(
                  initialValue: _email,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (val) => _email = val,
                ),
                SizedBox(height: 16),
                TextFormField(
                  initialValue: _phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  onChanged: (val) => _phone = val,
                ),
                SizedBox(height: 16),
                TextFormField(
                  initialValue: _bio,
                  decoration: InputDecoration(
                    labelText: 'Bio',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) => _bio = val,
                ),
                SizedBox(height: 16),
                TextFormField(
                  initialValue: _address,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) => _address = val,
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Preferred Language',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _language,
                  items: ['English', 'Spanish', 'French', 'Arabic']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) => setState(() => _language = val),
                ),
                SizedBox(height: 16),
                SwitchListTile(
                  title: Text('Enable Notifications'),
                  value: _notificationsEnabled,
                  onChanged: (val) =>
                      setState(() => _notificationsEnabled = val),
                ),
                SizedBox(height: 16),
                ListTile(
                  leading: Icon(Icons.location_on, color: Colors.blue),
                  title: Text(_location ?? ''),
                  trailing: Icon(Icons.edit_location),
                  onTap: () {
                    // TODO: Implement location picker
                  },
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .set({
                              'fullName': _fullName ?? user.displayName,
                              'email': _email ?? user.email,
                              'phone': _phone ?? '',
                              'bio': _bio ?? '',
                              'address': _address ?? '',
                              'language': _language ?? 'English',
                              'notificationsEnabled': _notificationsEnabled,
                            }, SetOptions(merge: true));
                      }
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
