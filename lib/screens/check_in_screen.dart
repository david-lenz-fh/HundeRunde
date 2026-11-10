import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:starter_flutter/controllers/dogwalk_controller.dart';
// Importiere hier deinen DogController / DogService und den MainScreen

class DogCheckInScreen extends StatefulWidget {
  const DogCheckInScreen({super.key});

  @override
  State<DogCheckInScreen> createState() => _DogCheckInScreenState();
}

class _DogCheckInScreenState extends State<DogCheckInScreen> {
  final _nameController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveDog() async {
    final dogName = _nameController.text.trim();

    if (dogName.isEmpty) {
      setState(() => _errorMessage = 'Bitte gib einen Namen ein.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dogController = context.read<DogWalkController>();
      dogController.addNewDog(dogName);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ... Deine UI (Icon, Text) ...

              // Simples TextField statt TextFormField
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name deines Hundes',
                  errorText: _errorMessage, // Zeigt den Fehler in Rot an, wenn nicht null
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              
              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: _isLoading ? null : _saveDog,
                child: _isLoading 
                    ? const CircularProgressIndicator() 
                    : const Text('Speichern'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}