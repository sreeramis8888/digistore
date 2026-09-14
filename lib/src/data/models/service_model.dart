class ServicePartnerModel {
  final String? id;
  final String? name;
  final String? category;
  final String? logo;
  final String? phone;
  final String? addressLine1;
  final String? city;
  final List<double>? coordinates;
  final String? businessMode;
  final double rating;

  const ServicePartnerModel({
    this.id,
    this.name,
    this.category,
    this.logo,
    this.phone,
    this.addressLine1,
    this.city,
    this.coordinates,
    this.businessMode,
    this.rating = 4.8,
  });

  factory ServicePartnerModel.fromJson(Map<String, dynamic> json) {
    List<double>? coords;
    final rawAddress = json['address'];
    String? addr1;
    String? cityName;

    if (rawAddress is Map) {
      addr1 = rawAddress['addressLine1']?.toString() ?? rawAddress['address']?.toString() ?? rawAddress['street']?.toString();
      cityName = rawAddress['city']?.toString();
      if (rawAddress['coordinates'] is List) {
        coords = (rawAddress['coordinates'] as List)
            .where((e) => e is num)
            .map((e) => (e as num).toDouble())
            .toList();
      }
    } else if (rawAddress is String) {
      addr1 = rawAddress;
    } else if (json['businessDetails'] is Map) {
      final bd = json['businessDetails'] as Map;
      addr1 = bd['address']?.toString() ?? bd['addressLine1']?.toString();
      cityName = bd['city']?.toString();
    }

    String? logoUrl = json['logo']?.toString() ?? json['image']?.toString() ?? json['shopLogo']?.toString();
    if (logoUrl == null && json['businessInfo'] is Map) {
      logoUrl = json['businessInfo']['businessLogo']?.toString();
    }

    String? partnerName = json['name']?.toString() ?? json['shopName']?.toString() ?? json['businessName']?.toString();
    if (partnerName == null && json['businessDetails'] is Map) {
      partnerName = json['businessDetails']['businessName']?.toString();
    }

    double rat = 4.8;
    if (json['rating'] is num) {
      rat = (json['rating'] as num).toDouble();
    } else if (json['rating'] != null) {
      rat = double.tryParse(json['rating'].toString()) ?? 4.8;
    }

    return ServicePartnerModel(
      id: (json['_id'] ?? json['id'])?.toString(),
      name: partnerName ?? 'SetGo Partner',
      category: json['category']?.toString(),
      logo: logoUrl,
      phone: json['phone']?.toString(),
      addressLine1: addr1,
      city: cityName,
      coordinates: coords,
      businessMode: json['businessMode']?.toString(),
      rating: rat,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'category': category,
      'logo': logo,
      'phone': phone,
      'address': {
        'addressLine1': addressLine1,
        'city': city,
        'coordinates': coordinates,
      },
      'businessMode': businessMode,
      'rating': rating,
    };
  }
}

class ServiceAddOnModel {
  final String? id;
  final String name;
  final double price;
  final int durationMinutes;

  const ServiceAddOnModel({
    this.id,
    required this.name,
    required this.price,
    this.durationMinutes = 0,
  });

  factory ServiceAddOnModel.fromJson(Map<String, dynamic> json) {
    double p = 0.0;
    if (json['price'] is num) {
      p = (json['price'] as num).toDouble();
    } else if (json['price'] != null) {
      p = double.tryParse(json['price'].toString().replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    }

    int dur = 0;
    final rawDur = json['durationMinutes'] ?? json['duration'] ?? json['duration_minutes'];
    if (rawDur is num) {
      dur = rawDur.toInt();
    } else if (rawDur != null) {
      final m = RegExp(r'\d+').firstMatch(rawDur.toString());
      if (m != null) dur = int.tryParse(m.group(0)!) ?? 0;
    }

    return ServiceAddOnModel(
      id: (json['_id'] ?? json['id'])?.toString(),
      name: (json['name'] ?? json['title'] ?? 'Add-on').toString(),
      price: p,
      durationMinutes: dur,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'price': price,
      'durationMinutes': durationMinutes,
    };
  }
}

class ServiceModel {
  final String? id;
  final String? partnerId;
  final String name;
  final String? category;
  final String? description;
  final double originalPrice;
  final double effectivePrice;
  final bool hasOffer;
  final String? offerType;
  final double? offerValue;
  final double? offerPrice;
  final double? savings;
  final int durationMinutes;
  final int bufferMinutes;
  final int totalTimeMinutes;
  final String bookingType;
  final int maxConcurrentGuests;
  final String spaceLabel;
  final List<String> availableDays;
  final List<String> images;
  final List<ServiceAddOnModel> addOns;
  final ServicePartnerModel? partner;
  final bool isActive;
  final double rating;
  final int reviewsCount;

