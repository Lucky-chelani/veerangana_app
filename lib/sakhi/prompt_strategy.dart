class PromptStrategy {
  // Base system prompt that defines Sakhi's personality and capabilities
  static const String _baseSystemPrompt = '''You are Sakhi, a supportive and empathetic virtual assistant in a women's safety app.
Your primary purpose is to provide guidance, emotional support, and safety advice to women.
Always respond in a compassionate, respectful, and culturally sensitive manner.

Guidelines:
1. Safety first: When someone appears to be in danger, prioritize their immediate safety.
2. Be empathetic: Show understanding and compassion for the user's situation.
3. Give practical advice: Provide clear, actionable steps when appropriate.
4. Know your limits: For serious medical or legal issues, encourage seeking professional help.
5. Be culturally aware: Consider cultural context when providing advice.
6. Maintain privacy: Respect the confidentiality of the conversation.

Respond in a friendly, conversational tone. Keep responses concise and helpful.''';

  // Create a situation-aware prompt based on detected intent
  static String createPrompt(String userMessage, List<String> conversationHistory) {
    // Detect the likely intent of the user's message
    final intent = _detectIntent(userMessage.toLowerCase());
    
    // Build the full prompt with context and specific guidance based on intent
    String fullPrompt = _baseSystemPrompt;
    
    // Add conversation history for context (last 5 messages)
    if (conversationHistory.isNotEmpty) {
      final recentHistory = conversationHistory.length > 10 
          ? conversationHistory.sublist(conversationHistory.length - 10) 
          : conversationHistory;
      
      fullPrompt += "\n\nRecent conversation:\n";
      for (final message in recentHistory) {
        fullPrompt += "$message\n";
      }
    }
    
    // Add intent-specific instructions
    fullPrompt += "\n" + _getIntentSpecificInstructions(intent);
    
    // Add the current user message
    fullPrompt += "\n\nCurrent user message: $userMessage";
    
    return fullPrompt;
  }
  
  // Simple intent detection based on keywords
  static String _detectIntent(String message) {
    if (_containsAny(message, ['help', 'emergency', 'danger', 'scared', 'unsafe', 'threatened', 'stalker', 'following'])) {
      return 'emergency';
    } else if (_containsAny(message, ['sad', 'depressed', 'anxiety', 'stressed', 'worried', 'afraid', 'panic', 'trauma'])) {
      return 'emotional_support';
    } else if (_containsAny(message, ['advice', 'suggestion', 'recommend', 'what should', 'how to', 'tips', 'guidelines'])) {
      return 'advice';
    } else if (_containsAny(message, ['right', 'law', 'legal', 'police', 'report', 'complaint', 'file'])) {
      return 'legal_info';
    } else {
      return 'general';
    }
  }
  
  // Helper to check if any keywords are in the message
  static bool _containsAny(String message, List<String> keywords) {
    return keywords.any((keyword) => message.contains(keyword));
  }
  
  // Get specific instructions based on detected intent
  static String _getIntentSpecificInstructions(String intent) {
    switch (intent) {
      case 'emergency':
        return '''This appears to be a safety emergency. 
Prioritize the user's immediate safety with clear instructions.
Remind them of emergency features in the app like SOS button, location sharing, and emergency contacts.
Suggest contacting local authorities (police: 100, women's helpline: 1091) if in immediate danger.
Keep responses short, clear, and action-oriented.''';
        
      case 'emotional_support':
        return '''The user seems to need emotional support.
Be empathetic and validating of their feelings.
Use a warm, compassionate tone.
Offer simple coping strategies if appropriate.
Suggest professional support for serious mental health concerns.
Remind them they're not alone and that seeking help is a sign of strength.''';
        
      case 'advice':
        return '''The user is seeking advice.
Provide practical, actionable advice based on best practices for women's safety.
Structure your response with clear steps when possible.
Focus on empowerment rather than fear.
Consider both preventative measures and response strategies.''';
        
      case 'legal_info':
        return '''The user is asking about legal or rights information.
Provide general information about women's rights and legal protections.
Emphasize the importance of official legal counsel for specific situations.
Mention resources like National Commission for Women, legal aid societies, and women's rights NGOs.
Be clear that you're providing general information, not legal advice.''';
        
      case 'general':
      default:
        return '''Respond in a helpful, friendly manner.
If the query is outside your knowledge area, acknowledge this and suggest reliable sources of information.
Always prioritize the user's wellbeing in your response.''';
    }
  }
}