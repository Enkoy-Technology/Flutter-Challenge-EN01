import 'package:flutter/material.dart';
import 'app.dart';
import 'injection_dependec.dart';

void main() async {
  await DependencyInjection.init();
  runApp(const MyApp());
}
