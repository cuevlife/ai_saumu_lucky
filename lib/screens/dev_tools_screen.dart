import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/security_service.dart';

class DevToolsScreen extends StatefulWidget {
  const DevToolsScreen({super.key});

  @override
  State<DevToolsScreen> createState() => _DevToolsScreenState();
}

class _DevToolsScreenState extends State<DevToolsScreen> {
  final TextEditingController _keyController = TextEditingController();
  String _encryptedResult = "";

  void _generateEncryptedKey() {
    if (_keyController.text.trim().isEmpty) return;
    setState(() {
      _encryptedResult = SecurityService.encryptKey(_keyController.text.trim());
      _keyController.clear(); // ล้าง Key จริงทิ้งทันทีหลังแปลงเสร็จเพื่อความปลอดภัย
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text('Sacred Vault', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 16)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            TextField(
              controller: _keyController,
              style: const TextStyle(color: Colors.white),
              obscureText: true, // ปิดบัง Key ขณะพิมพ์เพื่อความปลอดภัย
              decoration: InputDecoration(
                hintText: 'API KEY',
                hintStyle: const TextStyle(color: Colors.white12),
                filled: true,
                fillColor: Colors.white.withOpacity(0.03),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: _generateEncryptedKey,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37).withOpacity(0.8),
                foregroundColor: Colors.black,
                elevation: 0,
              ),
              child: const Text('ENCRYPT', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            if (_encryptedResult.isNotEmpty) ...[
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    SelectableText(
                      _encryptedResult,
                      style: const TextStyle(color: Color(0xFFD4AF37), fontFamily: 'monospace', fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    IconButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _encryptedResult));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('COPIED'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                        setState(() => _encryptedResult = ""); // ล้างผลลัพธ์หลังก๊อปปี้
                      },
                      icon: const Icon(Icons.copy_all, color: Colors.white24, size: 20),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
