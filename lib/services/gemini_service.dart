import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  final String scriptUrl;

  GeminiService({required this.scriptUrl});

  Future<String> callAbdul(String finalPrompt) async {
    try {
      print('--- ยิง Request ไปที่ Apps Script ---');
      
      final response = await http.post(
        Uri.parse(scriptUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'prompt': finalPrompt}),
      );

      String responseBody = "";
      if (response.statusCode == 302) {
        final newUrl = response.headers['location'];
        if (newUrl != null) {
          final finalResponse = await http.get(Uri.parse(newUrl));
          responseBody = finalResponse.body;
        }
      } else {
        responseBody = response.body;
      }

      print('RAW RESPONSE FROM AI: $responseBody');

      // ล้าง Markdown (```json)
      String cleanedBody = responseBody.trim();
      if (cleanedBody.contains('```')) {
        cleanedBody = cleanedBody.split('```')[cleanedBody.split('```').length - 2].replaceAll('json', '').trim();
      }

      return cleanedBody;
    } catch (e) {
      print('Service Error: $e');
      return json.encode({"error": "Connection Failed"});
    }
  }
}
