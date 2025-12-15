import 'package:flutter/material.dart';
import 'bottom_nav.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ===================== DATA =====================
  final List<Driver> drivers = [
    Driver('Danish', true, 'Muhammad Danish K.', 4, 'WWB 882', 'Black Myvi', 'September 2025 - September 2026'),
    Driver('Bohan', true, 'Bohan Meduri', 3, 'VAJ 2312', 'Red Axia', 'January 2025 - January 2026'),
    Driver('Kurt', false, 'Kurt Ernest', 5, 'PNY 9031', 'Blue Persona', 'November 2025 - November 2026'),
    Driver('Samantha', false, 'Samantha G.', 3, 'AGT 2769', 'Black Honda Civic', 'December 2025 - December 2026'),
    Driver('Wayne', false, 'Wayne Rhine', 5, 'BMG 3371', 'White Myvi', 'January 2025 - January 2026'),
    Driver('Sarah', false, 'Sarah W.', 3, 'KHN 4021', 'Red Yaris', 'November 2025 - November 2026'),
    Driver('Rue', false, 'Rue Pyra', 4, 'PSR 8910', 'Blue Viva', 'October 2025 - October 2026'),
  ];

  final List<RideRequest> requests = [
    RideRequest('MF', 'Farhan', 1, 'Terminal Sungai Nibong', 'M01, Desasiswa Restu', 'Apr 1, 2025', '9:30 AM'),
    RideRequest('AN', 'Amira', 2, 'K05, Desasiswa Aman Damai', 'Lotus Sungai Dua', 'Apr 1, 2025', '10:00 AM'),
    RideRequest('DY', 'Derick', 4, 'Dewan Kuliah STUV', 'SOLLAT, USM', 'Apr 1, 2025', '12:15 PM'),
    RideRequest('PH', 'Puteri', 3, 'Desasiswa CGH', 'Penang Airport', 'Apr 1, 2025', '12:45 PM'),
    RideRequest('MA', 'Akmal', 4, 'Desasiswa Indah Kembara', 'KOPA Arena', 'Apr 2, 2025', '8:30 AM'),
    RideRequest('CH', 'Chung', 4, 'M03, Desasiswa Saujana', 'Dewan Kuliah SK1', 'Apr 2, 2025', '11:45 AM'),
    RideRequest('WB', 'Winanda', 3, 'Dewan Kuliah G31', 'Queensbay Mall', 'Apr 2, 2025', '5:00 PM'),
  ];

  // ===================== UI =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('Welcome, Adam.', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: const [Padding(padding: EdgeInsets.only(right: 16), child: Icon(Icons.menu, color: Colors.black))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ===== OUR DRIVERS =====
          const Text('Our Drivers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: drivers.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final d = drivers[index];
                return GestureDetector(
                  onTap: () => _showDriverDialog(d),
                  child: Column(children: [
                    Stack(children: [
                      const CircleAvatar(radius: 28, backgroundColor: Colors.grey),
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: CircleAvatar(radius: 6, backgroundColor: d.isOnline ? Colors.green : Colors.grey),
                      ),
                    ]),
                    const SizedBox(height: 6),
                    Text(d.shortName, style: const TextStyle(fontSize: 12))
                  ]),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // ===== ONGOING REQUESTS =====
          const Text('Ongoing Requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          ...requests.map(_requestCard).toList(),
        ]),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  // ===================== REQUEST CARD =====================
  Widget _requestCard(RideRequest r) {
    final bool isFull = r.joined >= 4;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        CircleAvatar(radius: 24, backgroundColor: Colors.white, child: Text(r.initials, style: const TextStyle(fontWeight: FontWeight.bold))),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(r.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Pick-up: ${r.pickup}', style: const TextStyle(fontSize: 12)),
            Text('Destination: ${r.destination}', style: const TextStyle(fontSize: 12)),
          ]),
        ),
        Column(children: [
          Text('${r.joined}/4', style: const TextStyle(fontSize: 12)),
          Text(r.date, style: const TextStyle(fontSize: 11)),
          Text(r.time, style: const TextStyle(fontSize: 11)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: isFull ? null : () => _confirmJoin(r),
            style: ElevatedButton.styleFrom(backgroundColor: isFull ? Colors.grey : Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text(isFull ? 'Full' : 'Join'),
          )
        ])
      ]),
    );
  }

  // ===================== POPUPS =====================
  void _showDriverDialog(Driver d) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const CircleAvatar(radius: 36),
          const SizedBox(height: 12),
          Text(d.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) => Icon(Icons.star, color: i < d.rating ? Colors.amber : Colors.grey))),
          const SizedBox(height: 6),
          Text('${d.plate} · ${d.car}'),
          const SizedBox(height: 12),
          Text('License Validity', style: TextStyle(color: Colors.grey.shade600)),
          Text(d.license),
        ]),
      ),
    );
  }

  void _confirmJoin(RideRequest r) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Join This Ride?'),
        content: Text('${r.pickup}\n→ ${r.destination}\n${r.date} | ${r.time}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => r.joined++);
              _showSuccess();
            },
            child: const Text('Confirm'),
          )
        ],
      ),
    );
  }

  void _showSuccess() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(mainAxisSize: MainAxisSize.min, children: const [
          Text('✅', style: TextStyle(fontSize: 40)),
          SizedBox(height: 12),
          Text("You've successfully joined the trip!", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 6),
          Text('The creator has been notified.\nYou can view this ride in Orders.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
        ]),
      ),
    );
  }
}

// ===================== MODELS =====================
class Driver {
  final String shortName;
  final bool isOnline;
  final String fullName;
  final int rating;
  final String plate;
  final String car;
  final String license;

  Driver(this.shortName, this.isOnline, this.fullName, this.rating, this.plate, this.car, this.license);
}

class RideRequest {
  final String initials;
  final String name;
  int joined;
  final String pickup;
  final String destination;
  final String date;
  final String time;

  RideRequest(this.initials, this.name, this.joined, this.pickup, this.destination, this.date, this.time);
}
