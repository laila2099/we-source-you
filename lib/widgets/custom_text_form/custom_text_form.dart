// // custom_text_form.dart

// import 'package:flutter/material.dart';

// class CustomTextField extends StatelessWidget {
//   final String labelText;
//   final bool isPassword;
//   final bool isOptional;
//   final Widget? prefix;
//   final TextInputType keyboardType;

//   // New property for GetX binding
//   final ValueChanged<String>? onChanged;

//   const CustomTextField({
//     Key? key,
//     required this.labelText,
//     this.isPassword = false,
//     this.isOptional = false,
//     this.prefix,
//     this.keyboardType = TextInputType.text,
//     this.onChanged, // Initialize the new property
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     String finalLabel = isOptional ? '$labelText (Optional)' : labelText;

//     return TextField(
//       onChanged: onChanged, // Pass the callback to the TextField
//       obscureText: isPassword,
//       keyboardType: keyboardType,
//       decoration: InputDecoration(
//         labelText: finalLabel,
//         // The default look for the fields in the screenshot
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(4.0),
//           borderSide: BorderSide(color: Colors.grey.shade300),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(4.0),
//           borderSide: BorderSide(color: Colors.grey.shade300),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(4.0),
//           borderSide: BorderSide(color: Theme.of(context).primaryColor),
//         ),
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 12,
//           vertical: 16,
//         ),
//         prefixIcon: prefix != null
//             ? Padding(
//                 padding: const EdgeInsets.only(left: 12, right: 8),
//                 child: prefix,
//               )
//             : null,
//         prefixIconConstraints: prefix != null
//             ? const BoxConstraints(minWidth: 0, minHeight: 0)
//             : null,
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String labelText;
  final bool isPassword;
  final bool isOptional;
  final Widget? prefix;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;

  const CustomTextField({
    Key? key,
    required this.labelText,
    this.isPassword = false,
    this.isOptional = false,
    this.prefix,
    this.keyboardType = TextInputType.text,
    this.onChanged,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    String finalLabel = widget.isOptional
        ? '${widget.labelText} (Optional)'
        : widget.labelText;

    return TextField(
      onChanged: widget.onChanged,
      obscureText: widget.isPassword ? _obscureText : false,
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        labelText: finalLabel,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),

        /// 👁️ Eye Icon
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,

        prefixIcon: widget.prefix != null
            ? Padding(
                padding: const EdgeInsets.only(left: 12, right: 8),
                child: widget.prefix,
              )
            : null,
        prefixIconConstraints: widget.prefix != null
            ? const BoxConstraints(minWidth: 0, minHeight: 0)
            : null,
      ),
    );
  }
}
