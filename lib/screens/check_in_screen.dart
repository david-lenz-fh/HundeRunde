import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starter_flutter/screens/main_screen.dart'; // Pfad prüfen!

// 1. Wir definieren die möglichen Entscheidungen des Nutzers
enum CheckInMode { none, create, join }

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  // Wir brauchen nur noch einen Controller, da immer nur ein Feld sichtbar ist
  final TextEditingController _inputController = TextEditingController();
  
  // Am Anfang ist nichts ausgewählt
  CheckInMode _selectedMode = CheckInMode.none;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  // Diese Funktion wird aufgerufen, wenn eine der beiden Karten angeklickt wird
  void _selectMode(CheckInMode mode) {
    setState(() {
      _selectedMode = mode;
      _inputController.clear(); // Textfeld leeren, falls man sich umentscheidet
    });
  }

  Future<void> _completeCheckIn(BuildContext context) async {
    final input = _inputController.text.trim();

    // Validierung 1: Hat er überhaupt etwas ausgewählt?
    if (_selectedMode == CheckInMode.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte wähle eine der beiden Optionen aus.')),
      );
      return;
    }

    // Validierung 2: Ist das Textfeld leer?
    if (input.isEmpty) {
      final errorMessage = _selectedMode == CheckInMode.create 
          ? 'Bitte gib einen Namen für den Hund ein.' 
          : 'Bitte gib die ID der Gruppe ein.';
          
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      return;
    }

    // Speichern
    final prefs = await SharedPreferences.getInstance();
    
    if (_selectedMode == CheckInMode.create) {
      await prefs.setString('dogName', input);
      print("Erstelle neue Gruppe für Hund: $input");
    } else {
      await prefs.setString('groupId', input);
      print("Trete Gruppe bei mit ID: $input");
    }

    await prefs.setBool('hasCheckedIn', true);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  }

  Widget _buildOptionCard({
    required String title,
    required IconData icon,
    required CheckInMode mode,
  }) {
    final isSelected = _selectedMode == mode;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withOpacity(0.25) : Colors.transparent,
        border: Border.all(
          color: isSelected ? Colors.white : Colors.white54,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      // Material wird benötigt, damit der InkWell-Klickeffekt sichtbar bleibt
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectMode(mode),
          borderRadius: BorderRadius.circular(15),
          splashColor: Colors.white.withOpacity(0.4), // Verstärkter Klick-Effekt
          highlightColor: Colors.white.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(icon, color: isSelected ? Colors.white : Colors.white54),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white54,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (isSelected) 
                  const Icon(Icons.check_circle, color: Colors.white)
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.pets, size: 100, color: Colors.white),
                const SizedBox(height: 30),
                const Text(
                  "Willkommen bei DogWalk!",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Option 1 Karte
                _buildOptionCard(
                  title: "Neue Hunde-Gruppe erstellen",
                  icon: Icons.add_circle_outline,
                  mode: CheckInMode.create,
                ),
                
                const SizedBox(height: 15),

                // Option 2 Karte
                _buildOptionCard(
                  title: "Bestehender Gruppe beitreten",
                  icon: Icons.group_add_outlined,
                  mode: CheckInMode.join,
                ),

                const SizedBox(height: 30),

                // Das dynamische Textfeld taucht NUR auf, wenn etwas ausgewählt wurde
                if (_selectedMode != CheckInMode.none)
                  AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: TextField(
                      controller: _inputController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
                        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
                        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 2)),
                        labelText: _selectedMode == CheckInMode.create 
                            ? "Name des Hundes" 
                            : "ID der Hunde-Gruppe",
                        labelStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: Icon(
                          _selectedMode == CheckInMode.create ? Icons.pets : Icons.tag, 
                          color: Colors.white70
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 40),
                
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    // Der Button ist nur aktiv (klickbar), wenn eine Option gewählt wurde
                    disabledBackgroundColor: Colors.white30,
                    disabledForegroundColor: Colors.white54,
                  ),
                  onPressed: _selectedMode == CheckInMode.none ? null : () => _completeCheckIn(context),
                  child: const Text("Los geht's", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}