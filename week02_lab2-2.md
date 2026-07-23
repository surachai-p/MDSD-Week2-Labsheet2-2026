# ใบงานการทดลองที่ 2-2
# Flutter Framework Basics
### วิชา: การพัฒนาซอฟต์แวร์สำหรับอุปกรณ์เคลื่อนที่

| | |
|--|--|
| **สัปดาห์ที่** | 2 |
| **ใบงานที่** | 2-2 จาก 2 |
| **เวลา** | 2 ชั่วโมง 30 นาที |
| **เครื่องมือ** | VS Code + Flutter SDK (ติดตั้งแล้วจากสัปดาห์ที่ 1) |

---

## วัตถุประสงค์

เมื่อสิ้นสุดการทดลอง นักศึกษาสามารถ:

1. อธิบายโครงสร้าง Widget Tree และความสัมพันธ์ระหว่าง Parent-Child Widget ได้
2. เขียน StatelessWidget ที่รับ Parameter และแสดงผลได้
3. เขียน StatefulWidget ที่ใช้ setState() อัปเดต UI ได้
4. อธิบาย Widget Lifecycle และรู้ว่าควรทำอะไรใน initState() และ dispose()
5. ใช้ Hot Reload และ Hot Restart ได้อย่างถูกต้อง

---

## การเตรียมตัวก่อนทดลอง

### ตรวจสอบการติดตั้ง Flutter

เปิด Terminal แล้วรันคำสั่งต่อไปนี้:

```bash
flutter doctor
```

**ผลที่ต้องการเห็น (อย่างน้อย):**
```
[✓] Flutter (Channel stable, 3.x.x, ...)
[✓] Android toolchain
[✓] VS Code (version ...)
[!] Android Studio  ← ไม่ต้องสนใจ ไม่ใช้ใน Lab นี้
```

ถ้าเห็น `[✗] Flutter` แสดงว่ายังไม่ได้ติดตั้ง ให้ทำตาม **ภาคผนวก A** ก่อน

### ตรวจสอบ VS Code Extensions

เปิด VS Code → Extensions (Ctrl+Shift+X) → ค้นหาและติดตั้ง:
- **Flutter** (by Dart Code) — ต้องมี
- **Dart** (by Dart Code) — ต้องมี

---

## ทฤษฎีก่อนการทดลอง

### ก. Flutter Architecture — ทำงานอย่างไรเบื้องหลัง

Flutter แตกต่างจาก Framework อื่นตรงที่ **ไม่ได้ใช้ Native UI Component** แต่วาด UI ทุก Pixel ด้วย Rendering Engine ของตัวเอง

```
┌─────────────────────────────────────────────────────────┐
│                  Flutter Application                    │
│              (โค้ด Dart ที่เราเขียน)                        │
├─────────────────────────────────────────────────────────┤
│               Flutter Framework (Dart)                  │
│   Widgets │ Animation │ Painting │ Gestures │ Services  │
├─────────────────────────────────────────────────────────┤
│        Flutter Engine (C++ / Impeller)                  │
│   วาด UI ทุก Pixel ลงบน Canvas โดยตรง                    │
│   ← ไม่พึ่ง Native Button, Native Text ของ Platform        │
├────────────────────┬────────────────────────────────────┤
│   Android Embedder │   iOS Embedder                     │
│   (รับ Surface)    │   (รับ Surface)                      │
├────────────────────┴────────────────────────────────────┤
│              Operating System                           │
└─────────────────────────────────────────────────────────┘
```

**ผลที่ได้จาก Architecture นี้:**
- UI เหมือนกันทุก Pixel บนทุก Platform
- ไม่มี Bridge ระหว่าง Dart กับ Native — Performance ดี
- Flutter รองรับ Android, iOS, Web, Desktop จาก Codebase เดียว

---

### ข. Widget Tree — โครงสร้างต้นไม้ของ UI

ทุกอย่างใน Flutter เป็น Widget และซ้อนกันเป็นต้นไม้

```
MaterialApp  ← Root ของทั้งแอป
└── Scaffold  ← โครงหน้าจอหลัก
    ├── AppBar  ← แถบด้านบน
    │   └── Text("ชื่อหน้า")
    └── body: Column  ← จัดเรียงแนวตั้ง
        ├── Image.network(...)  ← รูปภาพ
        ├── Text("ชื่อ")
        ├── SizedBox(height: 16)  ← ช่องว่าง
        └── ElevatedButton(...)  ← ปุ่ม
```

**กฎการไหลของข้อมูล:**

```
Parent Widget
│  data = "ข้อมูล"
│  ↓ ส่งผ่าน Constructor (Props)
│
Child Widget(text: data)
│  ↓ แสดงผล
│
GrandChild Widget(...)
```

- **ข้อมูลไหลลง** จาก Parent → Child เสมอ
- **Event ไหลขึ้น** ผ่าน Callback Function

---

### ค. สามต้นไม้ที่ Flutter ใช้จัดการ UI

```
Widget Tree          Element Tree         RenderObject Tree
(คำอธิบาย UI)        (Instance จริง)      (วาดบนหน้าจอ)

Text("สวัสดี")  →    TextElement    →    RenderParagraph
    │                    │                     │
    │            จำตำแหน่งและ State     วาด Pixel จริง
    │
    └─ Widget เป็น Immutable ─┐
       สร้างใหม่ได้บ่อย        │
       ราคาถูก               Element ไม่สร้างใหม่
                             แค่อัปเดต → RenderObject
```

