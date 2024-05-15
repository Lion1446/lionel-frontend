import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FetchingDataDialog extends StatelessWidget {
  const FetchingDataDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 200,
        width: 100,
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                  width: 50, height: 50, child: CircularProgressIndicator()),
              const SizedBox(
                height: 50,
              ),
              Text(
                'Fetching Data',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
