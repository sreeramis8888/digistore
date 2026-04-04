class BusinessDetails {
  final String? businessName;
  final String? businessType;
  final String? registrationNumber;
  final String? gstNumber;
  final String? address;
  final String? pincode;

  const BusinessDetails({
    this.businessName,
    this.businessType,
    this.registrationNumber,
    this.gstNumber,
    this.address,
    this.pincode,
  });

  factory BusinessDetails.fromJson(Map<String, dynamic> json) {
    return BusinessDetails(
      businessName: json['businessName'] as String?,
      businessType: json['businessType'] as String?,
      registrationNumber: json['registrationNumber'] as String?,
      gstNumber: json['gstNumber'] as String?,
      address: json['address'] as String?,
      pincode: json['pincode'] as String?,
    );
  }
}