**สิ่งสำคัญ:** Widget เป็น Immutable (เปลี่ยนค่าตรงๆ ไม่ได้) เมื่อต้องการเปลี่ยน UI ต้อง rebuild Widget ใหม่ผ่าน setState()

---

### ง. StatelessWidget vs StatefulWidget

```
                ถาม: "Widget นี้ต้องเปลี่ยนแปลงเองได้ไหม?"
                              │
                  ┌───────────┴────────────┐
                 ไม่                      ใช่
                  │                        │
                  ▼                        ▼
          StatelessWidget          StatefulWidget
          (UI คงที่)               (UI เปลี่ยนได้)

ตัวอย่าง:                       ตัวอย่าง:
- Card แสดงข้อมูล              - Counter ที่นับเลข
- Avatar โปรไฟล์               - Form ที่กรอกข้อมูล
- Badge แสดงสถานะ             - Tab ที่สลับได้
- ข้อความทั่วไป                - Loading → Data → Error
```

**StatelessWidget — โครงสร้าง:**

```dart
class MyCard extends StatelessWidget {
  // รับข้อมูลจากภายนอกผ่าน Constructor เท่านั้น
  final String title;
  final String subtitle;

  const MyCard({              // const constructor = Performance ดีขึ้น
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    // build() เรียกเมื่อ Parent rebuild
    // ไม่มี State ที่เปลี่ยนเองได้
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}
```

**StatefulWidget — โครงสร้างสองชั้น:**

```dart
// ชั้นที่ 1: Widget (Immutable เหมือน Stateless)
class CounterWidget extends StatefulWidget {
  final String label;
  const CounterWidget({super.key, required this.label});

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

// ชั้นที่ 2: State (เปลี่ยนได้ คงอยู่แม้ Widget rebuild)
class _CounterWidgetState extends State<CounterWidget> {
  int _count = 0;  // State ที่เปลี่ยนได้

  // เข้าถึง Widget's properties ผ่าน widget.xxx
  String get _label => widget.label;

  void _increment() {
    setState(() {     // บอก Flutter: "State เปลี่ยน ให้ rebuild"
      _count++;       // แก้ State ข้างใน setState()
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("$_label: $_count"),
        ElevatedButton(
          onPressed: _increment,
          child: const Text("+1"),
        ),
      ],
    );
  }
}
```

---

### จ. Widget Lifecycle ของ StatefulWidget

```
สร้าง StatefulWidget
        │
        ▼
  createState()   ← Flutter สร้าง State Object
        │
        ▼
  initState()     ← ✅ รันครั้งเดียวเมื่อสร้าง Widget
        │            ✅ โหลดข้อมูลเริ่มต้น
        │            ✅ สมัคร Stream / Timer
        │            ✅ ตั้ง AnimationController
        │            ❗ ต้องเรียก super.initState() ก่อนเสมอ
        ▼
  build()         ← วาด UI ทุกครั้งที่ setState() เรียก
        │
    setState() → build() อีกครั้ง (วนซ้ำ)
        │
        ▼
  didUpdateWidget()  ← เมื่อ Parent ส่ง Parameter ใหม่
        │
        ▼
  deactivate()    ← Widget ถูกนำออกจาก Tree ชั่วคราว
        │
        ▼
  dispose()       ← ✅ รันครั้งเดียวเมื่อ Widget ถูกลบ
                     ✅ ยกเลิก Timer, Stream Subscription
                     ✅ dispose AnimationController
                     ✅ dispose TextEditingController
                     ❗ ต้องเรียก super.dispose() หลังสุดเสมอ
```

**ข้อควรระวัง: mounted check**

```dart
Future<void> _loadData() async {
  var result = await someApiCall();

  // ❗ ต้องตรวจสอบ mounted ก่อน setState
  // เพราะ Widget อาจถูก dispose() ระหว่างรอ API
  if (mounted) {
    setState(() {
      _data = result;
    });
  }
}
```

---

### ฉ. Hot Reload vs Hot Restart

```
ทำอะไร?      Hot Reload ⚡              Hot Restart 🔄
             Inject โค้ดใหม่ →          รีสตาร์ทแอป
             rebuild Widget Tree        ตั้งต้นใหม่

เวลา:         < 1 วินาที                2-5 วินาที
State:        ✅ คงอยู่                  ❌ รีเซ็ต

เหมาะกับ:    แก้สี, ขนาด, Text         แก้ initState()
             Logic ใน build()           แก้ main()
             เพิ่ม/ลบ Widget           เพิ่ม Asset ใหม่

วิธีใช้:     บันทึกไฟล์ (Ctrl+S)       กด 🔄 ใน toolbar
             หรือกด ⚡ ใน toolbar      หรือพิมพ์ R ใน Terminal
```

---

## การทดลอง — สร้าง Flutter App ทีละขั้นตอน

> **แนวทาง:** ใบงานนี้ค่อยๆ สร้างแอปทีละชิ้นส่วน เพื่อให้เห็นว่าแต่ละ Widget ทำหน้าที่อะไร ก่อนรวมกันเป็นแอปสมบูรณ์

### ขั้นตอนการเตรียม Project

**ขั้นตอนที่ 1** เปิด Terminal แล้วรันคำสั่งสร้าง Project ใหม่:

