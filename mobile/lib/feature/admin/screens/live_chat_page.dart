import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:bengkel_online_flutter/core/theme/app_colors.dart';
import 'package:bengkel_online_flutter/core/services/auth_provider.dart';

class LiveChatPage extends StatefulWidget {
  const LiveChatPage({super.key});

  @override
  State<LiveChatPage> createState() => _LiveChatPageState();
}

class _LiveChatPageState extends State<LiveChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  
  Timer? _pollingTimer;
  bool _isLoading = true;
  bool _isSending = false;
  String? _errorMessage;
  DateTime? _lastMessageTime;
  String? _roomId;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    
    if (user == null) {
      setState(() {
        _errorMessage = 'User not authenticated';
        _isLoading = false;
      });
      return;
    }

    // Generate room ID based on user ID - ADMIN VERSION
    _roomId = 'support_admin_${user.id}';
    
    // Load chat history
    await _loadHistory();
    
    // Start polling for new messages every 3 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _pollNewMessages();
    });
  }

  Future<void> _loadHistory() async {
    try {
      final auth = context.read<AuthProvider>();
      final token = auth.token;
      
      if (token == null || _roomId == null) return;

      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/v1/chat/history?room_id=$_roomId&limit=50'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List messages = data['data'] ?? [];
        
        setState(() {
          _messages.clear();
          for (var msg in messages) {
            _messages.add(ChatMessage.fromJson(msg));
            _lastMessageTime = DateTime.parse(msg['created_at']);
          }
          _isLoading = false;
        });
        
        _scrollToBottom();
      } else {
        debugPrint('❌ Load history failed: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        setState(() {
          _errorMessage = 'Failed to load chat history (${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Load history exception: $e');
      debugPrint('Stack: $stackTrace');
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }



  bool _isAiTyping = false;



  Future<void> _pollNewMessages() async {
    if (_roomId == null || _lastMessageTime == null) return;

    try {
      final auth = context.read<AuthProvider>();
      final token = auth.token;
      
      if (token == null) return;

      final afterTime = _lastMessageTime!.toIso8601String();
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/v1/chat/messages?room_id=$_roomId&after=$afterTime'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List newMessages = data['data'] ?? [];
        
        if (newMessages.isNotEmpty) {
          setState(() {
            bool hasAdminReply = false;
            for (var msg in newMessages) {
              final newMsg = ChatMessage.fromJson(msg);
              // Check if message already exists (deduplication)
              final exists = _messages.any((m) => m.id == newMsg.id);
              if (!exists) {
                _messages.add(newMsg);
                _lastMessageTime = DateTime.parse(msg['created_at']);
                if (!newMsg.isUser) hasAdminReply = true;
              }
            }
            if (hasAdminReply) {
                _isAiTyping = false;
            }
          });
          
          _scrollToBottom();
        }
      }
    } catch (e) {
      debugPrint('Polling error: $e');
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isSending || _roomId == null) return;

    final messageText = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _isSending = true;
      _isAiTyping = true; // Show typing indicator immediately
    });

    // Set timeout to clear typing indicator if no response after 30 seconds
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted && _isAiTyping) {
        setState(() {
          _isAiTyping = false;
        });
        debugPrint('⚠️ AI typing timeout - cleared indicator');
      }
    });

    try {
      final auth = context.read<AuthProvider>();
      final token = auth.token;
      
      if (token == null) return;

      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/v1/chat/send'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'room_id': _roomId,
          'message': messageText,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final newMessage = ChatMessage.fromJson(data['data']);
        
        setState(() {
          _messages.add(newMessage);
          _lastMessageTime = newMessage.timestamp;
          _isSending = false;
        });
        
        _scrollToBottom();
      } else {
        debugPrint('❌ Send message failed: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        
        setState(() {
          _isSending = false;
          _isAiTyping = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send message (${response.statusCode})')),
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Send message exception: $e');
      debugPrint('Stack: $stackTrace');
      
      setState(() {
        _isSending = false;
        _isAiTyping = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _confirmClearChat() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Chat?'),
        content: const Text('Semua riwayat chat akan dihapus permanen. Lanjutkan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.primaryRed),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _clearChat();
    }
  }

  Future<void> _clearChat() async {
     try {
      final auth = context.read<AuthProvider>();
      final token = auth.token;
      
      if (token == null || _roomId == null) return;

      setState(() => _isLoading = true);

      final response = await http.delete(
        Uri.parse('http://10.0.2.2:8000/api/v1/chat/history'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'room_id': _roomId}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _messages.clear();
          _isLoading = false;
        });
        if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Riwayat chat berhasil dihapus')),
             );
        }
      } else {
        setState(() => _isLoading = false);
        debugPrint('❌ Clear chat failed: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('❌ Clear chat error: $e');
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildQuickQuestionChip(String text) {
    return ActionChip(
      label: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: AppColors.primaryRed,
        ),
      ),
      backgroundColor: Colors.white,
      side: BorderSide(color: AppColors.primaryRed.withValues(alpha: 0.5)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      onPressed: () {
        if (!_isSending) {
            _messageController.text = text;
            _sendMessage();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: AppColors.primaryRed,
          title: const Text('Live Chat'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: AppColors.primaryRed,
          title: const Text('Live Chat'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(_errorMessage!, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF510707),
                Color(0xFF9B0D0D),
                Color(0xFFB70F0F),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(Icons.support_agent, color: AppColors.primaryRed, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Customer Support',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Online',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'clear_chat') {
                _confirmClearChat();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_chat',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Hapus Chat'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Operational hours banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              border: Border(
                bottom: BorderSide(color: AppColors.warning.withValues(alpha: 0.3), width: 1),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, size: 16, color: AppColors.warning),
                const SizedBox(width: 8),
                Text(
                  'Jam Operasional: Senin - Minggu (08:00 - 22:00 WIB)',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.warning.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),

          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isAiTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                    return const _TypingIndicator();
                }
                return _ChatBubble(message: _messages[index]);
              },
            ),
          ),

          // Quick Questions
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildQuickQuestionChip('Apa itu BBI Hub?'),
                const SizedBox(width: 8),
                _buildQuickQuestionChip('Cara upgrade Member?'),
                const SizedBox(width: 8),
                _buildQuickQuestionChip('Lupa Password'),
                const SizedBox(width: 8),
                _buildQuickQuestionChip('Fitur BBI Hub Plus'),
                const SizedBox(width: 8),
                _buildQuickQuestionChip('Hubungi Admin'),
              ],
            ),
          ),

          // Message input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.backgroundWhite,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.attach_file, color: AppColors.primaryRed),
                    onPressed: () {
                      // Attach file (future feature)
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      enabled: !_isSending,
                      decoration: InputDecoration(
                        hintText: 'Ketik pesan...',
                        hintStyle: GoogleFonts.poppins(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: AppColors.primaryRed),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        filled: true,
                        fillColor: AppColors.backgroundLight,
                      ),
                      style: GoogleFonts.poppins(fontSize: 14),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: _isSending 
                          ? AppColors.primaryRed.withValues(alpha: 0.5)
                          : AppColors.primaryRed,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: _isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: _isSending ? null : _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryRed,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.support_agent, color: Colors.white, size: 18),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                   SizedBox(
                       width: 12, height: 12,
                       child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textSecondary)
                   ),
                   const SizedBox(width: 8),
                   Text(
                     'Sedang mengetik...',
                     style: GoogleFonts.poppins(
                       color: AppColors.textSecondary,
                       fontSize: 12,
                       fontStyle: FontStyle.italic
                     ),
                   ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryRed,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.support_agent, color: Colors.white, size: 18),
            ),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: message.isUser ? AppColors.primaryRed : AppColors.backgroundWhite,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(message.isUser ? 20 : 4),
                      bottomRight: Radius.circular(message.isUser ? 4 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: GoogleFonts.poppins(
                      color: message.isUser ? AppColors.textOnPrimary : AppColors.textPrimary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('HH:mm').format(message.timestamp),
                  style: GoogleFonts.poppins(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (message.isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class ChatMessage {
  final int id;
  final String text;
  final String userName;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.userName,
    required this.isUser,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final userType = json['user_type'] ?? 'support';
    // ADMIN VERSION: admin messages are from user (isUser = true)
    return ChatMessage(
      id: json['id'],
      text: json['message'],
      userName: json['user_name'] ?? 'Unknown',
      isUser: userType == 'admin', // Changed from 'owner' to 'admin'
      timestamp: DateTime.parse(json['created_at']).toLocal(),
    );
  }
}
