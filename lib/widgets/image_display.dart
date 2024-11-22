import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageDisplay extends StatelessWidget {
  final String ref;

  const ImageDisplay({required this.ref, Key? key}) : super(key: key);

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          placeholder: (context, url) =>
              Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) =>
              Center(child: Icon(Icons.error)),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GestureDetector(
          onTap: () => _showImageDialog(
            context,
            "http://124.43.128.239/ApiOrchid/ImageApi/uploads/$ref/${ref}_REP1.png",
          ),
          child: Container(
            height: 150,
            width: 150,
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.image,
                    size: 100,
                    color: Colors.grey[300],
                  ),
                ),
                CachedNetworkImage(
                  imageUrl:
                      "http://124.43.128.239/ApiOrchid/ImageApi/uploads/$ref/${ref}_REP1.png",
                  placeholder: (context, url) =>
                      Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) =>
                      Center(child: Icon(Icons.error)),
                  fit: BoxFit.cover,
                  width: 120,
                  height: 150,
                ),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () => _showImageDialog(
            context,
            "http://124.43.128.239/ApiOrchid/ImageApi/uploads/$ref/${ref}_REP2.png",
          ),
          child: Container(
            height: 150,
            width: 150,
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.image,
                    size: 100,
                    color: Colors.grey[300],
                  ),
                ),
                CachedNetworkImage(
                  imageUrl:
                      "http://124.43.128.239/ApiOrchid/ImageApi/uploads/$ref/${ref}_REP2.png",
                  placeholder: (context, url) =>
                      Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) =>
                      Center(child: Icon(Icons.error)),
                  fit: BoxFit.cover,
                  width: 120,
                  height: 150,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:cached_network_image/cached_network_image.dart';

// class ImageDisplay extends StatelessWidget {
//   final String ref;

//   const ImageDisplay({required this.ref, Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         CachedNetworkImage(
//           imageUrl:
//               "http://124.43.128.239/ApiOrchid/ImageApi/uploads/$ref/${ref}_REP1.png",
//           placeholder: (context, url) => CircularProgressIndicator(),
//           errorWidget: (context, url, error) => Icon(Icons.error),
//         ),
//         SizedBox(height: 10), // Add some spacing between the images
//         CachedNetworkImage(
//           imageUrl:
//               "http://124.43.128.239/ApiOrchid/ImageApi/uploads/$ref/${ref}_REP2.png",
//           placeholder: (context, url) => CircularProgressIndicator(),
//           errorWidget: (context, url, error) => Icon(Icons.error),
//         ),
//       ],
//     );
//   }
// }
