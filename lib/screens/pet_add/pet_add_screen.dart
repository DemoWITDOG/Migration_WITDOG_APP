import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:testing_pet/model/pet_model.dart';
import 'package:testing_pet/model/user.dart';
import 'package:testing_pet/provider/auth_provider.dart';
import 'package:testing_pet/screens/home_screen.dart';
import 'package:testing_pet/utils/constants.dart';

class PetAddScreen extends StatefulWidget {
  late KakaoAppUser appUser;

  PetAddScreen({required this.appUser});

  @override
  State<PetAddScreen> createState() => _PetAddScreenState(appUser: appUser);
}

class _PetAddScreenState extends State<PetAddScreen> {
  late KakaoAppUser appUser;

  _PetAddScreenState({required this.appUser});

  PetModel petModel = PetModel();

  String petName = ''; // 별칭
  String selectedBreed = ''; // 품종
  String selectedFurColor = ''; // 털색
  String selectedDropdown = '';
  String selectedGender = '암컷';
  bool selectedIsNeutered = false;
  String petAge = '';
  String randomNumberText = '';
  String userEnteredNumber = '';
  String randomNumberHistory = '';
  String userEnteredNumberHistory = '';
  bool isDuplicate = false;
  String petIdentity = (Random().nextInt(900000) + 100000).toString();
  String duplicateText = '';
  bool isRandomMode = true; // 랜덤 모드 여부를 나타내는 변수 추가
  String userEnteredNumberText = '';
  late ImagePicker picker;
  XFile? image;
  Uint8List? imageBytes;

  Future<void> initializeImagePicker() async {
    picker = ImagePicker();
    image = await picker.pickImage(source: ImageSource.gallery);
  }

// 데이터베이스에 반려동물 정보 추가 함수
  Future<void> _addPetToDatabase() async {
    try {
      final userId = await KakaoAppUser.getUserID();

      String petAge = myPetAge(petBirthDay);
      print('Pet Age: $petAge');

      PetModel petModel = PetModel();

      String petPhone = await petModel.saveToDatabase(
        selectedGender: selectedGender,
        selectedFurColor: selectedFurColor,
        selectedPetAge: petAge,
        selectedBreed: selectedBreed,
      );
      Uint8List? imageBytes;
      if (image != null) {
        imageBytes = await image!.readAsBytes();
      }

      String? imageUrl;
      if (imageBytes != null) {
        imageUrl = await _uploadImageToDatabase(imageBytes);
      }

      // DB에 펫 데이터 저장
      await PetModel().addPet(
        userId: userId,
        petImages: imageBytes ?? Uint8List(0),
        petName: petName,
        petBreed: selectedBreed,
        //petSize: selectedSize,
        petFurColor: selectedFurColor,
        petGender: selectedGender,
        petAge: petAge,
        petPhone: petPhone,
        petIdentity: petIdentity,
        isFavorite: false,
      );
    } catch (error) {
      print('Error adding pet: $error');
      rethrow;
    }
  }

  // 이미지 선택
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage =
    await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      image = pickedImage;
    });
  }

// 이미지를 Supabase 데이터베이스에 업로드 및 URL 반환
  Future<String?> _uploadImageToDatabase(Uint8List imageBytes) async {
    try {
      final imageUrl = 'data:image/jpeg;base64,${base64Encode(imageBytes)}';
      final userId = await KakaoAppUser.getUserID();

      print('Image URL: $imageUrl');

      final response = await supabase.from('pet_images').upsert([
        {
          'user_id': userId,
          'pet_images': imageUrl,
        }
      ]);
      print('images response : $response');

      if (response != null) {
        // 에러 처리
        print('프로필 및 이미지 데이터 저장 오류: ${response.message}');
      } else {
        // 성공적으로 데이터 저장
        print('프로필 및 이미지 데이터가 성공적으로 저장되었습니다.');
      }
    } catch (error) {
      // 에러 처리
      print('프로필 및 이미지 데이터 저장 중 오류 발생: $error');
    }
  }

  void _onAddButtonClicked() async {
    try {
      await _pickImage(); // 이미지 선택 추가

      if (image == null) {
        // 이미지가 선택되지 않은 경우 예외 처리
        print('Error: Image not selected');
        return;
      }

      final imageBytes = await image!.readAsBytes();

      if (imageBytes == null) {
        // 이미지 바이트가 없는 경우 예외 처리
        print('Error: Image bytes are null');
        return;
      }

      // 이미지를 데이터베이스에 업로드하고 URL 가져오기
      await _uploadImageToDatabase(imageBytes!);

      // 나머지 코드 작성...
    } catch (error) {
      print('Error adding pet: $error');
    }
  }

  void checkForDuplicates() async {
    List<String> lastFourDigitsList = await getPetPhoneLastFourDigits();
    // 중복 확인
    bool isDuplicates =
    lastFourDigitsList.any((digits) => randomNumberText.contains(digits));

    // 중복 여부에 따라 메시지 업데이트
    setState(() {
      if (isDuplicates) {
        // 중복된 경우 - 빨간색으로 표시
        duplicateText = '이 번호는 이미 등록되었습니다.';
      } else {
        // 사용 가능한 경우 - 초록색으로 표시
        isDuplicate = true;
        duplicateText = '사용 가능한 번호입니다.';
      }
    });
  }

  void checkForUserEnteredDuplicates() async {
    List<String> userLastFourDigitsList = await getPetPhoneLastFourDigits();
    print('userEnteredNumberText:${userEnteredNumberText}');
    // 중복 확인
    print('userLastFourDigitsList:$userLastFourDigitsList ');
    bool isDuplicates = userLastFourDigitsList
        .any((digits) => userEnteredNumberText.contains(digits));

    // 중복 여부에 따라 메시지 업데이트
    setState(() {
      if (isDuplicates) {
        // 중복된 경우 - 빨간색으로 표시
        duplicateText = '이 번호는 이미 등록되었습니다.';
      } else {
        // 사용 가능한 경우 - 초록색으로 표시
        isDuplicate = true;
        duplicateText = '사용 가능한 번호입니다.';
      }
    });
  }

