class ImageResponse {
  final bool error;
  final List<String> images;

  ImageResponse({required this.error, required this.images});

  factory ImageResponse.fromJson(Map<String, dynamic> json) {
    return ImageResponse(
      error: json['error'],
      images: List<String>.from(json['images']),
    );
  }
}
