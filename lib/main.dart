import 'package:flutter/material.dart';
import 'dart:io';
import 'package:desktop_window/desktop_window.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'screens/dream_predictor_screen.dart';
import 'screens/horoscope_screen.dart';
import 'screens/zodiac_calculator_screen.dart';
import 'screens/lucky_history_screen.dart';
import 'screens/tarot_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (Platform.isAndroid || Platform.isIOS) {
    try {
      MobileAds.instance.initialize();
    } catch (e) {
      debugPrint('AdMob init error: $e');
    }
  }
  
  if (Platform.isWindows) {
    try {
      await DesktopWindow.setWindowSize(const Size(400, 750));
      await DesktopWindow.setMinWindowSize(const Size(400, 750));
      await DesktopWindow.setMaxWindowSize(const Size(400, 750));
    } catch (e) {
      debugPrint('Window sizing failed: $e');
    }
  }
  
  runApp(const SaumuLuckyApp());
}

class AdHelper {
  static String get bannerAdUnitId => 'ca-app-pub-2981218507515166/4209515460';
  static String get rewardedAdUnitId => 'ca-app-pub-2981218507515166/1687293908';
}

class SaumuLuckyApp extends StatelessWidget {
  const SaumuLuckyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Saumu Lucky',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD4AF37),
          primary: const Color(0xFFD4AF37),
          secondary: const Color(0xFF8B0000),
          surface: const Color(0xFF0F0F0F),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0F0F0F),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int userCoins = 10;
  BannerAd? _bannerAd;
  RewardedAd? _rewardedAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    _loadRewardedAd();
  }

  void _loadBannerAd() {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _isBannerAdReady = true),
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          _isBannerAdReady = false;
        },
      ),
    )..load();
  }

  void _loadRewardedAd() {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewardedAd = ad,
        onAdFailedToLoad: (err) => _rewardedAd = null,
      ),
    );
  }

  void _showRewardedAd() {
    if (_rewardedAd == null) {
      setState(() => userCoins += 1);
      _loadRewardedAd();
      return;
    }
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        ad.dispose();
        _loadRewardedAd();
      },
    );
    _rewardedAd!.show(onUserEarnedReward: (ad, reward) {
      setState(() => userCoins += 1);
    });
    _rewardedAd = null;
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _rewardedAd?.dispose();
    super.dispose();
  }

  Map<String, dynamic> _getDailyLuckyColor() {
    final int weekday = DateTime.now().weekday;
    switch (weekday) {
      case 1: return {'day': 'วันจันทร์', 'color': 'เหลือง / ส้ม', 'bg': const Color(0xFF333300), 'text': Colors.yellow[600]!};
      case 2: return {'day': 'วันอังคาร', 'color': 'ชมพู / แดง', 'bg': const Color(0xFF330011), 'text': Colors.pink[400]!};
      case 3: return {'day': 'วันพุธ', 'color': 'เขียว / เทา', 'bg': const Color(0xFF003311), 'text': Colors.green[400]!};
      case 4: return {'day': 'วันพฤหัสบดี', 'color': 'ส้ม / ทอง', 'bg': const Color(0xFF331A00), 'text': Colors.orange[400]!};
      case 5: return {'day': 'วันศุกร์', 'color': 'ฟ้า / น้ำเงิน', 'bg': const Color(0xFF001A33), 'text': Colors.blue[400]!};
      case 6: return {'day': 'วันเสาร์', 'color': 'ม่วง / ดำ', 'bg': const Color(0xFF1A0033), 'text': Colors.purple[400]!};
      case 7: return {'day': 'วันอาทิตย์', 'color': 'แดง / ชมพู', 'bg': const Color(0xFF330000), 'text': Colors.red[400]!};
      default: return {'day': 'วันนี้', 'color': 'ทองมงคล', 'bg': const Color(0xFF1A1A1A), 'text': const Color(0xFFD4AF37)};
    }
  }

  @override
  Widget build(BuildContext context) {
    final lucky = _getDailyLuckyColor();
    
    return Scaffold(
      body: Stack(
        children: [
          // พื้นหลังรูปดวงดาวอลังการ
          Positioned.fill(
            child: Opacity(
              opacity: 0.4, // จางๆ เพื่อไม่ให้กวนเนื้อหา
              child: Image.asset(
                'assets/stars_bg.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // พื้นหลังสีเข้มทับรูปอีกชั้น
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xFF0F0F0F)],
                ),
              ),
            ),
          ),
          
          Column(
            children: [
              AppBar(
                title: const Text('มูนำโชค', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, letterSpacing: 3)),
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                actions: [
                  Container(
                    margin: const EdgeInsets.only(right: 15),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFD4AF37), width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.stars, color: Color(0xFFD4AF37), size: 18),
                        const SizedBox(width: 6),
                        Text('$userCoins', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
                      ],
                    ),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeroBanner(),
                      _buildLuckyColorCard(lucky),
                      const SizedBox(height: 10),
                      _buildMenuGrid(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              _buildAdBanner(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      child: Column(
        children: [
          const Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.circle, size: 100, color: Colors.white10),
              Icon(Icons.auto_awesome, size: 50, color: Color(0xFFD4AF37)),
            ],
          ),
          const SizedBox(height: 15),
          const Text('ประตูสู่โชคชะตา', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5)),
          Text('ให้จิตสัมผัสและ AI นำทางคุณ', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.5))),
        ],
      ),
    );
  }

  Widget _buildLuckyColorCard(Map<String, dynamic> lucky) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: lucky['bg'].withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: lucky['text'].withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('สีมงคล${lucky['day']}: ', style: const TextStyle(fontSize: 14, color: Colors.white70)),
          Text(lucky['color'], style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: lucky['text'])),
        ],
      ),
    );
  }

  Widget _buildMenuGrid() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          _buildPremiumMenuCard(
            title: 'ทำนายฝันเจาะลึก',
            subtitle: 'AI วิเคราะห์ปริศนาธรรม (5 🪙)',
            icon: Icons.nightlight_round,
            color: const Color(0xFFD4AF37),
            onTap: () => _navigateTo(context, 'dream'),
          ),
          _buildPremiumMenuCard(
            title: 'ไพ่ยิปซีรายวัน',
            subtitle: 'เปิดประตูดวงชะตา (2 🪙)',
            icon: Icons.style,
            color: Colors.purple[400]!,
            onTap: () => _navigateTo(context, 'tarot'),
          ),
          Row(
            children: [
              Expanded(
                child: _buildSmallMenuCard(
                  title: 'ดวงปีเกิด',
                  icon: Icons.calendar_month,
                  onTap: () => _navigateTo(context, 'zodiac'),
                ),
              ),
              Expanded(
                child: _buildSmallMenuCard(
                  title: 'ดูดวงรายวัน',
                  icon: Icons.wb_sunny,
                  onTap: () => _navigateTo(context, 'horoscope'),
                ),
              ),
            ],
          ),
          _buildSmallMenuCard(
            title: 'คลังเลขมงคล',
            icon: Icons.auto_stories,
            isFullWidth: true,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LuckyHistoryScreen())),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumMenuCard({required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.5), width: 1.5),
            boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 10)],
          ),
          child: Row(
            children: [
              Icon(icon, size: 35, color: color),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5))),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallMenuCard({required String title, required IconData icon, bool isFullWidth = false, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: const Color(0xFFD4AF37)),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdBanner() {
    if (_isBannerAdReady) {
      return SizedBox(width: _bannerAd!.size.width.toDouble(), height: _bannerAd!.size.height.toDouble(), child: AdWidget(ad: _bannerAd!));
    }
    return Container(height: 50, color: Colors.black, child: const Center(child: Text('ADVERTISING', style: TextStyle(color: Colors.white10, fontSize: 10))));
  }

  void _navigateTo(BuildContext context, String type) {
    Widget targetScreen;
    switch (type) {
      case 'dream':
        targetScreen = DreamPredictorScreen(currentCoins: userCoins, onCoinDeducted: (newCoins) => setState(() => userCoins = newCoins));
        break;
      case 'tarot':
        targetScreen = TarotScreen(currentCoins: userCoins, onCoinDeducted: (newCoins) => setState(() => userCoins = newCoins));
        break;
      case 'zodiac':
        targetScreen = ZodiacCalculatorScreen(currentCoins: userCoins, onCoinDeducted: (newCoins) => setState(() => userCoins = newCoins));
        break;
      case 'horoscope':
        targetScreen = HoroscopeScreen(currentCoins: userCoins, onCoinDeducted: (newCoins) => setState(() => userCoins = newCoins));
        break;
      default: return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (context) => targetScreen));
  }
}
