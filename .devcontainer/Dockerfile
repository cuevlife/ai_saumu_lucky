FROM ghcr.io/cirruslabs/flutter:3.24.0

# ติดตั้งอุปกรณ์เพิ่มเติมที่จำเป็น
RUN apt-get update && apt-get install -y \
    usbutils \
    && rm -rf /var/lib/apt/lists/*

# ย้ายเข้าไปที่โฟลเดอร์ทำงาน
WORKDIR /app

# ยอมรับ Android Licenses อัตโนมัติ
RUN yes | flutter doctor --android-licenses || true

# ตรวจสอบสถานะ Flutter
RUN flutter doctor
