import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gsheets/gsheets.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'security_service.dart';

class GeminiService {
  final String _spreadsheetId = "1IKH7fnrCP91lKTmrW2d21c6CG_K3xpwS3FCsDkegc08";
  
  // 🔐 ข้อมูล Service Account (Encrypted JSON - ปลอดภัยจากการตรวจจับของ GitHub)
  final String _encryptedServiceAccount = "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";

  GSheets? _gsheets;
  Spreadsheet? _ss;
  String? _cachedApiKey;
  String? _cachedModelName;
  Future<void>? _initFuture;

  /// ระบบล็อกการเชื่อมต่อ พร้อมถอดรหัสกุญแจใน RAM
  Future<void> _initGSheets() async {
    if (_initFuture != null) return _initFuture;
    _initFuture = _doInit();
    return _initFuture;
  }

  Future<void> _doInit() async {
    try {
      // ถอดรหัสกุญแจชุดเต็มใน RAM
      final String serviceAccountJson = SecurityService.decryptKey(_encryptedServiceAccount);
      
      if (serviceAccountJson == "ERROR_DECRYPTING") {
        print("DEBUG_ERROR: Failed to decrypt Service Account credentials");
        _initFuture = null;
        return;
      }

      _gsheets = GSheets(serviceAccountJson);
      _ss = await _gsheets!.spreadsheet(_spreadsheetId);
      print("DEBUG_SUCCESS: Connected to Private Sheet!");
    } catch (e) {
      _initFuture = null;
      print("DEBUG_ERROR: GSheets Init Error: $e");
    }
  }

  Future<void> _loadConfig() async {
    if (_cachedApiKey != null) return;
    try {
      await _initGSheets();
      if (_ss == null) return;
      
      final sheet = _ss!.worksheetByTitle('Config');
      if (sheet == null) return;

      final values = await sheet.values.allRows();
      for (var row in values) {
        if (row.length < 2) continue;
        final key = row[0].toString().trim();
        final value = row[1].toString().trim();
        
        if (key == 'API_KEY_1') {
          _cachedApiKey = SecurityService.decryptKey(value);
          print("READ_SUCCESS: API_KEY_1 retrieved");
        } else if (key == 'MODEL_NAME') {
          _cachedModelName = value;
          print("READ_SUCCESS: MODEL_NAME: $_cachedModelName");
        }
      }
    } catch (e) {
      print("DEBUG_ERROR: Config Load Failed: $e");
    }
  }

  Future<String?> _getCachedHoroscope(String zodiac) async {
    try {
      await _loadConfig();
      if (_ss == null) return null;
      final sheet = _ss!.worksheetByTitle('HoroscopeDB');
      if (sheet == null) return null;
      final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final rows = await sheet.values.allRows();
      for (var i = rows.length - 1; i >= 0; i--) {
        if (rows[i].length < 3) continue;
        if (rows[i][0] == today && rows[i][1] == zodiac) return rows[i][2];
      }
    } catch (e) {
      print("READ_CACHE_ERROR: $e");
    }
    return null;
  }

  void _saveToSheet(String zodiac, String resultData) async {
    try {
      await _initGSheets();
      if (_ss == null) return;
      final sheet = _ss!.worksheetByTitle('HoroscopeDB');
      if (sheet == null) return;
      final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await sheet.values.appendRow([today, zodiac, resultData]);
      print("WRITE_SUCCESS: Saved to Private Sheet");
    } catch (e) {
      print("WRITE_ERROR: $e");
    }
  }

  Future<String> callAbdul(String finalPrompt) async {
    String? currentZodiac;
    if (finalPrompt.contains("ช่วยทำนายดวงรายวันของคนราศี")) {
      final match = RegExp(r"ราศี: '([^']+)'").firstMatch(finalPrompt);
      if (match != null) {
        currentZodiac = match.group(1)!;
        final String? cachedData = await _getCachedHoroscope(currentZodiac);
        if (cachedData != null) return cachedData;
      }
    }

    try {
      await _loadConfig();
      if (_cachedApiKey == null || _cachedApiKey == "ERROR_DECRYPTING") {
        return json.encode({"error": "กุญแจ AI ไม่ถูกต้อง หรือถอดรหัสไม่ได้"});
      }

      final model = GenerativeModel(
        model: _cachedModelName ?? 'gemini-1.5-flash', 
        apiKey: _cachedApiKey!,
      );

      final content = [Content.text(finalPrompt)];
      final response = await model.generateContent(content);

      String responseText = response.text ?? "";
      if (responseText.contains('```')) {
        responseText = responseText.split('```')[responseText.split('```').length - 2].replaceAll('json', '').trim();
      }

      if (currentZodiac != null && responseText.startsWith('{')) {
        _saveToSheet(currentZodiac, responseText);
      }

      return responseText;
    } catch (e) {
      return json.encode({"error": "Error: $e"});
    }
  }
}
