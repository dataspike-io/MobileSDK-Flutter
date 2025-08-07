import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/screens/templates/requirements_screen.dart';

class RequirementScreenFactory {
  static DocumentRequirementsScreen documentRequirementsScreen({
    required BuildContext context,
    required VoidCallback onContinue,
  }) {
    return DocumentRequirementsScreen(
      title: 'Document Requirements',
      subtitle:
          'To confirm your identity, we need you to upload a valid document. Check out the requirements below',
      requirements: [
        Requirement(
          image:
              'packages/dataspikemobilesdk/assets/images/document_requirements_1.svg',
          text: 'Original, full-size, unedited document',
        ),
        Requirement(
          image:
              'packages/dataspikemobilesdk/assets/images/document_requirements_2.svg',
          text: 'No black and white images',
        ),
        Requirement(
          image:
              'packages/dataspikemobilesdk/assets/images/document_requirements_3.svg',
          text: 'No dark images',
        ),
        Requirement(
          image:
              'packages/dataspikemobilesdk/assets/images/document_requirements_4.svg',
          text: 'No blurred and without reflections',
        ),
        Requirement(
          image:
              'packages/dataspikemobilesdk/assets/images/document_requirements_5.svg',
          text: 'No damaged documents',
        ),
        Requirement(
          image:
              'packages/dataspikemobilesdk/assets/images/document_requirements_6.svg',
          text: 'No expired documents',
        ),
      ],
      onContinue: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                RequirementScreenFactory.selfieRequirementsScreen(
                  context: context,
                ),
          ),
        );
      },
    );
  }

  static DocumentRequirementsScreen selfieRequirementsScreen({
    required BuildContext context,
  }) {
    return DocumentRequirementsScreen(
      title: 'Selfie Requirements',
      subtitle:
          'To confirm your identity, we need you to take a selfie. Check out the requirements below',
      requirements: [
        Requirement(
          image:
              'packages/dataspikemobilesdk/assets/images/selfie_requirements_1.svg',
          text: 'No accessories',
        ),
        Requirement(
          image:
              'packages/dataspikemobilesdk/assets/images/selfie_requirements_2.svg',
          text: 'No dark selfies',
        ),
        Requirement(
          image:
              'packages/dataspikemobilesdk/assets/images/selfie_requirements_3.svg',
          text: 'No cropped selfies',
        ),
        Requirement(
          image:
              'packages/dataspikemobilesdk/assets/images/selfie_requirements_4.svg',
          text: 'Full-size, unedited selfie',
        ),
      ],
      onContinue: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                RequirementScreenFactory.addressRequirementsScreen(
                  context: context,
                  onContinue: () {},
                ),
          ),
        );
      },
    );
  }

  static DocumentRequirementsScreen addressRequirementsScreen({
    required BuildContext context,
    required VoidCallback onContinue,
  }) {
    return DocumentRequirementsScreen(
      title: 'Proof of Address requirements',
      subtitle:
          'To confirm your address, upload utility bill. Check out the requirements below',
      requirements: [
        Requirement(
          image:
              'packages/dataspikemobilesdk/assets/images/address_requirements_1.svg',
          text: 'Original, full-size, unedited document',
        ),
        Requirement(
          image:
              'packages/dataspikemobilesdk/assets/images/address_requirements_2.svg',
          text: 'No filters, too light or too dark images',
        ),
        Requirement(
          image:
              'packages/dataspikemobilesdk/assets/images/address_requirements_3.svg',
          text: 'No cropped documents',
        ),
        Requirement(
          image:
              'packages/dataspikemobilesdk/assets/images/address_requirements_4.svg',
          text: 'No expired documents',
        ),
      ],
      onContinue: onContinue
    );
  }
}
