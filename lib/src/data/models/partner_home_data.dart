import 'offer_model.dart';
import 'product_model.dart';

class PartnerHomeData {
  final int? totalCustomers;
  final double? commissionAmount;
  final int? totalSalesViaSetgo;
  final List<OfferModel>? recentOffers;
  final List<ProductModel>? recentProducts;

  const PartnerHomeData({
    this.totalCustomers,
    this.commissionAmount,
    this.totalSalesViaSetgo,
    this.recentOffers,
    this.recentProducts,
  });

  factory PartnerHomeData.fromJson(Map<String, dynamic> json) {
    return PartnerHomeData(
      totalCustomers: json['totalCustomers'] as int?,
      commissionAmount: (json['commissionAmount'] as num?)?.toDouble(),
      totalSalesViaSetgo: (json['totalSalesViaSetgo'] as num?)?.toInt(),
      recentOffers: json['recentOffers'] != null
          ? (json['recentOffers'] as List).map((e) => OfferModel.fromJson(e as Map<String, dynamic>)).toList()
          : null,
      recentProducts: json['recentProducts'] != null
          ? (json['recentProducts'] as List).map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList()
          : null,
    );
  }
}
