class HomeVideoModel {
  final String id;
  final String title;
  final String subtitle;
  final String youtubeUrl;
  final String youtubeVideoId;
  final String? thumbnailUrl;
  final int order;
  final bool isActive;
  final DateTime? createdAt;

  const HomeVideoModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.youtubeUrl,
    required this.youtubeVideoId,
    this.thumbnailUrl,
    this.order = 0,
    this.isActive = true,
    this.createdAt,
  });

  String get effectiveThumbnail {
    if (thumbnailUrl != null && thumbnailUrl!.trim().isNotEmpty) {
      return thumbnailUrl!.trim();
    }
    return 'https://img.youtube.com/vi/$youtubeVideoId/hqdefault.jpg';
  }

  factory HomeVideoModel.fromJson(Map<String, dynamic> json) {
    return HomeVideoModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      youtubeUrl: json['youtubeUrl']?.toString() ?? '',
      youtubeVideoId: json['youtubeVideoId']?.toString() ?? '',
      thumbnailUrl: json['thumbnailUrl']?.toString(),
      order: (json['order'] is num) ? (json['order'] as num).toInt() : 0,
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'youtubeUrl': youtubeUrl,
    'youtubeVideoId': youtubeVideoId,
    'thumbnailUrl': thumbnailUrl,
    'order': order,
    'isActive': isActive,
    'createdAt': createdAt?.toIso8601String(),
  };
}
