import 'package:flutter/material.dart';
import 'package:login_app/core/constants/app_colors.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;
  final bool fullScreen;
  final Color? color;

  const LoadingIndicator({
    Key? key,
    this.message,
    this.fullScreen = false,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget loadingWidget = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? AppColors.primary,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );

    if (fullScreen) {
      return Scaffold(
        body: Center(child: loadingWidget),
      );
    }

    return Center(child: loadingWidget);
  }
}
