import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class FilterDropdown extends StatelessWidget {
  final String label;
  final ValueNotifier<String?> valueNotifier;
  final List<String> items;
  final IconData icon;

  const FilterDropdown({
    super.key,
    required this.label,
    required this.valueNotifier,
    required this.items,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField2<String>(
      valueListenable: valueNotifier,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF64748B)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC), 
        prefixIcon: Icon(icon, color: const Color(0xFF94A3B8)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
      items: items.map<DropdownItem<String>>((String e) => DropdownItem<String>(
        value: e, 
        child: Text(
          e, 
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      )).toList(),
      onChanged: (val) {
        valueNotifier.value = val;
      },
      validator: (val) => val == null ? 'Campo obrigatório' : null,
      buttonStyleData: const FormFieldButtonStyleData(
        padding: EdgeInsets.zero, 
      ),
      iconStyleData: const IconStyleData(
        icon: Icon(Icons.unfold_more_rounded, color: Color(0xFF94A3B8)),
      ),
      dropdownStyleData: DropdownStyleData(
        maxHeight: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        offset: const Offset(0, -4), 
      ),
      menuItemStyleData: const MenuItemStyleData(
        padding: EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}