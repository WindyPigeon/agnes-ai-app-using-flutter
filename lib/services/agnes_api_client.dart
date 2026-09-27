// Copyright 2026 Evan Li Zhen Feng. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/chat_message.dart';

class AgnesApiException implements Exception {
  AgnesApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// Talks to the documented Agnes AI OpenAI-compatible chat completions
/// endpoint: POST https://apihub.agnes-ai.com/v1/chat/completions
class AgnesApiClient {
  AgnesApiClient({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  static const _baseUrl = 'https://apihub.agnes-ai.com/v1';
  static const defaultModel = 'agnes-2.5-flash';

  final http.Client _http;

  /// Streams incremental assistant text deltas for the given conversation
  /// history. [systemPrompt], if non-empty, is sent as a leading system
  /// message (built from the user's Personalization settings).
  Stream<String> streamChat({
    required String apiKey,
    required List<ChatMessage> history,
    String systemPrompt = '',
    String model = defaultModel,
  }) async* {
    if (apiKey.isEmpty) {
      throw AgnesApiException('No Agnes AI secret key configured. Add one in Account settings.');
    }

    final messages = <Map<String, String>>[
      if (systemPrompt.isNotEmpty) {'role': 'system', 'content': systemPrompt},
      for (final m in history)
        {
          'role': m.role == MessageRole.user ? 'user' : 'assistant',
          'content': m.content,
        },
    ];

    final request = http.Request('POST', Uri.parse('$_baseUrl/chat/completions'))
      ..headers.addAll({
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
        'Accept': 'text/event-stream',
      })
      ..body = jsonEncode({
        'model': model,
        'messages': messages,
        'stream': true,
      });

    final response = await _http.send(request);

    if (response.statusCode != 200) {
      final body = await response.stream.bytesToString();
      throw AgnesApiException(
        _describeError(response.statusCode, body),
        statusCode: response.statusCode,
      );
    }

    final lines = response.stream.transform(utf8.decoder).transform(const LineSplitter());
    var buffer = StringBuffer();

    await for (final line in lines) {
      if (!line.startsWith('data:')) continue;
      final payload = line.substring(5).trim();
      if (payload.isEmpty) continue;
      if (payload == '[DONE]') break;

      try {
        final decoded = jsonDecode(payload) as Map<String, dynamic>;
        final choices = decoded['choices'] as List?;
        if (choices == null || choices.isEmpty) continue;
        final delta = choices.first['delta'] as Map<String, dynamic>?;
        final content = delta?['content'] as String?;
        if (content != null && content.isNotEmpty) {
          buffer.write(content);
          yield content;
        }
      } on FormatException {
        // Skip malformed/partial SSE frames.
        continue;
      }
    }
  }

  String _describeError(int statusCode, String body) {
    String? apiMessage;
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded['error'] is Map) {
        apiMessage = (decoded['error'] as Map)['message'] as String?;
      }
    } catch (_) {
      // ignore, fall through to generic message
    }
    if (statusCode == 401) {
      return apiMessage ?? 'Invalid Agnes AI secret key (401 Unauthorized).';
    }
    return apiMessage ?? 'Agnes AI request failed (HTTP $statusCode).';
  }

  void dispose() => _http.close();
}
