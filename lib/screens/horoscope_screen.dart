import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/gemini_service.dart';

class HoroscopeScreen extends StatefulWidget {
  final int currentCoins;
  final Function(int) onCoinDeducted;

  const HoroscopeScreen({
    super.key,
    required this.currentCoins,
    required this.onCoinDeducted,
  });

  @override
  State<HoroscopeScreen> createState() => _HoroscopeScreenState();
}

class _HoroscopeScreenState extends State<HoroscopeScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _result;
  String? _selectedZodiac;

  final List<String> _zodiacs = [
    'ราศีเมษ', 'ราศีพฤษภ', 'ราศีเมถุน', 'ราศีกรกฎ',
    'ราศีสิงห์', 'ราศีกันย์', 'ราศีตุลย์', 'ราศีพิจิก',
    'ราศีธนู', 'ราศีมังกร', 'ราศีกุมภ์', 'ราศีมีน'
  ];

  final Map<String, IconData> _zodiacIcons = {
    'ราศีเมษ': Icons.filter_drama, // แกะ
    'ราศีพฤษภ': Icons.agriculture, // วัว
    'ราศีเมถุน': Icons.people_outline, // คู่
    'ราศีกรกฎ': Icons.waves, // ปู
    'ราศีสิงห์': Icons.pets, // สิงโต
    'ราศีกันย์': Icons.face_retouching_natural, // นางฟ้า
    'ราศีตุลย์': Icons.balance, // คันชั่ง
    'ราศีพิจิก': Icons.bug_report, // แมงป่อง
    'ราศีธนู': Icons.near_me, // ธนู
    'ราศีมังกร': Icons.terrain, // มังกร
    'ราศีกุมภ์': Icons.opacity, // คนโทน้ำ
    'ราศีมีน': Icons.sailing, // ปลา
  };

  final String _scriptUrl = 'https://script.google.com/macros/s/AKfycbzNNrCsyhU0xRDTlddy0peMhcLg0DKvcZYORZfB1v6s6jH-poHSn2YdgKW7livWINHnow/exec';
  late final GeminiService _geminiService;

  @override
  void initState() {
    super.initState();
    _geminiService = GeminiService(scriptUrl: _scriptUrl);
  }

  Future<void> _fetchHoroscope(String zodiac) async {
    setState(() {
      _isLoading = true;
      _selectedZodiac = zodiac;
      _result = null;
    });

    try {
      final String horoscopePrompt = """
      คุณคือ 'อับดุล' ปรมาจารย์โหราศาสตร์ไทย
      ช่วยทำนายดวงรายวันของคนราศี: '$zodiac'
      ตอบกลับเป็น JSON ภาษาไทยดังนี้เท่านั้น:
      {
        "work": "สรุปดวงการงาน 1 ประโยค",
        "money": "สรุปดวงการเงิน 1 ประโยค",
        "love": "สรุปดวงความรัก 1 ประโยค",
        "lucky_color": "สีมงคล",
        "lucky_time": "ช่วงเวลาดี"
      }
      """;

      final response = await _geminiService.callAbdul(horoscopePrompt); 
      final decodedResponse = json.decode(response);

      setState(() {
        _result = decodedResponse;
        _isLoading = false;
      });

      // ดึงจาก Sheet (6.0) จะไม่เสีย Token แต่ถ้าเป็นคนแรกของวันจะเสีย 1 Token
      // ตรงนี้เราให้ดูฟรีเพื่อดึงดูดคน (ตามแผน Zero-Token)
    } catch (e) {
      setState(() {
        _isLoading = false;
        _result = {'error': 'กระแสจักรวาลติดขัด: $e'};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text('โชคชะตา 12 ราศี', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F0F0F), Color(0xFF1A0000)],
          ),
        ),
        child: Column(
          children: [
            if (_result == null && !_isLoading) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'เลือกราศีของท่านเพื่อรับคำพยากรณ์',
                  style: TextStyle(color: Colors.white54, fontSize: 16, fontStyle: FontStyle.italic),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _zodiacs.length,
                  itemBuilder: (context, index) {
                    final zodiac = _zodiacs[index];
                    return _buildZodiacPlate(zodiac);
                  },
                ),
              ),
            ] else if (_isLoading) ...[
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Color(0xFFD4AF37)),
                      SizedBox(height: 20),
                      Text('กำลังอ่านรหัสจากดวงดาว...', style: TextStyle(color: Color(0xFFD4AF37), letterSpacing: 1.5)),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(25),
                  child: _buildHoroscopeSacredResult(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: TextButton(
                  onPressed: () => setState(() => _result = null),
                  child: const Text('ตรวจสอบราศีอื่น', style: TextStyle(color: Color(0xFFD4AF37), decoration: TextDecoration.underline)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildZodiacPlate(String zodiac) {
    return InkWell(
      onTap: () => _fetchHoroscope(zodiac),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.4), width: 1.5),
          boxShadow: [
            BoxShadow(color: const Color(0xFFD4AF37).withOpacity(0.05), blurRadius: 10)
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_zodiacIcons[zodiac] ?? Icons.stars, color: const Color(0xFFD4AF37), size: 32),
            const SizedBox(height: 10),
            Text(
              zodiac, 
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHoroscopeSacredResult() {
    if (_result!.containsKey('error')) {
      return Text('เกิดข้อผิดพลาด: ${_result!['error']}', style: const TextStyle(color: Colors.red));
    }

    return Column(
      children: [
        Text(
          'คำพยากรณ์ประจำวัน',
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14, letterSpacing: 2),
        ),
        const SizedBox(height: 10),
        Text(
          _selectedZodiac!, 
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFFFFD700), shadows: [Shadow(color: Color(0xFFD4AF37), blurRadius: 20)]),
        ),
        const SizedBox(height: 40),
        
        _buildResultBox('ดวงการงาน', _result!['work'], Icons.work_outline, Colors.blueAccent),
        _buildResultBox('ดวงการเงิน', _result!['money'], Icons.account_balance_wallet_outlined, Colors.greenAccent),
        _buildResultBox('ดวงความรัก', _result!['love'], Icons.favorite_border, Colors.pinkAccent),
        
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildMiniPlate('สีมงคล', _result!['lucky_color']),
            _buildMiniPlate('ฤกษ์ดี', _result!['lucky_time']),
          ],
        ),
      ],
    );
  }

  Widget _buildResultBox(String title, dynamic content, IconData icon, Color accentColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accentColor, size: 28),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                Text(content.toString(), style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniPlate(String label, dynamic value) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5)),
          ),
          child: Text(
            value.toString(), 
            style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
