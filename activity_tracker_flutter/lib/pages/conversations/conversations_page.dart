import 'package:activity_tracker_flutter/components/home_drawer.dart';
import 'package:activity_tracker_flutter/models/conversation.dart';
import 'package:activity_tracker_flutter/models/message.dart';
import 'package:activity_tracker_flutter/models/user.dart';
import 'package:activity_tracker_flutter/providers/user_provider.dart';
import 'package:activity_tracker_flutter/services/conversation_service.dart';
import 'package:activity_tracker_flutter/services/message_service.dart';
import 'package:activity_tracker_flutter/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ConversationsPage extends StatefulWidget {
  const ConversationsPage({super.key});

  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: AppBar(title: const Text('Mensajes')),
      backgroundColor: Theme.of(context).colorScheme.surface,
      drawer: HomeDrawer(),
      drawerEdgeDragWidth: MediaQuery.of(context).size.width,

      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<Conversation>>(
                stream: ConversationService().getUserConversations(user!.uid),
                builder: (context, snapshot) {
                  // Waiting for the conversation list with circular progress indicator
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No has establecido aún ninguna conversación"));
                  }

                  final conversations = snapshot.data!;

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    itemCount: conversations.length,
                    itemBuilder: (context, index) {
                      final conversation = conversations[index];

                      // Makes sure we see our conversations instead of our friends
                      final otherUserId = conversation.user1Id == user.uid
                          ? conversation.user2Id
                          : conversation.user1Id;

                      // Stream for the friends information
                      return StreamBuilder<AppUser?>(
                        stream: UserService().getUserById(otherUserId),
                        builder: (context, userSnapshot) {
                          if (!userSnapshot.hasData) return const SizedBox();
                          final friend = userSnapshot.data!;

                          // Stream to show the last message and its hour in the conversation
                          return StreamBuilder<Message?>(
                            stream: MessageService().getLastMessage(conversation.id),
                            builder: (context, messageSnapshot) {
                              final lastMessageText = messageSnapshot.data;
                              final timestamp = lastMessageText?.createdAt.toDate();
                              final formattedTime = timestamp != null
                                  ? DateFormat('HH:mm dd/MM/yyyy').format(timestamp)
                                  : '';

                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  side: BorderSide(color: Colors.grey.shade700, width: 2),
                                ),
                                child: ListTile(
                                  // Navigate to the conversation chat with the user
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/conversationChat',
                                      arguments: {'conversationId': conversation.id, 'friend': friend},
                                    );
                                  },

                                  // Friend user profile picture
                                  leading: CircleAvatar(
                                    backgroundImage:
                                        friend.profilePictureURL != null && friend.profilePictureURL!.isNotEmpty
                                        ? NetworkImage(friend.profilePictureURL!)
                                        : null,
                                    backgroundColor: Colors.grey.shade600,
                                    child: friend.profilePictureURL == null || friend.profilePictureURL!.isEmpty
                                        ? const Icon(Icons.person_rounded, color: Colors.white)
                                        : null,
                                  ),

                                  // Friend username
                                  title: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        friend.nickname,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                      ),

                                      Text('@${friend.username}', overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 5),
                                    ],
                                  ),

                                  // Last sent message in the conversation
                                  subtitle: Text(
                                    lastMessageText == null
                                        ? 'No hay mensajes'
                                        : '${lastMessageText.userId == user.uid ? "Tú" : friend.nickname}: ${lastMessageText.text}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  // Date and hour of the last sent message in the conversation
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [Text(formattedTime)],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
