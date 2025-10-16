import 'package:flutter/material.dart';
import '../../../ui/top_bar.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';
import 'package:dataspikemobilesdk/view/ui/continue_button.dart';
import 'package:dataspikemobilesdk/view/ui/camera/additional/swipable_view.dart';
import 'package:dataspikemobilesdk/domain/models/instruction_type.dart';
import 'package:dataspikemobilesdk/main/coordinator/coordinator.dart';

class InstructionScreen extends StatefulWidget {
  final InstructionType type;

  const InstructionScreen({super.key, required this.type});

  @override
  State<InstructionScreen> createState() => _InstructionScreenState();
}

class _InstructionScreenState extends State<InstructionScreen> {
  void _onContinue() {
    switch (widget.type) {
      case InstructionType.poi:
        DataspikeCoordinator.proceedNext(
          context,
          after: DataspikeStep.documentInstruction,
        );
        break;
      case InstructionType.liveness:
        DataspikeCoordinator.proceedNext(
          context,
          after: DataspikeStep.selfieInstruction,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.type == InstructionType.poi
        ? 'Take a photo of your ID'
        : 'Take a selfie';

    final ctaText = widget.type == InstructionType.poi
        ? 'Take a photo'
        : 'Take a selfie';

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              TopBar(hasTimer: true),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                          fontFamily: 'FunnelDisplay',
                          package: 'dataspikemobilesdk',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Flexible(
                        flex: 6,
                        fit: FlexFit.tight,
                        child: SwipableView(type: widget.type),
                      ),
                      const Spacer(),
                      ContinueButton(text: ctaText, onPressed: _onContinue),
                      const SizedBox(height: 16),
                    ],
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
