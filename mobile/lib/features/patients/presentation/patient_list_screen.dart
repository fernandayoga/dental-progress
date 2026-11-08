import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';

class PatientListScreen extends ConsumerWidget {
  const PatientListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Patients'),
      ),
      body: const Center(
        child: Text(
          'Patient screen under development',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
