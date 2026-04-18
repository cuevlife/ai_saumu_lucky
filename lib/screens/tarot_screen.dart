import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/tarot_data.dart';

class TarotScreen extends StatefulWidget {
  final int currentCoins;
  final Function(int) onCoinDeducted;

  const TarotScreen({
    super.key,
    required this.currentCoins,
    required this.onCoinDeducted,
  });

  @override
  State<TarotScreen> createState() => _TarotScreenState();
}

class _TarotScreenState extends State<TarotScreen> {
  Map<String, dynamic>? _selectedCard;
  int? _selectedIndex;
  bool _isShuffling = false;
  bool _isLoading = true;
  bool _showDeepMeaning = false;

  @override
  void initState() {
    super.initState();
    _checkDailyCard();
  }

  Future<void> _checkDailyCard() async {
    final prefs = await SharedPreferences.getInstance();
    final String today = DateTime.now().toString().split(' ')[0];
    final String? savedDate = prefs.getString('tarot_date');
    final int? savedIndex = prefs.getInt('tarot_index');

    if (savedDate == today && savedIndex != null) {
      setState(() {
        _selectedIndex = savedIndex;
        _selectedCard = TarotData.majorArcana[savedIndex];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _drawCard() async {
    setState(() {
      _isShuffling = true;
      _selectedCard = null;
      _showDeepMeaning = false;
    });

    await Future.delayed(const Duration(milliseconds: 2000));

    final random = Random();
    final index = random.nextInt(TarotData.majorArcana.length);
    final card = TarotData.majorArcana[index];
    final String today = DateTime.now().toString().split(' ')[0];

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tarot_date', today);
    await prefs.setInt('tarot_index', index);

    setState(() {
      _selectedCard = card;
      _selectedIndex = index;
      _isShuffling = false;
    });

    widget.onCoinDeducted(widget.currentCoins - 2);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(backgroundColor: Color(0xFF0F0F0F), body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text('คำพยากรณ์ยิปซี', style: TextStyle(color: Color(0xFFD4AF37), letterSpacing: 2, fontWeight: FontWeight.bold)),
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
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
            child: Column(
              children: [
                if (_selectedCard == null && !_isShuffling)
                  _buildIntroSection()
                else if (_isShuffling)
                  _buildShufflingAnimation()
                else
                  _buildRevealedCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntroSection() {
    return Column(
      children: [
        const SizedBox(height: 40),
        const Icon(Icons.auto_awesome, color: Color(0xFFD4AF37), size: 50),
        const SizedBox(height: 20),
        const Text(
          'จงหลับตาอธิษฐานถึงสิ่งที่ปรารถนา\nแล้วให้ไพ่บอกทางสว่างแก่เจ้า',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5, fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 50),
        _buildCardBack(onTap: _drawCard),
      ],
    );
  }

  Widget _buildCardBack({VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        height: 380,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFD4AF37), width: 2),
          boxShadow: [
            BoxShadow(color: const Color(0xFFD4AF37).withOpacity(0.2), blurRadius: 25, spreadRadius: 5),
          ],
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.touch_app, color: Color(0xFFD4AF37), size: 60),
              SizedBox(height: 15),
              Text('แตะเพื่อทำนาย', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShufflingAnimation() {
    return Column(
      children: [
        const SizedBox(height: 100),
        const CircularProgressIndicator(color: Color(0xFFD4AF37), strokeWidth: 2),
        const SizedBox(height: 30),
        Text(
          'กระแสจิตกำลังสื่อสาร...',
          style: TextStyle(color: const Color(0xFFD4AF37), fontSize: 18, letterSpacing: 2, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Widget _buildRevealedCard() {
    return Column(
      children: [
        Container(
          width: 240,
          height: 410,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD4AF37), width: 3),
            boxShadow: [
              BoxShadow(color: const Color(0xFFD4AF37).withOpacity(0.4), blurRadius: 40),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(17),
            child: Image.asset(
              'assets/tarot/tarot_$_selectedIndex.jpg',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 30),
        Text(
          _selectedCard!['name'].toUpperCase(),
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37), letterSpacing: 3),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            children: [
              Text(
                _selectedCard!['meaning'],
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: Colors.white, height: 1.6, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 15),
              const Divider(color: Colors.white10),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: () => setState(() => _showDeepMeaning = !_showDeepMeaning),
                icon: Icon(_showDeepMeaning ? Icons.keyboard_arrow_up : Icons.menu_book, color: const Color(0xFFD4AF37)),
                label: Text(
                  _showDeepMeaning ? 'ซ่อนคำแนะนำ' : 'อ่านคำพยากรณ์เจาะลึก',
                  style: const TextStyle(color: Color(0xFFD4AF37)),
                ),
              ),
              if (_showDeepMeaning) ...[
                const SizedBox(height: 15),
                Text(
                  _selectedCard!['deep_meaning'],
                  style: const TextStyle(fontSize: 15, color: Colors.white70, height: 1.7),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 30),
        const Text(
          '* โชคชะตาได้ถูกลิขิตไว้แล้วสำหรับวันนี้ กลับมาใหม่ในวันพรุ่งนี้ *',
          style: TextStyle(color: Colors.white24, fontSize: 11, fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
