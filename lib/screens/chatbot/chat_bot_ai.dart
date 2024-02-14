import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const apiKey = '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';
const apiUrl = 'https://api.openai.com/v1/completions';

class ChatBotAi extends StatefulWidget {
  const ChatBotAi({Key? key}) : super(key: key);

  @override
  State<ChatBotAi> createState() => _ChatBotAiState();
}

class _ChatBotAiState extends State<ChatBotAi> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text(
          "펫봇",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xff2B3320),
      ),
      body: Container(
        color: Color(0xff2B3320),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true, // 새로운 메시지가 맨 위로 오도록 변경
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      _messages[index].text,
                      textAlign: _messages[index].isUser
                          ? TextAlign.right
                          : TextAlign.left,
                    ),
                    subtitle: Text(_messages[index].isUser ? '' : 'GPT'),
                  );
                },
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: Image.asset(
                  'assets/images/petbot_images/petbot_main_image.png'), // petbot_images.png를 추가
            ),
            SizedBox(
              height: 8,
            ),
            Container(
              child: Text(
                '안녕하세요 윗독입니다\n무엇을 도와드릴까요?',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 120,
            ),
            Container(
                child: Text(
              'AI상담으로 조금 더 정확한 진단은\n전문가를 찾아주세요',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            )),
            SizedBox(
              height: 50,
            ),
            Container(
              color: Color(0xff6A7C73),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(0, 0, 0, 0.3),
                            borderRadius: BorderRadius.circular(100.0),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.6),
                              width: 2,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _controller,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '궁금하신 것을 물어보세요',
                                      hintStyle: TextStyle(
                                        fontSize: 18,
                                        color: Color.fromRGBO(227, 227, 227, 1.0),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    _sendMessage(_controller.text, true);
                                    generateText(_controller.text)
                                        .then((response) {
                                      _sendMessage(response, false);
                                    });
                                    _controller.clear();
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.arrow_upward,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage(String text, bool isUser) {
    DateTime currentTime = DateTime.now();
    String period = (currentTime.hour >= 12) ? '오후' : '오전';
    int hour =
        (currentTime.hour > 12) ? currentTime.hour - 12 : currentTime.hour;
    String formattedHour = hour.toString().padLeft(2, '0');
    String formattedMinute = currentTime.minute.toString().padLeft(2, '0');
    String formattedTime = "$period $formattedHour:$formattedMinute";

    setState(() {
      _messages.insert(0, ChatMessage("$formattedTime   $text", isUser));
    });
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage(this.text, this.isUser);
}

Future<String> generateText(String prompt) async {
  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey'
    },
    body: jsonEncode({
      "model": "text-davinci-003",
      'prompt':
          "What is $prompt? Tell me like you're explaining to an eight-year-old.",
      'max_tokens': 1000,
      'temperature': 0,
      'top_p': 1,
      'frequency_penalty': 0,
      'presence_penalty': 0
    }),
  );

  Map<String, dynamic> newresponse =
      jsonDecode(utf8.decode(response.bodyBytes));

  print("Response from GPT: $newresponse");

  return newresponse['choices'][0]['text'];
}
