import 'package:dealsdray/verification.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dealsdray/emailsignup.dart';
// Import your OTP screen here

class PhoneVerificationScreen extends StatefulWidget {
  final String deviceId;

  const PhoneVerificationScreen({Key? key, required this.deviceId}) : super(key: key);

  @override
  _PhoneVerificationScreenState createState() => _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _otpSent = false;
  bool _isPhoneValid = false;

  void _validatePhoneNumber(String phoneNumber) {
    setState(() {
      _isPhoneValid = phoneNumber.length == 10 && int.tryParse(phoneNumber) != null;
    });
  }
Future<void> _sendOtp() async {
  if (!_isPhoneValid) {
    _showErrorMessage('Please enter a valid 10-digit phone number');
    return;
  }

  setState(() {
    _isLoading = true;
  });

  // Navigate to the OTP screen before making the network call
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => OTPScreen(), // Make sure OTPScreen is imported
    ),
  );

  try {
    final response = await http.post(
      Uri.parse('http://devapiv4.dealsdray.com/api/v2/user/otp'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({
        'mobileNumber': '+91${_phoneController.text.trim()}',
        'deviceId': widget.deviceId,
        'type': 'PHONE_VERIFICATION'
      }),
    );

    final responseData = json.decode(response.body);
    if (response.statusCode == 200 && responseData['status'] == true) {
      String sessionId = responseData['sessionId'] ?? ''; // Update this key based on actual response

      setState(() {
        _otpSent = true;
      });

      _showSuccessMessage('OTP sent successfully!');
    } else {
      final errorMessage = responseData['message'] ?? 'Failed to send OTP';
      _showErrorMessage(errorMessage);
    }
  } catch (e) {
    _showErrorMessage('Network error. Please try again.');
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}



  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    'lib/assets/logo.png',
                    height: 80,
                    width: 80,
                  ),
                ),
                const SizedBox(height: 30),
                _buildToggleButtons(context),
                const SizedBox(height: 40),
                const Text(
                  'Glad to see you!',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Please provide your phone number',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 30),
                _buildPhoneInputField(),
                const SizedBox(height: 40),
                _buildSendCodeButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButtons(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Center(
                child: Text(
                  'Phone',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const EmailSignupScreen()));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: const Center(
                  child: Text(
                    'Email',
                    style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneInputField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: const Text(
              '+91',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            width: 1,
            height: 30,
            color: Colors.grey[300],
          ),
          Expanded(
            child: TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              onChanged: _validatePhoneNumber,
              decoration: InputDecoration(
                hintText: 'Phone Number',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendCodeButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: _isPhoneValid && !_isLoading ? _sendOtp : null,
        style: TextButton.styleFrom(
          backgroundColor: _isPhoneValid ? Colors.red : Colors.grey[300],
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Text(
                'Send Code',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
