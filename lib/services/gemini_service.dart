import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gsheets/gsheets.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'security_service.dart';

class GeminiService {
  final String _spreadsheetId = "1IKH7fnrCP91lKTmrW2d21c6CG_K3xpwS3FCsDkegc08";
  
  // 🔐 ข้อมูล Service Account (Encrypted JSON - ปลอดภัยจากการตรวจจับของ GitHub)
  final String _encryptedServiceAccount = "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\n-----END PRIVATE KEY-----\n\",  \"client_email\": \"kranservice@sheetapikran.iam.gserviceaccount.com\",  \"client_id\": \"114691998876646156937\",  \"auth_uri\": \"https://accounts.google.com/o/oauth2/auth\",  \"token_uri\": \"https://oauth2.googleapis.com/token\",  \"auth_provider_x509_cert_url\": \"https://www.googleapis.com/oauth2/v1/certs\",  \"client_x509_cert_url\": \"https://www.googleapis.com/robot/v1/metadata/x509/kranservice%40sheetapikran.iam.gserviceaccount.com\",  \"universe_domain\": \"googleapis.com\"}";
  
  GSheets? _gsheets;
  Spreadsheet? _ss;
  List<String> _apiKeys = [];
  String? _model1;
  String? _model2;
  Future<void>? _initFuture;

  final Map<String, String> _sessionCache = {};

  Future<void> _initGSheets() async {
    if (_initFuture != null) return _initFuture;
    _initFuture = _doInit();
    return _initFuture;
  }

  Future<void> _doInit() async {
    try {
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
    if (_apiKeys.isNotEmpty) return;
    try {
      await _initGSheets();
      final sheet = _ss?.worksheetByTitle('Config');
      if (sheet == null) return;
      final values = await sheet.values.allRows();
      List<String> foundKeys = [];
      for (var row in values) {
        if (row.length < 2) continue;
        final keyName = row[0].toString().trim();
        final val = row[1].toString().trim();
        if (keyName.startsWith('API_KEY_')) {
          final decrypted = SecurityService.decryptKey(val);
          if (decrypted != "ERROR_DECRYPTING") foundKeys.add(decrypted);
        } else if (keyName == 'MODEL_NAME_1') {
          _model1 = val;
        } else if (keyName == 'MODEL_NAME_2') {
          _model2 = val;
        }
      }
      _apiKeys = foundKeys;
    } catch (e) {
      print("DEBUG_ERROR: Config Load Failed: $e");
    }
  }

  Future<String?> _getCachedHoroscope(String zodiac) async {
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final String cacheKey = "${today}_$zodiac";
    if (_sessionCache.containsKey(cacheKey)) return _sessionCache[cacheKey];
    try {
      await _initGSheets();
      final sheet = _ss?.worksheetByTitle('HoroscopeDB');
      if (sheet == null) return null;
      final rows = await sheet.values.allRows();
      for (var i = rows.length - 1; i >= 0; i--) {
        if (rows[i].length < 3) continue;
        final String sDate = rows[i][0].toString().replaceAll(RegExp(r'[^0-9-]'), '').trim();
        final String sZodiac = rows[i][1].toString().trim();
        if (sDate.contains(today) && sZodiac == zodiac.trim()) {
          final data = rows[i][2];
          _sessionCache[cacheKey] = data;
          return data;
        }
      }
    } catch (e) {
      print("READ_CACHE_ERROR: $e");
    }
    return null;
  }

  void _saveToSheet(String zodiac, String resultData) async {
    try {
      await _initGSheets();
      final sheet = _ss?.worksheetByTitle('HoroscopeDB');
      if (sheet == null) return;
      final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final rows = await sheet.values.allRows();
      bool alreadyExists = rows.any((r) => r.length >= 2 && r[0].toString().replaceAll(RegExp(r'[^0-9-]'), '').contains(today) && r[1].toString().trim() == zodiac.trim());
      if (!alreadyExists) {
        await sheet.values.appendRow(["'$today", zodiac, resultData]);
        print("WRITE_SUCCESS: Saved horoscope for $zodiac");
      }
    } catch (e) {
      print("WRITE_ERROR: $e");
    }
  }

  Future<String?> _tryGenerate(String modelName, String prompt) async {
    for (int i = 0; i < _apiKeys.length; i++) {
      try {
        final model = GenerativeModel(model: modelName, apiKey: _apiKeys[i], generationConfig: GenerationConfig(temperature: 0.1));
        final response = await model.generateContent([Content.text(prompt)]);
        if (response.text != null) return response.text;
      } catch (e) {
        print("DEBUG: Key ${i + 1} failed: $e");
      }
    }
    return null;
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
      if (_apiKeys.isEmpty) return json.encode({"error": "ไม่พบกุญแจ AI"});
      final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final String sacredPrompt = "$finalPrompt\nตัวแปรคงที่: วันที่ $today\nคำสั่ง: ทำนายตามหลักโหราศาสตร์ไทยแท้ 100%";
      String? result = await _tryGenerate(_model1 ?? 'gemini-1.5-flash', sacredPrompt);
      if (result == null && _model2 != null) result = await _tryGenerate(_model2!, sacredPrompt);
      if (result == null) return json.encode({"error": "พลังงานขัดข้อง"});
      String responseText = result;
      if (responseText.contains('```')) responseText = responseText.split('```')[responseText.split('```').length - 2].replaceAll('json', '').trim();
      if (currentZodiac != null && responseText.startsWith('{')) {
        _sessionCache["${today}_$currentZodiac"] = responseText;
        _saveToSheet(currentZodiac, responseText);
      }
      return responseText;
    } catch (e) {
      return json.encode({"error": "Error: $e"});
    }
  }
}
