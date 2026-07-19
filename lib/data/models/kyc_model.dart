class KycModel {
  final String? id;
  final String fullName;
  final String dob;
  final String addressLine1;
  final String city;
  final String state;
  final String pincode;
  final String panNumber;
  final String? panImageUrl;
  final String? aadhaarFrontUrl;
  final String? aadhaarBackUrl;
  final String? bankAccountHolderName;
  final String? bankAccountNumber;
  final String? bankIfscCode;
  final String? bankName;
  final String status; // not_submitted | pending | approved | rejected
  final String? rejectionReason;

  KycModel({
    this.id,
    required this.fullName,
    required this.dob,
    required this.addressLine1,
    required this.city,
    required this.state,
    required this.pincode,
    required this.panNumber,
    this.panImageUrl,
    this.aadhaarFrontUrl,
    this.aadhaarBackUrl,
    this.bankAccountHolderName,
    this.bankAccountNumber,
    this.bankIfscCode,
    this.bankName,
    required this.status,
    this.rejectionReason,
  });

  factory KycModel.fromJson(Map<String, dynamic> j) => KycModel(
        id: j['_id'],
        fullName: j['fullName'] ?? '',
        dob: j['dob'] ?? '',
        addressLine1: j['address']?['line1'] ?? '',
        city: j['address']?['city'] ?? '',
        state: j['address']?['state'] ?? '',
        pincode: j['address']?['pincode'] ?? '',
        panNumber: j['panNumber'] ?? '',
        panImageUrl: j['panImage']?['url'],
        aadhaarFrontUrl: j['aadhaarFront']?['url'],
        aadhaarBackUrl: j['aadhaarBack']?['url'],
        bankAccountHolderName: j['bankDetails']?['accountHolderName'],
        bankAccountNumber: j['bankDetails']?['accountNumber'],
        bankIfscCode: j['bankDetails']?['ifscCode'],
        bankName: j['bankDetails']?['bankName'],
        status: j['status'] ?? 'pending',
        rejectionReason: j['rejectionReason'],
      );

  bool get isApproved => status == 'approved';
  bool get isPending  => status == 'pending';
  bool get isRejected => status == 'rejected';
  bool get notSubmitted => status == 'not_submitted';
}