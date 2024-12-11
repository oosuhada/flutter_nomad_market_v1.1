import 'package:flutter/material.dart';
import 'package:flutter_market_app/core/validator_util.dart';

class NicknameTextFormField extends StatelessWidget {
  NicknameTextFormField({
    required this.controller,
  });
  TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(hintText: '닉네임을 입력해 주세요'),
      validator: ValidatorUtil.validatorNickname,
    );
  }
}
