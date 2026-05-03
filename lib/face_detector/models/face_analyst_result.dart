class FaceAnalysisResult {
  final double detectionScore;
  final List<Map<String, double>> landmarks;
  final Map<String, double>? headPose;
  final bool isHeadPoseAcceptable;
  final Map<String, bool> eyeStatus;
  final FaceBoundingBox boundingBox;
  final bool isBlurry;
  final bool isChinVisible;
  final bool isForeheadVisible;
  final bool isTooBright;
  final bool isTooDark;

  FaceAnalysisResult({
    required this.detectionScore,
    required this.landmarks,
    required this.headPose,
    required this.isHeadPoseAcceptable,
    required this.eyeStatus,
    required this.boundingBox,
    required this.isBlurry,
    required this.isChinVisible,
    required this.isForeheadVisible,
    required this.isTooBright,
    required this.isTooDark,
  });
}

class FaceBoundingBox {
  final double xMin;
  final double yMin;
  final double xMax;
  final double yMax;

  FaceBoundingBox({
    required this.xMin,
    required this.yMin,
    required this.xMax,
    required this.yMax,
  });

  double get width => xMax - xMin;
  double get height => yMax - yMin;
  double get centerX => (xMin + xMax) / 2;
  double get centerY => (yMin + yMax) / 2;

  FaceBoundingBox toAbsolute(double imageWidth, double imageHeight) {
    return FaceBoundingBox(
      xMin: xMin * imageWidth,
      yMin: yMin * imageHeight,
      xMax: xMax * imageWidth,
      yMax: yMax * imageHeight,
    );
  }
}
