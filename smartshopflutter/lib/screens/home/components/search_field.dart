import 'package:flutter/material.dart';
import '../../../constants.dart';

class SearchField extends StatelessWidget {
  final String? initialValue;
   final ValueChanged<String>? onSubmitted;

  const SearchField({
    Key? key,
    this.initialValue,
     this.onSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: initialValue);

    return TextFormField(
      controller: controller,
       onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        filled: true,
        fillColor: kSecondaryColor.withOpacity(0.1),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        border: searchOutlineInputBorder,
        focusedBorder: searchOutlineInputBorder,
        enabledBorder: searchOutlineInputBorder,
        hintText: "Search product",
        prefixIcon: const Icon(Icons.search),
      ),
    );
  }
}

const searchOutlineInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(12)),
  borderSide: BorderSide.none,
);
