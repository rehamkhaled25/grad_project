import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:graduation_project/services/gemini_service.dart';

class AICoachScreen extends StatefulWidget {
  const AICoachScreen({super.key});

  @override
  State<AICoachScreen> createState() => _AICoachScreenState();
}

class _AICoachScreenState extends State<AICoachScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  late final GenerativeModel _model;
  late final ChatSession _chatSession;
  bool _isTyping = false;
  bool _isInitialized = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _initGemini();
  }

  void _initGemini() {
    if (GeminiService.apiKeys.isEmpty) {
      setState(() {
        _errorMsg = "Gemini API key is missing. Please configure GEMINI_API_KEY in your .env file.";
        _isInitialized = false;
      });
      return;
    }

    try {
      final model = GeminiService.getModel(
        modelName: 'gemini-2.5-flash',
        systemInstruction: Content.system(
          "You are Nutra Coach, a friendly, certified dietitian. Answer user queries briefly, focusing on healthy eating, calories, and macros. Keep responses under 120 words."
        ),
      );

      if (model == null) {
        throw Exception("Failed to build model instance.");
      }
      
      _model = model;

      _chatSession = _model.startChat(history: [
        Content.model([
          TextPart("Hi! I'm Nutra Coach, your personal AI nutritionist. How can I help you today? You can ask me about healthy recipes, calorie tracking, or meal ideas!")
        ])
      ]);

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _errorMsg = "Initialization error: $e";
        _isInitialized = false;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();
    setState(() {
      _isTyping = true;
    });
    _scrollToBottom();

    int attempts = 0;
    const maxAttempts = 3;

    while (attempts < maxAttempts) {
      try {
        await _chatSession.sendMessage(Content.text(text));
        break; // Success
      } catch (e) {
        attempts++;
        final errStr = e.toString().toLowerCase();
        final isQuota = errStr.contains("quota") ||
                        errStr.contains("exhausted") ||
                        errStr.contains("429") ||
                        errStr.contains("limit");

        if (isQuota && attempts < maxAttempts && GeminiService.apiKeys.length > 1) {
          debugPrint("Quota exceeded during chat. Rotating and retrying... Attempt $attempts");
          GeminiService.rotateKey();

          final newModel = GeminiService.getModel(
            modelName: 'gemini-2.5-flash',
            systemInstruction: Content.system(
              "You are Nutra Coach, a friendly, certified dietitian. Answer user queries briefly, focusing on healthy eating, calories, and macros. Keep responses under 120 words."
            ),
          );

          if (newModel != null) {
            _model = newModel;
            _chatSession = _model.startChat(history: _chatSession.history.toList());
            continue; // Retry in loop
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e"), backgroundColor: Colors.redAccent),
          );
        }
        break;
      }
    }

    if (mounted) {
      setState(() {
        _isTyping = false;
      });
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F4F4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFFFE1E1),
                  radius: 20,
                  child: const Icon(Icons.psychology_rounded, color: Color(0xFFD90C0C), size: 22),
                ),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Nutra Coach",
                  style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "AI Dietitian",
                  style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
      body: !_isInitialized
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _errorMsg ?? "Loading chat model...",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _chatSession.history.length,
                    itemBuilder: (context, index) {
                      final message = _chatSession.history.toList()[index];
                      final isUser = message.role == 'user';
                      final text = message.parts
                          .whereType<TextPart>()
                          .map((e) => e.text)
                          .join('\n');

                      return _ChatBubble(isUser: isUser, text: text);
                    },
                  ),
                ),
                if (_isTyping)
                  const Padding(
                    padding: EdgeInsets.only(left: 20, bottom: 10),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFD90C0C)),
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Nutra Coach is typing...",
                          style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            hintText: "Ask anything about nutrition...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: const Color(0xffF4F4F4),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: _sendMessage,
                        child: CircleAvatar(
                          radius: 23,
                          backgroundColor: const Color(0xFFD90C0C),
                          child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
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
  final bool isUser;
  final String text;

  const _ChatBubble({required this.isUser, required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFFFFE1E1) : Colors.white,
          border: isUser ? Border.all(color: const Color(0xFF8C0B0B), width: 0.3) : null,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? const Color(0xFF8C0B0B) : Colors.black87,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
