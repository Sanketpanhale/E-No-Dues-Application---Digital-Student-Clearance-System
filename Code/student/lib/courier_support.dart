import 'package:flutter/material.dart';
import 'package:external_app_launcher/external_app_launcher.dart';

class CourierSupportScreen extends StatelessWidget {
  const CourierSupportScreen({super.key});

  // Helper functions to launch actions using external_app_launcher
  void _launchPhone() async {
    // Just open the dialer, not auto-call (for privacy)
    await LaunchApp.openApp(
      androidPackageName: 'com.android.dialer',
      openStore: false,
      // Fallback: show the number in a dialog if not supported
    );
  }

  void _launchMaps() async {
    // Open Google Maps at the address (using a geo: URI)
    const String address =
        "PCPG+5H9, Kusgaon, Lonavala, Kurvande, Maharashtra 410401";
    final geoUrl = Uri.encodeFull("geo:0,0?q=$address");
    await LaunchApp.openApp(
      androidPackageName: "com.google.android.apps.maps",
      openStore: false,
      // Fallback: show dialog or do nothing
    );
    // Note: You can't pass the address directly; for deep linking, url_launcher is more powerful,
    // but external_app_launcher just opens the app.
  }

  void _launchIndiaPost() async {
    // Opens the browser to the India Post website
    await LaunchApp.openApp(
      androidPackageName: "com.android.chrome",
      openStore: false,
      // Fallback: do nothing
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Courier Support')),
      body: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(22.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.phone, color: Colors.green),
                  title: const Text("Contact Number"),
                  subtitle: const Text("084118 57447"),
                  trailing: IconButton(
                    icon: const Icon(Icons.call, color: Colors.blue),
                    onPressed: _launchPhone,
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.red),
                  title: const Text("Postal Address"),
                  subtitle: const Text(
                    "PCPG+5H9, Kusgaon, Lonavala, Kurvande, Maharashtra 410401",
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.map, color: Colors.deepPurple),
                    onPressed: _launchMaps,
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.public, color: Colors.orange),
                  title: const Text("India Post Website"),
                  subtitle: const Text("indiapost.gov.in"),
                  trailing: IconButton(
                    icon: const Icon(Icons.open_in_browser,
                        color: Colors.blueGrey),
                    onPressed: _launchIndiaPost,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
