import 'package:flutter_market_app/data/repository/user_repository.dart';

class ValidatorUtil {
  final UserRepository userInfoRepository = UserRepository();

  Future<String?> validatorJoinEmail(String? value) async {
    if (value?.trim().isEmpty ?? true) {
      return "이메일을 입력해주세요";
    }

    // 이메일 형식 검증을 위한 정규식
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegExp.hasMatch(value!)) {
      return '올바른 이메일 형식이 아닙니다';
    }

    if (value.contains(' ')) {
      return '이메일에 공백이 포함되어있습니다';
    }

    // 추가 유효성 검사
    if (value.length > 254) {
      return '이메일이 너무 깁니다';
    }

    final localPart = value.split('@')[0];
    if (localPart.length > 64) {
      return '이메일 아이디가 너무 깁니다';
    }

    if (!await userInfoRepository.isEmailAvailable(value)) {
      return '이메일이 이미 사용 중입니다.';
    }

    return null;
  }

  Future<String?> validatorLoginEmail(String? value) async {
    if (value?.trim().isEmpty ?? true) {
      return "이메일을 입력해주세요";
    }
    if (!value!.contains('@')) {
      return '이메일은 유효한 형식이어야합니다';
    }
    if (value.contains(' ')) {
      // 공백 포함 여부 검사
      return '이메일에 공백이 포함되어있습니다';
    }
    // if (await userInfoRepository.isEmailInUse(value)) {
    //   return '이메일이 이미 사용 중입니다.';
    // }
    return null;
  }

  Future<String?> validatorNickname(String? value) async {
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
    if (!await userInfoRepository.isNicknameAvailable(value)) {
      return '닉네임이 이미 사용 중입니다.';
    }
    return null;
  }

  // Future<String?> validatorPassword(String? value) async {
  //   if (value?.trim().isEmpty ?? true) {
  //     return "비밀번호를 입력해주세요";
  //   }
  //   if (!value!.contains('@')) {
  //     return '비밀번호는 2글자 이상이여야합니다';
  //   }
  //   return null;
  // }

  static String? validatorPassword(String? value) {
    if (value?.trim().isEmpty ?? true) {
      return "비밀번호를 입력해주세요";
    }
    if (value!.length < 6) {
      return '비밀번호는 6글자 이상이여야합니다';
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
