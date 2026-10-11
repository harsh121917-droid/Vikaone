import 'package:flutter/material.dart';

class BusinessLocation {
  final String address;
  final String city;
  final String state;
  final String pincode;

  const BusinessLocation({
    this.address = '',
    required this.city,
    required this.state,
    this.pincode = '',
  });

  factory BusinessLocation.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const BusinessLocation(city: 'India', state: '');
    }
    return BusinessLocation(
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? 'India',
      state: json['state'] as String? ?? '',
      pincode: json['pincode'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'address': address,
    'city': city,
    'state': state,
    'pincode': pincode,
  };

  String get formatted {
    final parts = [city, state].where((s) => s.trim().isNotEmpty).toList();
    return parts.join(', ');
  }
}

class BusinessImage {
  final String url;
  final String caption;
  final bool isCover;

  const BusinessImage({
    required this.url,
    this.caption = '',
    this.isCover = false,
  });

  factory BusinessImage.fromJson(Map<String, dynamic> json) {
    return BusinessImage(
      url: json['url'] as String? ?? '',
      caption: json['caption'] as String? ?? '',
      isCover: json['isCover'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'url': url,
    'caption': caption,
    'isCover': isCover,
  };
}

class BusinessDocument {
  final String url;
  final String title;
  final String type;
  final DateTime? uploadedAt;

  const BusinessDocument({
    required this.url,
    required this.title,
    this.type = 'project_report',
    this.uploadedAt,
  });

  factory BusinessDocument.fromJson(Map<String, dynamic> json) {
    return BusinessDocument(
      url: json['url'] as String? ?? '',
      title: json['title'] as String? ?? 'Project Document',
      type: json['type'] as String? ?? 'project_report',
      uploadedAt: json['uploadedAt'] != null
          ? DateTime.tryParse(json['uploadedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'url': url,
    'title': title,
    'type': type,
    'uploadedAt': uploadedAt?.toIso8601String(),
  };
}

class BusinessModel {
  final String id;
  final String title;
  final String category;
  final BusinessLocation location;
  final String description;
  final double minInvestmentAmount;
  final double totalProjectCost;
  final String investmentTenure;
  final String expectedReturns;
  final String payoutFrequency;
  final List<String> highlights;
  final List<BusinessImage> images;
  final List<BusinessDocument> documents;
  final String spvName;
  final String status;
  final bool isActive;
  final bool featured;
  final int enquiriesCount;
  final DateTime? createdAt;

  const BusinessModel({
    required this.id,
    required this.title,
    required this.category,
    required this.location,
    required this.description,
    required this.minInvestmentAmount,
    required this.totalProjectCost,
    required this.investmentTenure,
    required this.expectedReturns,
    this.payoutFrequency = 'Monthly',
    this.highlights = const [],
    this.images = const [],
    this.documents = const [],
    this.spvName = '',
    this.status = 'active',
    this.isActive = true,
    this.featured = false,
    this.enquiriesCount = 0,
    this.createdAt,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    // Images & Cover parsing
    final rawCover = json['coverImage'] as String?;
    final rawImages = json['images'];
    final List<BusinessImage> imgList = [];
    if (rawImages is List) {
      for (final item in rawImages) {
        if (item is Map<String, dynamic>) {
          imgList.add(BusinessImage.fromJson(item));
        } else if (item is String && item.trim().isNotEmpty) {
          imgList.add(BusinessImage(url: item.trim()));
        }
      }
    }
    if (rawCover != null && rawCover.trim().isNotEmpty) {
      final coverTrim = rawCover.trim();
      final exists = imgList.any((img) => img.url.trim() == coverTrim);
      if (!exists) {
        imgList.insert(0, BusinessImage(url: coverTrim, isCover: true));
      }
    }

    // Documents parsing
    final rawDocs = json['documents'];
    final List<BusinessDocument> docList = [];
    if (rawDocs is List) {
      for (final item in rawDocs) {
        if (item is Map<String, dynamic>) {
          docList.add(BusinessDocument.fromJson(item));
        }
      }
    }

    // Highlights parsing
    final rawHighlights = json['highlights'];
    final List<String> highlightList = [];
    if (rawHighlights is List) {
      for (final item in rawHighlights) {
        if (item != null && item.toString().trim().isNotEmpty) {
          highlightList.add(item.toString().trim());
        }
      }
    }

    return BusinessModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? 'Other Business Opportunities',
      location: BusinessLocation.fromJson(json['location'] as Map<String, dynamic>?),
      description: json['description'] as String? ?? '',
      minInvestmentAmount: (json['minInvestmentAmount'] as num?)?.toDouble() ?? 0.0,
      totalProjectCost: (json['totalProjectCost'] as num?)?.toDouble() ?? 0.0,
      investmentTenure: json['investmentTenure'] as String? ?? '3 Years',
      expectedReturns: json['expectedReturns'] as String? ?? '18% - 24% p.a.',
      payoutFrequency: json['payoutFrequency'] as String? ?? 'Monthly',
      highlights: highlightList,
      images: imgList,
      documents: docList,
      spvName: json['spvName'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      isActive: json['isActive'] as bool? ?? true,
      featured: json['featured'] as bool? ?? false,
      enquiriesCount: (json['enquiriesCount'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'title': title,
    'category': category,
    'location': location.toJson(),
    'description': description,
    'minInvestmentAmount': minInvestmentAmount,
    'totalProjectCost': totalProjectCost,
    'investmentTenure': investmentTenure,
    'expectedReturns': expectedReturns,
    'payoutFrequency': payoutFrequency,
    'highlights': highlights,
    'images': images.map((i) => i.toJson()).toList(),
    'documents': documents.map((d) => d.toJson()).toList(),
    'spvName': spvName,
    'status': status,
    'isActive': isActive,
    'featured': featured,
  };

  // ── Helper Getters ──
  List<String> get allImageUrls {
    final Set<String> urls = {};
    if (coverImage.trim().isNotEmpty) urls.add(coverImage.trim());
    for (final img in images) {
      if (img.url.trim().isNotEmpty) urls.add(img.url.trim());
    }
    return urls.isNotEmpty ? urls.toList() : [coverImage];
  }

  int get photosCount => allImageUrls.length;
  String get coverImage {
    if (images.isNotEmpty) {
      final cover = images.firstWhere((img) => img.isCover, orElse: () => images.first);
      if (cover.url.isNotEmpty) return cover.url;
    }
    // Fallback based on category
    switch (category) {
      case 'Warehouses & Logistics':
        return 'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?auto=format&fit=crop&w=1000&q=80';
      case 'Petrol Pumps':
        return 'https://images.unsplash.com/photo-1545459720-aac8509eb02c?auto=format&fit=crop&w=1000&q=80';
      case 'Dairy Farms':
        return 'https://images.unsplash.com/photo-1527153857715-3908f2ae5e81?auto=format&fit=crop&w=1000&q=80';
      case 'Hotels & Hospitality':
        return 'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=1000&q=80';
      case 'CBG (Compressed Biogas) Plants':
        return 'https://images.unsplash.com/photo-1509391365360-2e959784a276?auto=format&fit=crop&w=1000&q=80';
      default:
        return 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?auto=format&fit=crop&w=1000&q=80';
    }
  }

  String get formattedMinInvestment {
    if (minInvestmentAmount >= 10000000) {
      return '₹${(minInvestmentAmount / 10000000).toStringAsFixed(2)} Cr';
    } else if (minInvestmentAmount >= 100000) {
      final val = minInvestmentAmount / 100000;
      return '₹${val == val.roundToDouble() ? val.toInt() : val.toStringAsFixed(1)} Lakh';
    } else if (minInvestmentAmount >= 1000) {
      return '₹${(minInvestmentAmount / 1000).toStringAsFixed(0)}K';
    }
    return '₹${minInvestmentAmount.toStringAsFixed(0)}';
  }

  String get formattedTotalCost {
    if (totalProjectCost >= 10000000) {
      return '₹${(totalProjectCost / 10000000).toStringAsFixed(2)} Cr';
    } else if (totalProjectCost >= 100000) {
      return '₹${(totalProjectCost / 100000).toStringAsFixed(2)} Lakh';
    }
    return '₹${totalProjectCost.toStringAsFixed(0)}';
  }

  IconData get categoryIcon {
    switch (category) {
      case 'Warehouses & Logistics':
        return Icons.warehouse_rounded;
      case 'Petrol Pumps':
        return Icons.local_gas_station_rounded;
      case 'Dairy Farms':
        return Icons.agriculture_rounded;
      case 'Hotels & Hospitality':
        return Icons.hotel_rounded;
      case 'CBG (Compressed Biogas) Plants':
        return Icons.eco_rounded;
      default:
        return Icons.business_center_rounded;
    }
  }

  Color get categoryColor {
    switch (category) {
      case 'Warehouses & Logistics':
        return const Color(0xFF00D2FF);
      case 'Petrol Pumps':
        return const Color(0xFFF59E0B);
      case 'Dairy Farms':
        return const Color(0xFF10B981);
      case 'Hotels & Hospitality':
        return const Color(0xFFA855F7);
      case 'CBG (Compressed Biogas) Plants':
        return const Color(0xFF14B8A6);
      default:
        return const Color(0xFF3B82F6);
    }
  }
}
