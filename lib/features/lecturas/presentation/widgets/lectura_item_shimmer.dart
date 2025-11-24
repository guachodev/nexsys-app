import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LecturaItemShimmer extends StatelessWidget {
  const LecturaItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200, width: 1.5),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    // Row superior (icono + medidor + badge)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade400,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 60,
                                  height: 10,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: 80,
                                  height: 16,
                                  color: Colors.grey.shade400,
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          width: 50,
                          height: 20,
                          color: Colors.grey.shade400,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Propietario
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 80,
                                height: 10,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: double.infinity,
                                height: 14,
                                color: Colors.grey.shade400,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Cedula + Catastro
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(width: 60, height: 12, color: Colors.grey.shade400),
                        Container(width: 60, height: 12, color: Colors.grey.shade400),
                      ],
                    ),
                  ],
                ),
              ),
              // Botón inferior
              Container(
                margin: const EdgeInsets.only(top: 6),
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
