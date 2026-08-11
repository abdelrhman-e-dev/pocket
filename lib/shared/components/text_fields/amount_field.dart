import 'package:flutter/material.dart';

class AmountField extends StatelessWidget {
  const AmountField({super.key, required this.controller, this.hint = '0.00'});

  final TextEditingController controller;
  
  final String hint;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final focusNode = FocusNode();
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outline, width: 1.5),
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            // العملة - يسار
            Padding(
              padding: const EdgeInsets.only(left: 28),
              child: Text(
                'جنيه',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 28,
                  fontWeight: FontWeight.normal,
                  color: colors.secondary,
                ),
              ),
            ),

            const SizedBox(width: 16),

            // amount
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                autofocus: false,
                onTapOutside: (event) {
                  focusNode.unfocus();
                },
                
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface.withValues(alpha: 0.35),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),

            const SizedBox(width: 28),
          ],
        ),
      ),
    );
  }
}
