import 'package:flutter/material.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  int _seconds = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _canResend = false;
    _seconds = 30;
    Future.doWhile(() async {
      await Future.delayed(Duration(seconds: 1));
      if (_seconds > 0) {
        setState(() => _seconds--);
        return true;
      } else {
        setState(() => _canResend = true);
        return false;
      }
    });
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('OTP Verification')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Enter the 6-digit OTP sent to your email',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                6,
                (i) => Container(
                  width: 40,
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  child: TextField(
                    controller: _controllers[i],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    decoration: InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      if (val.isNotEmpty && i < 5) {
                        FocusScope.of(context).nextFocus();
                      }
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(_canResend ? 'You can resend OTP' : 'Resend in $_seconds s'),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _canResend
                  ? () {
                      _startTimer();
                      // TODO: Resend OTP logic
                    }
                  : null,
              child: Text('Resend OTP'),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // TODO: Verify OTP logic
              },
              child: Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }
}
