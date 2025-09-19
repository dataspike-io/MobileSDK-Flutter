import 'package:dataspikemobilesdk/view_models/personal_data_view_model.dart';
import 'package:flutter/material.dart';
import '../../ui/top_bar.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';
import 'package:dataspikemobilesdk/view/ui/continue_button.dart';
import 'package:dataspikemobilesdk/view/ui/loader.dart';
import '/view_models/factory/dataspike_view_model_factory.dart';
import 'package:dataspikemobilesdk/view/ui/personal_data/field_card.dart';
import 'package:dataspikemobilesdk/main/coordinator/coordinator.dart';

class PersonalDataScreen extends StatefulWidget {
  const PersonalDataScreen({super.key});

  static Route route() =>
      MaterialPageRoute<void>(builder: (_) => const PersonalDataScreen());

  @override
  State<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> {
  late final PersonalDataViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = DataspikeViewModelFactory().create<PersonalDataViewModel>();
    viewModel.setVerificationTimer();
    viewModel.addListener(_onVmChanged);
  }

  @override
  void dispose() {
    viewModel.removeListener(_onVmChanged);
    super.dispose();
  }

  void _onVmChanged() => setState(() {});

  Future<void> _onContinue() async {
    final rootNav = Navigator.of(context, rootNavigator: true);

    showDialog(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      barrierColor: AppColors.slateGray,
      builder: (_) => const Center(child: Loader()),
    );

    var success = false;

    try {
      await Future.sync(() => viewModel.submitProfileData());
      success = true;
    } catch (e) {
      // TODO: Handle error if needed
    } finally {
      rootNav.pop();
    }

    if (!mounted) return;
    if (success) {
      DataspikeCoordinator.proceedNext(
        context,
        after: DataspikeStep.personalData,
      );
    } else {
      await showDialog<void>(
        context: context,
        useRootNavigator: true,
        barrierDismissible: false,
        builder: (dialogCtx) => AlertDialog(
          title: const Text(
            'Something went wrong',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Figtree',
              fontWeight: FontWeight.w600,
              color: AppColors.black,
              package: 'dataspikemobilesdk',
            ),
          ),
          content: const Text(
            'Please try again.',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Figtree',
              fontWeight: FontWeight.w500,
              color: AppColors.black,
              package: 'dataspikemobilesdk',
            ),
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogCtx, rootNavigator: true).pop(),
              child: const Text(
                'OK',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Figtree',
                  fontWeight: FontWeight.w500,
                  color: AppColors.black,
                  package: 'dataspikemobilesdk',
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final timer = viewModel.timerDuration;
    final fields = viewModel.personalDataFields;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            TopBar(timer: timer),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Complete personal data',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontFamily: 'FunnelDisplay',
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                        package: 'dataspikemobilesdk',
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (fields.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else
                      FieldsCard(
                        fields: fields,
                        onChanged: (index, val) {
                          setState(() {
                            fields[index].value = val;
                          });
                        },
                        uploadFile: (index, file) {
                          setState(() {
                            fields[index].file = file;
                          });
                        },
                      ),
                    const SizedBox(height: 24),
                    ContinueButton(
                      text: 'Continue',
                      onPressed: viewModel.isContinueButtonDisabled
                          ? null
                          : _onContinue,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
