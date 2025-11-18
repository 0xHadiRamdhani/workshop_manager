import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Widget untuk efek shimmer loading
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;

  const ShimmerLoading({
    super.key,
    required this.child,
    required this.isLoading,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                CupertinoColors.systemGrey.withOpacity(0.3),
                CupertinoColors.systemGrey.withOpacity(0.1),
                CupertinoColors.systemGrey.withOpacity(0.3),
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Widget untuk card informasi dengan efek hover dan animasi
class InfoCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final String content;

  const InfoCard({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.content,
  });

  @override
  State<InfoCard> createState() => _InfoCardState();
}

class _InfoCardState extends State<InfoCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<Color?> _borderColorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _elevationAnimation = Tween<double>(
      begin: 0.0,
      end: 12.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _borderColorAnimation = ColorTween(
      begin: CupertinoColors.systemGrey.withOpacity(0.2),
      end: widget.iconColor.withOpacity(0.5),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: CupertinoColors.darkBackgroundGray.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _borderColorAnimation.value!,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.iconColor.withOpacity(0.1),
                    blurRadius: _elevationAnimation.value,
                    offset: Offset(0, _elevationAnimation.value / 2),
                    spreadRadius: _elevationAnimation.value / 4,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: widget.iconColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          widget.icon,
                          color: widget.iconColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.content,
                    style: const TextStyle(
                      fontSize: 16,
                      color: CupertinoColors.systemGrey,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class AboutSchoolScreen extends StatefulWidget {
  const AboutSchoolScreen({super.key});

  @override
  State<AboutSchoolScreen> createState() => _AboutSchoolScreenState();
}

class _AboutSchoolScreenState extends State<AboutSchoolScreen> {
  late ScrollController _scrollController;
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    _scrollController.addListener(() {
      if (mounted) {
        setState(() {
          _scrollOffset = _scrollController.offset;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Tentang Sekolah'),
        backgroundColor: CupertinoColors.darkBackgroundGray,
        border: const Border(
          bottom: BorderSide(color: CupertinoColors.systemGrey4, width: 0.5),
        ),
        leading: IconButton(
          onPressed: () {
            final scaffoldState = Scaffold.maybeOf(context);
            if (scaffoldState != null && scaffoldState.hasDrawer) {
              scaffoldState.openDrawer();
            }
          },
          icon: const Icon(CupertinoIcons.bars),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan animasi
              _buildHeaderSection(),

              const SizedBox(height: 32),

              // Informasi sekolah
              _buildSchoolInfoSection(),

              const SizedBox(height: 24),

              // Program keahlian
              _buildProgramsSection(),

              const SizedBox(height: 24),

              // Visi & Misi
              _buildVisionMissionSection(),

              const SizedBox(height: 24),

              // Kontak & Alamat
              _buildContactSection(),

              const SizedBox(height: 32),

              // Footer
              _buildFooterSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    // Efek parallax berdasarkan scroll offset
    final parallaxOffset = _scrollOffset * 0.2;
    final scaleEffect = 1.0 - (_scrollOffset * 0.0003).clamp(0.0, 0.05);

    return Transform.translate(
      offset: Offset(0, parallaxOffset),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              CupertinoColors.systemBlue.withOpacity(0.8),
              CupertinoColors.systemPurple.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Animasi scale pada Lottie
            Transform.scale(
              scale: scaleEffect,
              child: Lottie.asset(
                'assets/school.json',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'STM BANI MASUM',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.white,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sekolah Teknik Menengah Unggulan',
              style: TextStyle(
                fontSize: 18,
                color: CupertinoColors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Versi 2.0.0',
              style: TextStyle(
                fontSize: 14,
                color: CupertinoColors.systemGrey2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchoolInfoSection() {
    return _buildInfoCard(
      'Tentang Sekolah',
      CupertinoIcons.info_circle,
      CupertinoColors.systemBlue,
      'STM Bani Masum adalah sekolah teknik menengah unggulan yang berfokus pada bidang teknik komputer dan teknik sepeda motor. Terletak di Cisalak, Subang, sekolah ini memiliki komitmen untuk menghasilkan lulusan yang berkualitas dan siap bersaing di dunia kerja.',
    );
  }

  Widget _buildProgramsSection() {
    return Column(
      children: [
        _buildInfoCard(
          'Program Keahlian',
          CupertinoIcons.book,
          CupertinoColors.systemGreen,
          '• Teknik Komputer dan Jaringan (TKJ)\n'
              '• Teknik Sepeda Motor (TSM)\n'
              '• Rekayasa Perangkat Lunak (RPL)\n'
              '• Teknik Kendaraan Ringan (TKR)',
        ),
        const SizedBox(height: 20),
        Center(
          child: Lottie.asset(
            'assets/teamwork.json',
            width: 100,
            height: 100,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  Widget _buildVisionMissionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoCard(
          'Visi',
          CupertinoIcons.eye,
          CupertinoColors.systemOrange,
          'Menjadi sekolah teknik menengah yang unggul dalam menghasilkan tenaga kerja profesional di bidang teknologi dan industri.',
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          'Misi',
          CupertinoIcons.flag,
          CupertinoColors.systemRed,
          '1. Menyelenggarakan pendidikan kejuruan yang berkualitas\n'
              '2. Mengembangkan potensi peserta didik secara optimal\n'
              '3. Menjalin kerjasama dengan dunia industri\n'
              '4. Menerapkan teknologi pembelajaran yang inovatif',
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return _buildInfoCard(
      'Kontak & Alamat',
      CupertinoIcons.location,
      CupertinoColors.systemPurple,
      '📍 Jl. Raya Cisalak No. 123, Kec. Cisalak, Kab. Subang\n'
          '📞 (0260) 123456\n'
          '📧 info@stmbanimasum.sch.id\n'
          '🌐 www.stmbanimasum.sch.id\n\n'
          '🕒 Senin - Jumat: 07.00 - 16.00 WIB\n'
          '🕒 Sabtu: 07.00 - 12.00 WIB',
    );
  }

  Widget _buildFooterSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CupertinoColors.darkBackgroundGray.withOpacity(0.7),
            CupertinoColors.darkBackgroundGray.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: CupertinoColors.systemGrey.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icon dengan efek animasi
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CupertinoColors.systemGreen.withOpacity(0.1),
              border: Border.all(
                color: CupertinoColors.systemGreen.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              CupertinoIcons.checkmark_shield_fill,
              color: CupertinoColors.systemGreen,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Copyright © 2025 STM Bani Masum',
            style: TextStyle(
              fontSize: 14,
              color: CupertinoColors.systemGrey,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            'All rights reserved',
            style: TextStyle(
              fontSize: 12,
              color: CupertinoColors.systemGrey2,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  CupertinoColors.systemGreen.withOpacity(0.15),
                  CupertinoColors.systemGreen.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: CupertinoColors.systemGreen.withOpacity(0.4),
                width: 1,
              ),
            ),
            child: const Text(
              'Licensed under MIT License',
              style: TextStyle(
                fontSize: 12,
                color: CupertinoColors.systemGreen,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Tambahan informasi
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.heart_fill,
                  color: CupertinoColors.systemRed,
                  size: 16,
                ),
                SizedBox(width: 6),
                Text(
                  'Dikembangkan dengan ❤️ untuk pendidikan',
                  style: TextStyle(
                    fontSize: 11,
                    color: CupertinoColors.systemGrey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    String title,
    IconData icon,
    Color iconColor,
    String content,
  ) {
    return InfoCard(
      title: title,
      icon: icon,
      iconColor: iconColor,
      content: content,
    );
  }
}
