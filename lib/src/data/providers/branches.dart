import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/business_info.dart';
import 'api_provider.dart';
import 'partner_provider.dart';

class BranchesNotifier extends Notifier<List<BusinessBranch>> {
  @override
  List<BusinessBranch> build() {
    return [];
  }

  List<Map<String, dynamic>> _mapOperatingHours(OperatingHours? hours) {
    if (hours == null) return [];
    
    final list = <Map<String, dynamic>>[];
    
    void addDay(String dayName, DayStatus? dayStatus) {
      list.add({
        'day': dayName,
        'isOpen': dayStatus?.isOpen ?? false,
        'open': dayStatus?.open,
        'close': dayStatus?.close,
      });
    }

    addDay('monday', hours.monday);
    addDay('tuesday', hours.tuesday);
    addDay('wednesday', hours.wednesday);
    addDay('thursday', hours.thursday);
    addDay('friday', hours.friday);
    addDay('saturday', hours.saturday);
    addDay('sunday', hours.sunday);
    
    return list;
  }

  Future<List<BusinessBranch>> getBranches() async {
    final api = ref.read(apiProvider);
    final response = await api.get('/branches', requireAuth: true);
    
    if (response.success && response.data != null) {
      final dynamic rawData = response.data!['data'] ?? response.data!['branches'] ?? response.data!;
      if (rawData is List) {
        final list = rawData.map((e) => BusinessBranch.fromJson(e as Map<String, dynamic>)).toList();
        state = list;
        return list;
      }
    }
    return state;
  }

  Future<bool> createBranch(BusinessBranch branch) async {
    final api = ref.read(apiProvider);
    final partner = ref.read(partnerProvider);
    
    // Ensure fallback values are not null to prevent backend substring errors on null values
    final String branchType = 'outlet';
    final String contactPerson = partner?.businessInfo?.ownerName ?? '';
    final String partnerPincode = partner?.businessDetails?.pincode ?? '000000';
    final String partnerAddress = partner?.businessDetails?.address ?? '';
    
    final List<String> phoneList = [];
    if (branch.phone != null && branch.phone!.isNotEmpty) {
      phoneList.add(branch.phone!);
    } else if (partner?.businessInfo?.contactPhone != null && partner!.businessInfo!.contactPhone!.isNotEmpty) {
      phoneList.add(partner.businessInfo!.contactPhone!);
    }
    
    final List<String> emailList = [];
    if (partner?.businessInfo?.email != null && partner!.businessInfo!.email!.isNotEmpty) {
      emailList.add(partner.businessInfo!.email!);
    }

    final double lng = (branch.location?.coordinates != null && branch.location!.coordinates!.isNotEmpty)
        ? branch.location!.coordinates![0]
        : 0.0;
    final double lat = (branch.location?.coordinates != null && branch.location!.coordinates!.length >= 2)
        ? branch.location!.coordinates![1]
        : 0.0;

    final locationMap = {
      'type': 'Point',
      'coordinates': [lng, lat],
      'address': branch.address ?? partnerAddress,
      'city': branch.location?.city ?? '',
      'state': branch.location?.state ?? '',
      'pincode': (branch.location?.pincode != null && branch.location!.pincode!.isNotEmpty)
          ? branch.location!.pincode!
          : partnerPincode,
      'lng': lng,
      'lat': lat,
    };

    final payload = {
      'branchName': branch.name ?? '',
      'branchType': branch.branchType ?? branchType,
      'contactPerson': contactPerson,
      'phoneNumbers': phoneList,
      'emailAddresses': emailList,
      'location': locationMap,
      'operatingHours': _mapOperatingHours(branch.operatingHours),
      'staff': <String>[],
      'capacity': 0,
      'coverageHexagons': <String>[],
      'isPrimary': false,
    };

    final response = await api.post(
      '/branches',
      payload,
      requireAuth: true,
    );
    
    if (response.success) {
      await getBranches();
      return true;
    }
    return false;
  }
}

final branchesProvider = NotifierProvider<BranchesNotifier, List<BusinessBranch>>(
  BranchesNotifier.new,
);
