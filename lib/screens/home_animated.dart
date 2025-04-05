import 'dart:math';

import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final int _rowCount = 4;
  final int _textsPerRow = 3;
  final double _rowSpacing = 60;
  final double _speed = 0.4;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 8))
          ..addListener(() {
            setState(() {});
          })
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

   Widget _buildFlowingText(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    List<Widget> positionedRows = [];

    for (int rowIndex = 0; rowIndex < _rowCount; rowIndex++) {
        double baseX = -200; 
        double baseY = screenHeight * 0.2 + rowIndex * _rowSpacing;
        double offset = _controller.value * _speed * (screenWidth + screenHeight);
        double x = (baseX + offset) % (screenWidth + 300);
      double y = (baseY - offset) % (screenHeight * 0.5 + 300);

        final rowWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_textsPerRow, (_) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              "NeoVault",
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(10, 59, 99, 1),
              ),
            ),
          );
        }),
      );
      final rotatedRow = Transform.rotate(
        angle: -25 * pi / 180, 
        child: rowWidget,
      );
      positionedRows.add(Positioned(
        left: x,
        top: y,
        child: rotatedRow,
      ));
      }
      return Stack(children: positionedRows);
    }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(child: _buildFlowingText(context)),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(flex: 3),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: Text("Login"),
                ),
                SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  child: Text("Register"),
                ),
                SizedBox(height: 20),
                const Text("Keep it safe, Access it anywhere"),
                Spacer(flex: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
