import 'package:contact_list/ui/contact_page.dart';
import 'package:contact_list/ui/home_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomePage(),
    title: "Contatos",
    color: Color.fromARGB(255, 77, 183, 229),
  ));
}
