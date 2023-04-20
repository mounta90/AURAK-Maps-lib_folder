import 'package:flutter/material.dart';

class SearchTextField extends StatelessWidget {
  final String searchHintText;

  const SearchTextField({
    super.key,
    required this.searchHintText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        suffixIcon: const Icon(
          Icons.search,
          color: Colors.blueGrey,
        ),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50.0),
          borderSide: const BorderSide(
            color: Colors.white,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50.0),
          borderSide: const BorderSide(
            color: Colors.white,
          ),
        ),
        hintText: searchHintText,
        hintStyle: const TextStyle(
          color: Colors.blueGrey,
          fontWeight: FontWeight.normal,
        ),
      ),
      cursorColor: Colors.blueGrey,
      style: const TextStyle(
        color: Colors.blueGrey,
        // fontWeight: FontWeight.bold,
      ),
    );
  }
}
