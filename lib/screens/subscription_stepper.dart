import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/services/auth_service.dart';

class SubscriptionStepper extends StatefulWidget {
  const SubscriptionStepper({super.key});

  @override
  State<SubscriptionStepper> createState() => _SubscriptionStepperState();
}

class _SubscriptionStepperState extends State<SubscriptionStepper> {
  int _currentStep = 0;
  final List<GlobalKey<FormState>> _formKeys = List.generate(3, (_) => GlobalKey<FormState>());
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSaving = false;
  final int freeTrial= 7;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /// Generate a random trial license key
  String _generateTrialKey() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    String block(int len) => List.generate(len, (_) => chars[rand.nextInt(chars.length)]).join();
    return 'TRIAL-${block(4)}-${block(4)}';
  }

  void _nextStep() {
    if (_currentStep < _buildSteps().length - 1) {
      if (_currentStep > 0 && _currentStep <= 3) {
        final currentFormKey = _formKeys[_currentStep - 1];
        if (!currentFormKey.currentState!.validate()) return;
      }
      setState(() => _currentStep += 1);
    } else {
      _saveDataToFirebase();
    }
  }

  void _backStep() {
    if (_currentStep > 0) setState(() => _currentStep -= 1);
  }
Future<void> _saveDataToFirebase() async {
   if (_isSaving) return;

  // Show login dialog
  
  setState(() => _isSaving = true);

  final email = _emailController.text.trim();
  final phone = _phoneController.text.trim();
  final name = _nameController.text.trim();
  final password = _passwordController.text.trim();

  final AuthService _authService = AuthService();
  try {
    final customers = FirebaseFirestore.instance.collection('customers');
    final authService = AuthService();

    // 🔍 Check duplicates in Firestore

    // 🔍 Check duplicates in Firestore
    final existingEmail = await customers.where('email', isEqualTo: email).limit(1).get();
    if (existingEmail.docs.isNotEmpty) {
      _showDuplicateDialog('Email address');
      return;
    }

    final existingPhone = await customers.where('phone', isEqualTo: phone).limit(1).get();
    if (existingPhone.docs.isNotEmpty) {
      _showDuplicateDialog('Phone number');
      return;
    }

    // 🎫 Generate trial license key
    final trialKey = _generateTrialKey();

    // 🔑 Create user in Firebase Auth
    // (use a random password so we don't need them to enter one at setup)
    final userCredential = await authService.createUserWithEmailAndPassword(
      email,
      password,
    );
    final uid = userCredential.user!.uid;
    // store the uid to shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('password', password);

    // Create a batch write
    final batch = FirebaseFirestore.instance.batch();

    // 👤 Save customer profile in Firestore
    batch.set(customers.doc(uid), {
      'uid': uid,
      'name': name,
      'phone': phone,
      'email': email,
      'trialKey': trialKey,
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': DateTime.now().add( Duration(days: freeTrial)),
    });

    // 🎟️ Save license entry
    batch.set(FirebaseFirestore.instance
        .collection('licenses')
        .doc('free_trial')
        .collection('keys')
        .doc(uid), {
      'uid': uid,
      'licenseKey': trialKey,
      'name': name,
      'phone': phone,
      'email': email,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': DateTime.now().add( Duration(days: freeTrial)),
    });

    // Commit the batch
    await batch.commit();

    // 🎉 Show success dialog
    await _showFreeTrialDialog(trialKey);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('❌ Error saving data: ${e.toString()}')),
    );
  } finally {
    setState(() => _isSaving = false);
  }
}

  Future<bool> _showLoginDialog() async {
    String email = '';
    String password = '';

    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login to Your Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
                onChanged: (value) => email = value,
              ),
              TextField(
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                onChanged: (value) => password = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final authService = AuthService();
                try {
                  await authService.signInWithEmailAndPassword(
                    email.trim(),
                    password.trim(),
                  );
                  Navigator.of(context).pop(true);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("❌ Auth Error: ${e.toString()}")),
                  );
                  Navigator.of(context).pop(false);
                }
              },
              child: const Text('Login'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  void _showDuplicateDialog(String field) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Already Registered'),
        content: Text('$field is already associated with a subscription.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
    setState(() => _isSaving = false);
  }

  Future<void> _showFreeTrialDialog(String trialKey) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('🎉 Free Trial Claimed!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('You have successfully claimed your 7-day free trial.\nEnjoy exploring our app!'),
            const SizedBox(height: 16),
            SelectableText(
              'Your Trial Key:\n$trialKey',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {

              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/dashboard');
            },
            child: const Text('Go to Dashboard'),
          ),
        ],
      ),
    );
  }

  List<Step> _buildSteps() {
    return [
      Step(
        title: const Text('Welcome'),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(Icons.subscriptions_rounded,
                  size: 64, color: Theme.of(context).primaryColor),
            ),
            const SizedBox(height: 16),
            Text(
              "Welcome to Our App 🎉",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              "Get instant access to powerful tools that make your experience "
              "simpler, faster, and more enjoyable. Start now and claim your 7-day free trial!",
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ListTile(
                  leading: Icon(Icons.check_circle, color: Colors.green),
                  title: Text("✔ Free 7-day trial"),
                ),
                ListTile(
                  leading: Icon(Icons.check_circle, color: Colors.green),
                  title: Text("✔ Full access to all features"),
                ),
                ListTile(
                  leading: Icon(Icons.check_circle, color: Colors.green),
                  title: Text("✔ Secure and private"),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "Tap 'Next' to begin your free trial setup.",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),

      // Step 2: Name
      Step(
        title: const Text('Name'),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
        content: Form(
          key: _formKeys[0],
          child: TextFormField(
            controller: _nameController,
            autofocus: _currentStep == 1,
            decoration: const InputDecoration(
              labelText: 'Your Name',
              helperText: 'Enter your full name',
              border: OutlineInputBorder(),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
          ),
        ),
      ),

      // Step 3: Phone
      Step(
        title: const Text('Phone'),
        isActive: _currentStep >= 2,
        state: _currentStep > 2 ? StepState.complete : StepState.indexed,
        content: Form(
          key: _formKeys[1],
          child: TextFormField(
            controller: _phoneController,
            autofocus: _currentStep == 2,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Your Phone Number',
              helperText: 'Include country code if needed',
              border: OutlineInputBorder(),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Please enter your phone number' : null,
          ),
        ),
      ),

      // Step 4: Email
      Step(
        title: const Text('Email & Password'),
        isActive: _currentStep >= 3,
        state: _currentStep > 3 ? StepState.complete : StepState.indexed,
        content: Form(
          key: _formKeys[2],
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                autofocus: _currentStep == 3,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Your Email Address',
                  helperText: 'We’ll send a confirmation email',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Please enter your email address';
                  if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  helperText: 'Create a password for your account',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Please enter a password';
                  if (v.trim().length < 6) return 'Password must be at least 6 characters';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),

      // Step 5: Confirmation
      Step(
        title: const Text('Confirmation'),
        isActive: _currentStep >= 4,
        state: _isSaving ? StepState.editing : StepState.complete,
        content: _isSaving
            ? const Center(child: CircularProgressIndicator())
            : Card(
                elevation: 2,
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("👤 Name: ${_nameController.text}"),
                      Text("📞 Phone: ${_phoneController.text}"),
                      Text("✉️ Email: ${_emailController.text}"),
                      const SizedBox(height: 12),
                      const Text("Press 'Confirm' to finish setup."),
                    ],
                  ),
                ),
              ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LinearProgressIndicator(
          value: (_currentStep + 1) / _buildSteps().length,
          backgroundColor: Colors.grey.shade200,
          color: Theme.of(context).primaryColor,
        ),
        Expanded(
          child: Stepper(
            currentStep: _currentStep,
            steps: _buildSteps(),
            onStepContinue: _nextStep,
            onStepCancel: _backStep,
            onStepTapped: (step) {
              if (step < _currentStep) setState(() => _currentStep = step);
            },
            controlsBuilder: (context, details) {
              return Row(
                children: [
                  ElevatedButton(
                    onPressed: _isSaving ? null : details.onStepContinue,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(_currentStep == _buildSteps().length - 1 ? 'Confirm' : 'Next'),
                  ),
                  const SizedBox(width: 8),
                  if (_currentStep > 0)
                    OutlinedButton(
                      onPressed: _isSaving ? null : details.onStepCancel,
                      child: const Text('Back'),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
