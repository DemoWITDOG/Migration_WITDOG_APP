import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:testing_pet/utils/constants.dart';

class PetModel {
  PetModel();

  DateTime petBirthDay = DateTime.now();  // 새로운 필드 추가

  Future<void> addPet({
    required String userId,
    required Uint8List petImages,
    required String petName,
    required String petBreed,
    required String petGender,
    required String petPhone,
    required String petFurColor,
    required bool isFavorite,
    required String petIdentity,
    required String petAge,
  }) async {
    try {
      // petImages를 base64로 인코딩
      String encodedImages = _encodeImages(petImages);

      // Add_UserPet 테이블에 데이터 추가
      final response = await supabase.from('Add_UserPet').upsert([
        {
          'user_id': userId,
          'pet_images': encodedImages,
          'pet_name': petName,
          'pet_breed': petBreed,
          'pet_gender': petGender,
          'pet_age': petAge,
          'pet_phone': petPhone,
          'pet_fur_color': petFurColor,
          'pet_favorite': isFavorite,
          'pet_identity': petIdentity,
        }
      ]);

      print(response);

      if (response != null && response.error != null) {
        throw response.error!;
      }
    } catch (error) {
      print('Error adding pet: $error');
      rethrow;
    }
  }

  static Uint8List _decodeImages(String? base64String) {
    if (base64String == null || base64String.isEmpty) {
      return Uint8List(0);
    }

    try {
      Uint8List decoded = base64Decode(base64String);
      print('Decoded data: $decoded');
      return decoded ?? Uint8List(0);
    } catch (e) {
      print('Error decoding images: $e');
      return Uint8List(0);
    }
  }

  static String _encodeImages(Uint8List images) {
    return base64Encode(images);
  }


  String myPetAge(DateTime selectedDate) {
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

  Future<List<Map<String, dynamic>>> getPet(String userId) async {
    try {
      final response = await supabase
          .from('Add_UserPet')
          .select()
          .eq('user_id', userId);

      print('getpet response $response');


      // 응답이 리스트인 경우
      if (response is List) {
        List<Map<String, dynamic>> dataList = (response as List)
            .map((dynamic item) => item as Map<String, dynamic>)
            .toList();

        return dataList;
      }

      // 응답이 단일 객체인 경우
      return [response as Map<String, dynamic>];
    } catch (error) {
      print('Error fetching pet: $error');
      rethrow;
    }
  }
  String generateRandomNumber1() {
    // 4자리 난수 생성
    String randomNum = (Random().nextInt(9000) + 1000).toString();
    return randomNum;
  }
  String generateRandomNumber() {
    // 4자리 난수 생성
    String randomNum = (Random().nextInt(9) + 1).toString();
    return randomNum;
  }

  Future<String> saveToDatabase({
    required String selectedGender,
    required String selectedPetAge,
    required String selectedFurColor,
    required String selectedBreed,
  }) async {
    try {
      //성,종,나이,모색
      String genderCode = (selectedGender == '암컷')
          ? 'A'
          : (selectedGender == '수컷')
          ? 'B'
          : 'C';

      //종 코드
      Map<String, String> breedNCode = {
        '닥스훈트': 'A',
        '도베르만': 'B',
        '라사압소': 'C',
        '리트리버': 'D',
        '말티즈': 'E',
        '보더콜리': 'F',
        '불도그': 'G',
        '블러드하운드': 'H',
        '비글': 'I',
        '비숑': 'J',
        '스피츠': 'K',
        '시바견': 'L',
        '시츄': 'M',
        '웰시코기': 'N',
        '진돗개': 'O',
        '치와와': 'P',
        '퍼그': 'Q',
        '포메라니안': 'R',
        '푸들': 'S',
        '믹스견': 'T',
        '달마시안':'U',  //추가
        '사모예드':'V'   //추가
      };
      String breedCode = breedNCode[selectedBreed] ?? 'U';
      //펫 나이에 따른 코드부여
      String age = selectedPetAge;
      print('개나이 : $age');

      String ageCode = '';

      switch (age) {
        case '0':
          ageCode = 'A';
          break;
        case '1':
          ageCode = 'B';
          break;
        case '2':
          ageCode = 'C';
          break;
        case '3':
          ageCode = 'D';
          break;
        case '4':
          ageCode = 'E';
          break;
        case '5':
          ageCode = 'F';
          break;
        case '6':
          ageCode = 'G';
          break;
        case '7':
          ageCode = 'H';
          break;
        case '8':
          ageCode = 'I';
          break;
        case '9':
          ageCode = 'J';
          break;
        default:
          ageCode = 'K';
          break;
      }
      print('ageCode : $ageCode');


      Map<String, String> furColr = {
        '크림색': 'A',
        '검은색': 'B',
        '금색': 'C',
        '빨간색': 'D',
        '블루말색': 'E',
        '연갈색': 'F',
        '은색': 'G',
        '진갈색': 'H',
        '진회색': 'I',
      };
      String furColorCode = furColr[selectedFurColor] ?? 'U';


      String petPhone = '$genderCode$breedCode$furColorCode$ageCode-${generateRandomNumber()}-${generateRandomNumber1()}';

      return petPhone;
    } catch (error) {
      print('Error saving to database: $error');
      rethrow;
    }
  }
}
