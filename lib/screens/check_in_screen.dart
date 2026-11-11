import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:starter_flutter/controllers/dogwalk_controller.dart';

class DogCheckInScreen extends StatefulWidget {
  const DogCheckInScreen({super.key});

  @override
  State<DogCheckInScreen> createState() => _DogCheckInScreenState();
}

class _DogCheckInScreenState extends State<DogCheckInScreen> {
  final _nameController = TextEditingController();
  final _idController = TextEditingController(); // Neuer Controller für die ID
  
  bool _isLoading = false;
  String? _nameErrorMessage;
  String? _idErrorMessage; // Eigener Fehler-Text für das ID-Feld

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    super.dispose();
  }

  Future<void> _saveDog() async {
    final dogName = _nameController.text.trim();

    if (dogName.isEmpty) {
      setState(() => _nameErrorMessage = 'Bitte gib einen Namen ein.');
      return;
    }

    setState(() {
      _isLoading = true;
      _nameErrorMessage = null;
      _idErrorMessage = null;
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

  Future<void> _joinDog() async {
    final dogId = _idController.text.trim();

    if (dogId.isEmpty) {
      setState(() => _idErrorMessage = 'Bitte gib eine Hunde-ID ein.');
      return;
    }

    setState(() {
      _isLoading = true;
      _idErrorMessage = null;
      _nameErrorMessage = null;
    });

    try {
      final dogController = context.read<DogWalkController>();
      final joined = await dogController.joinDog(dogId);
      if(!joined){
        if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hund nicht gefunden')),
        );
        setState(() => _isLoading = false);
      }
      }
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
        child: SingleChildScrollView( // Verhindert Tastatur-Überlappung
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.pets, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              const Text(
                'Willkommen bei Hunderunde!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              const Text(
                'Neuen Hund anlegen',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: 'Name deines Hundes',
                  errorText: _nameErrorMessage,
                  prefixIcon: const Icon(Icons.add_circle_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveDog,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                    : const Text('Speichern & Loslegen', style: TextStyle(fontSize: 16)),
              ),

              const SizedBox(height: 32),

              // --- TRENNER ---
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('ODER', style: TextStyle(color: Colors.grey)),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              
              const SizedBox(height: 32),
              const Text(
                'Bestehendem Hund beitreten',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _idController,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: 'Hunde-ID eingeben',
                  errorText: _idErrorMessage,
                  prefixIcon: const Icon(Icons.group_add),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _isLoading ? null : _joinDog,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Beitreten', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}