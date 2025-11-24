import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';

class BlankMessageScreen extends StatelessWidget {
  final String title, description;
  final IconData icon;
  final VoidCallback? callback;
  final String? buttonTitle;

  const BlankMessageScreen({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.callback,
    this.buttonTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //SvgPicture.asset('assets/svg/search.svg', height: 200),
            _buildIconContainer(),
            const SizedBox(height: 30),
            if (title.isNotEmpty) _buildTitle(context),
            const SizedBox(height: 12),
            _buildDescription(context),
            const SizedBox(height: 30),
            if (callback != null && buttonTitle != null) _buildButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildIconContainer() {
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(icon, size: 70, color: AppColors.primary),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        color: Colors.black87,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Text(
      description,
      textAlign: TextAlign.center,
      style: Theme.of(
        context,
      ).textTheme.bodyLarge?.copyWith(color: Colors.black87, height: 1.4),
    );
  }

  Widget _buildButton() {
    return GestureDetector(
      onTap: callback,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: .85),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Text(
          buttonTitle!,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
