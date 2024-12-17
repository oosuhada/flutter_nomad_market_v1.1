import 'package:flutter/material.dart';
import 'package:flutter_market_app/core/validator_util.dart';

class NicknameTextFormField extends StatefulWidget {
  NicknameTextFormField({
    required this.controller,
  });
  final TextEditingController controller;

  @override
  _NicknameTextFormFieldState createState() => _NicknameTextFormFieldState();
}

class _NicknameTextFormFieldState extends State<NicknameTextFormField> {
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        hintText: '닉네임을 입력해 주세요',
        errorText: _errorText,
      ),
      onChanged: (value) async {
        final result = await ValidatorUtil().validatorNickname(value);
        setState(() {
          _errorText = result;
        });
      },
    );
  }
}
