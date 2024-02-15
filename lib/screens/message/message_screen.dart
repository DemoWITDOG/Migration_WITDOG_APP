import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:testing_pet/model/message.dart';
import 'package:testing_pet/model/user.dart';
import 'package:testing_pet/utils/constants.dart';

class MessageScreen extends StatefulWidget {
  late KakaoAppUser? appUser;
  final String petIdentity;

  MessageScreen({Key? key, required this.petIdentity, this.appUser})
      : super(key: key);

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  late TextEditingController _messagesController = TextEditingController();
  late Stream<List<Message>> _messagesStream = Stream.empty();
  late String petName;
  Map<String, dynamic> petProfileResponse = {};

  @override
  void initState() {
    _initializeMessagesStream();
    _loadPetProfileCache(widget.petIdentity);
    super.initState();
  }

  void _initializeMessagesStream()  {
    final myUserId = widget.appUser?.user_id;

    // Supabase's utility system
    final chatIdentity = supabase
        .from('messages')
        .select()
        .eq('user_id', myUserId);

    if (chatIdentity == myUserId) {
      // 사용자의 채팅 데이터가 있는 경우에만 계속 진행
      print('myUserId $myUserId');

      _messagesStream = supabase
          .from('messages')
          .stream(primaryKey: ['id'])
          .order('created_at')
          .map((maps) => maps
          .map((map) => Message.fromMap(map: map, myUserId: myUserId))
          .toList());

      _messagesStream.listen((data) {
        print('Received data from stream: $data');
      });
    } else if (widget.petIdentity != null) {
    final myPetId = widget.petIdentity;

    _messagesStream = supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('user_id')
        .map((maps) => maps
            .map((map) => Message.fromMap(map: map, myUserId: myPetId))
            .toList());
    _messagesStream.listen((data) {
      print('Received data from stream: $data');
    });
  }

    // super.initState();를 마지막에 호출
  }

  Future<void> _sendUserMessage(String messageController) async {
    print('Sending message: $messageController');

    final response = await supabase.from('messages').upsert([
      {
        'user_id': widget.appUser!.user_id,
        'context': messageController, // 이 부분이 추가되었습니다.
      }
    ]);

    print('sendMessage response: $response');

    if (response != null && response.error != null) {
      print('메시지 전송 에러: ${response.error}');
    } else {
      print('메시지가 성공적으로 전송되었습니다.');

      // 메시지 전송 후에 프로파일 캐시를 업데이트합니다.
      if (widget.appUser != null) {
        await _loadUserProfileCache(widget.appUser!.user_id);
      } else {
        await _loadPetProfileCache(widget.petIdentity ?? '');
      }

      // 스트림을 업데이트합니다.
      _initializeMessagesStream();
    }
  }

  Future<void> _sendPetMessage(String messageController) async {
    print('Sending message: $messageController');

    final response = await supabase.from('messages').upsert([
      {
        'pet_id': widget.petIdentity,
        'context': messageController, // 이 부분이 추가되었습니다.
      }
    ]);

    print('sendMessage response: $response');

    if (response != null && response.error != null) {
      print('메시지 전송 에러: ${response.error}');
    } else {
      print('메시지가 성공적으로 전송되었습니다.');

      // 메시지 전송 후에 프로파일 캐시를 업데이트합니다.
      if (widget.appUser != null) {
        await _loadUserProfileCache(widget.appUser!.user_id);
      } else {
        await _loadPetProfileCache(widget.petIdentity ?? '');
      }

      // 스트림을 업데이트합니다.
      _initializeMessagesStream();
    }
  }

  Future<Map<String, dynamic>?> _loadUserProfileCache(String userId) async {
    final profileResponse =
        await supabase.from('Kakao_User').select().eq('user_id', userId);

    print('user profile response : $profileResponse');

    if (profileResponse != null && profileResponse.isNotEmpty) {
      final userProfile = profileResponse[0];

      if (userProfile != null) {
        return {
          'nickname': userProfile['nickname'],
        };
      }
    }

    return null;
  }

