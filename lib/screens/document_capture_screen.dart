import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_caf_document_detector/document_capture_flow.dart';
import 'package:flutter_caf_document_detector/document_detector_events.dart';
import 'package:flutter_caf_document_detector/enums.dart';
import 'package:caf_flutter_test/services/auth_service.dart';
import 'package:caf_flutter_test/services/caf_service.dart';

class DocumentCaptureScreen extends StatefulWidget {
  const DocumentCaptureScreen({Key? key}) : super(key: key);

  @override
  State<DocumentCaptureScreen> createState() => _DocumentCaptureScreenState();
}

class _DocumentCaptureScreenState extends State<DocumentCaptureScreen> {
  final CafService _cafService = CafService();
  
  bool _isLoading = false;
  String _resultMessage = '';
  bool _isSuccess = false;
  bool _isTestEnvironment = true;
  
  Future<void> _startRGFrontBack() async {
    await _startDocumentCapture([
      DocumentCaptureFlow(documentType: DocumentType.rgFront),
      DocumentCaptureFlow(documentType: DocumentType.rgBack),
    ]);
  }

  Future<void> _startCNHFrontBack() async {
    await _startDocumentCapture([
      DocumentCaptureFlow(documentType: DocumentType.cnhFront),
      DocumentCaptureFlow(documentType: DocumentType.cnhBack),
    ]);
  }

  Future<void> _startCNHFull() async {
    await _startDocumentCapture([
      DocumentCaptureFlow(documentType: DocumentType.cnhFull),
    ]);
  }

  Future<void> _startDocumentCapture(List<DocumentCaptureFlow> captureFlow) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    if (!authService.isAuthenticated) {
      setState(() {
        _resultMessage = 'Token expired or not available. Please go back and get a new token.';
        _isSuccess = false;
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _resultMessage = '';
      _isSuccess = false;
    });
    
    try {
      DocumentDetectorEvent event = await _cafService.startDocumentDetection(
        mobileToken: authService.token!,
        peopleId: authService.peopleId!,
        captureFlow: captureFlow,
        isTestEnvironment: _isTestEnvironment,
      );
      
      setState(() {
        _isLoading = false;
        
        if (event is DocumentDetectorEventSuccess) {
          _resultMessage = 'Success! Document Type: ${event.documentType}\n';
          _resultMessage += 'Captures: ${event.captures!.length}\n';
          
          for (var capture in event.captures!) {
            _resultMessage += '\n- Label: ${capture.label}\n';
            _resultMessage += '- Quality: ${capture.quality}\n';
            if (capture.imageUrl != null) {
              _resultMessage += '- URL: ${capture.imageUrl!.split("?")[0]}\n';
            }
          }
          
          _isSuccess = true;
        } else if (event is DocumentDetectorEventFailure) {
          _resultMessage = 'Failure! Error Type: ${event.errorType}\n';
          _resultMessage += 'Error Message: ${event.errorMessage}\n';
          if (event.securityErrorCode != null) {
            _resultMessage += 'Security Error Code: ${event.securityErrorCode}';
          }
          _isSuccess = false;
        } else if (event is DocumentDetectorEventClosed) {
          _resultMessage = 'The document capture was closed by the user';
          _isSuccess = false;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _resultMessage = 'Error: $e';
        _isSuccess = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Capture'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SwitchListTile(
              title: const Text('Test Environment'),
              subtitle: Text(_isTestEnvironment ? 'Using Beta/Testing' : 'Using Production'),
              value: _isTestEnvironment,
              onChanged: (value) {
                setState(() {
                  _isTestEnvironment = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _startRGFrontBack,
                    child: const Text('RG Front+Back'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _startCNHFrontBack,
                    child: const Text('CNH Front+Back'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _startCNHFull,
              child: const Text('CNH Full'),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_resultMessage.isNotEmpty) ...[
              Text(
                _isSuccess ? 'Success!' : 'Error',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _isSuccess ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(_resultMessage),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 