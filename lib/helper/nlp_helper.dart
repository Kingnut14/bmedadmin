// helper/nlp_helper.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class NLPHelper {
  static const String _geminiApiKey =
      "AIzaSyDJzommUw-gXCfo8FLqNEAtq_Fds_0copc"; // Palitan ng totoong API key
  static const String _url =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent";

  static Future<String> analyzeTextWithGemini(String text) async {
    final Uri uri = Uri.parse("$_url?key=$_geminiApiKey");

    try {
      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": text},
              ],
            },
          ],
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data["candidates"]?[0]["content"]?["parts"]?[0]["text"];
        return content ?? "Error: No valid response";
      } else {
        return "Error: ${response.statusCode} - ${response.body}";
      }
    } catch (e) {
      return "Error: $e";
    }
  }
}
