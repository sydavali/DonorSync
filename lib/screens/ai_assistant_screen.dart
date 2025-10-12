import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

// --- IMPORTANT: PASTE YOUR API KEY HERE ---
const String _apiKey = "PASTE_YOUR_GEMINI_API_KEY_HERE";
// -----------------------------------------

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  late final GenerativeModel _model;
  late final ChatSession _chat;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      // Use the gemini-pro model for chat
      model: 'gemini-pro',
      apiKey: _apiKey,
      // This is a safety setting to prevent harmful content
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none)
      ],
    );

    // Give the AI its instructions. This is the "prompt engineering" part.
    final systemInstruction = Content.text(
        'You are a helpful and friendly AI assistant for the DonorSync blood donation app. Your role is to answer user questions about blood donation eligibility, the donation process, and general health tips related to donating. Provide safe, accurate, and encouraging information. Do not give medical advice; instead, suggest users consult a doctor. Keep your answers concise and easy to understand.'
    );

    // Start a new chat session with the system instructions
    _chat = _model.startChat(history: [Content.system(systemInstruction.parts.last.text!)]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Donor Assistant"),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _chat.history.length,
                itemBuilder: (context, index) {
                  final content = _chat.history.toList()[index];
                  final text = content.parts
                      .whereType<TextPart>()
                      .map<String>((e) => e.text)
                      .join('');
                  // 'model' is the AI, 'user' is the person typing
                  return MessageWidget(
                    text: text,
                    isFromUser: content.role == 'user',
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: "Ask about donation eligibility...",
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox.square(dimension: 15),
                  if (_loading)
                    const CircularProgressIndicator()
                  else
                    IconButton(
                      onPressed: () => _sendMessage(_textController.text),
                      icon: const Icon(Icons.send),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;
    setState(() => _loading = true);

    try {
      final response = await _chat.sendMessage(Content.text(message));
      final text = response.text;
      if (text == null) {
        _showError('No response from API.');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      _textController.clear();
      setState(() => _loading = false);
      // Scroll to the bottom to show the new message
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Something went wrong'),
          content: SingleChildScrollView(child: Text(message)),
          actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
        );
      },
    );
  }
}

// Simple widget to display chat messages in a bubble
class MessageWidget extends StatelessWidget {
  const MessageWidget({
    super.key,
    required this.text,
    required this.isFromUser,
  });

  final String text;
  final bool isFromUser;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
            decoration: BoxDecoration(
              color: isFromUser ? Colors.red.shade100 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            margin: const EdgeInsets.only(bottom: 8),
            child: Text(text),
          ),
        ),
      ],
    );
  }
}