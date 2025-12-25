import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AnimatedCarousel extends StatefulWidget {
  const AnimatedCarousel({super.key});

  @override
  State<AnimatedCarousel> createState() => _AnimatedCarouselState();
}

class _AnimatedCarouselState extends State<AnimatedCarousel>
    with TickerProviderStateMixin {
  // -------- IMAGES --------
  final List<String> images = [
    "assets/images/roman-kraft-_Zua2hyvTBk-unsplash.jpg",
    "assets/images/kyle-loftus-_jg3dKZs6sg-unsplash.jpg",
    "assets/images/austin-distel-VCFxt2yT1eQ-unsplash.jpg",
  ];

  final List<String> texts = [
    "Welcome to our site",
    "Amazing Services",
    "Contact Us Anytime",
  ];

  int currentIndex = 0;

  late PageController imageController;
  // late Timer autoTimer;

  // virtual infinite carousel
  late int virtualLength;
  late int initialPage;

  // -------- TEXT ANIMATION --------
  late AnimationController textController;
  late Animation<Offset> textIn;
  late Animation<Offset> textOut;
  late Animation<double> fadeIn;
  late Animation<double> fadeOut;

  @override
  void initState() {
    super.initState();

    // -------- INFINITE IMAGES SETTINGS --------
    virtualLength = images.length * 1000;
    initialPage = images.length * 500;
    imageController = PageController(initialPage: initialPage);

    // -------- TEXT CONTROLLER ---------
    textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Slide In from left → center-left
    textIn = Tween<Offset>(begin: const Offset(-1.5, 0), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: textController,
            curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
          ),
        );

    // Slide Out upward
    textOut = Tween<Offset>(begin: Offset.zero, end: const Offset(0, -1.0))
        .animate(
          CurvedAnimation(
            parent: textController,
            curve: const Interval(0.55, 1.0, curve: Curves.easeIn),
          ),
        );

    // Fade In
    fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: textController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
      ),
    );

    // Fade Out
    fadeOut = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: textController,
        curve: const Interval(0.55, 1.0, curve: Curves.easeIn),
      ),
    );

    // -------- WHEN TEXT FINISHES OUT → CHANGE SLIDE --------
    textController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        currentIndex = (currentIndex + 1) % images.length;

        imageController.nextPage(
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeInOut,
        );

        Future.delayed(const Duration(milliseconds: 100), () {
          textController.reset();
          textController.forward();
        });
      }
    });

    // Start Immediately
    textController.forward();

    // AUTO SLIDE
    // autoTimer = Timer.periodic(const Duration(seconds: 4), (_) {
    //   textController.reset();
    //   textController.forward();
    // });
  }

  @override
  void dispose() {
    // autoTimer.cancel();
    imageController.dispose();
    textController.dispose();
    super.dispose();
  }

  Widget _buildErrorWidget(String imagePath, {String? error}) {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 8),
            Text('Failed to load image'),
            if (error != null) ...[
              const SizedBox(height: 4),
              Text(error, style: const TextStyle(fontSize: 10)),
            ],
            const SizedBox(height: 4),
            Text(imagePath, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500,
      child: Stack(
        children: [
          // -------- INFINITE IMAGES CAROUSEL --------
          PageView.builder(
            controller: imageController,
            itemCount: virtualLength,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final realIndex = index % images.length;

              return FutureBuilder<ByteData>(
                future: rootBundle.load(images[realIndex]),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Image.memory(
                      snapshot.data!.buffer.asUint8List(),
                      fit: BoxFit.cover,
                      width: double.infinity,
                    );
                  } else if (snapshot.hasError) {
                    return _buildErrorWidget(
                      images[realIndex],
                      error: snapshot.error.toString(),
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              );
            },
          ),

          // -------- TEXT --------
          AnimatedBuilder(
            animation: textController,
            builder: (context, child) {
              final isIn = textController.value < 0.5;

              final offset = isIn ? textIn.value : textOut.value;
              final opacity = isIn ? fadeIn.value : fadeOut.value;

              return Opacity(
                opacity: opacity,
                child: Transform.translate(
                  offset: Offset(offset.dx * 120, offset.dy * 80),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 32),
                      child: Text(
                        texts[currentIndex],
                        style: const TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              blurRadius: 4,
                              color: Colors.black,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
