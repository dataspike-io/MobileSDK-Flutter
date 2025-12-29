import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';

class VerificationStage {
  final String title;
  const VerificationStage({required this.title});
}

class VerificationStageRow extends StatelessWidget {
  final VerificationStage stage;
  const VerificationStageRow({super.key, required this.stage});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13.0),
      child: Text(
        stage.title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
          fontFamily: 'Figtree',
          package: 'dataspikemobilesdk',
        ),
      ),
    );
  }
}