```bash
cd ~/Documents
flutter create week02_flutter_lab
cd week02_flutter_lab
code .
```

**ขั้นตอนที่ 2** VS Code เปิดขึ้นมา รอสักครู่จนเห็น `pub get` ทำงานเสร็จ (มุมล่างขวา)

**ขั้นตอนที่ 3** เปิด Emulator

วิธีที่ 1 — ผ่าน VS Code:
- กด `Ctrl+Shift+P` → พิมพ์ `Flutter: Launch Emulator`
- เลือก Emulator ที่ต้องการ

วิธีที่ 2 — ผ่าน Terminal:
```bash
flutter emulators --launch <emulator_id>
# หรือดู emulator ที่มีก่อน
flutter emulators
```

> **ไม่มี Emulator?** ดู **ภาคผนวก B** เพื่อสร้าง Android Emulator

**ขั้นตอนที่ 4** ตรวจสอบว่า Emulator ขึ้นที่มุมขวาล่างของ VS Code เช่น `sdk gphone... (android)`

---

### การทดลองที่ 1 — Hello World และโครงสร้างพื้นฐาน

**เป้าหมาย:** เข้าใจโครงสร้างขั้นต่ำของ Flutter App

**ขั้นตอนที่ 1** เปิดไฟล์ `lib/main.dart` แล้ว **แทนที่เนื้อหาทั้งหมด** ด้วยโค้ดนี้:

```dart
import 'package:flutter/material.dart';

// จุดเริ่มต้นของ App ทุกตัว
void main() {
  runApp(const MyApp());
}

// Root Widget ของแอป
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Week 02 Lab',
      // ปิด Banner "DEBUG" ที่มุมขวาบน
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

// หน้าแรก
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Week 02 Flutter Lab'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'สวัสดี Flutter! 🎉',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
```

**ขั้นตอนที่ 2** รันแอปด้วยคำสั่ง:

```bash
flutter run
```

หรือกด **F5** ใน VS Code (เลือก Flutter ถ้าถาม)

**ขั้นตอนที่ 3** รอจน App ขึ้นบน Emulator ควรเห็นข้อความ "สวัสดี Flutter!"

**✏️ ทดลองแก้ไข A:** แก้ข้อความ `'สวัสดี Flutter! 🎉'` เป็นชื่อของตัวเอง แล้วบันทึกไฟล์ (`Ctrl+S`) สังเกตว่า UI อัปเดตทันทีผ่าน **Hot Reload** โดยไม่ต้อง Restart แอป

**✏️ ทดลองแก้ไข B:** เปลี่ยน `fontSize: 24` เป็น `fontSize: 48` บันทึกไฟล์และสังเกตผล

**บันทึกรูปผลการทดลอง**

<img width="1163" height="726" alt="image" src="https://github.com/user-attachments/assets/dad995b3-9f35-489f-9ac7-af2269f42388" />

---

### การทดลองที่ 2 — Layout Widgets: Column, Row, Container

**เป้าหมาย:** จัดวาง Widget ด้วย Column, Row และ Container ได้

**ขั้นตอนที่ 1** แทนที่ `body` ของ `HomePage` ด้วยโค้ดนี้:

```dart
      body: Column(
        // mainAxisAlignment จัดวางตามแกนหลัก (แนวตั้งสำหรับ Column)
        mainAxisAlignment: MainAxisAlignment.center,
        // crossAxisAlignment จัดวางตามแกนรอง (แนวนอนสำหรับ Column)
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Container — กล่องที่ปรับแต่งได้
          Container(
            width: 200,
            height: 100,
            color: Colors.indigo.shade100,
            child: const Center(
              child: Text(
                'Container',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),

          // SizedBox — ช่องว่างระหว่าง Widget
          const SizedBox(height: 16),

          // Row — จัดเรียงแนวนอน
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 80, height: 80, color: Colors.red.shade200,
                  child: const Center(child: Text('A'))),
              const SizedBox(width: 8),
              Container(width: 80, height: 80, color: Colors.green.shade200,
                  child: const Center(child: Text('B'))),
              const SizedBox(width: 8),
              Container(width: 80, height: 80, color: Colors.blue.shade200,
                  child: const Center(child: Text('C'))),
            ],
          ),

          const SizedBox(height: 16),
          const Text('Column + Row + Container', style: TextStyle(fontSize: 16)),
        ],
      ),
```

**ขั้นตอนที่ 2** บันทึกและสังเกตผล

**✏️ ทดลองแก้ไข C:** เปลี่ยน `MainAxisAlignment.center` ของ Column เป็น `.start`, `.end`, `.spaceBetween`, `.spaceEvenly` ทีละอัน สังเกตการเปลี่ยนแปลง

**บันทึกรูปผลการทดลอง**

<img width="1163" height="726" alt="image" src="https://github.com/user-attachments/assets/a7ce50f3-f6ed-454d-ab33-019bf1c52873" />


**✏️ ทดลองแก้ไข D:** ใน Row เพิ่ม Container D สีม่วง ขนาด 80×80 ต่อจาก C
**บันทึกรูปผลการทดลอง**

<img width="1163" height="726" alt="image" src="https://github.com/user-attachments/assets/e852db9c-f627-4963-94a8-9a990a3625e9" />


---

### การทดลองที่ 3 — StatelessWidget แรก