  Future<Map<String, dynamic>?> _loadPetProfileCache(String petIdentity) async {
    var petProfileResponseList = await supabase
        .from('Add_UserPet')
        .select()
        .eq('pet_identity', '701895');

    print('petProfileResponse $petProfileResponseList');

    if (petProfileResponseList != null && petProfileResponseList.isNotEmpty) {
      // 첫 번째 항목에서 프로필 정보를 추출하여 업데이트
      var firstPetProfile = petProfileResponseList[0];

      print('firstPetProfile $firstPetProfile');

      setState(() {
        petProfileResponse = {
          'pet_name': firstPetProfile['pet_name'],
          'pet_images': firstPetProfile['pet_images'],
        };
      });
    } else {
      print('Pet profile not found or empty.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text(
          "채팅",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xff6A9E85),
      ),
      body: Container(
        color: Color(0xff6A9E85),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<Message>>(
                stream: _messagesStream,
                builder: (BuildContext context,
                    AsyncSnapshot<List<Message>> snapshot) {
                  print('context data : $context');
                  final messages = snapshot.data ?? [];

                  return ListView.builder(
                    reverse: false,
                    itemCount: messages.length,
                    itemBuilder: (BuildContext context, index) {
                      final message = messages[index];

                      // 현재 사용자의 메시지 여부 확인
                      bool isCurrentUserMessage =  widget.appUser != null
                          ? message.userId == widget.appUser?.user_id ||
                          message.petId == widget.petIdentity
                          : message.userId == widget.appUser?.user_id ||
                          message.petId == widget.petIdentity;

                      print('isCurrentUserMessage : $isCurrentUserMessage');
                      /*
                      widget.appUser != null
                          ? message.userId == widget.appUser?.user_id &&
                          message.petId == widget.petIdentity
                          : message.userId == widget.appUser?.user_id ||
                          message.petId == widget.petIdentity;
                          */

                      // 현재 메시지의 시간을 포맷팅
                      String formattedTime =
                          DateFormat('hh:mm a').format(message.createdAt);

                      return Align(
                        alignment: isCurrentUserMessage
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: isCurrentUserMessage
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: [
                              // 이미지 표시 부분
                              if (!isCurrentUserMessage)
                                _buildImageFromBase64(
                                    petProfileResponse['pet_images']
                                            ?.toString() ??
                                        ''),
                              SizedBox(width: isCurrentUserMessage ? 108 : 0),
                              // 이미지와 메시지 사이의 간격 조절

                              // 채팅 버블 부분
                              isCurrentUserMessage
                                  ? Container(
                                      child: Row(
                                        children: [
                                          // formattedTime 표시
                                          Text(
                                            formattedTime ?? '',  // formattedTime이 널이 아닌 경우에만 사용
                                            style: TextStyle(color: Colors.black),
                                          ),
                                          // 채팅 버블 부분
                                          Padding(
                                            padding: const EdgeInsets.only(left: 8.0),
                                            child: ChatBubble(
                                              clipper: ChatBubbleClipper1(
                                                  type: BubbleType.sendBubble),
                                              margin: EdgeInsets.only(top: 10),
                                              backGroundColor: Colors.yellow,
                                              child: Container(
                                                constraints: BoxConstraints(
                                                  maxWidth: double.infinity
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    FutureBuilder<
                                                        Map<String, dynamic>?>(
                                                      future: _loadUserProfileCache(
                                                          message.petId!),
                                                      builder: (context, snapshot) {
                                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                                          return CircularProgressIndicator();
                                                        } else if (snapshot.hasError) {
                                                          return Text('Error: ${snapshot.error}');
                                                        } else if (!snapshot.hasData || snapshot.data == null) {
                                                          return Column(
                                                            crossAxisAlignment: CrossAxisAlignment.end,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Text(message.context),
                                                                ],
                                                              ),
                                                            ],
                                                          );
                                                        } else {
                                                          Map<String, dynamic> profileData = snapshot.data!;

                                                          print('profileData : $profileData');
                                                          String senderName = profileData['nickname'] ?? 'Unknown User';

                                                          return Column(
                                                            crossAxisAlignment: CrossAxisAlignment.end,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Text('${senderName}'),
                                                                  Text('${message.context}'),
                                                                  SizedBox(width: 10,),
                                                                ],
                                                              ),
                                                            ],
                                                          );
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ChatBubble(
                                    clipper: ChatBubbleClipper1(
                                      type: BubbleType.receiverBubble,
                                    ),
                                    backGroundColor: Color(0xffE7E7ED),
                                    margin: EdgeInsets.only(top: 20),
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxWidth: double.infinity,
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            message.context != null ? message.context : '',
                                            style: TextStyle(color: Colors.black),
                                          ),
                                          SizedBox(height: 8),
                                          // 다른 채팅 내용 또는 구성 요소 추가 가능
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                      Text(
                                      formattedTime ?? '',
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ]
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
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
                                    controller: _messagesController,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500
                                    ),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '메세지를 입력해 주세요',
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
                                  onPressed: () async {
                                    final messageText = _messagesController.text;
                                    if (widget.appUser != null) {
                                      await _sendUserMessage(messageText);
                                      _messagesController.clear();
                                    } else {
                                      await _sendPetMessage(messageText);
                                      _messagesController.clear();
                                    }
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

  Widget _buildImageFromBase64(String base64String) {
    if (base64String == null || base64String.isEmpty) {
      print('Empty or null base64 string.');
      return Container();
    }

    // 나머지 코드는 동일하게 유지
    try {
      Uint8List bytes = base64.decode(base64String);
      print('Decoded bytes for image: $bytes');
      return Image.memory(bytes, width: 50, height: 50);
    } catch (e) {
      print('Error decoding Base64 string: $e');
      return Container();
    }
  }
}
