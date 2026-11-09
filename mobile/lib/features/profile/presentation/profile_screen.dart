import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dentist Profile'),
      ),
      body: const Center(
        child: Text(
          'Profile screen under development',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
