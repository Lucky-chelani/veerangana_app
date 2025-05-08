import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../sakhi/chat_provider.dart';
import '../sakhi/chat_msg.dart';
import '../ui/colors.dart'; // Import colors

class SakhiChatScreen extends StatefulWidget {
  const SakhiChatScreen({Key? key}) : super(key: key);

  @override
  State<SakhiChatScreen> createState() => _SakhiChatScreenState();
}

class _SakhiChatScreenState extends State<SakhiChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Initialize chat with welcome message if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false).initializeChat();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.raspberry,
                AppColors.rosePink,
              ],
            ),
          ),
        ),
        title: Row(
          children: [
             ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(
                'assets/aiboticon.png', // Make sure to add this image to your assets
                width: 32,
                height: 32,
                fit: BoxFit.cover,
              ),
            ),
            // Icon for Sakhi
            // Icon(
            //   Icons.shield_rounded, // You can choose a different icon
            //   color: Colors.white,
            //   size: 28,
            // ),
            const SizedBox(width: 12.0),
            // Stacked text for "Sakhi" and "Your Safety Companion"
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sakhi',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    fontSize: 20.0,
                  ),
                ),
                Text(
                  'Your Safety Companion',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          ],
        ),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(
                    'Clear Chat History',
                    style: TextStyle(
                      color: AppColors.deepBurgundy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: Colors.white,
                  content: Text(
                    'Are you sure you want to clear the chat history?',
                    style: TextStyle(color: AppColors.deepBurgundy),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(
                        'CANCEL',
                        style: TextStyle(color: AppColors.salmonPink),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Provider.of<ChatProvider>(context, listen: false).clearChatHistory();
                        Navigator.of(ctx).pop();
                      },
                      child: Text(
                        'CLEAR',
                        style: TextStyle(color: AppColors.raspberry),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.lightPeach,
              AppColors.rosePink.withOpacity(0.3),
            ],
            stops: const [0.0, 1.0],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, chatProvider, child) {
                  WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                    itemCount: chatProvider.messages.length,
                    itemBuilder: (context, index) {
                      return _buildChatMessage(chatProvider.messages[index]);
                    },
                  );
                },
              ),
            ),
            Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                if (chatProvider.isLoading) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: LinearProgressIndicator(
                      color: AppColors.raspberry,
                      backgroundColor: AppColors.salmonPink.withOpacity(0.3),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildChatMessage(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: message.isUser 
              ? AppColors.raspberry.withOpacity(0.9)
              : Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: message.isUser ? Colors.white : AppColors.deepBurgundy,
                fontFamily: 'Poppins',
                fontSize: 15.0,
              ),
            ),
            const SizedBox(height: 4.0),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: message.isUser 
                        ? Colors.white.withOpacity(0.8)
                        : AppColors.deepBurgundy.withOpacity(0.5),
                    fontSize: 10.0,
                    fontFamily: 'Poppins',
                  ),
                ),
                if (message.isUser) 
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Icon(
                      Icons.done_all,
                      size: 12.0,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.emoji_emotions_outlined),
            color: AppColors.salmonPink,
            onPressed: () {
              // Implement emoji picker functionality if needed
            },
          ),
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(
                  color: AppColors.deepBurgundy.withOpacity(0.5),
                  fontFamily: 'Poppins',
                ),
                filled: true,
                fillColor: AppColors.lightPeach.withOpacity(0.5),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  borderSide: BorderSide(color: AppColors.raspberry, width: 1.5),
                ),
              ),
              style: TextStyle(
                color: AppColors.deepBurgundy,
                fontFamily: 'Poppins',
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          const SizedBox(width: 8.0),
          Consumer<ChatProvider>(
            builder: (context, chatProvider, child) {
              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.raspberry,
                ),
                child: IconButton(
                  icon: const Icon(Icons.send_rounded),
                  color: Colors.white,
                  onPressed: chatProvider.isLoading
                      ? null
                      : () {
                          if (_textController.text.trim().isNotEmpty) {
                            chatProvider.sendMessage(_textController.text);
                            _textController.clear();
                          }
                        },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}