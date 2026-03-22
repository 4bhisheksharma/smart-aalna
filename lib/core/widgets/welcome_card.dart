import 'package:flutter/material.dart';

class WelcomeCard extends StatelessWidget {
  final String userName;
  final String greeting;
  final String message;
  final VoidCallback? onTap;

  const WelcomeCard({
    super.key,
    required this.userName,
    this.greeting = 'Welcome back',
    this.message = 'Ready to make today productive and calm?',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF090909), Color(0xFF1A1A1A), Color(0xFF2A2A2A)],
              stops: [0.0, 0.55, 1.0],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x44000000),
                offset: Offset(0, 14),
                blurRadius: 28,
                spreadRadius: -8,
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -16,
                top: -18,
                child: _GlowCircle(
                  size: 110,
                  color: Colors.white.withOpacity(0.18),
                ),
              ),
              Positioned(
                left: -20,
                bottom: -26,
                child: _GlowCircle(
                  size: 90,
                  color: Colors.white.withOpacity(0.16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: const Icon(
                        Icons.waving_hand_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$greeting,',
                            style: const TextStyle(
                              color: Color(0xFFD9D9D9),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              height: 1.05,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            message,
                            style: const TextStyle(
                              color: Color(0xFFE8E8E8),
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                          if (onTap != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                'Tap to continue',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}
