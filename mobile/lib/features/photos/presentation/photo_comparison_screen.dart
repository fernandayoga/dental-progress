import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../patients/domain/patient_model.dart';
import '../domain/photo_model.dart';

class PhotoComparisonScreen extends StatefulWidget {
  final PatientModel patient;
  final List<PhotoModel> photos;
  final PhotoModel? initialPhotoA;
  final PhotoModel? initialPhotoB;

  const PhotoComparisonScreen({
    super.key,
    required this.patient,
    required this.photos,
    this.initialPhotoA,
    this.initialPhotoB,
  });

  @override
  State<PhotoComparisonScreen> createState() => _PhotoComparisonScreenState();
}

class _PhotoComparisonScreenState extends State<PhotoComparisonScreen> {
  late PhotoModel _photoA;
  late PhotoModel _photoB;

  @override
  void initState() {
    super.initState();
    // Default: oldest photo as A, newest as B, or provided initials
    final sortedByDate = List<PhotoModel>.from(widget.photos)
      ..sort((a, b) => a.documentationDate.compareTo(b.documentationDate));

    _photoA = widget.initialPhotoA ?? sortedByDate.first;
    _photoB = widget.initialPhotoB ?? (sortedByDate.length > 1 ? sortedByDate.last : sortedByDate.first);
  }

  void _swapPhotos() {
    setState(() {
      final temp = _photoA;
      _photoA = _photoB;
      _photoB = temp;
    });
  }

  void _showPhotoPicker({required bool isSlotA}) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: AppColors.surface,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppDimensions.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isSlotA ? 'Select Previous Photo (Slot A)' : 'Select Current Photo (Slot B)',
                      style: AppTypography.sectionTitle,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  itemCount: widget.photos.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final photo = widget.photos[index];
                    final isSelected = isSlotA ? photo.id == _photoA.id : photo.id == _photoB.id;

                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: AppDimensions.roundedSm,
                        child: CachedNetworkImage(
                          imageUrl: photo.imageUrl,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        photo.category,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        'Date: ${DateFormatter.format(photo.documentationDate)}',
                        style: AppTypography.caption,
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: AppColors.primary)
                          : null,
                      onTap: () {
                        setState(() {
                          if (isSlotA) {
                            _photoA = photo;
                          } else {
                            _photoB = photo;
                          }
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Side-by-Side Comparison',
              style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
            ),
            Text(
              '${widget.patient.name} (${widget.patient.patientId})',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz, color: Colors.white),
            tooltip: 'Swap Left / Right',
            onPressed: _swapPhotos,
          ),
          const SizedBox(width: AppDimensions.sm),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Side-by-side photo comparison viewport (prioritizes image visibility)
            Expanded(
              child: Row(
                children: [
                  // Photo A (Left)
                  Expanded(
                    child: _ComparisonPane(
                      label: 'PHOTO A (Earlier)',
                      photo: _photoA,
                      onTapChange: () => _showPhotoPicker(isSlotA: true),
                    ),
                  ),
                  Container(width: 1.5, color: Colors.white24),
                  // Photo B (Right)
                  Expanded(
                    child: _ComparisonPane(
                      label: 'PHOTO B (Later)',
                      photo: _photoB,
                      onTapChange: () => _showPhotoPicker(isSlotA: false),
                    ),
                  ),
                ],
              ),
            ),

            // Clinical Notes Comparison Bar (Compact footer)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: const Color(0xFF1E293B),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'NOTES A:',
                          style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          _photoA.notes.isNotEmpty ? _photoA.notes : '—',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(width: 1, height: 32, color: Colors.white24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'NOTES B:',
                          style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          _photoB.notes.isNotEmpty ? _photoB.notes : '—',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComparisonPane extends StatelessWidget {
  final String label;
  final PhotoModel photo;
  final VoidCallback onTapChange;

  const _ComparisonPane({
    required this.label,
    required this.photo,
    required this.onTapChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with Date & Slot Tag
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          color: const Color(0xFF0F172A),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              GestureDetector(
                onTap: onTapChange,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: AppDimensions.roundedSm,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit, color: Colors.white, size: 10),
                      SizedBox(width: 2),
                      Text(
                        'Change',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Photo with Interactive Zoom
        Expanded(
          child: InteractiveViewer(
            minScale: 1.0,
            maxScale: 4.0,
            child: CachedNetworkImage(
              imageUrl: photo.imageUrl,
              fit: BoxFit.contain,
              placeholder: (_, __) => const Center(
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              ),
              errorWidget: (_, __, ___) => const Center(
                child: Icon(Icons.broken_image, color: Colors.white38, size: 36),
              ),
            ),
          ),
        ),

        // Footer Metadata: Date & Category
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          color: const Color(0xFF0F172A),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusBadge.category(photo.category),
              Text(
                DateFormatter.format(photo.documentationDate),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
