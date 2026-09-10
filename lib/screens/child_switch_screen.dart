
import 'package:flutter/material.dart';

class ChildSwitchScreen extends StatelessWidget {
const ChildSwitchScreen({super.key});

static const Color primaryColor = Color(0xFF0B5D6B);
static const Color backgroundColor = Color(0xFFF5F7FA);

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: backgroundColor,
appBar: AppBar(
backgroundColor: primaryColor,
foregroundColor: Colors.white,
title: const Text(
'Switch Child',
style: TextStyle(fontWeight: FontWeight.bold),
),
),
body: Padding(
padding: const EdgeInsets.all(16),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text(
'Select Child',
style: TextStyle(
fontSize: 22,
fontWeight: FontWeight.bold,
color: Color(0xFF172033),
),
),

const SizedBox(height: 8),

const Text(
'Choose a child to view their school information.',
style: TextStyle(
fontSize: 14,
color: Colors.grey,
),
),

const SizedBox(height: 20),

_childCard(
context,
name: 'Ali Ahmed',
className: 'Class 8 - A',
icon: Icons.person,
),

const SizedBox(height: 12),

_childCard(
context,
name: 'Sara Ahmed',
className: 'Class 6 - B',
icon: Icons.person,
),
],
),
),
);
}

Widget _childCard(
BuildContext context, {
required String name,
required String className,
required IconData icon,
}) {
return Card(
elevation: 2,
margin: EdgeInsets.zero,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(16),
),
child: ListTile(
contentPadding: const EdgeInsets.symmetric(
horizontal: 16,
vertical: 8,
),
leading: CircleAvatar(
radius: 28,
backgroundColor: primaryColor.withOpacity(0.12),
child: const Icon(
Icons.person,
color: primaryColor,
size: 28,
),
),
title: Text(
name,
style: const TextStyle(
fontWeight: FontWeight.bold,
fontSize: 16,
),
),
subtitle: Text(className),
trailing: const Icon(
Icons.arrow_forward_ios,
size: 18,
color: primaryColor,
),
onTap: () {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text('$name selected'),
backgroundColor: primaryColor,
),
);
},
),
);
}
}