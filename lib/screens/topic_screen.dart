import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/study_provider.dart';

class TopicsScreen extends StatefulWidget {
  const TopicsScreen({super.key});

  @override
  State<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
// Purani chat history load karo (agar pehle se koi hai)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudyProvider>().loadChatHistory();
    });
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

  Future<void> _sendChatMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    await context.read<StudyProvider>().sendChatMessage(text);
    _scrollToBottom();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudyProvider>();
    final goals = provider.goals;
    final messages = provider.chatMessages;
    final isLoading = provider.isChatLoading;

    final Map<String, Set<String>> subjectTopics = {};
    for (final g in goals) {
      subjectTopics.putIfAbsent(g.subject, () => {}).add(g.topic);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("Topics", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.black54),
            tooltip: 'Clear Chat',
            onPressed: () {
              context.read<StudyProvider>().clearChat();
            },
          ),
        ],
      ),
      body: Column(
        children: [
// ---------------- AI Chat Section ----------------
          Expanded(
            child: messages.isEmpty
                ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  "Ask about any topic to get a full explanation.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isUser = message['role'] == 'user';

                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser
                          ? const Color(0xFF4A6CF7)
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      message['content'] ?? '',
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black,
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(),
            ),

// ---------------- Message input box ----------------
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendChatMessage(),
                    decoration: InputDecoration(
                      hintText: "Ask a question about any topic...",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 48,
                  width: 48,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _sendChatMessage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A6CF7),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Icon(Icons.send),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

// ---------------- Existing Topics list (neeche, collapsible) ----------------
          if (subjectTopics.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              color: Colors.white,
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  const Text(
                    "Your Topics",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...subjectTopics.entries.map((entry) {
                    return ExpansionTile(
                      leading: const Icon(Icons.topic_outlined, color: Color(0xFF4A6CF7)),
                      title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w600)),
                      children: entry.value
                          .map((topic) => ListTile(
                        dense: true,
                        leading: const Icon(Icons.circle, size: 6),
                        title: Text(topic, style: const TextStyle(fontSize: 13)),
                        trailing: IconButton(
                          icon: const Icon(Icons.auto_awesome,
                              size: 16, color: Color(0xFF4A6CF7)),
                          onPressed: () {
                            _controller.text = "Explain $topic";
                            _sendChatMessage();
                          },
                        ),
                      ))
                          .toList(),
                    );
                  }),
                ],
              ),
            ),
        ],
      ),
    );
  }
}