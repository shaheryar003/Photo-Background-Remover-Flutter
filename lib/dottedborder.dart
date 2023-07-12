import 'package:flutter/material.dart';

class DottedBorderButton extends StatefulWidget {
  final String text;
  final VoidCallback ontap;
  DottedBorderButton({required this.text, required this.ontap});

  @override
  State<DottedBorderButton> createState() => _DottedBorderButtonState();
}

class _DottedBorderButtonState extends State<DottedBorderButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: InkWell(
        onTap: widget.ontap,
        child: Container(
          width: 200,
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
              width: 1.0,
              style: BorderStyle.solid,
            ),
            color: Colors.white,
          ),
          child: Center(
            child: Text(
              widget.text,
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
