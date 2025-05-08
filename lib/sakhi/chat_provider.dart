import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../sakhi/chat_msg.dart';
import '../sakhi/gemini_service.dart';

class ChatProvider extends ChangeNotifier {
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  final GeminiService _geminiService;

  ChatProvider({required GeminiService geminiService}) 
      : _geminiService = geminiService {
    _loadChatHistory();
  }

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  // Add system message to introduce Sakhi at the start of conversation
  void initializeChat() {
    if (_messages.isEmpty) {
      _messages.add(
        ChatMessage(
          text: "Hello! I'm Sakhi, your personal safety assistant. I'm here to provide guidance and emotional support whenever you need. How can I help you today?",
          isUser: false,
        ),
      );
      _saveChatHistory();
      notifyListeners();
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    _messages.add(ChatMessage(text: text, isUser: true));
    notifyListeners();

    // Set loading state
    _isLoading = true;
    notifyListeners();

    try {
      // Create a context-aware prompt
      String prompt = _createContextAwarePrompt(text);
      
      // Get response from Gemini
      final response = await _geminiService.generateResponse(prompt);
      
      // Add bot response
      _messages.add(ChatMessage(text: response, isUser: false));
      _saveChatHistory();
    } catch (e) {
      // Handle error
      _messages.add(ChatMessage(
        text: "I'm sorry, I couldn't process your request. Please try again later.",
        isUser: false,
      ));
    } finally {
      // Reset loading state
      _isLoading = false;
      notifyListeners();
    }
  }

  String _createContextAwarePrompt(String userMessage) {
    // Create a prompt that provides context to the Gemini API
    return '''You are Sakhi, a supportive and empathetic virtual assistant in a women's safety app. 
Your primary purpose is to provide guidance, emotional support, and safety advice to women.
Always respond in a compassionate, respectful manner.

When asked about safety concerns, provide practical advice that prioritizes the user's wellbeing.
If the user appears to be in immediate danger, remind them to use the emergency features of the app or contact local authorities.
For mental health concerns, provide supportive responses and suggest professional resources when appropriate.
Be knowledgeable about women's rights, safety strategies, and support resources.

Current user message: $userMessage''';
  }

  // Save chat history to shared preferences
  Future<void> _saveChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encodedMessages = jsonEncode(_messages.map((m) => m.toJson()).toList());
      await prefs.setString('chat_history', encodedMessages);
    } catch (e) {
      print('Error saving chat history: $e');
    }
  }

  // Load chat history from shared preferences
  Future<void> _loadChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encodedMessages = prefs.getString('chat_history');
      
      if (encodedMessages != null && encodedMessages.isNotEmpty) {
        final decodedMessages = jsonDecode(encodedMessages) as List;
        _messages = decodedMessages
            .map((item) => ChatMessage.fromJson(item))
            .toList();
        notifyListeners();
      } else {
        // Initialize with welcome message if no history
        initializeChat();
      }
    } catch (e) {
      print('Error loading chat history: $e');
      initializeChat();
    }
  }

  // Clear chat history
  Future<void> clearChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('chat_history');
      _messages = [];
      initializeChat();
    } catch (e) {
      print('Error clearing chat history: $e');
    }
  }
}