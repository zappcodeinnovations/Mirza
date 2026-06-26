import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../services/chat_service.dart';

class ChatController extends ChangeNotifier {
  final ChatService _chatService = ChatService();

  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "Hello! I'm your Mirza Assistant. 🤖\n\nAsk me about SKU stock status (e.g., 'What is the stock of MK070338_05?'), returns KPI, sales forecasts, or competitive analysis!",
      isUser: false,
      timestamp: DateTime.now(),
    ),
  ];

  bool _isTyping = false;

  List<ChatMessage> get messages => _messages;
  bool get isTyping => _isTyping;

  // Send message to the assistant
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    _messages.add(ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    _isTyping = true;
    notifyListeners();

    try {
      // Build conversation history format for API
      final history = _messages
          .where((m) => m.stockCard == null) // exclude cards from history
          .map((m) => {
                'role': m.isUser ? 'user' : 'assistant',
                'content': m.text,
              })
          .toList();

      final reply = await _chatService.askChatbot(
        question: text,
        history: history,
      );

      // Check if bot reply contains a customized SKU stock card
      final cardData = StockCardData.parse(reply);

      _messages.add(ChatMessage(
        text: reply,
        isUser: false,
        timestamp: DateTime.now(),
        stockCard: cardData,
      ));
    } catch (e) {
      _messages.add(ChatMessage(
        text: "I'm sorry, I encountered an issue. Please try checking your internet connection.",
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

  // Clear chat conversation logs
  void clearChat() {
    _messages.clear();
    _messages.add(ChatMessage(
      text: "Chat history cleared. How can I assist you with Mirza Internationals BI today?",
      isUser: false,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }
}
