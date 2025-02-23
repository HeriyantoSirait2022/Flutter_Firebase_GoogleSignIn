import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../screens/home.dart';
import 'package:http/http.dart' as http;

class SignInWithGoogleButton extends StatefulWidget {
  const SignInWithGoogleButton({super.key});

  @override
  State<SignInWithGoogleButton> createState() => _SignInWithGoogleButtonState();
}

class _SignInWithGoogleButtonState extends State<SignInWithGoogleButton> {
  var _isGoogleSigning = false;

  Future<void> _signInWithGoogle() async {
    final List<String> scopes = <String>[
      'email',
      "https://www.googleapis.com/auth/userinfo.profile"
    ];

    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: scopes,
    );

    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      UserCredential user =
          await FirebaseAuth.instance.signInWithCredential(credential);

      //Pass headers below
      var idToken = await user.user?.getIdToken();

      debugPrint('ID Token: $idToken');

      final result = await http.post(
          Uri.parse("https://bandshare.online/api/users/auth"),
          body: jsonEncode({'fcm_key': 'bla bala bla blall....balalala.....'}),
          headers: {
            'Content-type': 'application/json',
            'Accept': 'application/json',
            "Authorization": 'Bearer $idToken'
          });

      Map<String, dynamic>? ress = jsonDecode(result.body);

      debugPrint(ress.toString());
    } on FirebaseAuthException catch (error) {
      debugPrint(error.toString());

      setState(() {
        _isGoogleSigning = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return _isGoogleSigning
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : InkWell(
            onTap: _signInWithGoogle,
            child: Container(
              height: screenSize.height / 18,
              width: screenSize.width / 2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context).primaryColor,
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/icons/google.png'),
                          fit: BoxFit.cover,
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const Text(
                      'Sign in with google',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
            ));
  }
}
