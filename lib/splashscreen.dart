import 'dart:convert';
import 'dart:async';
import 'package:dealsdray/login.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:geolocator/geolocator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLoading = true;
  String _error = '';
  String _status = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _updateStatus(String status) async {
    if (mounted) {
      setState(() {
        _status = status;
      });
    }
  }

  Future<void> _initializeApp() async {
    try {
      await _updateStatus('Checking permissions...');
      await _checkLocationPermission();
      
      await _updateStatus('Getting device info...');
      await _sendDeviceInfoToApi();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please enable location services in your device settings.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied. Please grant location permission in app settings.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied. Please enable in app settings.');
    }
  }

  Future<String> _getPublicIpAddress() async {
    final ipServices = [
      {'url': 'https://api.ipify.org?format=json', 'key': 'ip'},
      {'url': 'https://api64.ipify.org?format=json', 'key': 'ip'},
      {'url': 'https://httpbin.org/ip', 'key': 'origin'},
      {'url': 'https://api.myip.com', 'key': 'ip'},
    ];

    for (var service in ipServices) {
      try {
        final response = await http.get(Uri.parse(service['url']!)).timeout(const Duration(seconds: 10));
        if (response.statusCode == 200) {
          final jsonResponse = json.decode(response.body);
          final ip = jsonResponse[service['key']];
          if (ip != null && ip.toString().isNotEmpty) {
            return ip.toString();
          }
        }
      } catch (e) {
        continue;
      }
    }

    throw Exception('Failed to fetch IP address from all services');
  }

  Future<Position> _getLocation() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 20),
    );
  }

Future<void> _sendDeviceInfoToApi() async {
  try {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    final String deviceId = androidInfo.id;

    final String ipAddress = await _getPublicIpAddress();
    final Position position = await _getLocation();

    final Map<String, dynamic> deviceData = {
      "deviceType": "android",
      "deviceId": deviceId,
      "deviceName": androidInfo.model,
      "deviceOSVersion": androidInfo.version.release,
      "deviceIPAddress": ipAddress,
      "lat": position.latitude,
      "long": position.longitude,
      "buyer_gcmid": "",
      "buyer_pemid": "",
      "app": {
        "version": "1.20.5",
        "installTimeStamp": DateTime.now().toIso8601String(),
        "uninstallTimeStamp": DateTime.now().toIso8601String(),
        "downloadTimeStamp": DateTime.now().toIso8601String()
      }
    };

    // Print the device data to the terminal
    print("Device Data: $deviceData");

    final response = await http.post(
      Uri.parse('http://devapiv4.dealsdray.com/api/v2/user/device/add'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode(deviceData),
    );

    if (response.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PhoneVerificationScreen(deviceId: deviceId),
        ),
      );
    } else {
      throw Exception('Server returned ${response.statusCode}: ${response.body}');
    }
  } catch (e) {
    if (mounted) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
    rethrow;
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'lib/assets/splashscreen.jpeg',
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                if (_isLoading) ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    _status,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ] else if (_error.isNotEmpty)
                  Text(
                    _error,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
