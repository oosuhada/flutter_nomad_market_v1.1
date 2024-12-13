import 'package:flutter_market_app/data/repository/user_info_repository.dart';

class ValidatorUtil {
  final userInfoRepository = UserInfoRepository();

  String? validatorId(String? value) {
    if (value?.trim().isEmpty ?? true) {
      return "이메일을 입력해주세요";
    }
    if (!value!.contains('@')) {
      return '이메일은 유효한 형식이어야합니다';
    }
    if (value.contains(' ')) {
      // 공백 포함 여부 검사
      return '닉네임에 공백이 포함되어있습니다';
    }
    if (userInfoRepository.isEmailInUse(value) == true) {
      return '회원가입 실패: 이메일이 이미 사용 중입니다.';
    }
    return null;
  }

  static String? validatorNickname(String? value) {
    if (value?.trim().isEmpty ?? true) {
      return "닉네임을 입력해주세요";
    }
    if (value!.length < 2) {
      return '닉네임은 2글자 이상이여야합니다';
    }
    if (value.contains(' ')) {
      // 공백 포함 여부 검사
      return '닉네임에 공백이 포함되어있습니다';
    }
    return null;
  }

  static String? validatorPassword(String? value) {
    if (value?.trim().isEmpty ?? true) {
      return "비밀번호를 입력해주세요";
    }
    if (value!.length < 2) {
      return '비밀번호는 2글자 이상이여야합니다';
    }
    return null;
  }

  static String? validatorTitle(String? value) {
    if (value?.trim().isEmpty ?? true) {
      return "상품명을 입력해주세요";
    }
    if (value!.length < 2) {
      return '상품명은 2글자 이상이여야합니다';
    }
    return null;
  }

  static String? validatorPrice(String? value) {
    if (value?.trim().isEmpty ?? true) {
      return "가격을 입력해주세요";
    }
    return null;
  }

  static String? validatorContent(String? value) {
    if (value?.trim().isEmpty ?? true) {
      return "상품 내용을 입력해주세요";
    }
    return null;
  }
}
