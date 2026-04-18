import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/gemini_service.dart';
import '../data/dream_dictionary.dart';

class DreamPredictorScreen extends StatefulWidget {
  final int currentCoins;
  final Function(int) onCoinDeducted;

  const DreamPredictorScreen({
    super.key,
    required this.currentCoins,
    required this.onCoinDeducted,
  });

  @override
  State<DreamPredictorScreen> createState() => _DreamPredictorScreenState();
}

class _DreamPredictorScreenState extends State<DreamPredictorScreen> {
  final TextEditingController _dreamController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _result;
  bool _isSaved = false;
  bool _isAiAnalysis = false;

  final String _scriptUrl = 'https://script.google.com/macros/s/AKfycbzNNrCsyhU0xRDTlddy0peMhcLg0DKvcZYORZfB1v6s6jH-poHSn2YdgKW7livWINHnow/exec';
  late final GeminiService _geminiService;

  @override
  void initState() {
    super.initState();
    _geminiService = GeminiService(scriptUrl: _scriptUrl);
  }

  void _searchLocalDictionary() {
    final String query = _dreamController.text.trim();
    if (query.isEmpty) return;

    final localResult = DreamDictionary.search(query);
    if (localResult != null) {
      setState(() {
        _result = {
          'prediction': localResult['prediction'],
          'number_hint': 'เปิดตำราทำนายฝันโบราณ',
          'lucky_numbers_2': localResult['numbers_2'],
          'lucky_numbers_3': localResult['numbers_3'],
        };
        _isAiAnalysis = false;
        _isSaved = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่พบในตำรามาตรฐาน ลองให้ "อับดุล" ช่วยวิเคราะห์เจาะลึกดูไหมครับ?')),
      );
    }
  }

  Future<void> _getAiPrediction() async {
    if (widget.currentCoins < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เหรียญไม่พอ (ต้องการ 5 เหรียญสำหรับพลัง AI)')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _result = null;
      _isSaved = false;
    });

    try {
      final String dreamPrompt = """
      บทบาท: คุณคือ 'อับดุล' ผู้เชี่ยวชาญด้านจิตวิเคราะห์และความฝัน
      ผู้ใช้ฝันว่า: '${_dreamController.text}'
      ทำนายฝันเชิงปริศนาธรรม และให้คำใบ้ตัวเลขที่แฝงอยู่
      ตอบกลับเป็น JSON ภาษาไทย: {prediction, number_hint, lucky_numbers_2, lucky_numbers_3}
      """;

      final response = await _geminiService.callAbdul(dreamPrompt);
      final decodedResponse = json.decode(response);

      setState(() {
        _result = decodedResponse;
        _isLoading = false;
        _isAiAnalysis = true;
      });

      widget.onCoinDeducted(widget.currentCoins - 5);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _result = {'error': 'กระแสจิตขัดข้อง: $e'};
      });
    }
  }

  Future<void> _saveToHistory() async {
    if (_result == null || _result!.containsKey('error')) return;
    final prefs = await SharedPreferences.getInstance();
    final String historyJson = prefs.getString('lucky_history') ?? '[]';
    List<dynamic> history = json.decode(historyJson);
    history.insert(0, {
      'date': DateTime.now().toString(),
      'dream': _dreamController.text,
      'prediction': _result!['prediction'],
      'numbers_2': _result!['lucky_numbers_2'],
      'numbers_3': _result!['lucky_numbers_3'],
    });
    await prefs.setString('lucky_history', json.encode(history));
    setState(() => _isSaved = true);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('จารึกลงคลังสำเร็จ!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text('ถอดรหัสความฝัน', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F0F0F), Color(0xFF2A0A0A)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.nightlight_round, size: 60, color: Color(0xFFD4AF37)),
              const SizedBox(height: 20),
              const Text(
                'ความฝันคือสารจากเบื้องบน...',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 30),
              
              // ช่องพิมพ์ฝันแบบ Mystical
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
                ),
                child: TextField(
                  controller: _dreamController,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: const InputDecoration(
                    hintText: 'เล่าความฝันของท่านให้เราฟัง...',
                    hintStyle: TextStyle(color: Colors.white24),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(20),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      label: 'ค้นตำรา (ฟรี)',
                      color: Colors.white10,
                      textColor: const Color(0xFFD4AF37),
                      onTap: _isLoading ? null : _searchLocalDictionary,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildActionButton(
                      label: 'AI เจาะลึก (5 🪙)',
                      color: const Color(0xFFD4AF37),
                      textColor: Colors.black,
                      onTap: _isLoading ? null : _getAiPrediction,
                    ),
                  ),
                ],
              ),
              
              if (_isLoading) 
                const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: Color(0xFFD4AF37)))),
              
              if (_result != null) ...[
                const SizedBox(height: 40),
                _buildSacredResultCard(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({required String label, required Color color, required Color textColor, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5)),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildSacredResultCard() {
    if (_result!.containsKey('error')) return Text('Error: ${_result!['error']}', style: const TextStyle(color: Colors.red));
    
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
        boxShadow: [
          BoxShadow(color: _isAiAnalysis ? const Color(0xFFD4AF37).withOpacity(0.2) : Colors.black, blurRadius: 30)
        ],
      ),
      child: Column(
        children: [
          Icon(_isAiAnalysis ? Icons.auto_awesome : Icons.menu_book, color: const Color(0xFFD4AF37), size: 30),
          const SizedBox(height: 15),
          Text(
            _isAiAnalysis ? 'สารจากอับดุล' : 'จากตำราโบราณ',
            style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          const SizedBox(height: 20),
          Text(
            _result!['prediction'] ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.6),
          ),
          const Divider(height: 40, color: Colors.white10),
          Text(
            'เลขมงคลแฝง',
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, letterSpacing: 2),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildNumberGlow(_result!['lucky_numbers_2'].join(' , ')),
              const SizedBox(width: 20),
              _buildNumberGlow(_result!['lucky_numbers_3'].join(' , ')),
            ],
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: _isSaved ? null : _saveToHistory,
            icon: Icon(_isSaved ? Icons.check : Icons.bookmark_added_outlined),
            label: Text(_isSaved ? 'จารึกแล้ว' : 'จารึกลงคลังเลข'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B0000),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberGlow(String numbers) {
    return Text(
      numbers,
      style: const TextStyle(
        color: Color(0xFFFFD700),
        fontSize: 24,
        fontWeight: FontWeight.bold,
        shadows: [Shadow(color: Color(0xFFD4AF37), blurRadius: 15)],
      ),
    );
  }
}
