// class DataspikeVerificationStatus {
//   final bool success;
//   final String? details;
//   final String? error;

//   DataspikeVerificationStatus({required this.success, this.details, this.error});
// }

enum DataspikeVerificationStatus {
  verificationCompleted,
  verificationFailed,
  verificationExpired,
}

extension DataspikeVerificationStatusJson on DataspikeVerificationStatus {
  String toJson() {
    switch (this) {
      case DataspikeVerificationStatus.verificationCompleted:
        return "Completed";
      case DataspikeVerificationStatus.verificationFailed:
        return "Failed";
      case DataspikeVerificationStatus.verificationExpired:
        return "Expired";
    }
  }

  static DataspikeVerificationStatus fromJson(String value) {
    switch (value) {
      case "Completed":
        return DataspikeVerificationStatus.verificationCompleted;
      case "Failed":
        return DataspikeVerificationStatus.verificationFailed;
      case "Expired":
        return DataspikeVerificationStatus.verificationExpired;
      default:
        throw ArgumentError("Unknown DataspikeVerificationStatus: $value");
    }
  }
}