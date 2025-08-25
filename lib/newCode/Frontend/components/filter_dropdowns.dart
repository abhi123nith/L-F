// // lib/Frontend/components/filter_dropdowns.dart
// import 'package:flutter/material.dart';
// import 'package:l_f/Frontend/Contants/lists.dart';
// import 'package:l_f/newCode/constants/lists.dart';

// class FilterDropdowns extends StatelessWidget {
//   final String selectedType;
//   final String selectedLocation;
//   final String selectedCategory;
//   final String selectedDateRange;
//   final Function(String?) onTypeChanged;
//   final Function(String?) onLocationChanged;
//   final Function(String?) onCategoryChanged;
//   final Function(String?) onDateRangeChanged;

//   const FilterDropdowns({
//     super.key,
//     required this.selectedType,
//     required this.selectedLocation,
//     required this.selectedCategory,
//     required this.selectedDateRange,
//     required this.onTypeChanged,
//     required this.onLocationChanged,
//     required this.onCategoryChanged,
//     required this.onDateRangeChanged,
//   });

//   Widget _buildDropdown(String selectedValue, List<String> items, ValueChanged<String?> onChanged) {
//     return DropdownButton<String>(
//       value: selectedValue,
//       items: items.map((String value) {
//         return DropdownMenuItem<String>(
//           value: value,
//           child: Text(value),
//         );
//       }).toList(),
//       onChanged: onChanged,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final List<String> itemTypes = ['All', 'Lost', 'Found'];
//     const List<String> locations = locationsList;
//     const List<String> categories = itemsListWithAll; // Corrected to use the list with 'All'
//     final List<String> dateRanges = ['All Time', 'Today', 'This Week', 'This Month', 'This Year'];

//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 12.0),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             _buildDropdown(selectedType, itemTypes, onTypeChanged),
//             const SizedBox(width: 10),
//             _buildDropdown(selectedLocation, locations, onLocationChanged),
//             const SizedBox(width: 10),
//             _buildDropdown(selectedCategory, categories, onCategoryChanged),
//             const SizedBox(width: 10),
//             _buildDropdown(selectedDateRange, dateRanges, onDateRangeChanged),
//           ],
//         ),
//       ),
//     );
//   }
// }
