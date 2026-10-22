import 'package:flutter/material.dart';
import '../design/bagi_porsi_theme.dart';

class Peta extends StatelessWidget {
  const Peta({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.location_on_outlined, size: 25),
            SizedBox(width: 10),
            Text('Peta Restoran', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari makanan di sekitarmu...',
                      hintStyle: const TextStyle(fontSize: 14),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: BagiPorsiColors.green,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 17),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(17),
                        borderSide: const BorderSide(
                          color: BagiPorsiColors.border,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                IconButton.filledTonal(
                  tooltip: 'Filter peta',
                  onPressed: () {},
                  style: IconButton.styleFrom(
                    backgroundColor: BagiPorsiColors.mint,
                    foregroundColor: BagiPorsiColors.green,
                    minimumSize: const Size(48, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.tune),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomPaint(painter: _MapPreviewPainter()),
                    for (final position in const [
                      Alignment(-0.40, -0.70),
                      Alignment(0.55, -0.34),
                      Alignment(-0.35, 0.35),
                      Alignment(0.57, 0.75),
                      Alignment(-0.77, -0.02),
                    ])
                      Align(
                        alignment: position,
                        child: const CircleAvatar(
                          radius: 18,
                          backgroundColor: BagiPorsiColors.green,
                          child: Icon(
                            Icons.location_on_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    Center(
                      child: Container(
                        width: 310,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(17),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x22173D30),
                              blurRadius: 12,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Area Google Maps API',
                              style: TextStyle(
                                color: BagiPorsiColors.ink,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Integrasi menyusul',
                              style: TextStyle(
                                color: BagiPorsiColors.muted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(16, 18, 16, 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: BagiPorsiColors.mint,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 23,
                  backgroundColor: BagiPorsiColors.green,
                  child: Icon(Icons.location_on_outlined, color: Colors.white),
                ),
                SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '5 tempat di radius 2 km',
                        style: TextStyle(
                          color: BagiPorsiColors.ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Tarik ke atas untuk melihat daftar',
                        style: TextStyle(
                          color: BagiPorsiColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPreviewPainter extends CustomPainter {
  const _MapPreviewPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFE9F2ED),
    );
    final park = Paint()..color = const Color(0xFFD7E8D2);
    for (final rect in [
      Rect.fromLTWH(size.width * .22, size.height * .05, size.width * .30, size.height * .11),
      Rect.fromLTWH(size.width * .68, size.height * .25, size.width * .25, size.height * .17),
      Rect.fromLTWH(size.width * .22, size.height * .56, size.width * .29, size.height * .17),
      Rect.fromLTWH(size.width * .68, size.height * .84, size.width * .23, size.height * .12),
    ]) {
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(12)), park);
    }
    final road = Paint()..color = Colors.white;
    final roadWidth = size.width * .05;
    for (final x in [size.width * .12, size.width * .59]) {
      canvas.drawRect(Rect.fromLTWH(x, 0, roadWidth, size.height), road);
    }
    for (final y in [size.height * .19, size.height * .48, size.height * .78]) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, roadWidth), road);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
