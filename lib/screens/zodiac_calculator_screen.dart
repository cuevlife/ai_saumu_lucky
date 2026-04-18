import 'package:flutter/material.dart';
import '../services/zodiac_service.dart';

class ZodiacCalculatorScreen extends StatefulWidget {
  final int currentCoins;
  final Function(int) onCoinDeducted;

  const ZodiacCalculatorScreen({
    super.key,
    required this.currentCoins,
    required this.onCoinDeducted,
  });

  @override
  State<ZodiacCalculatorScreen> createState() => _ZodiacCalculatorScreenState();
}

class _ZodiacCalculatorScreenState extends State<ZodiacCalculatorScreen> {
  final TextEditingController _yearController = TextEditingController();
  Map<String, dynamic>? _basicInfo;

  void _calculateZodiac() {
    final int? year = int.tryParse(_yearController.text);
    if (year == null || year < 2400 || year > 2600) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกปี พ.ศ. ให้ถูกต้อง (เช่น 2535)')),
      );
      return;
    }
    setState(() {
      _basicInfo = ZodiacService.getZodiacInfo(year);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('ดวงชะตาตามปีเกิด', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF2A0A0A), Color(0xFF0F0F0F)],
            radius: 1.2,
            center: Alignment.center,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Icon(Icons.stars, size: 60, color: Color(0xFFD4AF37)),
                const SizedBox(height: 15),
                const Text(
                  'พลังแห่งดวงชะตาฟ้าลิขิต',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                ),
                const SizedBox(height: 40),
                
                // กล่องกรอกข้อมูล (Responsive Width)
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: screenWidth * 0.7),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.6), width: 2),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFFD4AF37).withOpacity(0.1), blurRadius: 20, spreadRadius: 2)
                      ],
                    ),
                    child: TextField(
                      controller: _yearController,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      style: const TextStyle(color: Color(0xFFFFD700), fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 10),
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        counterText: "", // ซ่อนเลข 0/4
                        hintText: 'พ.ศ. เกิด',
                        hintStyle: TextStyle(color: Colors.white12, fontSize: 18, letterSpacing: 0),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                      ),
                      onChanged: (text) {
                        if (text.length == 4) {
                          FocusScope.of(context).unfocus();
                          _calculateZodiac();
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                
                if (_basicInfo != null) 
                  _buildMysticalResultCard()
                else
                  _buildWaitingState(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWaitingState() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Opacity(
          opacity: 0.15,
          child: Icon(Icons.auto_awesome_motion, size: 120, color: const Color(0xFFD4AF37)),
        ),
        const SizedBox(height: 20),
        const Text('ระบุปีเกิดเพื่อถอดรหัสชะตาชีวิต', style: TextStyle(color: Colors.white24, letterSpacing: 1.2)),
      ],
    );
  }

  Widget _buildMysticalResultCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A).withOpacity(0.8),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
        boxShadow: [
          BoxShadow(color: const Color(0xFF8B0000).withOpacity(0.4), blurRadius: 50, spreadRadius: -10)
        ],
      ),
      child: Column(
        children: [
          const Text('นักษัตรที่สถิตในดวงของท่าน', style: TextStyle(fontSize: 13, color: Colors.white38, letterSpacing: 2)),
          const SizedBox(height: 12),
          Text(
            _basicInfo!['name'], 
            style: const TextStyle(
              fontSize: 38, 
              fontWeight: FontWeight.bold, 
              color: Color(0xFFFFD700), 
              shadows: [Shadow(color: Color(0xFFD4AF37), blurRadius: 20)]
            )
          ),
          const SizedBox(height: 35),
          const Divider(color: Colors.white10, thickness: 1),
          const SizedBox(height: 25),
          
          _buildDetailRow(Icons.palette_outlined, 'สีมงคลเสริมบารมี', _basicInfo!['lucky_colors']),
          const SizedBox(height: 25),
          _buildDetailRow(Icons.pin_drop_outlined, 'เลขนำโชคประจำตัว', _basicInfo!['lucky_numbers']),
          const SizedBox(height: 25),
          _buildDetailRow(Icons.psychology_outlined, 'พื้นฐานดวงชะตา', _basicInfo!['personality'], isLongText: true),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {bool isLongText = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFD4AF37).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFFD4AF37), size: 22),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.white38, fontSize: 12, letterSpacing: 1)),
              const SizedBox(height: 6),
              Text(
                value, 
                style: TextStyle(
                  color: Colors.white, 
                  fontSize: isLongText ? 15 : 18, 
                  fontWeight: isLongText ? FontWeight.normal : FontWeight.bold,
                  height: 1.6
                )
              ),
            ],
          ),
        ),
      ],
    );
  }
}
