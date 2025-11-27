import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  late GenerativeModel _model;
  late String _geminiKey;

  void initialize(String geminiKey) {
    try {
      _geminiKey = geminiKey;

      _model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: geminiKey,
      );

      print('AI Service initialized successfully');
      print('Gemini Key: ${geminiKey.isNotEmpty ? "Provided" : "Missing"}');
    } catch (e) {
      print('Error initializing AI Service: $e');
      // Initialize with default values to prevent LateInitializationError
      _geminiKey = '';
    }
  }

  // ---------------- TEXT (Gemini) ----------------
  Future<Map<String, dynamic>> extractPostDetails(
      String userDescription) async {
    try {
      final prompt = '''
      Based on the following description, extract the information for a lost/found item post. 
      Respond ONLY with a valid JSON object containing these fields:
      - type: either "Lost" or "Found"
      - item: the name of the item (must be one of these exact values: "Mobile Phone", "Laptop", "Charger", "Wallet", "ID Card", "Hoodie", "Jacket/Coat", "Bat", "Electronics Item", "Cloth", "Belt", "Ball", "Book", "Earphones", "Earbuds", "Water Bottle", "Watch", "Specs", "Jewellry", "Shoes", "Keys", "Umbrella", "Other")
      - location: where it was lost/found (must be one of these exact values: "Campus, NITH", "Gate 1", "Temple", "Verka", "Central GYM", "SAC", "Student Park", "Lecture Hall", "New LH", "Auditorium", "Library", "OAT", "Ground", "Admin Block", "Central Block", "CSE Department", "Civil Department", "MNC Department", "Electrical Department", "Chemical Department", "Mechanical Department", "Architecture Department", "ECE Department", "Workshop", "4H Court", "DBH Nescafe", "Food Plaza", "Gate 2", "Boys Hostel", "Girls Hostel")
      - date (YYYY-MM-DD)
      - description: a clear, helpful description that includes:
        * When it was lost/found (today, yesterday, last week, etc.)
        * Brief details about the item (brand, color, model if mentioned)
        * What to do if found (please contact/return to owner)
        * Encouraging note for finders to reach out
        
        Keep it natural and encouraging, like: "[Item] was [lost/found] [when] at [location]. [Specific details about the item]. If you have found this item, please [contact/return to] the owner. Your help would be greatly appreciated!"

      Description: "$userDescription"

      JSON Response:
      ''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      final jsonString = response.text?.trim() ?? '{}';

      String clean = jsonString;
      if (clean.startsWith('```json')) clean = clean.substring(7);
      if (clean.endsWith('```')) clean = clean.substring(0, clean.length - 3);

      final data = json.decode(clean);

      return {
        "type": data["type"] ?? "Lost",
        "item": data["item"] ?? "Other",
        "location": data["location"] ?? "Campus, NITH",
        "date": data["date"] ?? DateTime.now().toString().split(" ")[0],
        "description": data["description"] ?? userDescription,
      };
    } catch (e) {
      print('Error in extractPostDetails: $e');
      return fallback(userDescription);
    }
  }

  Map<String, dynamic> fallback(String desc) {
    return {
      "type": "Lost",
      "item": "Other",
      "location": "Campus, NITH",
      "date": DateTime.now().toString().split(" ")[0],
      "description": desc,
    };
  }
}
