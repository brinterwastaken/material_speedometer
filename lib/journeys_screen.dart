import 'package:flutter/material.dart';

class PastJourneyScreen extends StatefulWidget {
  const PastJourneyScreen({super.key});

  @override
  State<PastJourneyScreen> createState() => _PastJourneyScreenState();
}

class _PastJourneyScreenState extends State<PastJourneyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Past Journeys"),
      ),
    );
  }
}
