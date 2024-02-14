import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:testing_pet/model/PetList.dart';
import 'package:testing_pet/model/user.dart';
import 'package:testing_pet/screens/pet_add/pet_add_screen.dart';
import 'package:testing_pet/utils/constants.dart';

class PetListScreen extends StatefulWidget {
  final KakaoAppUser appUser;

  PetListScreen({required this.appUser});

  @override
  State<PetListScreen> createState() => _PetListScreenState();
}

class _PetListScreenState extends State<PetListScreen> {
  int _currentIndex = 0;
  late List<Map<String, dynamic>> dataList;
  late KakaoAppUser appUser;
  List<PetList> _petList = [];

  @override
  void initState() {
    super.initState();
    _loadPetList();
  }

  void _loadPetList() async {
    final response = await supabase
        .from('Add_UserPet')
        .select()
        .like('user_id', '${widget.appUser.user_id}%');
    print('response : $response');

    // 반려동물 데이터를 파싱하고 _petList 업데이트
    final List<dynamic>? data = response as List<dynamic>?;
    print(data);

    if (data != null && data.isNotEmpty) {
      final petList = data.map((petMap) => PetList.fromMap(petMap)).toList();
      print('Response Data: $data');
      print('petList : $petList');

      setState(() {
        _petList = petList;
      });
    } else {
      print('Error: No data received from Supabase or data is empty');
    }
  }

// 반려동물 리스트 아이템 위젯을 생성하는 함수
  Widget _buildPetListItem(int index) {
    PetList pet = _petList[index];

    // Check if petImages is null or empty
    if (pet.petImages == null || pet.petImages.isEmpty) {
      // Return a ListTile with default information and a placeholder image
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Container(
                height: 112,
                color: Colors.white,
                child: ListTile(
                  title: Text(pet.petName),
                  subtitle: Text(
                    'Age: ${pet.petAge}, ${pet.petBreed}, ${pet.petFavorite}, ${pet.petGender}',
                  ),
                  leading: Container(
                    width: 92.0,
                    height: 92.0,
                    child: FittedBox(
                      fit: BoxFit.fill,
                      child: SvgPicture.asset(
                          'assets/images/profile_images/default_dog_profile.svg'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Decode the base64 encoded image and convert it to bytes.
    List<int> imageBytes;
    try {
      imageBytes = base64.decode(pet.petImages);
    } catch (e) {
      print('Error decoding image: $e');
      // If decoding fails, return a ListTile with default information and a placeholder image
      return Container(
        height: 112,
        color: Colors.white,
        child: ListTile(
          title: Text(pet.petName),
          subtitle: Text(
              'Age: ${pet.petAge}, ${pet.petBreed}, ${pet.petFavorite}, ${pet.petGender}'),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Container(
              width: 92.0,
              height: 92.0,
              child: FittedBox(
                fit: BoxFit.fill,
                child: SvgPicture.asset(
                    'assets/images/profile_images/default_dog_profile.svg'),
              ),
            ),
          ),
        ),
      );
    }

    // Create an image widget from bytes
    Image petImage = Image.memory(
      Uint8List.fromList(imageBytes),
      width: 92.0,
      height: 92.0,
      fit: BoxFit.fill,
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0, left: 16.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Container(
              height: 112,
              color: Colors.white,
              child: ListTile(
                horizontalTitleGap: 30,
                minVerticalPadding: 18,

                title: Text(pet.petName,
                style: TextStyle(
                  fontSize: 22,
                  color: Color(0xFF272222),
                  fontWeight: FontWeight.w600,
                ),),
                subtitle: Text(
                  ' ${pet.petBreed},\n ${pet.petGender}, ${pet.petAge}살',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF272222),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                leading: Container(
                  width: 92.0,
                  height: 92.0,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: petImage,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    print('User ID: ${widget.appUser.user_id}');
    return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '내 반려동물',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 16),
              GestureDetector(
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PetAddScreen(appUser: appUser),
                    ),
                  );
                },
                child: Text(
                  '동물 추가',
                  style: TextStyle(
                    color: Color(0xFF0094FF),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Color(0xFFF0F0F0),
          elevation: 0,
        ),
        body: Container(
            decoration: BoxDecoration(
              color: Color(0xFFF0F0F0),
            ),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    '즐겨찾기',
                    style: TextStyle(
                      color: Color(0xFF7C7C7C),
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 14),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16.0),
                child: Divider(
                  // Separator line
                  color: Color(0xffE0E0E0), // Same color as text
                  thickness: 1.0, // 선의 두께
                ),
              ),
              SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    '반려동물 리스트',
                    style: TextStyle(
                      color: Color(0xFF7C7C7C),
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 14,
              ),
              Container(
                child: Column(
                  children: List.generate(
                    _petList.length,
                    (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFF0F0F0),
                            elevation: 0,
                            padding: EdgeInsets
                                .zero, // 버튼 패딩을 0으로 설정하여 내용물을 꽉 채우도록 합니다.
                          ),
                          child: Container(
                            height: 112.0, // 항목의 높이를 고정 값으로 설정
                            child: _buildPetListItem(index),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              )
            ])));
  }
}
