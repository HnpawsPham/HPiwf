import 'package:flutter/material.dart';

class GeofencingTab extends StatefulWidget {
  const GeofencingTab({super.key});

  @override
  State<GeofencingTab> createState() => _GeofencingTabState();
}

class _GeofencingTabState extends State<GeofencingTab> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Center(
        child: Text("COMING SOON", style: TextStyle(fontFamily: "cubano", fontSize: 30)),
      ),
    );
  }
}
