import 'package:activity_tracker_flutter/models/message.dart';
import 'package:activity_tracker_flutter/models/user.dart';
import 'package:activity_tracker_flutter/providers/user_provider.dart';
import 'package:activity_tracker_flutter/services/message_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ConversationChatPage extends StatefulWidget {
  const ConversationChatPage({super.key});

  @override
  State<ConversationChatPage> createState() => _ConversationChatPageState();
}

class _ConversationChatPageState extends State<ConversationChatPage> {
  late AppUser friend;
  late String conversationId;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    friend = args['friend'];
    conversationId = args['conversationId'];
  }

  // Function to send the message
  void _sendMessage(String myUserId) {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // Sends the message (creates it in the database)
    MessageService().sendMessage(conversationId: conversationId, userId: myUserId, text: text);

    // Clears the controller
    _messageController.clear();

    // Scroll down
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  // Method to scroll to the latest messages of the conversation
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: friend.profilePictureURL != null && friend.profilePictureURL!.isNotEmpty
                  ? NetworkImage(friend.profilePictureURL!)
                  : null,
              backgroundColor: Colors.grey.shade600,
              child: friend.profilePictureURL == null || friend.profilePictureURL!.isEmpty
                  ? const Icon(Icons.person_rounded, color: Colors.white, size: 18)
                  : null,
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(friend.nickname, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('@${friend.username}', style: const TextStyle(fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,

      // Chat
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<Message>>(
                stream: MessageService().getMessagesForConversation(conversationId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center();

                  final messages = snapshot.data!;

                  _scrollToBottom();

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message.userId == user!.uid;
                      final messageTime = DateFormat.Hm().format(message.createdAt.toDate());
                      final messageDate = message.createdAt.toDate();

                      // Show date before the first message of the day
                      bool showDateHeader = false;
                      if (index == 0) {
                        showDateHeader = true;
                      } else {
                        final prevMessageDate = messages[index - 1].createdAt.toDate();
                        showDateHeader = !isSameDay(messageDate, prevMessageDate);
                      }

                      // Messages
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (showDateHeader)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                formatDateHeader(messageDate),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? Theme.of(context).colorScheme.secondary
                                    : (Theme.of(context).brightness == Brightness.dark
                                          ? Colors.grey.shade800
                                          : Colors.grey.shade500),
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(12),
                                  topRight: const Radius.circular(12),
                                  bottomLeft: Radius.circular(isMe ? 12 : 0),
                                  bottomRight: Radius.circular(isMe ? 0 : 12),
                                ),
                              ),

                              // Message
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(message.text, style: const TextStyle(color: Colors.white)),
                                  const SizedBox(height: 4),
                                  Text(messageTime, style: TextStyle(color: Colors.grey.shade300, fontSize: 10)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),

            // Message input textfield
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  // Textfield
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        filled: true,
                        fillColor: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.shade700
                            : Colors.grey.shade400,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Send button
                  Container(
                    // Cirle decoration
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue, 
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded),
                      color: Colors.white,
                      onPressed: () => _sendMessage(user!.uid),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Compares to dates to check if they are the same
bool isSameDay(DateTime d1, DateTime d2) {
  return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
}

// Formats the date header in the chat
String formatDateHeader(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final dateOnly = DateTime(date.year, date.month, date.day);

  if (dateOnly == today) return 'Hoy';
  if (dateOnly == yesterday) return 'Ayer';

  return DateFormat('d MMMM yyyy', 'es_ES').format(date);
}
