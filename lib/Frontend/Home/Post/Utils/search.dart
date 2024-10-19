import 'package:flutter/material.dart';

class SearchFilterWidget extends StatefulWidget {
  final Function(String status, String location, DateTime? uploadDate, String title) onSearch;

  const SearchFilterWidget({super.key, required this.onSearch});

  @override
  _SearchFilterWidgetState createState() => _SearchFilterWidgetState();
}

class _SearchFilterWidgetState extends State<SearchFilterWidget> {
  String _selectedStatus = 'Lost'; // Initial value for status
  String _location = '';
  DateTime? _selectedDate;
  String _title = '';

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Status dropdown (Lost/Found)
        DropdownButton<String>(
          value: _selectedStatus,
          items: ['Lost', 'Found'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedStatus = newValue!;
            });
          },
        ),
        // Location input
        TextField(
          decoration: const InputDecoration(labelText: 'Location'),
          onChanged: (value) {
            setState(() {
              _location = value;
            });
          },
        ),
        // Date picker for upload date
        Row(
          children: [
            Text(_selectedDate == null ? 'Select Date' : _selectedDate!.toLocal().toString().split(' ')[0]),
            IconButton(
              onPressed: () => _selectDate(context),
              icon: const Icon(Icons.calendar_today),
            ),
          ],
        ),
        // Item title input
        TextField(
          decoration: const InputDecoration(labelText: 'Item Title'),
          onChanged: (value) {
            setState(() {
              _title = value;
            });
          },
        ),
        // Search button
        ElevatedButton(
          onPressed: () {
            widget.onSearch(_selectedStatus, _location, _selectedDate, _title);
          },
          child: const Text('Search'),
        ),
      ],
    );
  }
}
