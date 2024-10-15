import 'package:flutter/material.dart';

class JoinButtonToTextField extends StatefulWidget {
  const JoinButtonToTextField({super.key});

  @override
  _JoinButtonToTextFieldState createState() => _JoinButtonToTextFieldState();
}

class _JoinButtonToTextFieldState extends State<JoinButtonToTextField>
    with SingleTickerProviderStateMixin {
  bool _isTextFieldVisible = false;
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0), // départ hors écran à droite
      end: Offset.zero, // arrive à sa position initiale
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Ecoute la fin de l'animation
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        setState(() {
          _isTextFieldVisible = false; // Réapparition du bouton après animation
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _onButtonPressed() {
    setState(() {
      _isTextFieldVisible = true;
    });
    _controller.forward(); // Lancer l'animation
  }

  void _onCheckPressed() {
    _controller.reverse(); // Lancer l'animation inverse (repli)
    // Ici, vous pouvez également traiter la validation du texte
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return SlideTransition(
          position: _offsetAnimation,
          child: child,
        );
      },
      child: _isTextFieldVisible
          ? Row(
        key: const ValueKey('textField'), // Clé unique pour chaque widget
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Enter your name',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _onCheckPressed, // Appel de la méthode
          ),
        ],
      )
          : SizedBox(
        width: double.infinity, // Prendre toute la largeur disponible
        child: ElevatedButton(
          key: const ValueKey('button'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black, // CompanionAppTheme.darkerText
            backgroundColor: Colors.grey[300], // CompanionAppTheme.lightText
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 15.0,
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 16),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black, // CompanionAppTheme.darkerText
            ),
          ),
          onPressed: _onButtonPressed,
          child: const Text('Join'),
        ),
      ),
    );
  }
}
