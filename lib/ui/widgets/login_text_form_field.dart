import 'package:flutter/material.dart';
import 'package:flutter_market_app/core/validator_util.dart';

class LoginTextFormField extends StatefulWidget {
  LoginTextFormField({
    required this.controller,
  });
  final TextEditingController controller;

  @override
  _EmailTextFormFieldState createState() => _EmailTextFormFieldState();
}

class _EmailTextFormFieldState extends State<LoginTextFormField> {
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        hintText: '이메일을 입력해 주세요',
        errorText: _errorText,
      ),
      onChanged: (value) async {
        final result = await ValidatorUtil().validatorLoginEmail(value);
        setState(() {
          _errorText = result;
        });
      },
    );
  }
}
