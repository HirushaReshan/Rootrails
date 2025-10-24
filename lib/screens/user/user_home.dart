import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
]),
);
},
);
},
),
),
const SizedBox(height: 40),
],
),
),
bottomNavigationBar: BottomNavigationBar(items: const [
BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
BottomNavigationBarItem(icon: Icon(Icons.list), label: 'My List'),
BottomNavigationBarItem(icon: Icon(Icons.navigation), label: 'Navigation'),
BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
]),
);
}


bool _isOpen(String from, String to) {
try {
final now = TimeOfDay.now();
final f = _parse(from);
final t = _parse(to);
final nMinutes = now.hour * 60 + now.minute;
final fMinutes = f.hour * 60 + f.minute;
final tMinutes = t.hour * 60 + t.minute;
if (fMinutes <= tMinutes) return nMinutes >= fMinutes && nMinutes <= tMinutes;
// overnight
return nMinutes >= fMinutes || nMinutes <= tMinutes;
} catch (e) {
return false;
}
}


TimeOfDay _parse(String s) {
final parts = s.split(':');
return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
}
}