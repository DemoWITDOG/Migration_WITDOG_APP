import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testing_pet/provider/auth_provider.dart';
import 'package:testing_pet/provider/pet_provider.dart';
import 'package:testing_pet/screens/auth/tab_home_screen.dart';

class TabLoginScreen extends StatefulWidget {
  const TabLoginScreen({Key? key}) : super(key: key);

  @override
  State<TabLoginScreen> createState() => _TabLoginScreenState();
}

class _TabLoginScreenState extends State<TabLoginScreen> {
  late String petDevice;
  late TextEditingController petAccountController;

  @override
  void initState() {
    super.initState();
    petAccountController = TextEditingController(); // petAccountController 초기화 추가
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationBuilder(
        builder: (context, orientation) {
          return orientation == Orientation.portrait
              ? _buildPort()
              : _buildLand();
        },
      ),
    );
  }

  Widget _buildPort() {
    PetProvider petProvider = Provider.of<PetProvider>(context, listen: false);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/login_images/safe_area.png'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 240.0),
            child: Align(
              alignment: Alignment.bottomCenter,  // 하단 중앙 정렬로 변경
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '동물과의 커뮤니케이션이 즐겁다!',
                    style: TextStyle(
                      fontSize: 42.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.25,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),
                  // 반려동물 장치 입력을 위한 텍스트 필드 추가
                  Container(
                    width: 375,
                    height: 56,
                    child: TextField(
                      controller: petAccountController,
                      decoration: InputDecoration(
                        hintText: '반려동물 계정을 입력하세요',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(horizontal: 80, vertical: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                      ),
                    ),
                    onPressed: () async {
                      // 텍스트 필드에서 반려동물 장치 값을 가져옵니다.
                      petDevice = petAccountController.text;

                      try {
                        // PetProvider에 checkPetIdentity와 유사한 함수가 있다고 가정합니다.
                        bool isPetValid = await petProvider.checkPetIdentity(petDevice);

                        if (isPetValid) {
                          print('로그인 성공!');
                          // 홈 화면으로 이동
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TabHomeScreen(petIdentity: petDevice),
                            ),
                          );
                        } else {
                          // 반려동물 식별자가 유효하지 않은 경우 처리
                          print('유효하지 않은 반려동물 식별자: $petDevice');
                        }
                      } catch (e) {
                        // petdevicelogin 함수에서 예외가 발생한 경우 처리
                        print('로그인 중 오류 발생: $e');
                        // 로그인 실패 시 또는 적절한 예외 처리 수행
                      }
                    },
                    child: Container(
                      width: 323,
                      height: 56,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '반려동물 계정으로 시작하기',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildLand() {
    PetProvider petProvider = Provider.of<PetProvider>(context, listen: false);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/login_images/safe_area.png'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 122),
            child: Align(
              alignment: Alignment.bottomCenter,  // 하단 중앙 정렬로 변경
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '동물과의 커뮤니케이션이 즐겁다!',
                    style: TextStyle(
                      fontSize: 42.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.25,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),
                  // 반려동물 장치 입력을 위한 텍스트 필드 추가
                  Container(
                    width: 375,
                    height: 56,
                    child: TextField(
                      controller: petAccountController,
                      decoration: InputDecoration(
                        hintText: '반려동물 계정을 입력하세요',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(horizontal: 80, vertical: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                      ),
                    ),
                    onPressed: () async {
                      // 텍스트 필드에서 반려동물 장치 값을 가져옵니다.
                      petDevice = petAccountController.text;

                      try {
                        // PetProvider에 checkPetIdentity와 유사한 함수가 있다고 가정합니다.
                        bool isPetValid = await petProvider.checkPetIdentity(petDevice);

                        if (isPetValid) {
                          print('로그인 성공!');
                          // 홈 화면으로 이동
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TabHomeScreen(petIdentity: petDevice),
                            ),
                          );
                        } else {
                          // 반려동물 식별자가 유효하지 않은 경우 처리
                          print('유효하지 않은 반려동물 식별자: $petDevice');
                        }
                      } catch (e) {
                        // petdevicelogin 함수에서 예외가 발생한 경우 처리
                        print('로그인 중 오류 발생: $e');
                        // 로그인 실패 시 또는 적절한 예외 처리 수행
                      }
                    },
                    child: Container(
                      width: 323,
                      height: 56,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '반려동물 계정으로 시작하기',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
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