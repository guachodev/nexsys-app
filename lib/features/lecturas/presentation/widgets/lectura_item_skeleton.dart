import 'package:flutter/material.dart';

class LecturaItemSkeleton extends StatelessWidget {
  const LecturaItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 1.2),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // TOP ROW
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _skeletonRow(),
                    _skeletonRow(),
                  ],
                ),
                const SizedBox(height: 12),

                // PROPIETARIO
                Align(
                  alignment: Alignment.centerLeft,
                  child: _skeletonLine(width: 180, height: 16),
                ),

                const SizedBox(height: 10),

                // BOTTOM ROW INFO
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _skeletonInfoItem(),
                    _skeletonInfoItem(),
                  ],
                ),
              ],
            ),
          ),

          // BTN BOTTOM
          Container(
            height: 45,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ---- Skeleton Blocks ----

  Widget _skeletonRow() {
    return Row(
      children: [
        // icon box
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 8),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _skeletonLine(width: 70, height: 12),
            const SizedBox(height: 6),
            _skeletonLine(width: 90, height: 16),
          ],
        ),
      ],
    );
  }

  Widget _skeletonInfoItem() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _skeletonLine(width: 60, height: 12),
        const SizedBox(height: 4),
        _skeletonLine(width: 80, height: 16),
      ],
    );
  }

  Widget _skeletonLine({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
