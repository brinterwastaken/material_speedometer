import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PastJourneyScreen extends StatefulWidget {
  const PastJourneyScreen({super.key, required this.unit});
  final String unit;

  @override
  State<PastJourneyScreen> createState() => _PastJourneyScreenState();
}

class _PastJourneyScreenState extends State<PastJourneyScreen> {
  late List<String> _journeyList;
  bool _loaded = false;

  void _getPastJourneys() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _journeyList = prefs.getStringList('journeys')!;
      _loaded = true;
    });
  }

  void _deleteItem(int index) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _journeyList.removeAt(index);
    });
    prefs.setStringList('journeys', _journeyList);
  }

  @override
  void dispose() {
    bool _loaded = false;
    super.dispose();
  }

  @override
  void initState() {
    _getPastJourneys();
    super.initState();
  }

  void _showDeleteDialog(String journeyName, int index) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Delete $journeyName?'),
        content: Text(
            'Are you sure you want to delete this journey? This action is irreversible.',
        style: Theme.of(context).textTheme.bodyLarge,),
        actions: <Widget>[
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deleteItem(index);
              Navigator.pop(context, 'OK');
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Past Journeys"),
      ),
      body: _loaded
          ? ListView.builder(
              itemCount: _journeyList.length,
              itemBuilder: (context, i) {
                double topSpeed = jsonDecode(_journeyList[i])['topSpeed'];
                double avgSpeed = jsonDecode(_journeyList[i])['avgSpeed'];

                List<String> getTopAndAvg() {
                  if (widget.unit == "m/s") {
                    return [
                      (topSpeed.round()).toString(),
                      (avgSpeed.round()).toString()
                    ];
                  } else if (widget.unit == "km/h") {
                    return [
                      ((topSpeed * 3.6).round()).toString(),
                      ((avgSpeed * 3.6).round()).toString()
                    ];
                  } else if (widget.unit == "mph") {
                    return [
                      ((topSpeed * 2.2369363).round()).toString(),
                      ((avgSpeed * 2.2369363).round()).toString()
                    ];
                  } else {
                    return ["0", "0"];
                  }
                }

                return Padding(
                  padding: const EdgeInsets.only(left: 8, top: 8, right: 8),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Flex(
                            direction: Axis.horizontal,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Journey ${i + 1}',
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              const Spacer(),
                              SizedBox(
                                width: 36.0,
                                height: 36.0,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  color: Theme.of(context).colorScheme.error,
                                  onPressed: () =>
                                      _showDeleteDialog('Journey ${i + 1}', i),
                                  icon: Icon(
                                    Icons.delete_forever,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 8),
                          Flex(
                            direction: Axis.horizontal,
                            children: [
                              Text(
                                'Top Speed: ${getTopAndAvg()[0]} ${widget.unit}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const Spacer(),
                              Text(
                                'Average Speed: ${getTopAndAvg()[1]} ${widget.unit}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
