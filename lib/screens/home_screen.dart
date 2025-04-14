import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:caf_flutter_test/services/auth_service.dart';
import 'package:caf_flutter_test/screens/document_capture_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _peopleIdController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthService>(context, listen: false).initialize();
    });
  }

  @override
  void dispose() {
    _peopleIdController.dispose();
    super.dispose();
  }

  Future<void> _getToken() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    if (_peopleIdController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a CPF/ID';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      await authService.setPeopleId(_peopleIdController.text);
      final success = await authService.getToken();
      
      if (success) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DocumentCaptureScreen(),
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'Failed to get token. Check your connection.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('CAF Document Detector Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _peopleIdController,
              decoration: const InputDecoration(
                labelText: 'Enter CPF/ID',
                border: OutlineInputBorder(),
                hintText: 'Ex: 12345678900',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ElevatedButton(
              onPressed: _isLoading ? null : _getToken,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Get Token & Continue'),
            ),
            const SizedBox(height: 16),
            Text(
              'Token Status: ${authService.isAuthenticated ? 'Valid' : 'Not authenticated'}',
              textAlign: TextAlign.center,
            ),
            if (authService.token != null) ...[
              const SizedBox(height: 8),
              Text(
                'Token: ${authService.token!.substring(0, 20)}...',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
} 