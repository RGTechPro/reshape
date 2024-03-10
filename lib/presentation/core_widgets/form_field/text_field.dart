part of 'form_fields.dart';

class TextFormX extends StatelessWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextInputType textInputType;
  final int? maxLines;
  final bool isProcessing;
  final bool enabled;

  const TextFormX({
     this.controller,
    required this.onChanged,
    this.validator,
    this.maxLines,
    super.key,
    this.isProcessing = false,
    this.enabled = true,
    this.textInputType = TextInputType.multiline,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          enabled: enabled,
          maxLines: maxLines,
          onChanged: onChanged,
          keyboardType: textInputType,
          controller: controller,
          decoration: kFromInputDecoration.copyWith(
            hintText:(isProcessing)?'Processing audio....': 'Ask ReShape AI',
          ),
          validator: validator,
        )
      ],
    );
  }
}
