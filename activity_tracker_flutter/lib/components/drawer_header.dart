import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

class DrawerHeaderCard extends StatefulWidget {
  final String? profileImageUrl;
  final String username;
  final String nickname;

  const DrawerHeaderCard({super.key, required this.profileImageUrl, required this.username, required this.nickname});

  @override
  State<DrawerHeaderCard> createState() => _DrawerHeaderCardState();
}

class _DrawerHeaderCardState extends State<DrawerHeaderCard> {
  static final Map<String, List<Color>> _colorCache = {};

  static const Color defaultColor1 = Colors.blue;
  static const Color defaultColor2 = Colors.lightBlueAccent;

  late Future<List<Color>> _colorsFuture;

  @override
  void initState() {
    super.initState();
    _colorsFuture = _extractColors();
  }

  // Checks if the widget has updated
  @override
  void didUpdateWidget(DrawerHeaderCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.profileImageUrl != oldWidget.profileImageUrl) {
      _colorsFuture = _extractColors();
    }
  }

  // Extracts the colors from the profile image
  Future<List<Color>> _extractColors() async {
    final url = widget.profileImageUrl;
    if (url == null || url.isEmpty) {
      return [defaultColor1, defaultColor2];
    }

    // Checks in the cache if the image url has changed
    if (_colorCache.containsKey(url)) {
      return _colorCache[url]!;
    }

    try {
      // Sets the colors and saves them in cache
      final palette = await PaletteGenerator.fromImageProvider(
        NetworkImage(url),
        size: const Size(50, 50),
        maximumColorCount: 5,
      );

      final c1 = palette.colors.isNotEmpty ? palette.colors.first : defaultColor1;
      final c2 = palette.colors.length > 1 ? palette.colors.elementAt(1) : defaultColor2;

      final result = [c1, c2];
      _colorCache[url] = result;

      return result;
    } catch (_) {
      return [defaultColor1, defaultColor2];
    }
  }

  // Darkens the colors (used in dark mode)
  Color _darken(Color color, [double amount = 0.25]) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  Color _getTextColor(Color background) {
    final brightness = background.computeLuminance();
    return brightness > 0.5 ? Colors.black : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<List<Color>>(
      future: _colorsFuture,
      builder: (context, snapshot) {
        final colors = snapshot.data ?? [defaultColor1, defaultColor2];
        final color1 = isDark ? _darken(colors[0]) : colors[0];
        final color2 = isDark ? _darken(colors[1]) : colors[1];

        // User profile container
        return Container(
          height: 200,
          padding: const EdgeInsets.only(top: 50, bottom: 16, left: 16, right: 16),

          child: CustomPaint(
            painter: DiagonalBackgroundPainter(color1, color2),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(25)),

              child: Row(
                // Avatar
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: widget.profileImageUrl != null && widget.profileImageUrl!.isNotEmpty
                        ? NetworkImage(widget.profileImageUrl!)
                        : null,
                    backgroundColor: Colors.grey.shade600,
                    child: widget.profileImageUrl == null || widget.profileImageUrl!.isEmpty
                        ? const Icon(Icons.person, size: 32, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 16),

                  // App name, username and nickname
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App name
                      Text(
                        'Activity Tracker',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _getTextColor(color1)),
                      ),
                      const SizedBox(height: 5),

                      // Nickname
                      Text(
                        widget.nickname,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: _getTextColor(color1)),
                      ),

                      // Username
                      Text(
                        '@${widget.username}',
                        style: TextStyle(fontSize: 14, color: _getTextColor(color1).withValues(alpha: 0.8)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class DiagonalBackgroundPainter extends CustomPainter {
  final Color color1;
  final Color color2;

  DiagonalBackgroundPainter(this.color1, this.color2);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    const borderRadius = Radius.circular(20);

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    paint.shader = LinearGradient(
      begin: Alignment.bottomLeft,
      end: Alignment.bottomRight,
      colors: [color1, color2],
    ).createShader(rect);

    final mainRect = RRect.fromRectAndRadius(rect, borderRadius);
    canvas.drawRRect(mainRect, paint);
  }

  @override
  bool shouldRepaint(covariant DiagonalBackgroundPainter oldDelegate) {
    return oldDelegate.color1 != color1 || oldDelegate.color2 != color2;
  }
}
