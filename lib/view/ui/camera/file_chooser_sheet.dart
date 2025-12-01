import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FileChooserSheet extends StatelessWidget {
  const FileChooserSheet({
    super.key,
    required this.onImagePressed,
    required this.onFilePressed,
  });

  final VoidCallback onImagePressed;
  final VoidCallback onFilePressed;

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return SafeArea(
      top: false,
      bottom: false,
      child: Container(
        width: double.infinity,
        height: h * 0.3,
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
              BoxShadow(
                color: AppColors.shadowBlack,
                blurRadius: 30,
                spreadRadius: 0,
                offset: Offset(0, -14),
              ),
            ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () =>
                              Navigator.of(context, rootNavigator: true).pop(),
                          child: SvgPicture.asset(
                            'packages/dataspikemobilesdk/assets/images/cross_circled.svg',
                            width: 32,
                            height: 32,
                            alignment: Alignment.center,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 11),
                    SizedBox(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size(24.0, 24.0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          foregroundColor: AppColors.black,
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Figtree',
                            package: 'dataspikemobilesdk',
                          ),
                        ),
                        onPressed: onImagePressed,
                        child: Text('Upload image'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size(24.0, 24.0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          foregroundColor: AppColors.black,
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Figtree',
                            package: 'dataspikemobilesdk',
                          ),
                        ),
                        onPressed: onFilePressed,
                        child: Text('Upload file'),
                      ),
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
