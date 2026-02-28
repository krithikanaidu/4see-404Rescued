import 'package:flutter/material.dart';
import 'report_page.dart';
import 'student_profile_page.dart';

void main() {
  runApp(const QuizStartPage());
}

class QuizStartPage extends StatelessWidget {
  final bool showSidebar;
  const QuizStartPage({super.key, this.showSidebar = true});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Mind & Mood',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Georgia',
      ),
      home: QuizStartScreen(showSidebar: showSidebar),
    );
  }
}

// ─── Quiz Question Screen ─────────────────────────────────────────────────────

class QuizQuestionScreen extends StatefulWidget {
  final QuizCategory category;
  final List<QuizQuestion> questions;

  const QuizQuestionScreen({
    super.key,
    required this.category,
    required this.questions,
  });

  @override
  State<QuizQuestionScreen> createState() => _QuizQuestionScreenState();
}

class _QuizQuestionScreenState extends State<QuizQuestionScreen> {
  int _currentIndex = 0;
  List<int?> _answers = [];
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _answers = List.filled(widget.questions.length, null);
  }

  int get _totalScore {
    int score = 0;
    for (int i = 0; i < _answers.length; i++) {
      if (_answers[i] != null) {
        score += widget.questions[i].scores[_answers[i]!];
      }
    }
    return score;
  }

  void _nextQuestion() {
    if (_currentIndex < widget.questions.length - 1) {
      setState(() => _currentIndex++);
    } else {
      setState(() => _isFinished = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isFinished) {
      return _buildResults();
    }

    final question = widget.questions[_currentIndex];
    final progress = (_currentIndex + 1) / widget.questions.length;

    return Scaffold(
      backgroundColor: const Color(0xFF2D1A20),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              widget.category.color.withOpacity(0.2),
              const Color(0xFF2D1A20),
              const Color(0xFF1A1014),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopNav(),
              const SizedBox(height: 20),
              // Progress Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Question ${_currentIndex + 1} of ${widget.questions.length}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: TextStyle(
                            color: widget.category.color,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Stack(
                      children: [
                        Container(
                          height: 6,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOutCubic,
                          height: 6,
                          width: MediaQuery.of(context).size.width * (0.8 * progress),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [widget.category.color, widget.category.color.withOpacity(0.6)],
                            ),
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: [
                              BoxShadow(
                                color: widget.category.color.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Question Card
              _buildQuestionCard(question),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopNav() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.05),
              padding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(width: 20),
          Text(
            widget.category.title.replaceAll('\n', ' '),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(QuizQuestion question) {
    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth > 800;
      return Container(
        width: 800,
        margin: EdgeInsets.symmetric(horizontal: isWide ? 40 : 20),
        padding: EdgeInsets.all(isWide ? 40 : 24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              question.text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: isWide ? 28 : 20,
                fontWeight: FontWeight.w300,
                height: 1.4,
                fontFamily: 'serif',
              ),
            ),
            const SizedBox(height: 48),
            ...List.generate(question.options.length, (index) {
              final isSelected = _answers[_currentIndex] == index;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _OptionButton(
                  text: question.options[index],
                  isSelected: isSelected,
                  color: widget.category.color,
                  onTap: () {
                    setState(() => _answers[_currentIndex] = index);
                    Future.delayed(const Duration(milliseconds: 300), _nextQuestion);
                  },
                ),
              );
            }),
          ],
        ),
      );
    });
  }

  Widget _buildResults() {
    final score = _totalScore;
    final severity = QuizData.getSeverity(widget.category.title, score);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1014),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              widget.category.color.withOpacity(0.15),
              const Color(0xFF1A1014),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: widget.category.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: widget.category.color.withOpacity(0.3), width: 2),
                ),
                child: Icon(Icons.check_circle_outline, color: widget.category.color, size: 60),
              ),
              const SizedBox(height: 32),
              const Text(
                'Quiz Completed',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${widget.category.title.replaceAll('\n', ' ')} Screening',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 60),
              // Score Circle
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: widget.category.color.withOpacity(0.1), width: 12),
                    ),
                  ),
                  TweenAnimationBuilder<double>(
                    duration: const Duration(seconds: 2),
                    tween: Tween(begin: 0, end: score.toDouble()),
                    builder: (context, value, _) => Column(
                      children: [
                        Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 72,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -2,
                          ),
                        ),
                        Text(
                          'TOTAL SCORE',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 12,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              // Severity Label
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  color: widget.category.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: widget.category.color.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Result: ',
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                    Text(
                      severity,
                      style: TextStyle(
                        color: widget.category.color,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),
              // Return Button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 240,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: widget.category.color,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: widget.category.color.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Back to Dashboard',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionButton extends StatefulWidget {
  final String text;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _OptionButton({
    required this.text,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  State<_OptionButton> createState() => _OptionButtonState();
}

class _OptionButtonState extends State<_OptionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? widget.color
                : _hovered
                    ? Colors.white.withOpacity(0.08)
                    : Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isSelected
                  ? widget.color
                  : _hovered
                      ? Colors.white.withOpacity(0.2)
                      : Colors.white.withOpacity(0.08),
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.isSelected ? Colors.white : Colors.white24,
                    width: 2,
                  ),
                  color: widget.isSelected ? Colors.white : Colors.transparent,
                ),
                child: widget.isSelected
                    ? Icon(Icons.check, size: 16, color: widget.color)
                    : null,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  widget.text,
                  style: TextStyle(
                    color: widget.isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                    fontSize: 18,
                    fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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

class QuizQuestion {
  final String text;
  final List<String> options;
  final List<int> scores;

  const QuizQuestion({
    required this.text,
    required this.options,
    required this.scores,
  });
}

class QuizData {
  static const List<QuizQuestion> anxietyQuestions = [
    QuizQuestion(
      text: "Feeling nervous, anxious, or on edge?",
      options: ["Not at all", "Several days", "More than half the days", "Nearly every day"],
      scores: [0, 1, 2, 3],
    ),
    QuizQuestion(
      text: "Not being able to stop or control worrying?",
      options: ["Not at all", "Several days", "More than half the days", "Nearly every day"],
      scores: [0, 1, 2, 3],
    ),
    QuizQuestion(
      text: "Worrying too much about different things?",
      options: ["Not at all", "Several days", "More than half the days", "Nearly every day"],
      scores: [0, 1, 2, 3],
    ),
    QuizQuestion(
      text: "Trouble relaxing?",
      options: ["Not at all", "Several days", "More than half the days", "Nearly every day"],
      scores: [0, 1, 2, 3],
    ),
    QuizQuestion(
      text: "Being so restless that it is hard to sit still?",
      options: ["Not at all", "Several days", "More than half the days", "Nearly every day"],
      scores: [0, 1, 2, 3],
    ),
    QuizQuestion(
      text: "Becoming easily annoyed or irritable?",
      options: ["Not at all", "Several days", "More than half the days", "Nearly every day"],
      scores: [0, 1, 2, 3],
    ),
    QuizQuestion(
      text: "Feeling afraid, as if something awful might happen?",
      options: ["Not at all", "Several days", "More than half the days", "Nearly every day"],
      scores: [0, 1, 2, 3],
    ),
  ];

  static const List<QuizQuestion> adhdQuestions = [
    QuizQuestion(
      text: "How often do you have trouble wrapping up the final details of a project once the challenging parts have been done?",
      options: ["Never", "Rarely", "Sometimes", "Often", "Very Often"],
      scores: [0, 1, 2, 3, 4],
    ),
    QuizQuestion(
      text: "How often do you have difficulty getting things in order when you have to do a task that requires organization?",
      options: ["Never", "Rarely", "Sometimes", "Often", "Very Often"],
      scores: [0, 1, 2, 3, 4],
    ),
    QuizQuestion(
      text: "How often do you have problems remembering appointments or obligations?",
      options: ["Never", "Rarely", "Sometimes", "Often", "Very Often"],
      scores: [0, 1, 2, 3, 4],
    ),
    QuizQuestion(
      text: "When you have a task that requires a lot of thought, how often do you avoid or delay getting started?",
      options: ["Never", "Rarely", "Sometimes", "Often", "Very Often"],
      scores: [0, 1, 2, 3, 4],
    ),
    QuizQuestion(
      text: "How often do you fidget or squirm with your hands or feet when you have to sit down for a long time?",
      options: ["Never", "Rarely", "Sometimes", "Often", "Very Often"],
      scores: [0, 1, 2, 3, 4],
    ),
    QuizQuestion(
      text: "How often do you feel overly active and compelled to do things, as if you were driven by a motor?",
      options: ["Never", "Rarely", "Sometimes", "Often", "Very Often"],
      scores: [0, 1, 2, 3, 4],
    ),
  ];

  static const List<QuizQuestion> dyslexiaQuestions = [
    QuizQuestion(
      text: "Do you find yourself reading the same paragraph multiple times to understand it?",
      options: ["No", "Occasionally", "Frequently", "Always"],
      scores: [0, 1, 2, 3],
    ),
    QuizQuestion(
      text: "Do you feel more comfortable expressing your ideas out loud than writing them down?",
      options: ["No", "Occasionally", "Frequently", "Always"],
      scores: [0, 1, 2, 3],
    ),
    QuizQuestion(
      text: "Do you find it difficult to tell \"left\" from \"right\" quickly or follow multi-step directions?",
      options: ["No", "Occasionally", "Frequently", "Always"],
      scores: [0, 1, 2, 3],
    ),
    QuizQuestion(
      text: "Do you struggle with spelling, even for common words, or rely heavily on spell-check?",
      options: ["No", "Occasionally", "Frequently", "Always"],
      scores: [0, 1, 2, 3],
    ),
    QuizQuestion(
      text: "Do you find it exhausting to read for long periods of time?",
      options: ["No", "Occasionally", "Frequently", "Always"],
      scores: [0, 1, 2, 3],
    ),
    QuizQuestion(
      text: "When reading aloud, do you skip over words or lose your place on the page?",
      options: ["No", "Occasionally", "Frequently", "Always"],
      scores: [0, 1, 2, 3],
    ),
  ];

  static const List<QuizQuestion> depressionQuestions = [
    QuizQuestion(
      text: "How often have you felt physically heavy, as if your limbs are weighted down, making simple movements feel like a chore?",
      options: ["Not at all", "Several days", "More than half the days", "Nearly every day"],
      scores: [0, 1, 2, 3],
    ),
    QuizQuestion(
      text: "How often have you struggled to make even tiny decisions (like what to eat or what to wear) because they felt overwhelming?",
      options: ["Not at all", "Several days", "More than half the days", "Nearly every day"],
      scores: [0, 1, 2, 3],
    ),
    QuizQuestion(
      text: "How often have you avoided answering texts, calls, or invitations—not because you were busy, but because you didn't have the \"energy\" to interact?",
      options: ["Not at all", "Several days", "More than half the days", "Nearly every day"],
      scores: [0, 1, 2, 3],
    ),
    QuizQuestion(
      text: "How often have you felt \"numb\" or disconnected from your surroundings, as if you are watching your life happen from behind a pane of glass?",
      options: ["Not at all", "Several days", "More than half the days", "Nearly every day"],
      scores: [0, 1, 2, 3],
    ),
    QuizQuestion(
      text: "How often have you felt uncharacteristically angry or frustrated by minor inconveniences that normally wouldn't bother you?",
      options: ["Not at all", "Several days", "More than half the days", "Nearly every day"],
      scores: [0, 1, 2, 3],
    ),
    QuizQuestion(
      text: "How often has the future felt like a \"blank wall\" or a \"fog,\" where you find it impossible to imagine things getting better or feeling excited about upcoming events?",
      options: ["Not at all", "Several days", "More than half the days", "Nearly every day"],
      scores: [0, 1, 2, 3],
    ),
    QuizQuestion(
      text: "How often have you skipped basic hygiene (showering, brushing teeth, tidying your space) because it felt like too much effort?",
      options: ["Not at all", "Several days", "More than half the days", "Nearly every day"],
      scores: [0, 1, 2, 3],
    ),
  ];

  static List<QuizQuestion> getQuestionsForCategory(String title) {
    if (title.contains('Worry')) return anxietyQuestions;
    if (title.contains('Focus')) return adhdQuestions;
    if (title.contains('Reading')) return dyslexiaQuestions;
    if (title.contains('Mood')) return depressionQuestions;
    return anxietyQuestions;
  }

  static String getSeverity(String category, int score) {
    if (category.contains('Worry')) { // GAD-7
      if (score <= 4) return "Minimal";
      if (score <= 9) return "Mild";
      if (score <= 14) return "Moderate";
      return "Severe";
    }
    if (category.contains('Focus')) { // ASRS
      if (score <= 9) return "Low";
      if (score <= 13) return "Mild to Moderate";
      if (score <= 17) return "High";
      return "Very High";
    }
    if (category.contains('Reading')) { // Dyslexia
      if (score <= 5) return "Low Probability";
      if (score <= 10) return "Moderate Probability";
      return "High Probability";
    }
    if (category.contains('Mood')) { // Depression
      if (score <= 4) return "Minimal";
      if (score <= 9) return "Mild";
      if (score <= 14) return "Moderate";
      if (score <= 19) return "Moderately Severe";
      return "Severe";
    }
    return "Neutral";
  }
}

class QuizStartScreen extends StatefulWidget {
  final bool showSidebar;
  const QuizStartScreen({super.key, this.showSidebar = true});

  @override
  State<QuizStartScreen> createState() => _QuizStartScreenState();
}

class _QuizStartScreenState extends State<QuizStartScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late List<AnimationController> _cardControllers;

  int _hoveredIndex = -1;
  int _selectedNav = 2; // Default to Mind & Mood

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
      subtitle: 'Anxiety Patterns',
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
          if (widget.showSidebar)
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
      {'icon': Icons.person_outline_rounded, 'label': 'My Profile'},
      {'icon': Icons.bar_chart_rounded,       'label': 'Report'},
      {'icon': Icons.psychology_outlined,     'label': 'My Mind & Mood'},
    ];

    return Container(
      width: 220,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          // Logo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5E6B),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.psychology, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  '4see',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          ...navItems.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value as Map<String, dynamic>;
            final icon = item['icon'] as IconData;
            final label = item['label'] as String;
            final isSelected = _selectedNav == i;
            return GestureDetector(
              onTap: () {
                if (isSelected) return;
                if (i == 0) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const StudentProfilePage()));
                } else if (i == 1) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ReportPage()));
                } else {
                  setState(() => _selectedNav = i);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF8B5E6B).withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(color: const Color(0xFF8B5E6B).withOpacity(0.4))
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      color: isSelected
                          ? const Color(0xFFD4A0AE)
                          : Colors.white.withOpacity(0.3),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      label,
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFFD4A0AE)
                            : Colors.white.withOpacity(0.3),
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const Spacer(),
          // Profile Widget
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF5A3540)),
                  child: const Center(child: Text('RS', style: TextStyle(color: Color(0xFFD4A0AE), fontWeight: FontWeight.bold, fontSize: 10))),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rohan Sharma', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    Text('Class X A', style: TextStyle(color: Colors.white54, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
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
          final qList = QuizData.getQuestionsForCategory(category.title);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => QuizQuestionScreen(
                category: category,
                questions: qList,
              ),
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