import 'package:flutter/material.dart';

class SettingsModal {

  static Future<void> settingsModal(
      BuildContext context,
      String unit,
      Function(String unit) setUnit,
      int maxSpeed,
      Function(int maxSpeed) setMaxSpeed,
      ThemeMode themeMode,
      Function(ThemeMode themeMode) setThemeMode,
      String versionText) {
    List<String> units = ["m/s", "km/h", "mph"];
    List<int> maxSpeeds = [50, 100, 250, 500, 1000, 2000];
    List<String> themes = ["Light", "Dark", "System"];
    List<ThemeMode> themeModes = [ThemeMode.light, ThemeMode.dark, ThemeMode.system];

    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).devicePixelRatio * MediaQuery.of(context).size.width/4,
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Container(
                      width: 80,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.25),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(2)),
                      ),
                    ),
                  ),
                ),
                ListTile(
                  title: Text(
                    "Options",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                ListTile(
                  title: const Text(
                    "Unit",
                  ),
                  subtitle: const Text("Select the unit to measure speed in."),
                  trailing: DropdownButton(
                    value: unit,
                    onChanged: (value) {
                      setState(() {
                        unit = value;
                        setUnit(value);
                      });
                    },
                    items: List<DropdownMenuItem>.generate(
                      units.length,
                          (int index) {
                        return DropdownMenuItem(
                            value: units[index],
                            child: Text(units[index]));
                      },
                    ),
                  ),
                ),
                ListTile(
                  title: const Text(
                    "Max Speed",
                  ),
                  subtitle: const Text("Set the max speed shown on the dial."),
                  trailing: DropdownButton(
                    value: maxSpeed,
                    onChanged: (value) {
                      setState(() {
                        maxSpeed = value;
                        setMaxSpeed(value);
                      });
                    },
                    items: List<DropdownMenuItem>.generate(
                      maxSpeeds.length,
                      (int index) {
                        return DropdownMenuItem(
                            value: maxSpeeds[index],
                            child: Text('${maxSpeeds[index]}'));
                      },
                    ),
                  ),
                ),
                ListTile(
                  title: const Text(
                    "Theme",
                  ),
                  subtitle: const Text("Set the application's user interface theme."),
                  trailing: DropdownButton(
                    value: themeMode,
                    onChanged: (value) {
                      setState(() {
                        themeMode = value;
                        setThemeMode(value);
                      });
                    },
                    items: List<DropdownMenuItem>.generate(
                      themes.length,
                          (int index) {
                        return DropdownMenuItem(
                            value: themeModes[index],
                            child: Text(themes[index]));
                      },
                    ),
                  ),
                ),
                ListTile(
                  dense: true,
                  visualDensity: VisualDensity(vertical: -4),
                  leading: Icon(Icons.info_outline_rounded, size: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),),
                  title: Text(
                    "Version $versionText",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }
}
