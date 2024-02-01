import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testing_pet/model/user.dart';
import 'package:testing_pet/provider/auth_provider.dart';
import 'package:testing_pet/screens/chatbot/chat_bot_ai.dart';
import 'package:testing_pet/screens/message/message_screen.dart';
import 'package:testing_pet/screens/pet_add/pet_add_screen.dart';
import 'package:testing_pet/screens/pet_add/pet_another_list_screen.dart';
import 'package:testing_pet/screens/pet_add/pet_list_screen.dart';
import 'package:testing_pet/screens/pet_add/pet_profile_screen.dart';
import 'package:testing_pet/screens/routing/routing_helper.dart';
import 'package:testing_pet/screens/video_screen/video_chat_screen.dart';
import 'package:testing_pet/widgets/buttom_navbar_items.dart';
import 'package:testing_pet/widgets/guest_dialog.dart';
import 'package:testing_pet/widgets/service_guide_dialog.dart';

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
  }

  void _onItemTapped(int index) {
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
        PetAnotherListScreen(appUser: appUser,),
        PetProfileScreen(appUser: appUser)
      ];

  @override
  Widget build(BuildContext context) {
    print('widget.appUser: ${widget.appUser.user_id}');
    return Scaffold(
      appBar: _appBarVisible
          ? AppBar(
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
                SizedBox(width: 15),
              ],
            )
          : null,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            floating: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Color(0xFFD4ECEA),
                child: Card(
                  elevation: 1.5,
                  color: Color(0xFFD4ECEA),
                  child: InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return ServiceGuideDialog();
                        },
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(1),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Image.asset(
                                  'assets/images/index_images/demo_dialog.png'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(10),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              children: [
                buildCard(
                  context,
                  '영상 통화',
                  'assets/images/index_images/demo_video_call.png',
                  VideoChatScreen(callerId: appUser.user_id),
                ),
                buildCard(
                  context,
                  '채팅',
                  'assets/images/index_images/demo_chat.png',
                  MessageScreen(
                    appUser: appUser,
                    petIdentity: '',
                  ),
                ),
                buildCard(
                  context,
                  '펫 봇',
                  'assets/images/index_images/demo_chatbot.png',
                  ChatBotAi(),
                ),
                buildCard(
                  context,
                  '반려 프로필',
                  'assets/images/index_images/demo_community.png',
                  PetListScreen(appUser: appUser),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex < bottomNavBarItems.length ? _selectedIndex : 0,
        onTap: _onItemTapped,
        items: bottomNavBarItems,
        selectedItemColor: const Color(0xFF01DF80),
        showUnselectedLabels: true,
      ),
    );
  }

  Widget buildCard(
      BuildContext context, String title, String imagePath, Widget route) {
    return Card(
      color: Color(0xFFD4ECEA),
      elevation: 1.5,
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return route;
          }));
        },
        child: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(imagePath, width: 100, height: 100),
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
