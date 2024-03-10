import 'package:flutter/material.dart';

var kFromInputDecoration = InputDecoration(
  filled: true,
  fillColor: const Color(0xFFF3F5F5),
  contentPadding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),

  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8.0), // Rounded border
    borderSide: const BorderSide(color: Color(0xFFF3F5F5)), // Border color
  ), // Background color
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8.0), // Rounded border
    borderSide: const BorderSide(color: Color(0xFFF3F5F5)), // Border color
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8.0),
    borderSide:
        const BorderSide(color: Color(0xFFF3F5F5)), // Border color when focused
  ),
  hintText: 'Ask ReShape AI', // Placeholder text
  hintStyle: const TextStyle(color: Colors.grey), // Placeholder text color
);
