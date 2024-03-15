import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:testing_pet/model/user.dart';
import 'package:testing_pet/screens/chatbot/chat_bot_ai.dart';
import 'package:testing_pet/screens/message/message_screen.dart';
import 'package:testing_pet/screens/pet_add/pet_add_screen.dart';
import 'package:testing_pet/screens/pet_add/pet_another_list_screen.dart';
import 'package:testing_pet/screens/pet_add/pet_list_screen.dart';
import 'package:testing_pet/screens/pet_add/pet_profile_screen.dart';
import 'package:testing_pet/screens/qr/pet_phone_qr_screen.dart';
import 'package:testing_pet/screens/video_screen/video_chat_screen.dart';
import 'package:testing_pet/widgets/buttom_navbar_items.dart';
import 'package:testing_pet/widgets/guest_dialog.dart';
import 'package:testing_pet/widgets/service_guide_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  final KakaoAppUser appUser;

  HomeScreen({required this.appUser});

  @override
  State<HomeScreen> createState() => _HomeScreenState(appUser: appUser);
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // 변경: _selectedIndex를 상태로 선언
  bool _appBarVisible = true;
  late KakaoAppUser appUser;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final dio = Dio();

  _HomeScreenState({required this.appUser});

  @override
  void initState() {
    super.initState();
    if (widget.appUser is KakaoAppUser) {
      appUser = widget.appUser;
    } else {
      // 예상치 못한 형식이라면 적절히 처리
      print('Unexpected type for widget.appUser');
    }
    _scaffoldKey = GlobalKey<ScaffoldState>();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      print('print guest user :${widget.appUser.user_id}');

      if (widget.appUser.user_id == 'guest') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GuestDialog()),
        );
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => _widgetOptions(widget.appUser)[index]),
      );
    }
  }

  void _performLogout(BuildContext context) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    await prefs.remove('password');

    await Navigator.pushNamedAndRemoveUntil(
        context, '/login', (Route<dynamic> route) => false);
  }

  static List<Widget> _widgetOptions(KakaoAppUser appUser) => [
        HomeScreen(appUser: appUser),
        PetAnotherListScreen(
          appUser: appUser,
        ),
        PetProfileScreen(appUser: appUser)
      ];

  void _getWitdogPage() async {
    final Uri _url = Uri.parse('https://smartwarekorea.com');

    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  void _getWitdogQ() async {
    final Uri _url = Uri.parse('https://witdog.kr');

    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('widget.appUser: ${widget.appUser.user_id}');
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: buildDrawer(context),
      appBar: AppBar(
              iconTheme: IconThemeData(color: Colors.grey),
              backgroundColor: Colors.white,
              toolbarHeight: 65,
              title: Row(
                children: [
                  Center(
                    child: Image.asset(
                      'assets/images/index_images/WITDOG.png',
                      width: 130,
                      height: 100,
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                Builder(
                  builder: (BuildContext context) {
                    return IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PetAddScreen(
                              appUser: widget.appUser,
                            ),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.add,
                        color: Colors.grey,
                        size: 30,
                      ),
                    );
                  },
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PetPhoneQrScreen(),
                      ),
                    );
                  },
                  icon: Image.asset(
                    'assets/images/index_images/demo_user_friend_add.png',
                    color: Colors.grey,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _scaffoldKey.currentState?.openEndDrawer(); // Builder 내에서 Scaffold.of 사용
                  },
                  icon: Icon(
                    Icons.menu,
                    color: Colors.grey,
                    size: 30,
                  ),
                ),
              ],
            ),
      body: Container(
        color: Colors.white, // 흰색 배경으로 설정
        child: ListView(
          children: [
            InkWell(
              onTap: () {
                _getWitdogPage();
              },
              child: Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Align(
                            alignment: Alignment.topCenter, // 또는 다른 정렬을 선택하세요
                            child: Column(
                              children: [
                                Text(
                                  '윗독에\n오신 것을\n환영해요',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    _getWitdogPage();
                                  },
                                  child: Text(
                                    '서비스 소개',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Color(0xFF6A9E85)),
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Image.asset(
                            'assets/images/index_images/demo_dialog.png',
                            width: 160,
                            height: 155,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 58,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25.0, right: 25.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
                itemCount: 4,
                itemBuilder: (context, index) {
                  switch (index) {
                    case 0:
                      return buildCard(
                        context,
                        '문자하기',
                        'assets/images/index_images/demo_chat.png',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MessageScreen(
                                appUser: appUser,
                                petIdentity: '',
                              ),
                            ),
                          );
                        },
                      );
                    case 1:
                      return buildCard(
                        context,
                        '영상통화하기',
                        'assets/images/index_images/demo_video_call.png',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  VideoChatScreen(callerId: appUser.user_id),
                            ),
                          );
                        },
                      );
                    case 2:
                      return buildCard(
                        context,
                        '챗봇하기',
                        'assets/images/index_images/demo_chatbot.png',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ChatBotAi()), // YourPetbotScreen은 실제로 이동하고자 하는 화면으로 변경해야 합니다.
                          );
                        },
                      );
                    case 3:
                      return buildCard(
                        context,
                        '커뮤니티',
                        'assets/images/index_images/demo_community.png',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PetListScreen(appUser: appUser),
                            ),
                          );
                        },
                      );
                    default:
                      return Container(); // Handle additional cases
                  }
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: bottomNavBarItems,
        selectedItemColor: const Color(0xFF6A9E85),
        showUnselectedLabels: true,
      ),
    );
  }

  Widget buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            Container(
              height: 50,
              child: Text('안녕하세요 ${appUser.nickname}님',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w400,
                  )),
            ),
            Divider(color: Colors.black12),
            SizedBox(
              height: 20,
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      PetAddScreen(appUser: appUser)));
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Color(0xffF4F4F4),
                          minimumSize: Size(46, 55),
                        ),
                        child: Image.asset(
                            'assets/images/index_images/drawer1.png'),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        '개추가',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      )
                    ],
                  ),
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _getWitdogQ();
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Color(0xffF4F4F4),
                          minimumSize: Size(46, 55),
                        ),
                        child: Image.asset(
                            'assets/images/index_images/drawer2.png'),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        '공지사항',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      )
                    ],
                  ),
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _getWitdogQ();
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Color(0xffF4F4F4),
                          minimumSize: Size(46, 55),
                        ),
                        child: Image.asset(
                            'assets/images/index_images/drawer3.png'),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'FAQ',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      )
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              child: TextButton(
                  onPressed: () {
                    _getWitdogPage();
                  },
                  child: Text(
                    '스마트웨어 정보',
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  )),
            ),
            Divider(
              color: Colors.black12,
            ),
            SizedBox(height: 620),
            Container(
              child: ElevatedButton(
                onPressed: () {
                  _performLogout(context);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white70,
                    minimumSize: Size(241, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    )),
                child: Text(
                  '로그아웃',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildCard(BuildContext context, String title, String imagePath,
      {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap, // 여기에서 onTap을 설정합니다.
      child: Card(
        color: Color(0xFF6A9E85),
        elevation: 1.5,
        child: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(imagePath, width: 100, height: 100),
              Text(
                title,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
