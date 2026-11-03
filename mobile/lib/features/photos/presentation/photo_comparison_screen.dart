import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
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
    // Default: oldest photo as A (Baseline), newest as B (Progress)
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isSlotA ? 'Select Baseline Photo (Slot A)' : 'Select Progress Photo (Slot B)',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
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
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        photo.category,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        'Date: ${DateFormatter.format(photo.documentationDate)}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
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
              style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w700),
            ),
            Text(
              '${widget.patient.name} (${widget.patient.patientId})',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz_rounded, color: Colors.white),
            tooltip: 'Swap Left / Right',
            onPressed: _swapPhotos,
          ),
          const SizedBox(width: AppDimensions.xs),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Side-by-side comparison viewport (Maximized image space)
            Expanded(
              child: Row(
                children: [
                  // Photo A (Left)
                  Expanded(
                    child: _ComparisonPane(
                      label: 'SLOT A (Baseline)',
                      photo: _photoA,
                      onTapChange: () => _showPhotoPicker(isSlotA: true),
                    ),
                  ),
                  Container(width: 1.5, color: Colors.white24),
                  // Photo B (Right)
                  Expanded(
                    child: _ComparisonPane(
                      label: 'SLOT B (Progress)',
                      photo: _photoB,
                      onTapChange: () => _showPhotoPicker(isSlotA: false),
                    ),
                  ),
                ],
              ),
            ),

            // Clinical Notes Comparison Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              color: const Color(0xFF0F172A),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'NOTES A (BASELINE):',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _photoA.notes.isNotEmpty ? _photoA.notes : '— No notes',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(width: 1, height: 34, color: Colors.white24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'NOTES B (PROGRESS):',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _photoB.notes.isNotEmpty ? _photoB.notes : '— No notes',
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
        // Pane Header Bar
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
                  letterSpacing: 0.4,
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
                      Icon(Icons.edit_rounded, color: Colors.white, size: 10),
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

        // Photo with Interactive Zoom (contain mode, uncropped)
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
                child: Icon(Icons.broken_image_rounded, color: Colors.white38, size: 36),
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
