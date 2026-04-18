import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LuckyHistoryScreen extends StatefulWidget {
  const LuckyHistoryScreen({super.key});

  @override
  State<LuckyHistoryScreen> createState() => _LuckyHistoryScreenState();
}

class _LuckyHistoryScreenState extends State<LuckyHistoryScreen> {
  List<dynamic> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String historyJson = prefs.getString('lucky_history') ?? '[]';
    setState(() {
      _history = json.decode(historyJson);
      _isLoading = false;
    });
  }

  Future<void> _deleteItem(int index) async {
    setState(() {
      _history.removeAt(index);
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lucky_history', json.encode(_history));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text('คลังเลขศักดิ์สิทธิ์', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F0F0F), Color(0xFF1A0A0A)],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
            : _history.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _history.length,
                    itemBuilder: (context, index) {
                      final item = _history[index];
                      return _buildHistorySacredCard(item, index);
                    },
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_stories_outlined, size: 80, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 20),
          const Text('ยังไม่มีบันทึกโชคชะตา', style: TextStyle(color: Colors.white24, fontSize: 16, letterSpacing: 1.5)),
        ],
      ),
    );
  }

  Widget _buildHistorySacredCard(Map<String, dynamic> item, int index) {
    final DateTime date = DateTime.parse(item['date']);
    final String dateStr = "${date.day}/${date.month}/${date.year + 543}";

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              item['dream'] ?? 'ถอดรหัสฝัน',
              style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Text(dateStr, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12)),
            trailing: IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: Color(0xFF8B0000)),
              onPressed: () => _deleteHistoryDialog(index),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Text(
              item['prediction'] ?? '',
              style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withOpacity(0.05),
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNumberAura('2 ตัว', item['numbers_2'].join(' , ')),
                _buildNumberAura('3 ตัว', item['numbers_3'].join(' , ')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberAura(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(
          value, 
          style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 20, shadows: [Shadow(color: Color(0xFF8B4513), blurRadius: 10)]),
        ),
      ],
    );
  }

  void _deleteHistoryDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('ลบจารึกนี้?', style: TextStyle(color: Color(0xFFD4AF37))),
        content: const Text('ท่านต้องการลบประวัติเลขมงคลนี้ใช่หรือไม่?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ยกเลิก', style: TextStyle(color: Colors.white24))),
          TextButton(
            onPressed: () {
              _deleteItem(index);
              Navigator.pop(context);
            },
            child: const Text('ลบออก', style: TextStyle(color: Color(0xFF8B0000))),
          ),
        ],
      ),
    );
  }
}
