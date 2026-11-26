import 'package:flutter/material.dart';

class EntryButton extends StatelessWidget {
  final VoidCallback onTap;

  const EntryButton({
    super.key,

    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
          child: const Text(
            'Enter',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}