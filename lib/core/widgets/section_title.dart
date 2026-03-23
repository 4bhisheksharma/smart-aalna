import 'package:flutter/material.dart';

class AddClothesSectionTitle extends StatelessWidget {
  final String title;

  const AddClothesSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: const Color(0xFF171717),
      ),
    );
  }
}
