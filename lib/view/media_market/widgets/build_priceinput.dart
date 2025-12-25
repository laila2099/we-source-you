import 'package:flutter/material.dart';

Widget buildPriceInput(TextEditingController textCtrl) {
  final Color borderColor = const Color(0xFFE0E0E0);

  return Expanded(
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: textCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_drop_up, size: 18, color: Colors.grey),
              Icon(Icons.arrow_drop_down, size: 18, color: Colors.grey),
            ],
          ),
        ],
      ),
    ),
  );
}
