import 'package:flutter/material.dart';
import '../../core/models/learning_models.dart';
import '../../core/data/python_curriculum_data.dart';
import '../../core/services/learning_state_manager.dart';
import '../../core/theme/app_theme.dart';
import '../lesson/engine/lesson_engine_screen.dart';

class CourseMapScreen extends StatefulWidget {
  final LearningStateManager stateManager;

  const CourseMapScreen({super.key, required this.stateManager});

  @override
  State<CourseMapScreen> createState() => _CourseMapScreenState();
}

class _CourseMapScreenState extends State<CourseMapScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.stateManager.searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nodes = widget.stateManager.filteredCourseNodes;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: const [
            Text('🐍', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text(
              'PYTHON SKILL TREE',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt, color: AppColors.energyOrange, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${widget.stateManager.student.energy}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Fast Local Search Bar (0ms local index search)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.stateManager.searchQuery.isNotEmpty
                      ? AppColors.iqooCyan
                      : AppColors.border,
                ),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => widget.stateManager.setSearchQuery(val),
                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search Python concepts, topics, functions...',
                  hintStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.iqooCyan),
                  suffixIcon: widget.stateManager.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16, color: AppColors.textSecondary),
                          onPressed: () {
                            _searchController.clear();
                            widget.stateManager.setSearchQuery('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),

          // Skill Tree List or Empty Search State
          Expanded(
            child: nodes.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.search_off, size: 48, color: AppColors.textMuted),
                          const SizedBox(height: 12),
                          Text(
                            'No concepts matching "${widget.stateManager.searchQuery}"',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Try "variable", "functions", "loops", or "return"',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: () {
                              _searchController.clear();
                              widget.stateManager.setSearchQuery('');
                            },
                            child: const Text('CLEAR SEARCH'),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    itemCount: nodes.length,
                    itemBuilder: (context, index) {
                      final node = nodes[index];
                      final isLast = index == nodes.length - 1;

                      // Compute gentle alternating horizontal offset for Duolingo curve feel
                      double xOffset = 0;
                      if (index % 4 == 1) xOffset = 36;
                      if (index % 4 == 3) xOffset = -36;

                      return Column(
                        children: [
                          // Show Week Header when week changes
                          if (index == 0 || nodes[index - 1].weekNumber != node.weekNumber)
                            _buildWeekHeader(node.weekNumber, node.weekTitle, nodes),

                          // Show Unit Header when unit changes
                          if (index == 0 || nodes[index - 1].unitTitle != node.unitTitle)
                            _buildUnitHeader(node.unitTitle),

                          Transform.translate(
                            offset: Offset(xOffset, 0),
                            child: _buildSkillNode(context, node),
                          ),

                          if (!isLast)
                            Transform.translate(
                              offset: Offset(xOffset / 2, 0),
                              child: Container(
                                width: 6,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: node.status == NodeStatus.completed
                                      ? AppColors.duolingoGreen.withValues(alpha: 0.5)
                                      : AppColors.surface,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekHeader(int weekNumber, String weekTitle, List<CourseNode> allNodes) {
    final weekNodes = allNodes.where((n) => n.weekNumber == weekNumber).toList();
    final completedCount = weekNodes.where((n) => n.status == NodeStatus.completed).length;
    final totalCount = weekNodes.isEmpty ? 1 : weekNodes.length;
    final progress = completedCount / totalCount;
    final percent = (progress * 100).toInt();

    String weekEmoji = '🚀';
    if (weekNumber == 2) weekEmoji = '🏙️';
    if (weekNumber == 3) weekEmoji = '🏭';
    if (weekNumber == 4) weekEmoji = '🖥️';

    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: progress > 0 ? AppColors.iqooCyan.withValues(alpha: 0.6) : AppColors.border,
          width: 1.5,
        ),
        boxShadow: [
          if (progress > 0)
            BoxShadow(
              color: AppColors.iqooCyan.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(weekEmoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WEEK $weekNumber',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.3,
                        color: AppColors.iqooCyan,
                      ),
                    ),
                    Text(
                      weekTitle.replaceFirst(RegExp(r'^Week \d+:\s*'), ''),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: progress == 1.0
                      ? AppColors.duolingoGreen.withValues(alpha: 0.2)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$percent%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: progress == 1.0 ? AppColors.duolingoGreen : AppColors.iqooCyan,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surface,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress == 1.0 ? AppColors.duolingoGreen : AppColors.iqooCyan,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitHeader(String unitTitle) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 20),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            unitTitle.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: AppColors.iqooCyan,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkillNode(BuildContext context, CourseNode node) {
    Color nodeColor;
    Widget centerIcon;
    bool isClickable = node.status != NodeStatus.locked;

    switch (node.status) {
      case NodeStatus.completed:
        nodeColor = AppColors.duolingoGreen;
        centerIcon = const Icon(Icons.check, color: Colors.black, size: 28);
        break;
      case NodeStatus.current:
        nodeColor = AppColors.iqooCyan;
        centerIcon = const Icon(Icons.play_arrow, color: Colors.black, size: 32);
        break;
      case NodeStatus.locked:
        nodeColor = AppColors.surface;
        centerIcon = const Icon(Icons.lock, color: AppColors.textMuted, size: 24);
        break;
    }

    return GestureDetector(
      onTap: () {
        if (isClickable) {
          _showNodeDialog(context, node);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🔒 Complete previous units to unlock this node!'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      },
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow for active node
              if (node.status == NodeStatus.current)
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.iqooCyan.withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                ),

              // Circular Node
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: nodeColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: node.status == NodeStatus.current ? Colors.white : AppColors.card,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      offset: const Offset(0, 4),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Center(child: centerIcon),
              ),

              // Star badge if completed
              if (node.status == NodeStatus.completed && node.stars > 0)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: AppColors.xpAmber,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.star, color: Colors.black, size: 14),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Day ${node.dayNumber}: ${node.title}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: node.status == NodeStatus.locked ? AppColors.textMuted : AppColors.textPrimary,
            ),
          ),
          if (node.masteryPercent > 0)
            Text(
              '${(node.masteryPercent * 100).toInt()}% Mastered',
              style: TextStyle(
                fontSize: 10,
                color: node.masteryPercent > 0.8 ? AppColors.duolingoGreen : AppColors.xpAmber,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  void _showNodeDialog(BuildContext context, CourseNode node) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.iqooCyan.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(node.icon, color: AppColors.iqooCyan, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        node.title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        node.unitTitle,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildModalStat('Mastery', '${(node.masteryPercent * 100).toInt()}%'),
                    _buildModalStat('Time', '4-5 min'),
                    _buildModalStat('XP', '+25 XP'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    final concept = PythonCurriculumData.getById(node.id) ??
                        PythonCurriculumData.allUnits.firstWhere(
                          (u) => u.title.toLowerCase() == node.title.toLowerCase() ||
                                 node.title.toLowerCase().contains(u.storyTheme.toLowerCase()),
                          orElse: () => PythonCurriculumData.allUnits.first,
                        );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) => LessonEngineScreen(
                          concept: concept,
                          stateManager: widget.stateManager,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.duolingoGreen,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    'START STORY ADVENTURE 🚀',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.iqooCyan)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}
