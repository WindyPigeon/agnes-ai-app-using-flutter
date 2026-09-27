// Copyright 2026 Evan Li Zhen Feng. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import '../models/chat_message.dart';
import '../models/conversation.dart';
import '../models/scheduled_task.dart';
import '../models/user_profile.dart';
import '../services/agnes_api_client.dart';
import '../services/local_store.dart';
import '../services/secure_key_store.dart';
import '../util/id.dart';

enum NavSection { chat, search, scheduled, library }

class AppState extends ChangeNotifier {
  AppState({
    AgnesApiClient? apiClient,
    LocalStore? localStore,
    SecureKeyStore? keyStore,
  })  : _api = apiClient ?? AgnesApiClient(),
        _local = localStore ?? LocalStore(),
        _keys = keyStore ?? SecureKeyStore();

  final AgnesApiClient _api;
  final LocalStore _local;
  final SecureKeyStore _keys;

  NavSection section = NavSection.chat;
  List<Conversation> conversations = [];
  String? activeConversationId;
  List<ScheduledTask> tasks = [];
  UserProfile profile = UserProfile();
  String apiKey = '';
  bool isLoading = true;
  bool isSending = false;
  String? errorMessage;

  Conversation? get activeConversation {
    if (activeConversationId == null) return null;
    for (final c in conversations) {
      if (c.id == activeConversationId) return c;
    }
    return null;
  }

  List<Conversation> get recentConversations {
    final sorted = [...conversations]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted;
  }

  Future<void> init({required String seedApiKey}) async {
    final results = await Future.wait([
      _local.loadConversations(),
      _local.loadTasks(),
      _local.loadProfile(),
      _keys.read(),
    ]);
    conversations = results[0] as List<Conversation>;
    tasks = results[1] as List<ScheduledTask>;
    profile = results[2] as UserProfile;
    apiKey = results[3] as String;

    if (apiKey.isEmpty && seedApiKey.isNotEmpty) {
      apiKey = seedApiKey;
      await _keys.write(apiKey);
    }

    isLoading = false;
    notifyListeners();
  }

  void selectSection(NavSection s) {
    section = s;
    notifyListeners();
  }

  void startNewChat() {
    activeConversationId = null;
    section = NavSection.chat;
    notifyListeners();
  }

  void openConversation(String id) {
    activeConversationId = id;
    section = NavSection.chat;
    notifyListeners();
  }

  Future<void> deleteConversation(String id) async {
    conversations.removeWhere((c) => c.id == id);
    if (activeConversationId == id) activeConversationId = null;
    await _local.saveConversations(conversations);
    notifyListeners();
  }

  Future<void> renameConversation(String id, String title) async {
    final convo = conversations.where((c) => c.id == id).firstOrNull;
    if (convo == null) return;
    convo.title = title;
    await _local.saveConversations(conversations);
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || isSending) return;

    var convo = activeConversation;
    if (convo == null) {
      convo = Conversation(
        id: generateId(),
        title: _titleFromMessage(trimmed),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      conversations.add(convo);
      activeConversationId = convo.id;
    }

    convo.messages.add(ChatMessage(
      id: generateId(),
      role: MessageRole.user,
      content: trimmed,
      createdAt: DateTime.now(),
    ));

    final assistantMessage = ChatMessage(
      id: generateId(),
      role: MessageRole.assistant,
      content: '',
      createdAt: DateTime.now(),
      isStreaming: true,
    );
    convo.messages.add(assistantMessage);
    convo.updatedAt = DateTime.now();
    isSending = true;
    errorMessage = null;
    notifyListeners();

    await _streamAssistantReply(convo, assistantMessage);
  }

  Future<void> regenerateLast() async {
    final convo = activeConversation;
    if (convo == null || isSending) return;
    if (convo.messages.isEmpty || convo.messages.last.role != MessageRole.assistant) return;

    final removed = convo.messages.removeLast();
    final assistantMessage = ChatMessage(
      id: generateId(),
      role: MessageRole.assistant,
      content: '',
      createdAt: DateTime.now(),
      isStreaming: true,
    );
    convo.messages.add(assistantMessage);
    isSending = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _streamAssistantReply(convo, assistantMessage);
    } catch (_) {
      convo.messages.removeLast();
      convo.messages.add(removed);
      rethrow;
    }
  }

  Future<void> _streamAssistantReply(Conversation convo, ChatMessage assistantMessage) async {
    final history = convo.messages.where((m) => m.id != assistantMessage.id).toList();

    try {
      final stream = _api.streamChat(
        apiKey: apiKey,
        history: history,
        systemPrompt: profile.buildSystemPrompt(),
      );
      await for (final delta in stream) {
        assistantMessage.content += delta;
        _notifyIfNotDisposed();
      }
    } on AgnesApiException catch (e) {
      assistantMessage.isError = true;
      assistantMessage.content = e.message;
      errorMessage = e.message;
    } catch (e) {
      assistantMessage.isError = true;
      assistantMessage.content = 'Something went wrong: $e';
      errorMessage = assistantMessage.content;
    } finally {
      assistantMessage.isStreaming = false;
      isSending = false;
      convo.updatedAt = DateTime.now();
      await _local.saveConversations(conversations);
      _notifyIfNotDisposed();
    }
  }

  // The streaming loop above keeps running in the background even if the
  // widget hosting this AppState is torn down mid-reply (e.g. hot restart,
  // or in tests); ChangeNotifier throws if notifyListeners() is called
  // after dispose(), so guard every post-await notification.
  bool _disposed = false;

  void _notifyIfNotDisposed() {
    if (!_disposed) notifyListeners();
  }

  String _titleFromMessage(String text) {
    final singleLine = text.replaceAll('\n', ' ').trim();
    return singleLine.length > 48 ? '${singleLine.substring(0, 48)}...' : singleLine;
  }

  Future<void> addTask(ScheduledTask task) async {
    tasks.add(task);
    await _local.saveTasks(tasks);
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    tasks.removeWhere((t) => t.id == id);
    await _local.saveTasks(tasks);
    notifyListeners();
  }

  Future<void> updateApiKey(String key) async {
    apiKey = key.trim();
    await _keys.write(apiKey);
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile updated) async {
    profile = updated;
    await _local.saveProfile(profile);
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    await _local.clearAll();
    await _keys.clear();
    conversations = [];
    tasks = [];
    profile = UserProfile();
    apiKey = '';
    activeConversationId = null;
    section = NavSection.chat;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _api.dispose();
    super.dispose();
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
