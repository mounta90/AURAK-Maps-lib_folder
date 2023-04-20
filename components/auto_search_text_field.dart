import 'package:flutter/material.dart';

class AutoSearchTextField extends StatelessWidget {
  final String searchHintText;

  // The required parameters that need to be passed from the AutoComplete fieldViewBuilder widget.
  final TextEditingController textEditingController;
  final FocusNode focusNode;
  final void Function() onFieldSubmitted;

  const AutoSearchTextField({
    super.key,
    required this.searchHintText,
    required this.textEditingController,
    required this.focusNode,
    required this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textEditingController,
      focusNode: focusNode,
      onEditingComplete: onFieldSubmitted,
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        prefixIcon: const Icon(
          Icons.search,
          color: Colors.blueGrey,
        ),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: const OutlineInputBorder(
          // borderRadius: BorderRadius.circular(50.0),
          borderSide: BorderSide(
            color: Colors.white,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          // borderRadius: BorderRadius.circular(50.0),
          borderSide: BorderSide(
            color: Colors.white,
          ),
        ),
        hintText: searchHintText,
        hintStyle: TextStyle(
          color: Colors.blueGrey.withOpacity(0.5),
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
