import 'package:chat/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

final firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  final form = GlobalKey<FormState>();
  var isLogin = false;
  var enteredEmail = '';
  var enteredPassword = '';
  var enteredUsername = '';
  File? selectedImage;
  var isAuthenticating = false;

  submit() async {
    final isValid = form.currentState!.validate();
    if (!isValid || !isLogin && selectedImage == null) {
      return;
    }
    form.currentState!.save();
    try {
      isAuthenticating = true;
      if (isLogin) {
        final userCredentials = await firebase.signInWithEmailAndPassword(
            email: enteredEmail, password: enteredPassword);
        //print(userCredentials);
      } else {
        final userCredentials = await firebase.createUserWithEmailAndPassword(
            email: enteredEmail, password: enteredPassword);
        //print(userCredentials);

        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${userCredentials.user!.uid}.jpg');

        await storageRef.putFile(selectedImage!);
        String imageUrl = await storageRef.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
          'username': enteredUsername,
          'email': enteredEmail,
          'image_url': imageUrl,
        });
      }
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error.message ?? 'Authendication failed'),
      ));
      setState(() {
        isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                    top: 30, bottom: 20, left: 20, right: 20),
                width: 200,
                child: Image.asset('assets/images/pngwing.com.png'),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                        key: form,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isLogin)
                              UserImagePicker(
                                onPickImage: (pickedImage) {
                                  selectedImage = pickedImage;
                                },
                              ),
                            TextFormField(
                              decoration: const InputDecoration(
                                  label: Text('Email Address')),
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    !value.contains('@')) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                enteredEmail = value!;
                              },
                            ),
                            if (!isLogin)
                              TextFormField(
                                decoration: const InputDecoration(
                                  label: Text('Enter Username'),
                                ),
                                enableSuggestions: false,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty ||
                                      value.trim().length < 4) {
                                    return 'Minimum 4 chanracters';
                                  }
                                },
                                onSaved: (value) {
                                  enteredUsername = value!;
                                },
                              ),
                            TextFormField(
                              decoration: const InputDecoration(
                                label: Text('Password'),
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    value.trim().length < 8 ||
                                    !value.contains(RegExp(r'[A-Z]')) ||
                                    !value.contains(RegExp(r'[0-9]')) ||
                                    !value.contains(RegExp(r'[!@#$%^&*?]'))) {
                                  return 'Password should be of minimum 8 characters and must contain atleast 1 Upper case ,1 special character and 1 number ';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                enteredPassword = value!;
                              },
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            if (isAuthenticating)
                              const CircularProgressIndicator(),
                            if (!isAuthenticating)
                              ElevatedButton(
                                  onPressed: submit,
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer),
                                  child: Text(isLogin ? 'Login' : 'Signup')),
                            if (!isAuthenticating)
                              TextButton(
                                  onPressed: () {
                                    setState(() {
                                      isLogin = !isLogin;
                                    });
                                  },
                                  child: Text(isLogin
                                      ? 'Create an account'
                                      : 'I already have an account')),
                          ],
                        )),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
