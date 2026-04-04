class BusinessDetails {
  final String? businessName;
  final String? businessType;
  final String? address;
  final String? pincode;

  const BusinessDetails({
    this.businessName,
    this.businessType,
    this.address,
    this.pincode,
  });

  factory BusinessDetails.fromJson(Map<String, dynamic> json) {
    return BusinessDetails(
      businessName: json['businessName'] as String?,
      businessType: json['businessType'] as String?,
      address: json['address'] as String?,
      pincode: json['pincode'] as String?,
    );
  }
}
