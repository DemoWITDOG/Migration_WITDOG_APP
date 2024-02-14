import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:testing_pet/screens/qr/pet_qr_camera_screen.dart';
import 'package:testing_pet/utils/constants.dart';

class PetPhoneQrScreen extends StatefulWidget {
  const PetPhoneQrScreen({Key? key}) : super(key: key);

  @override
  State<PetPhoneQrScreen> createState() => _PetPhoneQrScreenState();
}

class _PetPhoneQrScreenState extends State<PetPhoneQrScreen> {
  late Future<void> _initializeControllerFuture;
  String? _petPhoneData;
  String? _petNameData;
  String? _userName;



  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeCamera();
    _fetchPetPhoneData();
    _fetchPetNameData();
    _fetchUserName();
  }

  Future<void> _initializeCamera() async {
    // 카메라 초기화 로직은 PetQrCameraScreen에 이미 있으므로 여기에는 추가로 필요하지 않습니다.
  }

  Future<void> _fetchPetPhoneData() async {
    final response = await supabase.from('Add_UserPet').select('pet_phone');

    print('pet phone data : $response');

    List<dynamic> petPhones = response;
    print('pet petPhones data : $petPhones');

    if (petPhones.isNotEmpty) {
      // 첫 번째 항목의 'pet_phone' 값을 가져옴
      String firstPetPhone = petPhones[0]['pet_phone'] as String;
      setState(() {
        _petPhoneData = firstPetPhone;
      });
    } else {
      print('No pet phone data available.');
    }
  }

  Future<void> _fetchPetNameData() async {
    final response = await supabase.from('Add_UserPet').select('pet_name');

    print('pet name data : $response');

    List<dynamic> petName = response;
    print('pet name data : $petName');

    if (petName.isNotEmpty) {
      // 첫 번째 항목의 'pet_phone' 값을 가져옴
      String firstName = petName[0]['pet_name'] as String;
      setState(() {
        _petNameData = firstName;
      });
    } else {
      print('No pet phone data available.');
    }
  }

  Future<void> _fetchUserName() async {
    final response = await supabase.from('Kakao_User').select('nickname');

    print('user nickname response : $response');

    // 추가: 사용자 닉네임 설정
    setState(() {
      _userName = response[0]['nickname'] as String?;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.grey),
        backgroundColor: Colors.white,
        toolbarHeight: 65,
        title: Text('친구 반려견 초대하기'),
        actions: <Widget>[
          Builder(
            builder: (BuildContext context) {
              return IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PetQrCameraScreen(),
                    ),
                  );
                },
                icon: Icon(
                  Icons.fullscreen_rounded,
                  color: Colors.grey,
                  size: 30,
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(
              top: 50,
              child: Column(
                children: <Widget>[
                  if (_petPhoneData != null)
                    Container(
                      width: 216,
                      height: 276,
                      decoration: BoxDecoration(
                        color: Color(0xFF16C077),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 80.0, left: 20, right: 20, bottom: 20),
                        child: QrImageView(
                          data: _petPhoneData!,
                          backgroundColor: Colors.white,
                          size: 200,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Positioned(
              top: 72,
              left: 120,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (_petNameData != null)
                    Text('$_petNameData',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700
                    )), // 펫 이름 추가
                  if (_userName != null)
                    Text('$_userName',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500
                    ),), // 사용자 닉네임 추가
                ],
              ),
            ),
            Positioned(
              top: 63,
              right: 125,
              child: Image.asset(
                'assets/images/emoticon_images/emoticon_heart.png',
                width: 80,
                height: 72,
              ),
            ),
            Positioned(
              top: 340,
              child: Text(
              '위에 있는 QR을\n핸드폰으로 찍어주세요',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),),
          ],

        ),

      ),
    );
  }
}
