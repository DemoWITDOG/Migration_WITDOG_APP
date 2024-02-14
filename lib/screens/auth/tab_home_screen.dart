import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testing_pet/provider/pet_provider.dart';
import 'package:testing_pet/screens/chatbot/chat_bot_ai.dart';
import 'package:testing_pet/screens/message/message_screen.dart';
import 'package:testing_pet/screens/pet_add/pet_list_screen.dart';
import 'package:testing_pet/screens/routing/routing_helper.dart';
import 'package:testing_pet/screens/video_screen/video_chat_screen.dart';
import 'package:testing_pet/widgets/buttom_navbar_items.dart';
import 'package:testing_pet/widgets/service_guide_dialog.dart';

class TabHomeScreen extends StatefulWidget {
  late String petIdentity;

  TabHomeScreen({required this.petIdentity});

  @override
  _TabHomeScreen createState() => _TabHomeScreen();
}

class _TabHomeScreen extends State<TabHomeScreen> {
  bool _appBarVisible = true;
  int _selectedIndex = 0;
  late String petIdentity; // petIdentity 변수 추가

  @override
  void initState() {
    super.initState();
    petIdentity = widget.petIdentity; // widget에서 petIdentity 값 가져오기
  }

  void _performLogout(BuildContext context) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.remove('pet_identity');

    await Navigator.pushNamedAndRemoveUntil(
        context, '/login', (Route<dynamic> route) => false);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    routingHelper(context, index, _selectedIndex);
  }

  static List<Widget> _widgetOptions() => [
    Container(),
    Container(),
  ];

  @override
  Widget build(BuildContext context) {

    print('pet device pet account : $petIdentity');
    return Scaffold(
      endDrawer: buildDrawer(context),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
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
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.notifications_none,
                    color: Colors.grey,
                    size: 30,
                  ),
                ),
                Builder(
                  builder: (BuildContext context) {
                    return IconButton(
                      onPressed: () {
                        Scaffold.of(context).openEndDrawer();
                      },
                      icon: Icon(
                        Icons.menu,
                        color: Colors.grey,
                        size: 30,
                      ),
                    );
                  },
                ),
                SizedBox(width: 15),
              ],
            ),
          ];
        },
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                height: 320,
                color: Color(0xFF6ABFB9),
                child: Card(
                  elevation: 1.5,
                  color: Color(0xFF6ABFB9),
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
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Image.asset(
                                'assets/images/index_images/demo_dialog.png',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.all(25),
              sliver: SliverGrid.count(
                crossAxisCount: 2,
                children: [
                  buildCard(
                      context,
                      '챗 커뮤니티',
                      'assets/images/index_images/demo_chatbot.png',
                      MessageScreen(petIdentity: petIdentity)),
                  buildCard(
                    context,
                    '영상 통화',
                    'assets/images/index_images/demo_video_call.png',
                    VideoChatScreen(calleeId: petIdentity,),
                  ),
                ],
              ),
            ),
          ],
        )
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        items: bottomNavBarItems,
        onTap: _onItemTapped,
        selectedItemColor: Color(0xFF6ABFB9),
        showUnselectedLabels: _appBarVisible,
        unselectedItemColor: Colors.grey,
        unselectedLabelStyle: TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            height: 150,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF6ABFB9),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Text(
                '메뉴',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.home,
              color: Colors.grey[850],
            ),
            title: Text('홈'),
            onTap: () {
              // 변경: 홈 아이콘을 누를 때마다 홈 화면으로 이동하도록 수정
              setState(() {
                _selectedIndex = 0;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.logout,
              color: Colors.grey[850],
            ),
            title: Text('로그아웃'),
            onTap: () {
              _performLogout(context);
            },
          )
        ],
      ),
    );
  }
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


