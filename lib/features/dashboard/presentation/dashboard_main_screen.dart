import 'package:flutter/material.dart';

class DashboardMainScreen extends StatelessWidget {
  const DashboardMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Principal')),
      body: const Center(child: Text('Pantalla del Dashboard')),
    );
  }
}
