import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/models/SignUpResponse.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:flutter_application_1/services/websocket_service.dart';

import 'package:image_picker/image_picker.dart';

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
  File? _Image;
  final ScrollController _scrollController = ScrollController();
  String translateText = 'Translate to :';
  String selectedLanguageCode = 'ar'; // Default selected language

  @override
  void initState() {
    super.initState();
    _webSocketService.connect();
    _webSocketService.getInitData();

    _webSocketService.listenMessages((type, message) {
      setState(() {
        if (type == "m") {
          if (messages.any((element) => element.id == message.id)) {
            return;
          }
          messages.add(message);
        } else if (type == "i") {
          messages.add(message);
        } else if (type == "r") {
          messages.removeWhere((element) => element.id == message.id);
          messages.add(message);
        } else if (type == "d") {
          messages.removeWhere((element) => element.id == message.id);
        } else if (type == "u") {
          messages =
              messages.map((e) => e.id == message.id ? message : e).toList();
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

  String _formatDateTime(DateTime dateTime) {
    String dayName = dateTime.weekday == 1
        ? 'Monday'
        : dateTime.weekday == 2
            ? 'Tuesday'
            : dateTime.weekday == 3
                ? 'Wednesday'
                : dateTime.weekday == 4
                    ? 'Thursday'
                    : dateTime.weekday == 5
                        ? 'Friday'
                        : dateTime.weekday == 6
                            ? 'Saturday'
                            : 'Sunday';

    return '$dayName, ${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute}:${dateTime.second}';
  }

  void _sendMessage() {
    if (widget.loggedUser.bannedUntil != null &&
        widget.loggedUser.bannedUntil!.isAfter(DateTime.now())) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            title: Row(
              children: [
                const Icon(Icons.error, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Access Denied',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Text(
              'You are currently banned from sending messages until ${_formatDateTime(widget.loggedUser.bannedUntil!)}.',
              style: const TextStyle(fontSize: 16),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          );
        },
      );
      return;
    }

    if (_controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a message'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.blue,
        ),
      );
      return;
    }
    if (_controller.text.isNotEmpty) {
      _webSocketService.sendMessage(
        Message(
          message: _controller.text,
          senderId: widget.loggedUser.id,
          date: DateTime.now(),
          isImage: false,
        ),
      );
      _controller.clear();
      _scrollToBottom();
    }
    _scrollToBottom();
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
              image: AssetImage('asset/images/test.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: 16),
              Image(
                image: AssetImage('asset/images/logo1.png'),
                height: 80,
              ),
              SizedBox(height: 8),
              Text(
                'Hello 👋 Welcome to the conversation!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color.fromARGB(255, 50, 50, 50),
                ),
              ),
              Divider(thickness: 1),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.user.id == widget.loggedUser.id;

                    return ListTile(
                      title: Column(
                        crossAxisAlignment: isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Text(messages[index].user.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Color.fromARGB(255, 92, 88, 88),
                              )),
                          SizedBox(height: 4),
                          isMe
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${msg.date.day}/${msg.date.month}/${msg.date.year}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          'At ${msg.date.hour}:${msg.date.minute}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onLongPress: () {
                                        showMenu(
                                          context: context,
                                          position: const RelativeRect.fromLTRB(
                                              300, 550, 70, 0),
                                          items: [
                                            PopupMenuItem(
                                              padding: EdgeInsets.zero,
                                              child: Container(
                                                color: Colors.transparent,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.60,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const SizedBox(width: 30),
                                                    const Icon(
                                                      Icons.delete,
                                                      color: Color.fromARGB(
                                                          255, 85, 83, 83),
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 20),
                                                    const Text(
                                                      'Delete Message',
                                                      style: TextStyle(
                                                        color: Color.fromARGB(
                                                            255, 85, 83, 83),
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
                                            PopupMenuItem(
                                              padding: EdgeInsets.zero,
                                              child: Container(
                                                color: Colors.transparent,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.60,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const SizedBox(width: 30),
                                                    const Icon(
                                                      Icons.copy,
                                                      color: Color.fromARGB(
                                                          255, 85, 83, 83),
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 30),
                                                    const Text(
                                                      'Copy Message',
                                                      style: TextStyle(
                                                        color: Color.fromARGB(
                                                            255, 85, 83, 83),
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              onTap: () {
                                                Clipboard.setData(
                                                  ClipboardData(
                                                    text:
                                                        messages[index].message,
                                                  ),
                                                );
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Message copied to clipboard',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    duration:
                                                        Duration(seconds: 1),
                                                    backgroundColor:
                                                        Colors.blueAccent,
                                                  ),
                                                );
                                              },
                                            ),
                                            PopupMenuItem(
                                              padding: EdgeInsets.zero,
                                              child: Container(
                                                color: Colors.transparent,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.60,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const SizedBox(width: 25),
                                                    const Icon(
                                                      Icons.edit,
                                                      color: Color.fromARGB(
                                                          255, 85, 83, 83),
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 30),
                                                    const Text(
                                                      'Edit Message',
                                                      style: TextStyle(
                                                        color: Color.fromARGB(
                                                            255, 85, 83, 83),
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    TextEditingController
                                                        editController =
                                                        TextEditingController();
                                                    editController.text =
                                                        messages[index].message;
                                                    return AlertDialog(
                                                      title: const Text(
                                                          'Edit Message'),
                                                      content: TextField(
                                                        controller:
                                                            editController,
                                                        decoration:
                                                            const InputDecoration(
                                                          hintText:
                                                              'Enter your new message',
                                                        ),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop(); // Close the dialog
                                                          },
                                                          child: const Text(
                                                              'Cancel'),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            if (editController
                                                                .text
                                                                .isNotEmpty) {
                                                              _webSocketService
                                                                  .editMessage(
                                                                messages[index]
                                                                    .id,
                                                                editController
                                                                    .text,
                                                              );
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            }
                                                          },
                                                          child: const Text(
                                                              'Save'),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                            PopupMenuItem(
                                              padding: EdgeInsets.zero,
                                              child: Container(
                                                color: Colors.transparent,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.75,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const SizedBox(width: 25),
                                                    const Icon(
                                                      Icons.translate,
                                                      color: Color.fromARGB(
                                                          255, 85, 83, 83),
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 15),
                                                    const Text(
                                                      'Translate To : ',
                                                      style: TextStyle(
                                                        color: Color.fromARGB(
                                                            255, 85, 83, 83),
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                    DropdownButton<String>(
                                                      value:
                                                          selectedLanguageCode,
                                                      icon: const Icon(Icons
                                                          .arrow_drop_down),
                                                      onChanged: (String?
                                                          newValue) async {
                                                        print(newValue);
                                                        if (newValue != null) {
                                                          selectedLanguageCode =
                                                              newValue;

                                                          var msg =
                                                              messages[index]
                                                                  .message;

                                                          var translatedMessage =
                                                              await _webSocketService
                                                                  .translateText(
                                                            msg,
                                                            selectedLanguageCode,
                                                          );
                                                          print(
                                                              translatedMessage);
                                                          Navigator.of(context)
                                                              .pop();

                                                          setState(() {
                                                            messages[index] =
                                                                MessageResult(
                                                              id: messages[
                                                                      index]
                                                                  .id,
                                                              user: messages[
                                                                      index]
                                                                  .user,
                                                              message:
                                                                  translatedMessage,
                                                              date: messages[
                                                                      index]
                                                                  .date,
                                                              isImage: messages[
                                                                      index]
                                                                  .isImage,
                                                            );
                                                          });

                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                'Message translated!',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                              backgroundColor:
                                                                  Colors
                                                                      .blueAccent,
                                                            ),
                                                          );
                                                        }
                                                      },
                                                      items: [
                                                        DropdownMenuItem(
                                                          value: 'en',
                                                          child: Row(
                                                            children: [
                                                              Text('English'),
                                                            ],
                                                          ),
                                                        ),
                                                        DropdownMenuItem(
                                                          value: 'ar',
                                                          child: Row(
                                                            children: [
                                                              Text('Arabic'),
                                                            ],
                                                          ),
                                                        ),
                                                        DropdownMenuItem(
                                                          value: 'fr',
                                                          child: Row(
                                                            children: [
                                                              Text('French'),
                                                            ],
                                                          ),
                                                        ),
                                                        DropdownMenuItem(
                                                          value: 'es',
                                                          child: Row(
                                                            children: [
                                                              Text('Spanish'),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
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
                                                0.55,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            color: Colors.grey,
                                          ),
                                          child: messages[index].isImage
                                              ? Container(
                                                  width: 200,
                                                  height: 200,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    color: Colors.grey[
                                                        300], // Background color if image fails
                                                  ),
                                                  child: Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      // Try to load the image, catch errors
                                                      if (messages[index]
                                                          .message
                                                          .isNotEmpty)
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          child: Image.file(
                                                            File(messages[index]
                                                                .message),
                                                            fit: BoxFit.cover,
                                                            errorBuilder:
                                                                (context, error,
                                                                    stackTrace) {
                                                              // Return empty container on error, the fallback UI below will show
                                                              print(
                                                                  "Error loading image: $error");
                                                              return Container();
                                                            },
                                                          ),
                                                        ),
                                                      // Fallback UI that shows when the image fails to load
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(Icons.image,
                                                              color: Colors
                                                                  .grey[600],
                                                              size: 40),
                                                          SizedBox(height: 8),
                                                          Text(
                                                            "Image",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .grey[800]),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : Text(
                                                  messages[index].message,
                                                  textAlign: TextAlign.end,
                                                  softWrap: true,
                                                  overflow:
                                                      TextOverflow.visible,
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                )),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () {
                                        showUserInfoBottomSheet(
                                          context,
                                          widget.loggedUser.name,
                                          widget.loggedUser.email,
                                          ApiService.imageProfileLink(
                                              widget.loggedUser.profilePicture),
                                        );
                                      },
                                      child: CircleAvatar(
                                        radius: 20,
                                        backgroundImage: _selectedImage != null
                                            ? FileImage(_selectedImage!)
                                            : widget.loggedUser
                                                        .profilePicture ==
                                                    null
                                                ? const AssetImage(
                                                        'asset/images/profile.png')
                                                    as ImageProvider<Object>?
                                                : NetworkImage(
                                                    ApiService.imageProfileLink(
                                                        widget.loggedUser
                                                            .profilePicture!),
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
                                          messages[index].user.name,
                                          messages[index].user.email,
                                          ApiService.imageProfileLink(
                                              messages[index]
                                                  .user
                                                  .profilePicture),
                                        );
                                      },
                                      child: CircleAvatar(
                                        radius: 20,
                                        backgroundImage: _selectedImage != null
                                            ? FileImage(_selectedImage!)
                                            : widget.loggedUser
                                                        .profilePicture ==
                                                    null
                                                ? const AssetImage(
                                                        'asset/images/profile.png')
                                                    as ImageProvider<Object>?
                                                : NetworkImage(
                                                    ApiService.imageProfileLink(
                                                        messages[index]
                                                            .user
                                                            .profilePicture),
                                                  ) as ImageProvider<Object>?,
                                        backgroundColor: Colors.transparent,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    GestureDetector(
                                      onLongPress: () {
                                        showMenu(
                                          context: context,
                                          position: const RelativeRect.fromLTRB(
                                              300, 470, 120, 0),
                                          items: [
                                            PopupMenuItem(
                                              padding: EdgeInsets.zero,
                                              child: Container(
                                                color: Colors.transparent,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.60,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const SizedBox(width: 25),
                                                    const Icon(
                                                      Icons.report,
                                                      color: Color.fromARGB(
                                                          255, 85, 83, 83),
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 10),
                                                    const Text(
                                                      'Report Message',
                                                      style: TextStyle(
                                                        color: Color.fromARGB(
                                                            255, 85, 83, 83),
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              onTap: () {
                                                _webSocketService.reportMessage(
                                                  widget.loggedUser.id,
                                                  messages[index].id,
                                                );
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Message reported !',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    backgroundColor:
                                                        Colors.blueAccent,
                                                  ),
                                                );
                                              },
                                            ),
                                            PopupMenuItem(
                                              padding: EdgeInsets.zero,
                                              child: Container(
                                                color: Colors.transparent,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.60,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const SizedBox(width: 25),
                                                    const Icon(
                                                      Icons.copy,
                                                      color: Color.fromARGB(
                                                          255, 85, 83, 83),
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 15),
                                                    const Text(
                                                      'Copy Message',
                                                      style: TextStyle(
                                                        color: Color.fromARGB(
                                                            255, 85, 83, 83),
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              onTap: () {
                                                Clipboard.setData(
                                                  ClipboardData(
                                                    text:
                                                        messages[index].message,
                                                  ),
                                                );
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Message copied to clipboard',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    duration:
                                                        Duration(seconds: 1),
                                                    backgroundColor:
                                                        Colors.blueAccent,
                                                  ),
                                                );
                                              },
                                            ),
                                            PopupMenuItem(
                                              padding: EdgeInsets.zero,
                                              child: Container(
                                                color: Colors.transparent,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.75,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const SizedBox(width: 25),
                                                    const Icon(
                                                      Icons.translate,
                                                      color: Color.fromARGB(
                                                          255, 85, 83, 83),
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 15),
                                                    const Text(
                                                      'Translate To : ',
                                                      style: TextStyle(
                                                        color: Color.fromARGB(
                                                            255, 85, 83, 83),
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                    DropdownButton<String>(
                                                      value:
                                                          selectedLanguageCode,
                                                      icon: const Icon(Icons
                                                          .arrow_drop_down),
                                                      onChanged: (String?
                                                          newValue) async {
                                                        if (newValue != null) {
                                                          selectedLanguageCode =
                                                              newValue;

                                                          var msg =
                                                              messages[index]
                                                                  .message;

                                                          var translatedMessage =
                                                              await _webSocketService
                                                                  .translateText(
                                                            msg,
                                                            selectedLanguageCode,
                                                          );
                                                          Navigator.of(context)
                                                              .pop();

                                                          setState(() {
                                                            messages[index] =
                                                                MessageResult(
                                                              id: messages[
                                                                      index]
                                                                  .id,
                                                              user: messages[
                                                                      index]
                                                                  .user,
                                                              message:
                                                                  translatedMessage,
                                                              date: messages[
                                                                      index]
                                                                  .date,
                                                              isImage: messages[
                                                                      index]
                                                                  .isImage,
                                                            );
                                                          });

                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                'Message translated!',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                              backgroundColor:
                                                                  Colors
                                                                      .blueAccent,
                                                            ),
                                                          );
                                                        }
                                                      },
                                                      items: [
                                                        DropdownMenuItem(
                                                          value: 'en',
                                                          child: Row(
                                                            children: [
                                                              Text('English'),
                                                            ],
                                                          ),
                                                        ),
                                                        DropdownMenuItem(
                                                          value: 'ar',
                                                          child: Row(
                                                            children: [
                                                              Text('Arabic'),
                                                            ],
                                                          ),
                                                        ),
                                                        DropdownMenuItem(
                                                          value: 'fr',
                                                          child: Row(
                                                            children: [
                                                              Text('French'),
                                                            ],
                                                          ),
                                                        ),
                                                        DropdownMenuItem(
                                                          value: 'es',
                                                          child: Row(
                                                            children: [
                                                              Text('Spanish'),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
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
                                                0.55,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            color: Colors.blueAccent[400],
                                          ),
                                          child: messages[index].isImage
                                              ? Container(
                                                  width: 200,
                                                  height: 200,
                                                  child: Image.file(
                                                    File(messages[index]
                                                        .message),
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      // This error builder will show when the image can't be loaded
                                                      return Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                              Icons
                                                                  .broken_image,
                                                              color: Colors
                                                                  .white70,
                                                              size: 40),
                                                          SizedBox(height: 8),
                                                          Text(
                                                            'Image unavailable',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  ),
                                                )
                                              : Text(
                                                  messages[index].message,
                                                  textAlign: isMe
                                                      ? TextAlign.end
                                                      : TextAlign.start,
                                                  softWrap: true,
                                                  overflow:
                                                      TextOverflow.visible,
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                )),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${msg.date.day}/${msg.date.month}/${msg.date.year}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          'At ${msg.date.hour}:${msg.date.minute}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            hintText: 'Type a message...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            hintStyle: TextStyle(
                                color: Color.fromARGB(255, 78, 74, 74)),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.summarize_outlined,
                          color: Colors.blue),
                      onPressed: () async {
                        try {
                          List<String> conversation =
                              messages.map((msg) => msg.message).toList();

                          String summary = await _webSocketService
                              .summarizeConversationWithCohere(
                            conversation,
                            'x9EyIZ3eAafBdx1iXX6vwz6SoRZLrDb5ubkjQLQY',
                          );

                          await showSummaryPopup(context, summary);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Failed to summarize conversation: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.photo_album, color: Colors.blue),
                      onPressed: () async {
                        final pickedFile = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                        );
                        if (pickedFile != null) {
                          setState(() {
                            _Image = File(pickedFile.path);
                          });

                          _webSocketService.sendMessage(
                            Message(
                              message: pickedFile.path,
                              senderId: widget.loggedUser.id,
                              date: DateTime.now(),
                              isImage: true,
                            ),
                          );
                          _controller.clear();
                        }
                      },
                      padding: const EdgeInsets.all(0),
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
      shape: RoundedRectangleBorder(
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
                    backgroundImage: NetworkImage(photoUrl),
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Name:',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                      Text(name,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text('Email:',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey)),
              Text(email,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Future<void> showSummaryPopup(BuildContext context, String summary) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '📝 Generating Summary...',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text('Please wait...'),
          ],
        ),
      ),
    );

    await Future.delayed(Duration(seconds: 3));
    Navigator.pop(context);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '📝 Conversation Summary',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(summary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
