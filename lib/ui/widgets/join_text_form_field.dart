import 'package:flutter/material.dart';
import 'package:flutter_market_app/core/validator_util.dart';

class JoinTextFormField extends StatefulWidget {
  JoinTextFormField({
    required this.controller,
  });
  final TextEditingController controller;

  @override
  _EmailTextFormFieldState createState() => _EmailTextFormFieldState();
}

class _EmailTextFormFieldState extends State<JoinTextFormField> {
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
        final result = await ValidatorUtil().validatorJoinEmail(value);
        setState(() {
          _errorText = result;
        });
      },
    );
  }
}
