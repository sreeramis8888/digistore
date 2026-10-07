import '../utils/name_case.dart';

class BusinessDetails {
  final String? businessName;
  final String? businessType;
  final String? registrationNumber;
  final String? gstNumber;
  final String? address;
  final String? pincode;
  final String? district;

  const BusinessDetails({
    this.businessName,
    this.businessType,
    this.registrationNumber,
    this.gstNumber,
    this.address,
    this.pincode,
    this.district,
  });

  factory BusinessDetails.fromJson(Map<String, dynamic> json) {
    return BusinessDetails(
      businessName: NameCase.maybe(json['businessName']?.toString()),
      businessType: json['businessType'] is Map
          ? NameCase.maybe((json['businessType'] as Map)['name']?.toString())
          : NameCase.maybe(json['businessType']?.toString()),
      registrationNumber: json['registrationNumber'] as String?,
      gstNumber: json['gstNumber'] as String?,
      address: json['address'] as String?,
      pincode: json['pincode'] as String?,
      district: NameCase.maybe(json['district']?.toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'businessName': businessName,
      'businessType': businessType,
      'registrationNumber': registrationNumber,
      'gstNumber': gstNumber,
      'address': address,
      'pincode': pincode,
      'district': district,
    };
  }
}
