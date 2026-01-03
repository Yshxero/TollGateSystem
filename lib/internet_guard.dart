import 'package:flutter/material.dart';
import 'internet_service.dart';

class InternetGuard extends StatefulWidget {
  final Widget child;
  const InternetGuard({super.key, required this.child});

  @override
  State<InternetGuard> createState() => _InternetGuardState();
}

class _InternetGuardState extends State<InternetGuard> {
  bool dialogShown = false;

  @override
  void initState() {
    super.initState();

    InternetService().internetStatus.listen((hasInternet) {
      if (!hasInternet && !dialogShown && mounted) {
        dialogShown = true;

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            backgroundColor: const Color(0xFF2E1C38),
            title: const Text(
              "No Internet Connection",
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              "Please connect to the internet to continue using the app.",
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "OK",
                  style: TextStyle(color: Colors.pinkAccent),
                ),
              ),
            ],
          ),
        );
      }

      if (hasInternet) {
        dialogShown = false; // allow popup again
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
