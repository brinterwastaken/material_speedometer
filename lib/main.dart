import 'dart:async';

import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:location/location.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:material_speedometer/widgets/speed_dial.dart';
import 'package:material_speedometer/location_perm_dialog.dart';
import 'package:material_speedometer/settings_modal.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();

  // ignore: library_private_types_in_public_api
  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  // Application root
  Color primaryColor = const Color(0xff70baff);
  ThemeMode _themeMode = ThemeMode.dark;

  void _setTheme(ThemeMode newTheme) {
    setState(() {
      _themeMode = newTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme _defaultLightColorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
    );
    final ColorScheme _defaultDarkColorScheme = ColorScheme.fromSeed(
        seedColor: primaryColor, brightness: Brightness.dark);

    return DynamicColorBuilder(builder: (lightDynamic, darkDynamic) {
      return MaterialApp(
        title: 'VelocityView',
        theme: ThemeData(
          colorScheme: lightDynamic ?? _defaultLightColorScheme,
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: darkDynamic ?? _defaultDarkColorScheme,
          useMaterial3: true,
        ),
        themeMode: _themeMode,
        home: MyHomePage(
          title: 'VelocityView',
          themeMode: _themeMode,
          setTheme: _setTheme,
        ),
        debugShowCheckedModeBanner: false,
      );
    });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage(
      {super.key,
      required this.title,
      required this.themeMode,
      required this.setTheme});

  final String title;
  final ThemeMode themeMode;
  final Function(ThemeMode themeMode) setTheme;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  Location location = Location();
  late StreamSubscription _locationSubscription;
  late Timer _avgSpeedTimer;

  @override
  void initState() {
    super.initState();
    _getPrefs();
    _animationController = AnimationController(
      vsync: this, // the SingleTickerProviderStateMixin
    );
  }

  @override
  void dispose() {
    _stopListening();
    _animationController.dispose();
    super.dispose();
  }

  void _getPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    int? storedThemeInt = prefs.getInt('themeMode');
    String? storedUnit = prefs.getString('unit');
    int? storedMaxSpeed = prefs.getInt('maxSpeed');
    widget.setTheme(_themeModes[storedThemeInt!]);

    setState(() {
      _unit = storedUnit!;
      _maxspeed = storedMaxSpeed!;
      _appVersion = "${packageInfo.version}+${packageInfo.buildNumber}";
    });
  }

  void _startListening() async {
    if (await location.hasPermission() != PermissionStatus.granted) {
      PermissionStatus result = await location.requestPermission();
      if (result != PermissionStatus.granted) {
        LocationPermDialog.locationPermDialog(context);
        return;
      }
    }
    if (await location.serviceEnabled() == false) {
      bool result = await location.requestService();
      if (result == false) return;
    }
    setState(() {
      _isListening = true;
    });
    location.changeSettings(
      accuracy: LocationAccuracy.high,
      interval: 1000,
      distanceFilter: 1,
    );
    _locationSubscription = location.onLocationChanged.listen(
      (LocationData currentLocation) {
        _pollingStarted = true;
        double speedmps = currentLocation.speed ?? 0;
        if (_unit == "m/s") {
          _updateSpeed(speedmps.round());
        } else if (_unit == "km/h") {
          _updateSpeed((speedmps * 3.6).round());
        } else if (_unit == "mph") {
          _updateSpeed((speedmps * 2.2369363).round());
        }
      },
    );
    _avgSpeedTimer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        if (_pollingStarted) {
          _avgcount++;
          _speedsSum += _newspeed;
          _avgspeed = (_speedsSum / _avgcount).round();
        }
      });
    });
  }

  void _stopListening() {
    _locationSubscription.cancel();
    _avgSpeedTimer.cancel();
    _updateSpeed(0);
    setState(() {
      _isListening = false;
      _topspeed = 0;
      _avgspeed = 0;
      _pollingStarted = false;
    });
  }

  int _maxspeed = 100;
  int _newspeed = 0;
  int _oldspeed = 0;
  int _topspeed = 0;
  int _avgspeed = 0;
  int _avgcount = 0;
  int _speedsSum = 0;
  bool _pollingStarted = false;
  String _unit = "km/h";
  bool _isListening = false;

  String _appVersion = "";

  final List<ThemeMode> _themeModes = [
    ThemeMode.light,
    ThemeMode.dark,
    ThemeMode.system
  ];

  void _updateSpeed(int speed) {
    setState(() {
      _oldspeed = _newspeed;
      _newspeed = speed;
      _topspeed = _newspeed > _topspeed ? _newspeed : _topspeed;
    });
    _animationController.animateTo(_newspeed / _maxspeed,
        duration: const Duration(milliseconds: 1000), curve: Curves.ease);
  }

  void _setUnit(String unit) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _unit = unit;
      _topspeed = 0;
    });
    prefs.setString('unit', unit);
  }

  void _setMaxSpeed(int speed) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _maxspeed = speed;
    });
    _animationController.animateTo(_newspeed / _maxspeed,
        duration: const Duration(milliseconds: 1000), curve: Curves.ease);
    prefs.setInt('maxSpeed', speed);
  }

  void _setThemeSave(ThemeMode themeMode) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    widget.setTheme(themeMode);
    prefs.setInt('themeMode', _themeModes.indexOf(themeMode));
  }

  //TODO: remove these in final prod
  /*void _incrementCounter() {
    setState(() {
      _oldspeed = _newspeed;
      _newspeed = _newspeed >= _maxspeed ? _maxspeed : _newspeed + 10;
    });
    _animationController.animateTo(_newspeed / _maxspeed,
        duration: Duration(milliseconds: 1000), curve: Curves.ease);
  }

  void _decrementCounter() {
    setState(() {
      _oldspeed = _newspeed;
      _newspeed = _newspeed - 20 <= 0 ? 0 : _newspeed - 20;
    });
    _animationController.animateTo(_newspeed / _maxspeed,
        duration: Duration(milliseconds: 1000), curve: Curves.ease);
  }*/

  @override
  Widget build(BuildContext context) {
    int meterWidth = MediaQuery.of(context).orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width.round() - 40
        : MediaQuery.of(context).size.height.round() - 40;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: OrientationBuilder(builder: (context, orientation) {
          return Flex(
            direction: orientation == Orientation.portrait
                ? Axis.vertical
                : Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: meterWidth.toDouble() - 40,
                width: meterWidth.toDouble(),
                child: SpeedDial(
                  colorScheme: Theme.of(context).colorScheme,
                  maxSpeed: _maxspeed,
                  oldSpeed: _oldspeed,
                  newSpeed: _newspeed,
                  controller: _animationController,
                  active: _isListening,
                  diameter: meterWidth - 40,
                  unit: _unit,
                ),
              ),
              SizedBox(
                width: meterWidth / 3,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Top Speed: ",
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                    color: _isListening
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.5)),
                          ),
                          Text(
                            "Average Speed: ",
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                    color: _isListening
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.5)),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "$_topspeed ",
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                    color: _isListening
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.5)),
                          ),
                          Text(
                            "$_avgspeed ",
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                    color: _isListening
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.5)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  TextButton.icon(
                    style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll<Color>(
                            Theme.of(context).colorScheme.primaryContainer)),
                    onPressed: _isListening ? _stopListening : _startListening,
                    label: Text(_isListening ? "Stop" : "Start"),
                    icon: Icon(_isListening ? Icons.stop : Icons.play_arrow),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.settings),
        onPressed: () => SettingsModal.settingsModal(
            context,
            _unit,
            _setUnit,
            _maxspeed,
            _setMaxSpeed,
            widget.themeMode,
            _setThemeSave,
            _appVersion),
      ),
    );
  }
}