  const ServiceModel({
    this.id,
    this.partnerId,
    required this.name,
    this.category,
    this.description,
    this.originalPrice = 0.0,
    this.effectivePrice = 0.0,
    this.hasOffer = false,
    this.offerType,
    this.offerValue,
    this.offerPrice,
    this.savings,
    this.durationMinutes = 30,
    this.bufferMinutes = 0,
    this.totalTimeMinutes = 30,
    this.bookingType = 'appointment',
    this.maxConcurrentGuests = 1,
    this.spaceLabel = 'Chairs',
    this.availableDays = const [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday'
    ],
    this.images = const [],
    this.addOns = const [],
    this.partner,
    this.isActive = true,
    this.rating = 4.8,
    this.reviewsCount = 0,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    final rawPartner = json['partner'] ?? json['partnerId'] ?? json['partner_id'] ?? json['shop'] ?? json['store'];
    ServicePartnerModel? partnerModel;
    String? partnerIdStr;

    if (rawPartner is Map<String, dynamic>) {
      partnerModel = ServicePartnerModel.fromJson(rawPartner);
      partnerIdStr = partnerModel.id;
    } else if (rawPartner is Map) {
      partnerModel = ServicePartnerModel.fromJson(Map<String, dynamic>.from(rawPartner));
      partnerIdStr = partnerModel.id;
    } else if (rawPartner is String) {
      partnerIdStr = rawPartner;
    }

    double parseDouble(dynamic v, [double def = 0.0]) {
      if (v == null) return def;
      if (v is num) return v.toDouble();
      final s = v.toString().replaceAll(RegExp(r'[^0-9.]'), '');
      return double.tryParse(s) ?? def;
    }

    int parseInt(dynamic v, [int def = 0]) {
      if (v == null) return def;
      if (v is num) return v.toInt();
      final m = RegExp(r'\d+').firstMatch(v.toString());
      return m != null ? int.tryParse(m.group(0)!) ?? def : def;
    }

    final origPrice = parseDouble(json['originalPrice'] ?? json['price'] ?? json['mrp']);
    final offPrice = json['offerPrice'] != null
        ? parseDouble(json['offerPrice'])
        : (json['discountPrice'] != null ? parseDouble(json['discountPrice']) : null);
    final effPrice = parseDouble(json['effectivePrice'] ?? offPrice ?? origPrice);
    final hasOff = json['hasOffer'] == true || (offPrice != null && offPrice < origPrice);

    List<String> imgList = [];
    if (json['images'] is List) {
      for (var img in json['images'] as List) {
        if (img is String && img.isNotEmpty) {
          imgList.add(img);
        } else if (img is Map && img['url'] != null) {
          imgList.add(img['url'].toString());
        }
      }
    } else if (json['image'] is String && (json['image'] as String).isNotEmpty) {
      imgList.add(json['image'].toString());
    } else if (json['imageUrl'] is String && (json['imageUrl'] as String).isNotEmpty) {
      imgList.add(json['imageUrl'].toString());
    } else if (json['bannerImage'] is String && (json['bannerImage'] as String).isNotEmpty) {
      imgList.add(json['bannerImage'].toString());
    }

    List<String> daysList = [];
    if (json['availableDays'] is List) {
      daysList = (json['availableDays'] as List).map((e) => e.toString().toLowerCase()).toList();
    } else {
      daysList = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    }

    String? catName;
    final rawCat = json['category'] ?? json['categoryName'] ?? json['categoryId'];
    if (rawCat is Map) {
      catName = (rawCat['name'] ?? rawCat['category'] ?? rawCat['title'] ?? rawCat['_id'])?.toString();
    } else if (rawCat != null) {
      catName = rawCat.toString();
    }

    final rawAddons = json['addOns'] ?? json['addons'] ?? json['extras'] ?? json['subServices'];
    List<ServiceAddOnModel> addOnsList = [];
    if (rawAddons is List) {
      for (var a in rawAddons) {
        if (a is Map) {
          addOnsList.add(ServiceAddOnModel.fromJson(Map<String, dynamic>.from(a)));
        }
      }
    }

    final dur = parseInt(json['durationMinutes'] ?? json['duration'] ?? json['timeMinutes'] ?? json['duration_minutes'], 30);
    final buf = parseInt(json['bufferMinutes'] ?? json['buffer'] ?? json['buffer_minutes'], 0);

    return ServiceModel(
      id: (json['_id'] ?? json['id'])?.toString(),
      partnerId: partnerIdStr,
      name: (json['name'] ?? json['title'] ?? json['serviceName'] ?? 'Service').toString(),
      category: catName,
      description: json['description']?.toString() ?? json['desc']?.toString(),
      originalPrice: origPrice,
      effectivePrice: effPrice,
      hasOffer: hasOff,
      offerType: json['offerType']?.toString(),
      offerValue: json['offerValue'] != null ? parseDouble(json['offerValue']) : null,
      offerPrice: offPrice,
      savings: json['savings'] != null ? parseDouble(json['savings']) : (origPrice > effPrice ? origPrice - effPrice : 0),
      durationMinutes: dur > 0 ? dur : 30,
      bufferMinutes: buf,
      totalTimeMinutes: parseInt(json['totalTimeMinutes'], dur + buf),
      bookingType: json['bookingType']?.toString() ?? 'appointment',
      maxConcurrentGuests: parseInt(json['maxConcurrentGuests'] ?? json['capacity'], 1),
      spaceLabel: json['spaceLabel']?.toString() ?? 'Chairs',
      availableDays: daysList,
      images: imgList,
      addOns: addOnsList,
      partner: partnerModel,
      isActive: json['isActive'] != false,
      rating: parseDouble(json['rating'] ?? json['avgRating'] ?? 4.8, 4.8),
      reviewsCount: parseInt(json['reviewsCount'] ?? json['totalReviews'], 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'partnerId': partnerId,
      'name': name,
      'category': category,
      'description': description,
      'price': originalPrice,
      'originalPrice': originalPrice,
      'effectivePrice': effectivePrice,
      'hasOffer': hasOffer,
      'offerType': offerType,
      'offerValue': offerValue,
      'offerPrice': offerPrice,
      'durationMinutes': durationMinutes,
      'bufferMinutes': bufferMinutes,
      'totalTimeMinutes': totalTimeMinutes,
      'bookingType': bookingType,
      'maxConcurrentGuests': maxConcurrentGuests,
      'spaceLabel': spaceLabel,
      'availableDays': availableDays,
      'images': images,
      'addOns': addOns.map((e) => e.toJson()).toList(),
      'isActive': isActive,
    };
  }
}

class TimeSlotModel {
  final String startTime;
  final String endTime;
  final bool available;
  final int remainingCapacity;
  final int totalCapacity;
  final String? reason;

  const TimeSlotModel({
    required this.startTime,
    required this.endTime,
    this.available = true,
    this.remainingCapacity = 1,
    this.totalCapacity = 1,
    this.reason,
  });

  factory TimeSlotModel.fromJson(Map<String, dynamic> json) {
    return TimeSlotModel(
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
      available: json['available'] as bool? ?? true,
      remainingCapacity: (json['remainingCapacity'] as num?)?.toInt() ?? 1,
      totalCapacity: (json['totalCapacity'] as num?)?.toInt() ?? 1,
      reason: json['reason']?.toString(),
    );
  }
}

class SlotsResponseModel {
  final ServicePartnerModel? partner;
  final String date;
  final int requiredDurationMinutes;
  final bool isPartnerOpen;
  final int availableSlotsCount;
  final List<TimeSlotModel> slots;

  const SlotsResponseModel({
    this.partner,
    required this.date,
    this.requiredDurationMinutes = 30,
    this.isPartnerOpen = true,
    this.availableSlotsCount = 0,
    this.slots = const [],
  });

  factory SlotsResponseModel.fromJson(Map<String, dynamic> json) {
    return SlotsResponseModel(
      partner: json['partner'] != null
          ? ServicePartnerModel.fromJson(Map<String, dynamic>.from(json['partner']))
          : null,
      date: json['date']?.toString() ?? '',
      requiredDurationMinutes: (json['requiredDurationMinutes'] as num?)?.toInt() ?? 30,
      isPartnerOpen: json['isPartnerOpen'] as bool? ?? true,
      availableSlotsCount: (json['availableSlotsCount'] as num?)?.toInt() ?? 0,
      slots: json['slots'] is List
          ? (json['slots'] as List)
              .map((e) => TimeSlotModel.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : [],
    );
  }
}

class CustomerDetailsModel {
  final String name;
  final String phone;
  final String? notes;

  const CustomerDetailsModel({
    required this.name,
    required this.phone,
    this.notes,
  });

  factory CustomerDetailsModel.fromJson(Map<String, dynamic> json) {
    return CustomerDetailsModel(
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      if (notes != null) 'notes': notes,
    };
  }
}

class BookingModel {
  String get bookingDate => date;
  String get startTime => timeSlot;
  CustomerDetailsModel? get customerDetails => customer;
  List<String> get services => serviceNames.isNotEmpty ? serviceNames : (service != null ? [service!.name] : []);
  final String id;
  final String tokenNumber;
  final String? partnerId;
  final String? customerId;
  final ServicePartnerModel? partner;
  final ServiceModel? service;
  final List<String> serviceNames;
  final List<ServiceAddOnModel> selectedAddOns;
  final String date;
  final String timeSlot;
  final int durationMinutes;
  final double totalAmount;
  final double basePrice;
  final double discountAmount;
  final double taxes;
  final String status;
  final String paymentStatus;
  final CustomerDetailsModel? customer;
  final String? notes;
  final DateTime? createdAt;

  const BookingModel({
    required this.id,
    required this.tokenNumber,
    this.partnerId,
    this.customerId,
    this.partner,
    this.service,
    this.serviceNames = const [],
    this.selectedAddOns = const [],
    required this.date,
    required this.timeSlot,
    this.durationMinutes = 30,
    this.totalAmount = 0.0,
    this.basePrice = 0.0,
    this.discountAmount = 0.0,
    this.taxes = 0.0,
    this.status = 'PENDING',
    this.paymentStatus = 'PAY_AT_STORE',
    this.customer,
    this.notes,
    this.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    ServiceModel? serviceObj;
    if (json['service'] is Map) {
      serviceObj = ServiceModel.fromJson(Map<String, dynamic>.from(json['service']));
    }

    ServicePartnerModel? partnerObj;
    if (json['partner'] is Map) {
      partnerObj = ServicePartnerModel.fromJson(Map<String, dynamic>.from(json['partner']));
    }

    CustomerDetailsModel? customerObj;
    if (json['customer'] is Map) {
      customerObj = CustomerDetailsModel.fromJson(Map<String, dynamic>.from(json['customer']));
    }

    List<String> names = [];
    if (json['serviceNames'] is List) {
      names = (json['serviceNames'] as List).map((e) => e.toString()).toList();
    } else if (serviceObj != null) {
      names = [serviceObj.name];
    }

    List<ServiceAddOnModel> addOns = [];
    if (json['selectedAddOns'] is List) {
      addOns = (json['selectedAddOns'] as List)
          .where((e) => e is Map)
          .map((e) => ServiceAddOnModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString().replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    }

    int parseInt(dynamic v, [int def = 30]) {
      if (v == null) return def;
      if (v is num) return v.toInt();
      final m = RegExp(r'\d+').firstMatch(v.toString());
      return m != null ? int.tryParse(m.group(0)!) ?? def : def;
    }

    final idStr = (json['_id'] ?? json['id'] ?? '').toString();
    final token = (json['tokenNumber'] ?? json['token'] ?? (idStr.length >= 6 ? 'TK-${idStr.substring(idStr.length - 6).toUpperCase()}' : 'TK-1001')).toString();

    return BookingModel(
      id: idStr,
      tokenNumber: token,
      partnerId: (json['partnerId'] ?? json['partner_id'])?.toString(),
      customerId: (json['customerId'] ?? json['customer_id'])?.toString(),
      partner: partnerObj,
      service: serviceObj,
      serviceNames: names,
      selectedAddOns: addOns,
      date: json['date']?.toString() ?? '',
      timeSlot: (json['timeSlot'] ?? json['slot'] ?? json['startTime'] ?? '').toString(),
      durationMinutes: parseInt(json['durationMinutes'] ?? json['duration'], 30),
      totalAmount: parseDouble(json['totalAmount'] ?? json['amount'] ?? json['price']),
      basePrice: parseDouble(json['basePrice']),
      discountAmount: parseDouble(json['discountAmount'] ?? json['discount']),
      taxes: parseDouble(json['taxes'] ?? json['tax']),
      status: (json['status']?.toString() ?? 'PENDING').toUpperCase(),
      paymentStatus: (json['paymentStatus']?.toString() ?? 'PAY_AT_STORE').toUpperCase(),
      customer: customerObj,
      notes: json['notes']?.toString(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }
}

class BlockedSlotModel {
  final String id;
  final String date;
  final String startTime;
  final String endTime;
  final String? reason;

  const BlockedSlotModel({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.reason,
  });

  factory BlockedSlotModel.fromJson(Map<String, dynamic> json) {
    return BlockedSlotModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      date: json['date']?.toString() ?? '',
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
      reason: json['reason']?.toString(),
    );
  }
}

class PartnerBookingDashboardModel {
  int get todayAppointmentsCount => confirmedBookings + completedBookings;
  int get inQueueCount => totalBookings > (completedBookings + cancelledBookings) ? totalBookings - completedBookings - cancelledBookings : (confirmedBookings > 0 ? confirmedBookings : totalBookings);
  int get completedCount => completedBookings;
  final int totalBookings;
  final int confirmedBookings;
  final int completedBookings;
  final int cancelledBookings;
  final double totalRevenue;
  final List<BookingModel> recentBookings;

  const PartnerBookingDashboardModel({
    this.totalBookings = 0,
    this.confirmedBookings = 0,
    this.completedBookings = 0,
    this.cancelledBookings = 0,
    this.totalRevenue = 0.0,
    this.recentBookings = const [],
  });

  factory PartnerBookingDashboardModel.fromJson(Map<String, dynamic> json) {
    final rawRecent = json['recentBookings'] ?? json['bookings'] ?? [];
    List<BookingModel> recents = [];
    if (rawRecent is List) {
      recents = rawRecent
          .where((e) => e is Map)
          .map((e) => BookingModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    int parseInt(dynamic v) {
      if (v is num) return v.toInt();
      return int.tryParse(v?.toString() ?? '0') ?? 0;
    }

    double parseDouble(dynamic v) {
      if (v is num) return v.toDouble();
      return double.tryParse(v?.toString() ?? '0') ?? 0.0;
    }

    return PartnerBookingDashboardModel(
      totalBookings: parseInt(json['totalBookings'] ?? json['total']),
      confirmedBookings: parseInt(json['confirmedBookings'] ?? json['confirmed']),
      completedBookings: parseInt(json['completedBookings'] ?? json['completed']),
      cancelledBookings: parseInt(json['cancelledBookings'] ?? json['cancelled']),
      totalRevenue: parseDouble(json['totalRevenue'] ?? json['revenue']),
      recentBookings: recents,
    );
  }
}
