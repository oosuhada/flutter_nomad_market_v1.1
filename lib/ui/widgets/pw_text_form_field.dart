import 'package:flutter/material.dart';
import 'package:flutter_market_app/core/validator_util.dart';

class PwTextFormField extends StatefulWidget {
  PwTextFormField({
    required this.controller,
  });
  final TextEditingController controller;

  @override
  State<PwTextFormField> createState() => _PwTextFormFieldState();
}

class _PwTextFormFieldState extends State<PwTextFormField> {
  String? _errorText;

  // @override
  // Widget build(BuildContext context) {
  //   return TextFormField(
  //     controller: widget.controller,
  //     decoration: InputDecoration(
  //       hintText: '비밀번호를 입력해 주세요',
  //       errorText: _errorText,
  //     ),
  //     onChanged: (value) {
  //       setState(() {
  //         _errorText = null;
  //       });
  //     },
  //     obscureText: true,
  //     validator: ValidatorUtil.validatorPassword,
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        hintText: '비밀번호를 입력해 주세요',
        errorText: _errorText,
      ),
      onChanged: (value) async {
        final result = await ValidatorUtil.validatorPassword(value);
        setState(() {
          _errorText = result;
        });
      },
    );
  }
}
