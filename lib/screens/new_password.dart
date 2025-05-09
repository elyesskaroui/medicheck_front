import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({Key? key}) : super(key: key);

  @override
  _NewPasswordScreenState createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  bool _isLoading = false;
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  void _resetPassword() {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });

      String newPassword = _newPasswordController.text;
      String confirmPassword = _confirmPasswordController.text;

      if (newPassword.isEmpty || confirmPassword.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Veuillez remplir tous les champs."),
            backgroundColor: Colors.red,
          ),
        );
      } else if (newPassword != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Les mots de passe ne correspondent pas."),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Mot de passe réinitialisé avec succès!"),
            backgroundColor: Colors.green,
          ),
        );
        // Ici, vous pouvez rediriger l'utilisateur (ex: vers la page de login)
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fond avec un overlay sombre
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
                    const SizedBox(height: 20),
                    // Titre
                    Text(
                      "Reset Password",
                      style: TextStyle(
                        color: const Color.fromARGB(255, 224, 224, 224),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Champ "Enter New Password" avec icône
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: TextField(
                        controller: _newPasswordController,
                        obscureText: true,
                        style: TextStyle(color: Colors.white, fontSize: 18),
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            FontAwesomeIcons.lock,
                            color: Colors.white,
                          ),
                          hintText: "Enter New Password",
                          hintStyle: TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Champ "Confirm Password" avec icône
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: TextField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        style: TextStyle(color: Colors.white, fontSize: 18),
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            FontAwesomeIcons.lock,
                            color: Colors.white,
                          ),
                          hintText: "Confirm Password",
                          hintStyle: TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Bouton "Reset Password" avec animation
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      height: 50,
                      width: _isLoading ? 50 : 250,
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
                              onPressed: _resetPassword,
                              child: Text(
                                "Submit",
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
