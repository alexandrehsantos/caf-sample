import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_caf_document_detector/document_capture_flow.dart';
import 'package:flutter_caf_document_detector/document_captures_model.dart';
import 'package:flutter_caf_document_detector/document_detector.dart';
import 'package:flutter_caf_document_detector/document_detector_events.dart';
import 'package:flutter_caf_document_detector/enums.dart';
import 'package:flutter_caf_document_detector/capture_preview_settings.dart';
import 'package:flutter_caf_document_detector/android_settings/android_settings.dart';
import 'package:flutter_caf_document_detector/android_settings/security_settings.dart';

class CafService {
  Future<DocumentDetectorEvent> startDocumentDetection({
    required String mobileToken,
    required String peopleId,
    required List<DocumentCaptureFlow> captureFlow,
    required bool isTestEnvironment,
  }) async {
    try {
      debugPrint('Initializing Document Detector with token: ${mobileToken.substring(0, 20)}...');
      debugPrint('Using peopleId: $peopleId');
      debugPrint('Environment: ${isTestEnvironment ? 'Beta/Test' : 'Production'}');
      
      // Check if running on web - CAF Document Detector doesn't support web platform
      if (kIsWeb) {
        debugPrint('Web platform detected. CAF Document Detector is not supported on web.');
        return DocumentDetectorEventFailure(
          errorType: "PLATFORM_NOT_SUPPORTED", 
          errorMessage: "Document detection is not supported on web browsers. Please run this app on a mobile device."
        );
      }
      
      // Initialize the Document Detector
      DocumentDetector documentDetector = DocumentDetector(
        mobileToken: mobileToken,
        captureFlow: captureFlow,
      );

      // Configure environment
      documentDetector.setStage(isTestEnvironment ? CafStage.beta : CafStage.prod);
      
      // Set peopleId
      documentDetector.setPersonId(peopleId);
      
      // Configure preview settings
      documentDetector.setPreviewSettings(PreviewSettings(show: true));
      
      // Configure Android settings for development
      if (isTestEnvironment) {
        AndroidSettings androidSettings = AndroidSettings(
          securitySettings: SecuritySettings(
            useAdb: true,
            useDebug: true,
            useDeveloperMode: true,
            useEmulator: true,
            useRoot: true,
          ),
        );
        documentDetector.setAndroidSettings(androidSettings);
      }
      
      // Set network timeout
      documentDetector.setNetworkSettings(30);
      
      debugPrint('Starting document detection...');
      
      // Start the document detection flow
      DocumentDetectorEvent event = await documentDetector.start();
      
      debugPrint('Document detection completed with result type: ${event.runtimeType}');
      
      return event;
    } catch (e) {
      debugPrint('Error starting document detection: $e');
      return DocumentDetectorEventFailure(
        errorType: "ERROR", 
        errorMessage: "Error starting document detection: $e"
      );
    }
  }
} 