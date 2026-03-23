import 'package:flutter/material.dart';

class AddClothesHeader extends StatelessWidget {
  final String title;

  const AddClothesHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111111),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                offset: Offset(0, 8),
                blurRadius: 18,
                spreadRadius: -8,
              ),
            ],
          ),
          child: IconButton(
            onPressed: () => Navigator.of(context).pushNamed('/added-clothes'),
            icon: const Icon(Icons.local_laundry_service),
            color: const Color(0xFF111111),
            tooltip: 'Added Clothes',
          ),
        ),
      ],
    );
  }
}
