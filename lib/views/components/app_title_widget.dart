import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppTitleWidget extends StatelessWidget {
  const AppTitleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () async {
          final packageInfo = await PackageInfo.fromPlatform();
          showAboutDialog(
            context: context,
            applicationName: 'Quran Computer Publication',
            applicationVersion: 'v${packageInfo.version}',
            applicationIcon: Image.asset(
              'assets/logo/logo500x500.png',
              width: 300,
              height: 300,
            ),
          );
        },
        child: const Row(
          children: [
            Text(
              'Quran Computer Publication',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w600,
              ),
            ),
            Gap(8),
            Chip(label: Text('Beta'))
          ],
        ),
      ),
    );
  }
}
