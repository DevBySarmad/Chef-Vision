import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ScanLoader extends StatelessWidget {
  const ScanLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          SpinKitThreeBounce(color: Color(0xFF284C3B), size: 26),
          SizedBox(height: 14),
          Text('Reading your ingredients and planning dishes...'),
        ],
      ),
    );
  }
}
