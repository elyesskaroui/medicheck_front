import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/SignUpResponse.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:flutter_application_1/services/websocket_service.dart';

class ChatScreen extends StatefulWidget {
  final User loggedUser;
  const ChatScreen({super.key, required this.loggedUser});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final WebSocketService _webSocketService = WebSocketService();
  final TextEditingController _controller = TextEditingController();
  List<MessageResult> messages = [];
  File? _selectedImage;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _webSocketService.connect();
    _webSocketService.getInitData();

    _webSocketService.listenMessages((type, message) {
      setState(() {
        if (type == "m") {
          messages.add(message);
        } else if (type == "d") {
          messages.removeWhere((element) => element.id == message.id);
        }
      });
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _webSocketService.disconnect();
    super.dispose();
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      _webSocketService.sendMessage(
        Message(
          message: _controller.text,
          senderId: widget.loggedUser.id,
          date: DateTime.now(),
        ),
      );
      _controller.clear();
      _scrollToBottom(); 
    }
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime date) {
    String hour = date.hour.toString().padLeft(2, '0');
    String minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Chat With Users'),
          automaticallyImplyLeading: false,
          centerTitle: true,
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  'asset/images/test.jpg'), 
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.id == widget.loggedUser.id;
                    
                    return ListTile(
                      title: Column(
                        crossAxisAlignment: isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Text(
                            isMe ? widget.loggedUser.name : msg.user.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Color.fromARGB(255, 92, 88, 88),
                            ),
                          ),
                          SizedBox(height: 4),
                          isMe
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      _formatTime(msg.date),
                                      style: const TextStyle(
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onLongPress: () {
                                        showMenu(
                                          context: context,
                                          position: RelativeRect.fromLTRB(
                                              300, 300, 60, 0),
                                          items: [
                                            PopupMenuItem(
                                              padding: EdgeInsets.zero,
                                              child: Container(
                                                color: Colors.transparent,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.50,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.delete,
                                                      color: Colors.red,
                                                      size: 20,
                                                    ),
                                                    SizedBox(width: 30),
                                                    Text(
                                                      'Delete Message',
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              onTap: () {
                                                _webSocketService.deleteMessage(
                                                    messages[index].id);
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(8.0),
                                        constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.65,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          color: Colors.grey,
                                        ),
                                        child: Text(
                                          msg.message,
                                          textAlign: TextAlign.start,
                                          softWrap: true,
                                          overflow: TextOverflow.visible,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () {
                                        showUserInfoBottomSheet(
                                          context,
                                          widget.loggedUser.name,
                                          widget.loggedUser.email,
                                          widget.loggedUser.profilePicture != null
                                              ? ApiService.imageProfileLink(
                                                  widget.loggedUser.profilePicture!)
                                              : '',
                                        );
                                      },
                                      child: CircleAvatar(
                                        radius: 20,
                                        backgroundImage: widget.loggedUser.profilePicture == null
                                            ? const AssetImage('asset/images/profile.png')
                                                as ImageProvider<Object>?
                                            : NetworkImage(
                                                ApiService.imageProfileLink(
                                                    widget.loggedUser.profilePicture!),
                                              ) as ImageProvider<Object>?,
                                        backgroundColor: Colors.transparent,
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        showUserInfoBottomSheet(
                                          context,
                                          msg.user.name,
                                          msg.user.email,
                                          msg.user.profilePicture != null
                                              ? ApiService.imageProfileLink(
                                                  msg.user.profilePicture!)
                                              : '',
                                        );
                                      },
                                      child: CircleAvatar(
                                        radius: 20,
                                        backgroundImage: msg.user.profilePicture == null
                                            ? const AssetImage('asset/images/profile.png')
                                                as ImageProvider<Object>?
                                            : NetworkImage(
                                                ApiService.imageProfileLink(
                                                    msg.user.profilePicture!),
                                              ) as ImageProvider<Object>?,
                                        backgroundColor: Colors.transparent,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
                                      padding: const EdgeInsets.all(8.0),
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.65,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.blueAccent[400],
                                      ),
                                      child: Text(
                                        msg.message,
                                        textAlign: TextAlign.start,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _formatTime(msg.date),
                                      style: const TextStyle(
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                color: Colors.white.withOpacity(0.8),
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            hintText: 'Type a message...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            hintStyle: TextStyle(color: Color.fromARGB(255, 78, 74, 74)),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.blue),
                      onPressed: _sendMessage,
                      padding: const EdgeInsets.all(0),
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
  }

  void showUserInfoBottomSheet(
      BuildContext context, String name, String email, String photoUrl) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: photoUrl.isNotEmpty
                        ? NetworkImage(photoUrl)
                        : const AssetImage('asset/images/profile.png') as ImageProvider,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Name:',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                      Text(name,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text('Email:',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey)),
              Text(email,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}