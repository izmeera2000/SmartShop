import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../constants.dart';

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({
    Key? key,
    required this.text,
    required this.icon,
    this.press,
  }) : super(key: key);

  final String text, icon;
  final VoidCallback? press;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 10),
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: Colors.black,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          side: BorderSide(
            color: Colors.black, // Set the color of the outline
            width: 1, // Set the width of the outline
          ),
          backgroundColor: Colors.white,
        ),
        onPressed: press,
        child: Row(
          children: [
            SvgPicture.asset(
              icon,
              color: Colors.black,
              width: 20,
            ),
            const SizedBox(width: 20),
            Expanded(child: Text(text)),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color.fromARGB(255, 255, 0, 0),
            ),
          ],
        ),
      ),
    );
  }
}
