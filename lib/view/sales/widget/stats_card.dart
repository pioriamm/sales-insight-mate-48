import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  const StatCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style:
                const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            Text(title),
          ],
        ),
      ),
    );
  }
}