**เป้าหมาย:** สร้าง Reusable Widget ที่รับ Parameter ได้

**ขั้นตอนที่ 1** เพิ่ม Class `InfoCard` **ด้านล่าง** Class `HomePage` (ยังอยู่ในไฟล์เดิม):

```dart
// StatelessWidget ที่รับ Parameter
class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color = Colors.indigo,  // มีค่า default
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // ไอคอนในวงกลมสี
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            // ข้อมูล
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

**ขั้นตอนที่ 2** แก้ `body` ของ `HomePage` เพื่อใช้ `InfoCard`:

```dart
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ข้อมูลสรุป',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // ใช้ InfoCard ซ้ำได้หลายครั้งด้วย Parameter ต่างกัน
            const InfoCard(
              title: 'จำนวนนักศึกษา',
              value: '42 คน',
              icon: Icons.people,
              color: Colors.indigo,
            ),

            const SizedBox(height: 8),

            const InfoCard(
              title: 'GPA เฉลี่ย',
              value: '3.21',
              icon: Icons.school,
              color: Colors.green,
            ),

            const SizedBox(height: 8),

            InfoCard(
              title: 'รายวิชาที่ลงทะเบียน',
              value: '5 วิชา',
              icon: Icons.book,
              color: Colors.orange,
            ),
          ],
        ),
      ),
```

**ขั้นตอนที่ 3** บันทึกและตรวจสอบผล — ควรเห็น Card 3 ใบเรียงกัน
**บันทึกรูปผลการทดลอง**

<img width="1163" height="726" alt="image" src="https://github.com/user-attachments/assets/4c2dfcbb-828a-4617-8a9e-361a84326442" />



**✏️ ทดลองแก้ไข E:** เพิ่ม `InfoCard` ที่ 4 แสดง "คณะ" ด้วยไอคอน `Icons.account_balance` สีแดง

**บันทึกรูปผลการทดลอง**

<img width="1163" height="726" alt="image" src="https://github.com/user-attachments/assets/98d01fbe-0519-413d-9817-fb5b120a5566" />

---

### การทดลองที่ 4 — StatefulWidget: Counter

**เป้าหมาย:** อธิบายการทำงานของ setState() จากตัวอย่างที่เรียบง่ายที่สุดได้

**ขั้นตอนที่ 1** เพิ่ม Class `CounterSection` ด้านล่างไฟล์:

```dart
class CounterSection extends StatefulWidget {
  const CounterSection({super.key});

  @override
  State<CounterSection> createState() => _CounterSectionState();
}

class _CounterSectionState extends State<CounterSection> {
  // === State ===
  int _count = 0;       // ตัวเลข Counter
  int _step = 1;        // ค่าที่เพิ่มแต่ละครั้ง

  // === Methods ===
  void _increment() {
    setState(() {
      _count += _step;
      // ลอง: แก้เป็น _count++ แล้วดูว่าต่างกันไหม
    });
  }

  void _decrement() {
    setState(() {
      if (_count - _step < 0) {
        _count = 0; // ไม่ให้ต่ำกว่า 0
      } else {
        _count -= _step;
      }
    });
  }

  void _reset() {
    setState(() {
      _count = 0;
    });
  }

