import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

const Color kPrimaryGreen = Color(0xFF4C7D4D);

class ImageCarousel extends StatelessWidget {
  final List<String> imageUrls;
  final double height;
  final bool autoPlay;

  const ImageCarousel({
    Key? key,
    required this.imageUrls,
    this.height = 200.0,
    this.autoPlay = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    return CarouselSlider(
      options: CarouselOptions(
        height: height,
        autoPlay: autoPlay,
        enlargeCenterPage: true,
        viewportFraction: 0.9,
      ),
      items: imageUrls.map((url) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 8,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                FadeInImage(
                  placeholder: const AssetImage('assets/placeholder.png'),
                  image: NetworkImage(url),
                  fit: BoxFit.cover,
                  imageErrorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  placeholderErrorBuilder: (context, error, stackTrace) =>
                      Container(
                        color:
                            Colors.grey.shade200, // Color shown while loading
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: kPrimaryGreen,
                          ),
                        ),
                      ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 80, // Height of the gradient
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
