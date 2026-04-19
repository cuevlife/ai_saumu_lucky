import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gsheets/gsheets.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'security_service.dart';

class GeminiService {
  final String _spreadsheetId = "1IKH7fnrCP91lKTmrW2d21c6CG_K3xpwS3FCsDkegc08";
  
  final String _clientEmail = "kranservice@sheetapikran.iam.gserviceaccount.com";
  final String _projectId = "sheetapikran";
  final String _clientId = "114691998876646156937";
  final String _privateKeyId = "ae76025c3912ff069f64acd42c4e93b476e24097";
  
  // 🔐 รหัสลับ Private Key (ชุดสมบูรณ์ 100% ผ่านการตรวจสอบ Block Size แล้ว)
  final String _encryptedPrivateKey = "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";

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
      final String privateKey = SecurityService.decryptKey(_encryptedPrivateKey.trim());
      if (privateKey == "ERROR_DECRYPTING") {
        print("DEBUG_ERROR: Private Key Decryption Failed");
        _initFuture = null;
        return;
      }

      final credentials = {
        "type": "service_account",
        "project_id": _projectId,
        "private_key_id": _privateKeyId,
        "private_key": privateKey,
        "client_email": _clientEmail,
        "client_id": _clientId,
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/${Uri.encodeComponent(_clientEmail)}",
        "universe_domain": "googleapis.com"
      };

      _gsheets = GSheets(json.encode(credentials));
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
      if (_ss == null) return;
      final sheet = _ss!.worksheetByTitle('Config');
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
        await sheet.values.appendRow([today, zodiac, resultData]);
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
      if (result == null) return json.encode({"error": "พลังงานจักรวาลขัดข้อง"});
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
