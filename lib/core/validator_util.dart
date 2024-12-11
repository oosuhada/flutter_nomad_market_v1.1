class ValidatorUtil {
  static String? validatorId(String? value) {
    if (value?.trim().isEmpty ?? true) {
      return "아이디를 입력해주세요";
    }
    if (value!.length < 2) {
      return '아이디는 2글자 이상이여야합니다';
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