  void _changeStep(int newStep) {
    setState(() {
      _step = newStep;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Counter Widget',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // แสดงตัวเลข
            Text(
              '$_count',
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: _count > 0
                    ? Colors.indigo
                    : _count < 0
                        ? Colors.red
                        : Colors.grey,
              ),
            ),

            const SizedBox(height: 16),

            // ปุ่มควบคุม
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  heroTag: 'dec',
                  onPressed: _decrement,
                  backgroundColor: Colors.red.shade100,
                  child: const Icon(Icons.remove, color: Colors.red),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: _reset,
                  child: const Text('Reset'),
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  heroTag: 'inc',
                  onPressed: _increment,
                  backgroundColor: Colors.green.shade100,
                  child: const Icon(Icons.add, color: Colors.green),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // เลือก Step
            const Text('ค่าที่เพิ่มแต่ละครั้ง:'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [1, 5, 10].map((s) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text('$s'),
                    selected: _step == s,
                    onSelected: (_) => _changeStep(s),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
```

**ขั้นตอนที่ 2** แก้ `body` ของ `HomePage` เดิม เพื่อแสดง `CounterSection` (ลบโค้ดส่วนของ body เดิมออกทั้งหมด แล้วแทนด้วยโค้ด 1 บรรทัดด้านล่าง:

```dart
      body: const CounterSection(),
```

**ขั้นตอนที่ 3** บันทึกและทดลองกดปุ่ม +, -, Reset และสลับ Step
**บันทึกรูปผลการทดลอง**
<img width="1163" height="726" alt="image" src="https://github.com/user-attachments/assets/951929a1-466d-4e55-9636-4a6d4b6b5e91" />



**✏️ ทดลองแก้ไข F:** ทดลองลบ `setState()` ออก เหลือแค่ `_count += _step` แล้วกดปุ่ม สังเกตว่าตัวเลขไม่เปลี่ยนบนหน้าจอแม้ตัวแปรเปลี่ยน แล้วใส่ `setState()` กลับคืน

> **สิ่งที่เกิดขึ้น:** เมื่อไม่มี `setState()` ค่า `_count` เปลี่ยนในหน่วยความจำจริง แต่ Flutter ไม่รู้ว่าต้อง rebuild UI ทำให้หน้าจอยังแสดงค่าเดิม

**บันทึกรูปผลการทดลอง**
<img width="1163" height="726" alt="image" src="https://github.com/user-attachments/assets/a7bc13c8-0186-4e54-92c9-c19bd8af604d" />
<img width="1163" height="726" alt="image" src="https://github.com/user-attachments/assets/65d6a45b-4589-4158-a13e-2d6128383582" />

---

### การทดลองที่ 5 — StatefulWidget: Form และ Text Input

**เป้าหมาย:** ใช้ TextEditingController รับข้อมูลจาก TextField ได้

**ขั้นตอนที่ 1** เพิ่ม Class `GreetingForm`:

```dart
class GreetingForm extends StatefulWidget {
  const GreetingForm({super.key});

  @override
  State<GreetingForm> createState() => _GreetingFormState();
}

class _GreetingFormState extends State<GreetingForm> {
  // TextEditingController จัดการ TextField
  final _nameController = TextEditingController();
  String _greeting = '';
  String _error = '';

  @override
  void dispose() {
    // ❗ ต้อง dispose Controller เสมอ เพื่อป้องกัน Memory Leak
    _nameController.dispose();
    super.dispose();
  }

  void _generateGreeting() {
    final name = _nameController.text.trim();

    setState(() {
      if (name.isEmpty) {
        _error = 'กรุณากรอกชื่อ';
        _greeting = '';
      } else {
        _error = '';
        final hour = DateTime.now().hour;
        String timeOfDay;
        if (hour < 12) {
          timeOfDay = 'ตอนเช้า';
        } else if (hour < 17) {
          timeOfDay = 'ตอนบ่าย';
        } else {
          timeOfDay = 'ตอนเย็น';
        }
        _greeting = 'สวัสดี$timeOfDay คุณ$name! 👋\nยินดีต้อนรับสู่ Flutter';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'สร้างคำทักทาย',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // TextField — ช่องรับข้อมูล
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'ชื่อของคุณ',
              hintText: 'เช่น สมชาย',
              prefixIcon: const Icon(Icons.person),
              border: const OutlineInputBorder(),
              // แสดง error ถ้ามี
              errorText: _error.isEmpty ? null : _error,
            ),
            // กด Enter บน Keyboard → สร้างคำทักทาย
            onSubmitted: (_) => _generateGreeting(),
          ),

          const SizedBox(height: 12),

          // ปุ่ม
          ElevatedButton.icon(
            onPressed: _generateGreeting,
            icon: const Icon(Icons.waving_hand),
            label: const Text('สร้างคำทักทาย'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),

          const SizedBox(height: 20),

          // แสดงผล
          if (_greeting.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.indigo.shade200),
              ),
              child: Text(
                _greeting,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
```

**ขั้นตอนที่ 2** แก้ `body` ของ `HomePage`:

```dart
      body: const SingleChildScrollView(
        child: GreetingForm(),
      ),
```

**ขั้นตอนที่ 3** บันทึกและทดสอบ — กรอกชื่อแล้วกดปุ่ม

**บันทึกรูปผลการทดลอง**
<img width="1163" height="726" alt="image" src="https://github.com/user-attachments/assets/17172afb-640a-407d-bba6-19580c3ba7fc" />


**✏️ ทดลองแก้ไข G:** ทดลองกดปุ่มโดยไม่กรอกชื่อ สังเกตว่า Error Message ปรากฏ และกดปุ่ม Reset (clear field) แล้วสังเกตว่า Error หายไป

---

### การทดลองที่ 6 — Lifecycle: initState และ dispose

**เป้าหมาย:** อธิบายการทำงานของ initState, setState และ dispose พร้อมกัน

**ขั้นตอนที่ 1** เพิ่ม Class `ClockWidget`:

```dart
import 'dart:async';  // เพิ่มบรรทัดนี้ที่ด้านบนของไฟล์ (ต่อจาก import แรก)

class ClockWidget extends StatefulWidget {
  const ClockWidget({super.key});

  @override
  State<ClockWidget> createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget> {
  late DateTime _currentTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState(); // ❗ ต้องเรียกก่อนเสมอ
    _currentTime = DateTime.now();

    // ตั้ง Timer อัปเดตเวลาทุก 1 วินาที
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {  // ❗ ตรวจสอบก่อน setState เสมอ
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // ❗ ต้องยกเลิก Timer เพื่อป้องกัน Memory Leak
    super.dispose();  // ❗ ต้องเรียกหลังสุดเสมอ
  }

  String _formatTime(DateTime dt) {
    String h = dt.hour.toString().padLeft(2, '0');
    String m = dt.minute.toString().padLeft(2, '0');
    String s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String _formatDate(DateTime dt) {
    const months = [
      '', 'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
      'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year + 543}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.access_time, size: 40, color: Colors.indigo),
            const SizedBox(height: 8),
            Text(
              _formatTime(_currentTime),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            Text(
              _formatDate(_currentTime),
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
```

> **หมายเหตุ:** ถ้า `FontFeature` มี Error ให้ลบ `fontFeatures: [FontFeature.tabularFigures()]` ออกได้

**ขั้นตอนที่ 2** เพิ่ม import ที่บนไฟล์:

```dart
import 'dart:async';
```

**ขั้นตอนที่ 3** แก้ `body` ของ `HomePage`:

```dart
      body: const SingleChildScrollView(
        child: Column(
          children: [
            ClockWidget(),
            CounterSection(),
          ],
        ),
      ),
```

**ขั้นตอนที่ 4** บันทึกและดูผล — เวลาควรอัปเดตทุกวินาที
**บันทึกรูปผลการทดลอง**
<img width="1163" height="726" alt="image" src="https://github.com/user-attachments/assets/f306b2d1-ff41-4045-bd68-637b4d465bab" />


**✏️ ทดลองแก้ไข H:** ลองลบ `_timer?.cancel()` ใน `dispose()` แล้วสังเกต — ใน Debug Console อาจเห็น Warning "setState() called after dispose()" หลังจากออกจากหน้า แล้วใส่กลับคืน

---

### การทดลองที่ 7 — รวมทุกส่วนเป็นแอปสมบูรณ์

**เป้าหมาย:** รวม Widget ทั้งหมดเข้าด้วยกันเป็นแอปที่มีหลายหน้า

**ขั้นตอนที่ 1** แทนที่ไฟล์ `lib/main.dart` ทั้งหมดด้วยโค้ดต่อไปนี้:

```dart
import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Week 02 Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

// ─── Main Screen with Bottom Navigation ─────────────────
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    CounterPage(),
    FormPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.calculate),
            label: 'Counter',
          ),
          NavigationDestination(
            icon: Icon(Icons.edit),
            label: 'Form',
          ),
        ],
      ),
    );
  }
}

// ─── Page 1: Dashboard ──────────────────────────────────
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClockWidget(),
            SizedBox(height: 16),
            Text('ข้อมูลสรุป',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            InfoCard(
              title: 'นักศึกษา', value: '42 คน',
              icon: Icons.people, color: Colors.indigo,
            ),
            SizedBox(height: 8),
            InfoCard(
              title: 'GPA เฉลี่ย', value: '3.21',
              icon: Icons.school, color: Colors.green,
            ),
            SizedBox(height: 8),
            InfoCard(
              title: 'รายวิชา', value: '5 วิชา',
              icon: Icons.book, color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Page 2: Counter ────────────────────────────────────
class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const CounterSection(),
    );
  }
}

// ─── Page 3: Form ───────────────────────────────────────
class FormPage extends StatelessWidget {
  const FormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สร้างคำทักทาย'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const GreetingForm(),
    );
  }
}

// ─── Reusable Widgets ────────────────────────────────────

class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color = Colors.indigo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                Text(value,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── ClockWidget (StatefulWidget) ───────────────────────

class ClockWidget extends StatefulWidget {
  const ClockWidget({super.key});

  @override
  State<ClockWidget> createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget> {
  late DateTime _currentTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _currentTime = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.access_time, size: 32, color: Colors.indigo),
              Text(
                '${_pad(_currentTime.hour)}:${_pad(_currentTime.minute)}:${_pad(_currentTime.second)}',
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
              Text('${_currentTime.day}/${_currentTime.month}/${_currentTime.year + 543}',
                  style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── CounterSection (StatefulWidget) ────────────────────

class CounterSection extends StatefulWidget {
  const CounterSection({super.key});

  @override
  State<CounterSection> createState() => _CounterSectionState();
}

class _CounterSectionState extends State<CounterSection> {
  int _count = 0;
  int _step = 1;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$_count',
            style: TextStyle(
              fontSize: 80,
              fontWeight: FontWeight.bold,
              color: _count >= 0 ? Colors.indigo : Colors.red,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton(
                heroTag: 'dec',
                onPressed: () => setState(() => _count -= _step),
                backgroundColor: Colors.red.shade50,
                child: const Icon(Icons.remove, color: Colors.red),
              ),
              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: () => setState(() => _count = 0),
                child: const Text('Reset'),
              ),
              const SizedBox(width: 16),
              FloatingActionButton(
                heroTag: 'inc',
                onPressed: () => setState(() => _count += _step),
                backgroundColor: Colors.green.shade50,
                child: const Icon(Icons.add, color: Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Step:'),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [1, 5, 10, 100].map((s) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Text('$s'),
                selected: _step == s,
                onSelected: (_) => setState(() => _step = s),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

// ─── GreetingForm (StatefulWidget) ──────────────────────

class GreetingForm extends StatefulWidget {
  const GreetingForm({super.key});

  @override
  State<GreetingForm> createState() => _GreetingFormState();
}

class _GreetingFormState extends State<GreetingForm> {
  final _nameController = TextEditingController();
  String _greeting = '';
  String _error = '';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    setState(() {
      if (name.isEmpty) {
        _error = 'กรุณากรอกชื่อ';
        _greeting = '';
      } else {
        _error = '';
        final h = DateTime.now().hour;
        final period = h < 12 ? 'ตอนเช้า' : h < 17 ? 'ตอนบ่าย' : 'ตอนเย็น';
        _greeting = 'สวัสดี$period คุณ$name! 👋\nยินดีต้อนรับสู่ Flutter';
      }
    });
  }

  void _clear() {
    _nameController.clear();
    setState(() {
      _greeting = '';
      _error = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'ชื่อของคุณ',
              hintText: 'เช่น สมชาย',
              prefixIcon: const Icon(Icons.person),
              border: const OutlineInputBorder(),
              errorText: _error.isEmpty ? null : _error,
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.waving_hand),
                  label: const Text('สร้างคำทักทาย'),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: _clear,
                child: const Text('ล้าง'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_greeting.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.indigo.shade200),
              ),
              child: Text(
                _greeting,
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
```

**ขั้นตอนที่ 2** Hot Restart แอป (กด `R` ใน Terminal หรือ 🔄 ใน Toolbar)

**ขั้นตอนที่ 3** ทดสอบทุก Tab และทุก Feature

**บันทึกรูปผลการทดลอง**
<img width="1163" height="726" alt="image" src="https://github.com/user-attachments/assets/5dd1783c-04c8-448c-802b-5b3a0d3d2f86" />
<img width="1163" height="726" alt="image" src="https://github.com/user-attachments/assets/699c9643-b84a-47da-b783-1e19137780f0" />
<img width="1163" height="726" alt="image" src="https://github.com/user-attachments/assets/d020e7ac-eaf8-4c07-927e-2368ad4fcaa8" />

---

### การทดลองที่ 8 — Hot Reload vs Hot Restart

**⏱ เวลา:** 10 นาที

**ขั้นตอนที่ 1** กดปุ่ม `+` ใน Counter Tab หลายครั้งจนถึง 15

**ขั้นตอนที่ 2** ไปที่ไฟล์ `main.dart` แก้สีใน `MyApp`:

```dart
// เปลี่ยน
colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
// เป็น
colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
```

**ขั้นตอนที่ 3** บันทึก → **Hot Reload** อัตโนมัติ

**ขั้นตอนที่ 4** บันทึกผลในตาราง:

| | หลัง Hot Reload |
|--|--|
| สี Theme | Teal |
| ค่า Counter | 15 |

**ขั้นตอนที่ 5** กด **Hot Restart** (พิมพ์ `R` ใน Terminal หรือกด 🔄)

| | หลัง Hot Restart |
|--|--|
| สี Theme | Teal |
| ค่า Counter | 0 |

**ขั้นตอนที่ 6** อธิบายผลลัพธ์:

> Hot Reload: สี ____Teal______ Counter _____15_____ เพราะ ____Hot Reload ทำงานโดย Inject โค้ดที่แก้ไขเข้าไปใน Render Tree แล้วสั่ง Rebuild UI โดยที่ยังคงรักษา State เดิมของแอปพลิเคชันเอาไว้ในหน่วยความจำ______
> Hot Restart: สี ____Teal______ Counter ____0______ เพราะ ____Hot Restart ทำงานโดยการรีสตาร์ทกระบวนการทั้งหมดของแอปพลิเคชันใหม่ สั่งรัน main() ใหม่ และล้าง State ทั้งหมดในหน่วยความจำให้กลับไปเป็นค่าเริ่มต้น (Initial State)______

---

### 🎯 โจทย์ฝึกทำ — ขยาย App ด้วยตนเอง

เลือกทำอย่างน้อย **2 ข้อ** จากโจทย์ด้านล่าง:

**โจทย์ A (ง่าย):** เพิ่ม Tab ที่ 4 ชื่อ "About" แสดงชื่อ รหัสนักศึกษา และคณะของตัวเอง พร้อมรูป Avatar (ใช้ `CircleAvatar` กับ Text แรกของชื่อ)
<img width="1163" height="726" alt="image" src="https://github.com/user-attachments/assets/2bdd5578-bb5d-4208-9de4-559b2398d352" />


**โจทย์ B (กลาง):** ใน Counter Page เพิ่ม History ที่บันทึกทุกการกระทำ (เพิ่ม/ลด/Reset) พร้อมเวลา เช่น "14:30:25 — เพิ่ม 5 (รวม: 15)" แสดงเป็น List ด้านล่าง Counter และมีปุ่ม "ล้าง History"
<img width="1163" height="726" alt="image" src="https://github.com/user-attachments/assets/3558eb95-b776-411c-8b02-a420c73b77c2" />

**โจทย์ C (กลาง):** ใน Form Page เพิ่ม Dropdown เลือก "ภาษาของคำทักทาย" (ไทย / อังกฤษ / ญี่ปุ่น) และเปลี่ยนข้อความคำทักทายตามภาษาที่เลือก

**โจทย์ D (ยาก):** สร้าง Tab ใหม่ "Todo List" ที่มี TextField รับชื่องาน, ปุ่ม Add, รายการ Todo ที่กดติ๊กถูก/ลบได้ และแสดงจำนวนงานที่เหลือ

---


### คำถามท้ายใบงาน

**ข้อ 1** ทำไม Flutter ถึงเลือกวาด UI ด้วย Engine ของตัวเองแทนการใช้ Native Component? มีข้อดีและข้อเสียอย่างไร?
เหตุผล: เพื่อให้ UI แสดงผลเหมือนกันทุกแพลตฟอร์มโดยไม่พึ่งพาคอนโทรลเลอร์ของ OS  
ข้อดี: UI เหมือนกัน 100% ทุกระบบ, ประสิทธิภาพสูง, วาด UI ได้ละเอียด  
ข้อเสีย: ขนาดไฟล์แอปใหญ่ขึ้น และ Native UI บางอย่างอาจดูไม่กลมกลืนถ้าไม่ปรับแต่ง

**ข้อ 2** อธิบายความสัมพันธ์ของ Widget Tree, Element Tree และ RenderObject Tree และเหตุผลที่ต้องมีทั้ง 3 ส่วน
Widget Tree เป็นพิมพ์เขียว, Element Tree เป็นตัวเก็บตำแหน่งและ State, RenderObject Tree เป็นตัววาดหน้าจอจริง มี 3 ส่วนเพื่อช่วยอัปเดตเฉพาะจุดที่เปลี่ยน ทำให้แอปทำงานได้เร็วขึ้น

**ข้อ 3** อธิบายโครงสร้าง Widget Tree และความสัมพันธ์ระหว่าง Parent-Child Widget 
Parent ส่งข้อจำกัดขนาดลงไปให้ Child, Child เลือกขนาดของตัวเองแล้วส่งคืน, จากนั้น Parent จึงจัดวางตำแหน่งให้ Child บนหน้าจอ

**ข้อ 4** จากการทดลองที่ 4 ข้อ F (ลบ setState ออก) ผลที่เกิดขึ้นคืออะไร และอธิบายเหตุผลเชิงเทคนิคว่าทำไมจึงเกิดผลนั้น
ค่าตัวแปรเปลี่ยนแต่ UI ไม่เปลี่ยน เพราะไม่มี setState() คอยส่งสัญญาณบอกให้สั่งเรียก build() เพื่อวาดหน้าจอใหม่


**ข้อ 5** เมื่อออกแบบ Flutter App ที่มี Widget หลายตัว จะตัดสินใจอย่างไรว่า Widget ไหนควรเป็น Stateless และ Widget ไหนควรเป็น Stateful? ยกตัวอย่างจากใบงานนี้
ใช้ Stateless เมื่อ UI นิ่งคงที่ เช่น InfoCard และใช้ Stateful เมื่อ UI เปลี่ยนตามข้อมูลหรือการโต้ตอบได้ เช่น CounterSection

**ข้อ 6** เหตุใดจึงต้องเรียก `dispose()` และยกเลิก Timer ใน `ClockWidget`? หากไม่ทำจะเกิดอะไรขึ้นในระยะยาว?
เพื่อป้องกัน Memory Leak จากการที่ Timer ยังคงทำงานใน Background แม้จะปิดหน้านั้นไปแล้ว

---

## ข้อผิดพลาดที่พบบ่อยใน Flutter

| อาการ | สาเหตุที่เป็นไปได้ | วิธีแก้ |
|---|---|---|
| UI ไม่อัปเดตเมื่อค่าเปลี่ยน | ลืม `setState()` | ห่อโค้ดด้วย `setState(() { ... })` |
| `setState() after dispose()` | ไม่ check `mounted` | เพิ่ม `if (mounted)` ก่อน `setState` |
| Widget ล้นหน้าจอ | Column ไม่มี Scroll | ห่อด้วย `SingleChildScrollView` |
| `TextEditingController` Warning | ลืม dispose | เพิ่ม `controller.dispose()` ใน `dispose()` |
| Hot Reload ไม่เห็นผล | แก้ `initState()` หรือ `main()` | ใช้ Hot Restart แทน |
| `No connected devices` | ไม่ได้เปิด Emulator | เปิด Emulator ก่อนรัน `flutter run` |
| `pub get` failed | Package ใน pubspec.yaml ผิด | ตรวจ indent และชื่อ Package |

---

## ภาคผนวก A — ติดตั้ง Flutter SDK (ถ้ายังไม่ได้ติดตั้ง)

### Windows

```bash
# 1. ดาวน์โหลด Flutter SDK จาก https://flutter.dev/docs/get-started/install/windows
# 2. แตกไฟล์ไปที่ C:\flutter (ห้ามวางใน C:\Program Files)
# 3. เพิ่ม C:\flutter\bin ใน PATH Environment Variable
# 4. ติดตั้ง Android SDK Command-line Tools
#    Android Studio → SDK Manager → SDK Tools → Android SDK Command-line Tools ✓
# 5. ยอมรับ License
flutter doctor --android-licenses
# 6. ตรวจสอบ
flutter doctor
```

### macOS

```bash
# 1. ติดตั้ง Homebrew (ถ้ายังไม่มี)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. ติดตั้ง Flutter
brew install --cask flutter

# 3. ยอมรับ License
flutter doctor --android-licenses

# 4. ตรวจสอบ
flutter doctor
```

---

## ภาคผนวก B — สร้าง Android Emulator ด้วย Command Line (ไม่ใช้ Android Studio)

```bash
# 1. ตรวจสอบ System Images ที่ดาวน์โหลดไว้
sdkmanager --list | grep system-images

# 2. ดาวน์โหลด System Image (ถ้ายังไม่มี)
sdkmanager "system-images;android-34;google_apis;x86_64"

# 3. สร้าง Emulator ใหม่
avdmanager create avd \
  --name "Pixel6_API34" \
  --package "system-images;android-34;google_apis;x86_64" \
  --device "pixel_6"

# 4. เปิด Emulator
emulator -avd Pixel6_API34 &

# 5. ตรวจสอบ
flutter devices
```

> **ทาง Windows:** เปิด Command Prompt แบบ Administrator แล้วรันคำสั่งเดิม (ไม่มี `&` ท้าย)

---

*ใบงานการทดลองที่ 2-2 | Flutter Framework Basics*
*วิชา: การพัฒนาซอฟต์แวร์สำหรับอุปกรณ์เคลื่อนที่*
