import 'package:firebase_functions/firebase_functions.dart';
import '../models/generation_result.dart';
import '../models/script.dart';

/// Calls the VyralIQ Firebase Cloud Function (generateContent)
/// which securely proxies all OpenAI calls server-side.
class AiService {
  final HttpsCallable _callable;

  AiService({HttpsCallable? callable})
      : _callable = callable ??
            FirebaseFunctions.instance
                .httpsCallable('generateContent');

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Generates all content types via the Cloud Function.
  /// Returns a complete [GenerationResult].
  ///
  /// Throws [AiServiceException] on failure.
  Future<GenerationResult> generateContent({
    required String platform,
    required String niche,
    required String goal,
    required String tone,
    required String length,
  }) async {
    try {
      final response = await _callable.call<Map<String, dynamic>>({
        'platform': platform,
        'niche': niche,
        'goal': goal,
        'tone': tone,
        'length': length,
      });

      final data = response.data;
      if (data == null) {
        throw AiServiceException('Empty response from server.');
      }

      return _parseResult(data);
    } on FirebaseFunctionsException catch (e) {
      throw AiServiceException(
        _mapFirebaseError(e),
        code: _codeFromFirebaseError(e),
      );
    } on AiServiceException {
      rethrow;
    } catch (e) {
      throw AiServiceException(
        'Unable to reach VyralIQ servers. Check your connection and try again.',
        code: 0,
        original: e,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Parsing
  // ---------------------------------------------------------------------------

  GenerationResult _parseResult(Map<String, dynamic> data) {
    return GenerationResult(
      viralHooks: List<String>.from(data['viralHooks'] ?? []),
      videoIdeas: List<String>.from(data['videoIdeas'] ?? []),
      scripts: (data['scripts'] as List<dynamic>?)
              ?.map((s) => Script(
                    hook: (s as Map<String, dynamic>)['hook'] as String? ?? '',
                    body: s['body'] as String? ?? '',
                    cta: s['cta'] as String? ?? '',
                  ))
              .toList() ??
          [],
      caption: data['caption'] as String? ?? '',
      cta: data['cta'] as String? ?? '',
      hashtags: List<String>.from(data['hashtags'] ?? []),
      thumbnailText: data['thumbnailText'] as String? ?? '',
      editingSuggestions: data['editingSuggestions'] as String? ?? '',
      bRollIdeas: List<String>.from(data['bRollIdeas'] ?? []),
      cameraAngles: data['cameraAngles'] as String? ?? '',
      lightingSuggestions: data['lightingSuggestions'] as String? ?? '',
      musicStyle: data['musicStyle'] as String? ?? '',
      bestPostingTime: data['bestPostingTime'] as String? ?? '',
      seoKeywords: List<String>.from(data['seoKeywords'] ?? []),
      repurposeIdeas: List<String>.from(data['repurposeIdeas'] ?? []),
      carouselVersion: data['carouselVersion'] as String? ?? '',
      instagramStoryVersion: data['instagramStoryVersion'] as String? ?? '',
      facebookVersion: data['facebookVersion'] as String? ?? '',
      linkedinVersion: data['linkedinVersion'] as String? ?? '',
      pinterestVersion: data['pinterestVersion'] as String? ?? '',
      platform: data['platform'] as String? ?? '',
      niche: data['niche'] as String? ?? '',
      goal: data['goal'] as String? ?? '',
      tone: data['tone'] as String? ?? '',
      length: data['length'] as String? ?? '',
    );
  }

  // ---------------------------------------------------------------------------
  // Error mapping
  // ---------------------------------------------------------------------------

  String _mapFirebaseError(FirebaseFunctionsException e) {
    switch (e.code) {
      case 'invalid-argument':
        return 'Invalid request. Please check your selections.';
      case 'resource-exhausted':
        return 'AI rate limit reached. Please wait a moment and try again.';
      case 'unauthenticated':
        return 'Please sign in to continue.';
      case 'internal':
        return e.message ?? 'Server error. Please try again later.';
      default:
        return e.message ?? 'An unexpected error occurred.';
    }
  }

  int _codeFromFirebaseError(FirebaseFunctionsException e) {
    switch (e.code) {
      case 'invalid-argument':
        return 400;
      case 'unauthenticated':
        return 401;
      case 'resource-exhausted':
        return 429;
      case 'internal':
        return 500;
      default:
        return -1;
    }
  }
}

/// Structured exception for AI service errors.
class AiServiceException implements Exception {
  final String message;
  final int code;
  final Object? original;

  const AiServiceException(
    this.message, {
    this.code = -1,
    this.original,
  });

  @override
  String toString() => 'AiServiceException($code): $message';
}
