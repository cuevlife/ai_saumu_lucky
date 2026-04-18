class ZodiacService {
  static const List<String> zodiacNames = [
    'วอก (ลิง)', 'ระกา (ไก่)', 'จอ (หมา)', 'กุน (หมู)',
    'ชวด (หนู)', 'ฉลู (วัว)', 'ขาล (เสือ)', 'เถาะ (กระต่าย)',
    'มะโรง (มังกร/งูใหญ่)', 'มะเส็ง (งูเล็ก)', 'มะเมีย (ม้า)', 'มะแม (แพะ)'
  ];

  static Map<String, dynamic> getZodiacInfo(int yearBE) {
    // สูตรคำนวณปีนักษัตรไทย: (พ.ศ. % 12)
    final int index = yearBE % 12;
    final String name = zodiacNames[index];

    // ข้อมูลพื้นฐานตามตำรา (ไม่ต้องใช้ AI - ประหยัด Token)
    switch (index) {
      case 4: // ชวด
        return {'name': name, 'lucky_numbers': '1, 6, 7', 'lucky_colors': 'น้ำเงิน, ทอง', 'personality': 'ฉลาดหลักแหลม ปรับตัวเก่ง'};
      case 5: // ฉลู
        return {'name': name, 'lucky_numbers': '2, 8, 9', 'lucky_colors': 'เขียว, เหลือง', 'personality': 'อดทน ซื่อสัตย์ หนักแน่น'};
      case 6: // ขาล
        return {'name': name, 'lucky_numbers': '1, 3, 4', 'lucky_colors': 'ขาว, แดง', 'personality': 'กล้าหาญ มีความเป็นผู้นำ'};
      case 7: // เถาะ
        return {'name': name, 'lucky_numbers': '3, 4, 6', 'lucky_colors': 'ชมพู, เขียว', 'personality': 'อ่อนโยน ใจดี มีเมตตา'};
      case 8: // มะโรง
        return {'name': name, 'lucky_numbers': '2, 5, 8', 'lucky_colors': 'เหลือง, ขาว', 'personality': 'มีอำนาจบารมี ทะเยอทะยาน'};
      case 9: // มะเส็ง
        return {'name': name, 'lucky_numbers': '2, 3, 9', 'lucky_colors': 'ดำ, แดง', 'personality': 'เฉลียวฉลาด ลึกลับ มีเสน่ห์'};
      case 10: // มะเมีย
        return {'name': name, 'lucky_numbers': '1, 3, 7', 'lucky_colors': 'ม่วง, ส้ม', 'personality': 'รักอิสระ ร่าเริง กระตือรือร้น'};
      case 11: // มะแม
        return {'name': name, 'lucky_numbers': '2, 5, 9', 'lucky_colors': 'น้ำตาล, ครีม', 'personality': 'สุภาพ มีศิลปะ รักสงบ'};
      case 0: // วอก
        return {'name': name, 'lucky_numbers': '4, 6, 8', 'lucky_colors': 'ขาว, ทอง', 'personality': 'ซน ฉลาด มีไหวพริบ'};
      case 1: // ระกา
        return {'name': name, 'lucky_numbers': '5, 7, 8', 'lucky_colors': 'เหลือง, น้ำตาล', 'personality': 'เจ้าระเบียบ ขยัน ตรงไปตรงมา'};
      case 2: // จอ
        return {'name': name, 'lucky_numbers': '3, 4, 9', 'lucky_colors': 'แดง, เขียว', 'personality': 'ซื่อสัตย์ กตัญญู จริงใจ'};
      case 3: // กุน
        return {'name': name, 'lucky_numbers': '1, 2, 6', 'lucky_colors': 'ฟ้า, ขาว', 'personality': 'ใจกว้าง มีโชคลาภตลอดชีวิต'};
      default:
        return {'name': 'ไม่ระบุ', 'lucky_numbers': '-', 'lucky_colors': '-', 'personality': '-'};
    }
  }
}
