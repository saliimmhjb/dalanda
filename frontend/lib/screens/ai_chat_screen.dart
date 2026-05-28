import 'package:dalanda/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/common.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  // 1. Chat State
  final List<Map<String, String>> _messages = [
    {
      "role": "bot",
      "text": "Hello! I am Dalanda. I have access to the company database. How can I help you with HR tasks today?"
    }
  ];

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isBotTyping = false;

  // 2. Logic to handle messages
  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    String userText = _controller.text.trim();

    setState(() {
      _messages.add({"role": "user", "text": userText});
      _controller.clear();
      _isBotTyping = true;
    });

    // Auto-scroll to show the user's message
    _scrollToBottom();

    // 🔥 Call the Django API (which talks to Ollama)
    String botReply = await ApiService.getAiResponse(userText);

    if (mounted) {
      setState(() {
        _isBotTyping = false;
        _messages.add({"role": "bot", "text": botReply});
      });
      // Auto-scroll to show the bot's reply
      _scrollToBottom();
    }
  }

  // Helper to keep the chat at the bottom
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
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWrapper(
      safeBottom: false, // We handle bottom padding manually for the nav bar
      child: Column(
        children: [
          // --- Header ---
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [Color(0xFF6A4CFF), Color(0xFFB84CFF)]),
                  ),
                  child: const CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xFF1E1E2A),
                    child: Text('D', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dalanda AI', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Local Intelligence Active', style: GoogleFonts.poppins(fontSize: 12, color: Colors.greenAccent)),
                  ],
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),

          // --- Chat Messages List ---
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                bool isUser = _messages[index]["role"] == "user";
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isUser
                          ? const Color(0xFF6A4CFF)
                          : Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(isUser ? 20 : 0),
                        bottomRight: Radius.circular(isUser ? 0 : 20),
                      ),
                    ),
                    child: Text(
                      _messages[index]["text"]!,
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                    ),
                  ),
                );
              },
            ),
          ),

          // --- Thinking Indicator ---
          if (_isBotTyping)
            Padding(
              padding: const EdgeInsets.only(left: 25, bottom: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Dalanda is analyzing database...",
                  style: GoogleFonts.poppins(
                      color: Colors.white30,
                      fontSize: 12,
                      fontStyle: FontStyle.italic
                  ),
                ),
              ),
            ),

          // --- Input Area ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 55,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E2A),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Ask about employees, leaves...",
                        hintStyle: GoogleFonts.poppins(color: Colors.white30, fontSize: 14),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    height: 55,
                    width: 55,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [Color(0xFF6A4CFF), Color(0xFFB84CFF)]),
                    ),
                    child: const Icon(Icons.send_rounded, color: Colors.white),
                  ),
                )
              ],
            ),
          ),

          // Space for the Floating Bottom Navigation Bar (approx 100px)
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}