// Supabase에서 pet_phone의 뒤에서 4자리를 가져오는 함수
  Future<List<String>> getPetPhoneLastFourDigits() async {
    final response = await supabase.from('Add_UserPet').select('pet_phone');

    print('phone list number : $response');

    // pet_phone 값을 추출하여 뒤에서 4자리만 남기고 리스트로 만듦
    List<String> lastFourDigitsList = response.map<String>((pet) {
      String petPhoneValue = pet['pet_phone'];
      print('petPhoneValue : $petPhoneValue');
      print(
          'petPhoneValue.substring(petPhoneValue.length - 4)${petPhoneValue.substring(petPhoneValue.length - 4)}');
      return petPhoneValue.substring(petPhoneValue.length - 4);
    }).toList() ??
        [];

    print('lastFourDigitsList $lastFourDigitsList');

    return lastFourDigitsList;
  }

  TextEditingController phoneNumberController = TextEditingController();

  List<String> dogSizeList = ['소형', '중형', '대형'];
  List<String> dogBreedList = [
    '닥스훈트',
    '도베르만',
    '라사압소',
    '리트리버',
    '말티즈',
    '보더콜리',
    '불도그',
    '블러드하운드',
    '비글',
    '비숑',
    '스피츠',
    '시바견',
    '시츄',
    '웰시코기',
    '진돗개',
    '치와와',
    '퍼그',
    '포메라니안',
    '푸들',
    '믹스견'
  ];
  List<String> dogColor = [
    '크림색',
    '검은색',
    '금색',
    '빨간색',
    '블루말색',
    '연갈색',
    '은색',
    '진갈색',
    '진회색'
  ];

  DateTime petBirthDay = DateTime.now(); //datePicker-오늘을 기준으로 변숫값 선언

  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 300,
        padding: const EdgeInsets.only(top: 6.0),
        // The Bottom margin is provided to align the popup above the system
        // navigation bar.
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        // Provide a background color for the popup.
        color: CupertinoColors.systemBackground.resolveFrom(context),
        // Use a SafeArea widget to avoid system overlaps.
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
      barrierDismissible: true, //외부 탭하면 다이얼로그 닫기
    );
    String petAge = myPetAge(petBirthDay); // 여기서 myPetAge의 반환값을 저장합니다.
    print('Pet Age: $petAge');
    myPetAge(petBirthDay);
  }

  myPetAge(DateTime selectedDate) {
    DateTime nowDate = DateTime.now();
    int age = nowDate.year - selectedDate.year;
    int month1 = nowDate.month;
    int month2 = selectedDate.month;

    if (month1 < month2) {
      age--;
    }
    if (month1 == month2) {
      int day1 = nowDate.day;
      int day2 = selectedDate.day;
      if (day2 > day1) {
        age--;
      }
    }
    return age.toString();
  }

  TextEditingController _controller = TextEditingController();

  void _setControllerText() {
    setState(() {
      _controller.text =
      isRandomMode ? randomNumberText : userEnteredNumberText;
    });
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    print('widget.app : ${widget.appUser.user_id}');
    print('randomNumberHistory : $randomNumberHistory'); // 현재 번호를 이력에 추가)
    print(
        'userEnteredNumberHistory : $userEnteredNumberHistory'); // 현재 번호를 이력에 추가)

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: Text(
                '반려동물추가',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              actions: [
                GestureDetector(
                  onTap: () async {
                    await _addPetToDatabase();
                    Navigator.pushAndRemoveUntil(
                      context,
                      // TODO : 시간날때 고쳐야 되는 부분
                      MaterialPageRoute(
                        builder: (context) {
                          if (authProvider.appUser != null &&
                              authProvider.appUser is KakaoAppUser) {
                            KakaoAppUser appUser =
                            authProvider.appUser as KakaoAppUser;
                            return HomeScreen(appUser: appUser);
                          } else {
                            // 처리할 로직이나 기본값을 반환하세요.
                            return HomeScreen(appUser: appUser);
                          }
                        },
                      ),
                          (route) => false,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Text(
                      '저장',
                      style: TextStyle(
                        color: Color(0xFF0094FF),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
              iconTheme: IconThemeData(
                color: Colors.black,
              ),
              backgroundColor: Color(0xFFF0F0F0),
              elevation: 0,
              titleSpacing: 0,
            ),
          ];
        },
        body: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFFF0F0F0),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      '반려동물 사진 추가',
                      style: TextStyle(
                        color: Color(0xFF7C7C7C),
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 19,
                ),
                Container(
                  width: 184,
                  height: 184,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                      ),
                    ],
                  ),
                  child: GestureDetector(
                    onTap: _onAddButtonClicked, // Add 버튼 클릭 시 함수 호출
                    child: Stack(
                      children: [
                        // gradation
                        Positioned(
                          top: 0.67 * 184,
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0xFFC1C1C1),
                                  Colors.grey,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        if (image != null)
                          Positioned(
                            child: Image.file(
                              File(image!.path),
                              width: 184,
                              height: 184,
                              fit: BoxFit.fill, // 이미지를 완전히 채우도록 설정
                            ),
                          ),
                        // 디폴트 이미지
                        if (image == null)
                          Padding(
                            padding: const EdgeInsets.all(33.0),
                            child: SvgPicture.asset(
                              'assets/images/profile_images/default_dog_profile.svg',
                              width: 118,
                              height: 118,
                            ),
                          ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 11,
                          child: Center(
                            child: image != null
                                ? Text(
                              '수정하기',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                                : Text(
                              '추가하기',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // 텍스트 입력 필드 3개 추가
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0, left: 16.0),
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.transparent,
                        ),
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              petName = value;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: '별칭을 입력해 주세요',
                            labelStyle: TextStyle(
                              color: Color(0xffC1C1C1),
                              fontSize: 18,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Color(0xffC1C1C1),
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Color(0xffE0E0E0),
                                width: 1,
                              ),
                            ),
                            contentPadding: EdgeInsets.all(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(
                  height: 12,
                ),
                Padding(
                  padding:
                  const EdgeInsets.only(right: 16.0, left: 16.0, top: 12),
                  child: Container(
                    height: 56, // DropdownButton의 높이 조절
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.transparent,
                      border: Border.all(
                        color: Color(0xffE0E0E0),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButton<String>(
                            value:
                            selectedBreed.isNotEmpty ? selectedBreed : null,
                            items: dogBreedList.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: SizedBox(
                                  child: Center(
                                    child: Text(
                                      value,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              setState(() {
                                selectedBreed = value ?? '';
                              });
                            },
                            underline: Container(),
                            icon: Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: Icon(Icons.arrow_drop_down,
                                  color: Color(0xffC1C1C1)),
                            ),
                            hint: Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                '반려동물 품종 선택',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xffC1C1C1),
                                ),
                              ),
                            ),
                            isExpanded: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 12,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // 암컷 선택 버튼
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16, right: 7),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedGender = '암컷';
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            fixedSize: Size.fromHeight(56),
                            backgroundColor: selectedGender == '암컷'
                                ? Color(0xFF16C077)
                                : Color(0xffE0E0E0),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            '암컷',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: selectedGender == '암컷'
                                  ? Colors.white
                                  : Color(0xffC1C1C1),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // 수컷 선택 버튼
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 7, right: 16),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedGender = '수컷';
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            fixedSize: Size.fromHeight(56),
                            backgroundColor: selectedGender == '수컷'
                                ? Color(0xFF16C077)
                                : Color(0xffE0E0E0),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            '수컷',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: selectedGender == '수컷'
                                  ? Colors.white
                                  : Color(0xffC1C1C1),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: selectedIsNeutered,
                          onChanged: (bool? value) {
                            setState(() {
                              selectedIsNeutered = value ?? false;
                            });
                          },
                          visualDensity:
                          VisualDensity(horizontal: -4, vertical: -4),
                        ),
                        Text(
                          '중성화했음',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 24,
                ),
                Column(
                  children: <Widget>[
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Color(0xFFF0F0F0),
                        fixedSize: Size(377, 56),
                        side: BorderSide(
                          color: Color(0xffE0E0E0),
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(12))),
                      ),
                      onPressed: () => _showDialog(
                        CupertinoDatePicker(
                          initialDateTime: petBirthDay,
                          mode: CupertinoDatePickerMode.date,
                          maximumYear: DateTime.now().year,
                          maximumDate: DateTime.now(),
                          onDateTimeChanged: (DateTime birthDay) {
                            setState(
                                  () => petBirthDay = birthDay,
                            );
                          },
                        ),
                      ),
                      child: Text(
                        '${petBirthDay.year}/${petBirthDay.month}/${petBirthDay.day}',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    //CupertinoButton.filled(child: child, onPressed: onPressed)
                  ],
                ),
                SizedBox(
                  height: 12,
                ),
                Padding(
                  padding:
                  const EdgeInsets.only(right: 16.0, left: 16.0, top: 12),
                  child: Container(
                    height: 56, // DropdownButton의 높이 조절
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.transparent,
                      border: Border.all(
                        color: Color(0xffE0E0E0),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButton<String>(
                            value: selectedFurColor.isNotEmpty
                                ? selectedFurColor
                                : null,
                            items: dogColor.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: SizedBox(
                                  child: Center(
                                    child: Text(
                                      value,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              setState(() {
                                selectedFurColor = value ?? '';
                              });
                            },
                            underline: Container(),
                            icon: Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: Icon(Icons.arrow_drop_down,
                                  color: Color(0xffC1C1C1)),
                            ),
                            hint: Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                '반려동물 모색 선택',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xffC1C1C1),
                                ),
                              ),
                            ),
                            isExpanded: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Row(
                    children: [
                      Text(
                        '동물전화번호',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 3,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Row(
                    children: [
                      Text(
                        '원격으로 통신할 수 있는 동물전화번호를 등록합니다.\n끝자리만 선택이 가능해요 예시) ABC-1234-5678',
                        style: TextStyle(
                          color: Color(0xff7C7C7C),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        height: 56,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                style: TextStyle(fontSize: 20),
                                readOnly: false,
                                onTap: () {
                                  // 필드를 터치할 때 실행할 동작 정의
                                  setState(() {
                                    randomNumberText = '';
                                    userEnteredNumberText = '';
                                    userEnteredNumberHistory = '';
                                    randomNumberHistory = '';
                                    _setControllerText();
                                    print('object:$userEnteredNumberText');
                                  });
                                },
                                onChanged: (value) {
                                  setState(() {
                                    userEnteredNumberText = value;
                                    randomNumberText = '';
                                    userEnteredNumberHistory = '';
                                    randomNumberHistory = '';
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: '번호입력',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border:
                          Border.all(color: Color(0xFFDDDDDD), width: 1),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size(96, 56),
                              backgroundColor: Color(0xFF262121),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                randomNumberText =
                                    PetModel().generateRandomNumber1();
                              });
                              _setControllerText(); // 수정된 부분: 터치할 때 컨트롤러 텍스트 갱신
                              print('랜덤번호 생성: $randomNumberText');
                            },
                            child: Text(
                              '랜덤번호',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size(96, 56),
                              backgroundColor: Color(0xFF16C077),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              print('input random : $randomNumberText');
                              print(
                                  'userEnteredNumberText random : $userEnteredNumberText');
                              print('object:$userEnteredNumberText');

                              if (randomNumberText.isNotEmpty) {
                                // 랜덤번호가 있을 때만 중복확인 수행
                                randomNumberHistory +=
                                    randomNumberText; // 현재 번호를 이력에 추가
                                checkForDuplicates(); // 중복 확인
                              } else if (userEnteredNumberText.isNotEmpty) {
                                // 사용자가 직접 입력한 번호가 있을 때만 중복확인 수행
                                userEnteredNumberHistory +=
                                    userEnteredNumberText; // 사용자가 직접 입력한 번호를 이력에 추가
                                print(
                                    'input userEnter : $userEnteredNumberText');
                                checkForUserEnteredDuplicates(); // 사용자가 직접 입력한 번호에 대한 중복 확인 수행
                              }
                            },
                            child: Text(
                              '중복확인',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          duplicateText,
                          style: TextStyle(
                            color: isDuplicate ? Colors.blue : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Stack(
                  children: [
                    Positioned(
                        child: TextButton(
                            style: TextButton.styleFrom(
                                minimumSize: const Size.fromHeight(56),
                                backgroundColor: Colors.grey,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.all(Radius.zero))),
                            onPressed: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          HomeScreen(appUser: appUser)));
                            },
                            child: Container(
                              child: Text(
                                '스킵하기',
                                style: TextStyle(color: Colors.white,
                                    fontSize: 18),
                              ),
                            ))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
