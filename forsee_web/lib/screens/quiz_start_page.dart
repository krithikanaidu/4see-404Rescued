import 'package:flutter/material.dart';

void main() {
  runApp(const QuizStartPage());
}

class QuizStartPage extends StatelessWidget {
  const QuizStartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Mind & Mood',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Georgia',
      ),
      home: const QuizStartScreen(),
    );
  }
}

class QuizCategory {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const QuizCategory({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

class QuizStartScreen extends StatefulWidget {
  const QuizStartScreen({super.key});

  @override
  State<QuizStartScreen> createState() => _QuizStartScreenState();
}

class _QuizStartScreenState extends State<QuizStartScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late List<AnimationController> _cardControllers;

  int _hoveredIndex = -1;
  int _selectedNav = 0;

  final List<QuizCategory> categories = const [
    QuizCategory(
      title: 'Focus &\nEnergy',
      subtitle: 'ADHD Patterns',
      icon: Icons.bolt,
      color: Color(0xFF8B5E6B),
    ),
    QuizCategory(
      title: 'Mood &\nMotivation',
      subtitle: 'Depression Patterns',
      icon: Icons.sentiment_satisfied_alt,
      color: Color(0xFF7A4F5C),
    ),
    QuizCategory(
      title: 'Reading &\nWords',
      subtitle: 'Dyslexia Patterns',
      icon: Icons.menu_book,
      color: Color(0xFF9B6F7A),
    ),
    QuizCategory(
      title: 'Worry &\nStress',
      subtitle: 'ADHD Patterns',
      icon: Icons.favorite_border,
      color: Color(0xFF6B4A54),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();

    _cardControllers = List.generate(
      4,
      (i) => AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      ),
    );

    for (int i = 0; i < _cardControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 200 + i * 120), () {
        if (mounted) _cardControllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    for (final c in _cardControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 1100;

    return Scaffold(
      backgroundColor: const Color(0xFF2D1A20),
      body: Row(
        children: [
          // Sidebar Navigation
          _buildSidebar(),

          // Main Content
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF3D2028),
                    Color(0xFF2D1A20),
                    Color(0xFF251520),
                  ],
                ),
              ),
              child: FadeTransition(
                opacity: _fadeController,
                child: Column(
                  children: [
                    _buildTopBar(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: isWide ? 80 : 40,
                          vertical: 40,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(),
                            const SizedBox(height: 40),
                            _buildInfoCard(),
                            const SizedBox(height: 48),
                            _buildCategoriesGrid(isWide),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    final navItems = [
      Icons.home_rounded,
      Icons.swap_horiz_rounded,
      Icons.school_rounded,
      Icons.settings_rounded,
    ];

    return Container(
      width: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1015),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 32),
          // Logo
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF8B5E6B),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.psychology, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 48),
          ...navItems.asMap().entries.map((entry) {
            final i = entry.key;
            final icon = entry.value;
            final isSelected = _selectedNav == i;
            return GestureDetector(
              onTap: () => setState(() => _selectedNav = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF8B5E6B).withOpacity(0.3)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(color: const Color(0xFF8B5E6B), width: 1.5)
                      : null,
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? const Color(0xFFD4A0AE)
                      : Colors.white.withOpacity(0.3),
                  size: 22,
                ),
              ),
            );
          }),
          const Spacer(),
          // Profile
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(bottom: 28),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF5A3540),
              border: Border.all(
                color: const Color(0xFF8B5E6B),
                width: 2,
              ),
            ),
            child: const Icon(Icons.person, color: Color(0xFFD4A0AE), size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.06),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            'quiz-start',
            style: TextStyle(
              color: Colors.white.withOpacity(0.25),
              fontSize: 12,
              letterSpacing: 2,
              fontFamily: 'Courier',
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5E6B).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF8B5E6B).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.circle, color: Color(0xFF7BC67E), size: 8),
                const SizedBox(width: 8),
                Text(
                  'Session Active',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOutCubic,
      )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A0AE),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 20),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Mind',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                      letterSpacing: -1,
                    ),
                  ),
                  Text(
                    '& Mood',
                    style: TextStyle(
                      color: Color(0xFFD4A0AE),
                      fontSize: 48,
                      fontWeight: FontWeight.w300,
                      height: 1.1,
                      letterSpacing: -1,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _slideController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      )),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: const Color(0xFFB07A8A).withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFD4A0AE).withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5E6B).withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.info_outline,
                color: Color(0xFFD4A0AE),
                size: 24,
              ),
            ),
            const SizedBox(width: 20),
            const Expanded(
              child: Text(
                'There are no right or wrong answers. This is just a tool to help you understand your own brain better. Read each statement and decide if it sounds like you.',
                style: TextStyle(
                  color: Color(0xFFE8C8D0),
                  fontSize: 15,
                  height: 1.6,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid(bool isWide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECT A CATEGORY',
          style: TextStyle(
            color: Colors.white.withOpacity(0.3),
            fontSize: 11,
            letterSpacing: 3,
            fontFamily: 'Courier',
          ),
        ),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isWide ? 4 : 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: isWide ? 0.9 : 1.0,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return AnimatedBuilder(
              animation: _cardControllers[index],
              builder: (context, child) {
                final anim = CurvedAnimation(
                  parent: _cardControllers[index],
                  curve: Curves.easeOutBack,
                );
                return FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.4),
                      end: Offset.zero,
                    ).animate(anim),
                    child: _buildCategoryCard(index),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategoryCard(int index) {
    final category = categories[index];
    final isHovered = _hoveredIndex == index;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = -1),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Starting: ${category.title.replaceAll('\n', ' ')}'),
              backgroundColor: category.color,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()
            ..translate(0.0, isHovered ? -8.0 : 0.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                category.color.withOpacity(isHovered ? 0.95 : 0.8),
                category.color.withOpacity(isHovered ? 0.75 : 0.6),
              ],
            ),
            border: Border.all(
              color: isHovered
                  ? Colors.white.withOpacity(0.3)
                  : Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: category.color.withOpacity(isHovered ? 0.5 : 0.2),
                blurRadius: isHovered ? 30 : 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    category.icon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),

                // Text
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        category.subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),

                // Arrow
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(isHovered ? 0.3 : 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white.withOpacity(0.9),
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}