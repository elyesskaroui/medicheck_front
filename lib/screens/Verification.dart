import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/new_password.dart'; // Assurez-vous que ce fichier existe et définit NewPasswordScreen

class VerificationScreen extends StatefulWidget {
  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  bool _isLoading = false;
  // Création de 4 contrôleurs pour saisir 4 chiffres du code OTP
  final List<TextEditingController> otpControllers =
      List.generate(4, (index) => TextEditingController());

  void _verifyOTP() {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });

      String otpCode =
          otpControllers.map((controller) => controller.text).join();

      if (otpCode.length == 4) {
        // Si le code est correct, navigation vers NewPasswordScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NewPasswordScreen()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Code vérifié avec succès!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Veuillez entrer un code valide à 4 chiffres."),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  void _resendCode() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Code renvoyé! Vérifie ton email."),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fond avec opacité pour un effet "dark overlay"
      backgroundColor: Colors.black.withOpacity(0.8),
      body: Stack(
        children: [
          // Image de fond
          Positioned.fill(
            child: Image.asset(
              'asset/images/test.jpg', // Vérifiez le chemin de votre image
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.6),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          // Contenu scrollable centré
          SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 60.0, horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo centré
                    Center(
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          color: Colors.white24, // Fond transparent
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Image.asset(
                            'asset/images/logo1.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Titre
                    Text(
                      "Enter Verification Code",
                      style: TextStyle(
                        color: const Color.fromARGB(255, 224, 224, 224),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 15),
                    // Champs OTP (4 zones de texte)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        return Container(
                          width: 50,
                          height: 50,
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          child: TextField(
                            controller: otpControllers[index],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            style: TextStyle(fontSize: 18, color: Colors.white),
                            decoration: InputDecoration(
                              counterText: "",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.blueAccent),
                              ),
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty && index < 3) {
                                FocusScope.of(context).nextFocus();
                              }
                            },
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 20),
                    // Texte "If you didn't receive a code! Resend"
                    GestureDetector(
                      onTap: _resendCode,
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "If you didn't receive a code! ",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            TextSpan(
                              text: "Resend",
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    // Bouton "Verify" avec animation
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      height: 50,
                      width: _isLoading ? 50 : 200,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: _isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : TextButton(
                              onPressed: _verifyOTP,
                              child: Text(
                                "Verify",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
