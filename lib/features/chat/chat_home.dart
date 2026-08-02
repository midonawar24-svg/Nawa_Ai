import 'package:flutter/material.dart';
import 'dart:async';
import '../../../core/app_theme.dart';
import '../../../shared/widgets/glass_widgets.dart';

class ChatMasterPage extends StatefulWidget {
  const ChatMasterPage({super.key});

  @override
  State<ChatMasterPage> createState() => _ChatMasterPageState();
}

class _ChatMasterPageState extends State<ChatMasterPage> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  late AnimationController _langController;
  bool _isArabic = true;
  bool _showLangHint = true;

  // History & Control Center
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  // Floating chat results overlay
  bool _showResultsOverlay = false;
  List<Map<String, dynamic>> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _langController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _langController.forward();
    
    // Welcome message after boot
    Future.delayed(const Duration(milliseconds: 500), () {
      _addBotMessage(
        _isArabic
            ? '👋 أهلاً بعودتك\nتم تشغيل AI Core بنجاح.\nكيف يمكنني مساعدتك اليوم؟'
            : '👋 Welcome Back\nAI Core is ready.\nHow can I help you today?',
      );
    });

    // Hide lang hint after 3s
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showLangHint = false);
    });
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add({'role': 'bot', 'text': text, 'time': DateTime.now()});
    });
    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add({'role': 'user', 'text': text, 'time': DateTime.now()});
    });
    _scrollToBottom();
    _simulateBotResponse(text);
  }

  void _simulateBotResponse(String query) async {
    setState(() => _isTyping = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _isTyping = false);

    // Mock intelligent response
    String response;
    if (query.contains('طنطا') || query.toLowerCase().contains('tanta')) {
      response = _isArabic
          ? 'طنطا هي عاصمة محافظة الغربية في مصر، مدينة جميلة تشتهر بمسجد السيد البدوي. هل تريد أن أحفظ معلومة عنها؟'
          : 'Tanta is the capital of Gharbia Governorate in Egypt, known for Al-Sayyid al-Badawi Mosque.';
    } else if (query.toLowerCase().contains('flutter')) {
      response = _isArabic
          ? 'Flutter هو إطار عمل رائع لبناء تطبيقات جميلة! هل تريد أن أحفظ best practices عنه؟'
          : 'Flutter is amazing for building beautiful apps! Want me to save best practices?';
    } else {
      response = _isArabic
          ? 'فهمت: "$query"\nأنا AI Core OS، نظام ذكاء اصطناعي متكامل. يمكنني حفظ الذكريات، إدارة المعرفة، واتخاذ القرارات.\nجرب: "احفظ أن الاجتماع بكرة" أو "ما هي طنطا؟"'
          : 'Got it: "$query"\nI am AI Core OS, a complete AI operating system. I can save memories, manage knowledge, and make decisions.\nTry: "Remember meeting tomorrow" or "What is Tanta?"';
    }
    _addBotMessage(response);
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _toggleLanguage() async {
    await _langController.reverse();
    setState(() => _isArabic = !_isArabic);
    await _langController.forward();
    
    // Update welcome message language hint
    _addBotMessage(
      _isArabic ? 'تم التحويل للعربية 🇪🇬' : 'Switched to English 🇺🇸',
    );
  }

  void _showSearchResults(String query) {
    // Mock results with scores
    setState(() {
      _searchResults = [
        {'title': _isArabic ? 'طنطا مدينة جميلة في مصر' : 'Tanta is a beautiful city in Egypt', 'type': 'episodic', 'time': '2h ago', 'score': 94},
        {'title': _isArabic ? 'طنطا في محافظة الغربية' : 'Tanta in Gharbia Governorate', 'type': 'semantic', 'time': 'Yesterday', 'score': 87},
        {'title': _isArabic ? 'مسجد السيد البدوي في طنطا' : 'Al-Badawi Mosque in Tanta', 'type': 'knowledge', 'time': '3d ago', 'score': 82},
      ];
      _showResultsOverlay = true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _langController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.deepBlack,
      drawer: _buildHistoryDrawer(),
      endDrawer: _buildControlCenter(),
      body: Stack(
        children: [
          // Main chat
          Column(
            children: [
              _buildAppBar(),
              Expanded(child: _buildMessages()),
              _buildInputBar(),
            ],
          ),

          // Transparent results overlay - scores in middle
          if (_showResultsOverlay)
            GestureDetector(
              onTap: () => setState(() => _showResultsOverlay = false),
              child: Container(
                color: Colors.black.withOpacity(0.4),
                child: BackdropFilter(
                  filter: ColorFilter.mode(Colors.black.withOpacity(0.1), BlendMode.srcOver),
                  child: TransparentResultBar(
                    results: _searchResults,
                    onClose: () => setState(() => _showResultsOverlay = false),
                    onGoToChat: () => setState(() => _showResultsOverlay = false),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, left: 16, right: 16, bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.deepBlack.withOpacity(0.8),
        border: Border(bottom: BorderSide(color: AppTheme.glassBorder.withOpacity(0.5))),
      ),
      child: Row(
        children: [
          // History button
          IconButton(
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            icon: const Icon(Icons.menu, color: Colors.white, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.glassBg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(width: 12),
          // Logo + name
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: AppTheme.cyanNeon.withOpacity(0.3), blurRadius: 12)],
            ),
            child: ClipOval(
              child: Image.asset('assets/images/ai_core_boot_logo.png', fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppTheme.cyanNeon, AppTheme.purpleNeon]), shape: BoxShape.circle),
                  child: const Center(child: Text('AI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('AI CORE OS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2)),
              Row(
                children: [
                  Icon(Icons.circle, size: 6, color: AppTheme.knowledgeEmerald),
                  SizedBox(width: 4),
                  Text('Neural Link Active', style: TextStyle(fontSize: 10, color: AppTheme.knowledgeEmerald)),
                ],
              ),
            ],
          ),
          const Spacer(),
          // Language button - Master V1: AR|EN with Fade, does NOT disappear permanently
          Stack(
            children: [
              FadeTransition(
                opacity: _langController,
                child: ScaleTransition(
                  scale: _langController,
                  child: GlassCard(
                    borderRadius: 12,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    onTap: _toggleLanguage,
                    hasGlow: true,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_isArabic ? 'AR' : 'EN', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.cyanNeon)),
                        const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('|', style: TextStyle(fontSize: 10, color: Colors.white24))),
                        Text(_isArabic ? 'EN' : 'AR', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5))),
                      ],
                    ),
                  ),
                ),
              ),
              if (_showLangHint)
                Positioned(
                  top: 36,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppTheme.deepBlack3, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.glassBorder)),
                    child: Text(_isArabic ? 'دوس للتبديل' : 'Tap to switch', style: const TextStyle(fontSize: 9, color: Colors.white70)),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
          // Control center button
          IconButton(
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            icon: const Icon(Icons.dashboard_outlined, size: 18),
            color: Colors.white70,
            style: IconButton.styleFrom(backgroundColor: AppTheme.glassBg, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ],
      ),
    );
  }

  Widget _buildMessages() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isTyping) {
          return _buildTypingIndicator();
        }
        final msg = _messages[index];
        final isUser = msg['role'] == 'user';
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isUser ? AppTheme.cyanNeon.withOpacity(0.15) : AppTheme.glassBg,
              borderRadius: BorderRadius.circular(20).copyWith(
                bottomRight: isUser ? const Radius.circular(4) : null,
                bottomLeft: !isUser ? const Radius.circular(4) : null,
              ),
              border: Border.all(color: isUser ? AppTheme.cyanNeon.withOpacity(0.3) : AppTheme.glassBorder),
            ),
            child: Text(
              msg['text'],
              style: TextStyle(fontSize: 13.5, color: Colors.white.withOpacity(0.9), height: 1.5),
              textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: AppTheme.glassBg, borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...List.generate(3, (i) => Container(
              margin: EdgeInsets.only(left: i == 0 ? 0 : 4),
              width: 6, height: 6,
              decoration: BoxDecoration(color: AppTheme.cyanNeon.withOpacity(0.6), shape: BoxShape.circle),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, bottom: MediaQuery.of(context).padding.bottom + 12, top: 12),
      decoration: BoxDecoration(
        color: AppTheme.deepBlack.withOpacity(0.9),
        border: Border(top: BorderSide(color: AppTheme.glassBorder.withOpacity(0.5))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.attach_file, size: 18),
            color: Colors.white.withOpacity(0.6),
            style: IconButton.styleFrom(backgroundColor: AppTheme.glassBg, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              decoration: AppTheme.glassDecorationWithRadius(24),
              child: TextField(
                controller: _controller,
                style: const TextStyle(fontSize: 14, color: Colors.white),
                textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
                decoration: InputDecoration(
                  hintText: _isArabic ? 'اسأل AI Core...' : 'Ask AI Core...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                ),
                onSubmitted: (v) {
                  if (v.trim().isNotEmpty) {
                    _addUserMessage(v);
                    _controller.clear();
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              if (_controller.text.trim().isNotEmpty) {
                _showSearchResults(_controller.text);
              }
            },
            icon: const Icon(Icons.search, size: 18),
            color: Colors.white.withOpacity(0.6),
            style: IconButton.styleFrom(backgroundColor: AppTheme.glassBg, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppTheme.cyanNeon, AppTheme.purpleNeon]),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: AppTheme.cyanNeon.withOpacity(0.3), blurRadius: 12)],
            ),
            child: IconButton(
              onPressed: () {
                if (_controller.text.trim().isNotEmpty) {
                  _addUserMessage(_controller.text);
                  _controller.clear();
                }
              },
              icon: const Icon(Icons.send, size: 18, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryDrawer() {
    return Drawer(
      backgroundColor: AppTheme.deepBlack2,
      width: 320,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16, left: 16, right: 16, bottom: 16),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.glassBorder.withOpacity(0.5)))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('المحادثات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    const Spacer(),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.search, size: 18), color: Colors.white60),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() => _messages.clear());
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('New Chat', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.cyanNeon,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildSmallChip('Search Chats', Icons.search),
                    const SizedBox(width: 6),
                    _buildSmallChip('Favorites', Icons.star_outline),
                    const SizedBox(width: 6),
                    _buildSmallChip('Archive', Icons.archive_outlined),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: 8,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (context, i) {
                final titles = [
                  'تذكر أن طنطا مدينة جميلة',
                  'ما هي طنطا؟',
                  'احفظ اجتماع بكرة',
                  'Flutter best practices',
                  'Meeting with Ahmed',
                  'AI Prompt Engineering',
                  'Decision: Use Drift DB',
                  'خطة مشروع AI Core',
                ];
                return GlassCard(
                  borderRadius: 16,
                  padding: const EdgeInsets.all(12),
                  onTap: () {
                    Navigator.pop(context);
                    _addUserMessage(titles[i]);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titles[i], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text('آخر رسالة...', style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.5)), maxLines: 1),
                      const SizedBox(height: 4),
                      Text('${i + 1}h ago', style: TextStyle(fontSize: 9, color: Colors.white.withOpacity(0.3))),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: AppTheme.glassBg, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.glassBorder)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 10, color: Colors.white60), const SizedBox(width: 4), Text(label, style: const TextStyle(fontSize: 9, color: Colors.white60))]),
    );
  }

  Widget _buildControlCenter() {
    final items = [
      {'icon': '🧠', 'title': 'Memory', 'sub': '128 memories', 'color': AppTheme.memoryIndigo},
      {'icon': '📚', 'title': 'Knowledge', 'sub': '42 items', 'color': AppTheme.knowledgeEmerald},
      {'icon': '⚡', 'title': 'Decision Engine', 'sub': '99.7% accuracy', 'color': AppTheme.decisionAmber},
      {'icon': '📊', 'title': 'Analytics', 'sub': 'Insights', 'color': AppTheme.searchCyan},
      {'icon': '🕸', 'title': 'Memory Graph', 'sub': 'Neural network', 'color': AppTheme.purpleNeon},
      {'icon': '🔍', 'title': 'Search', 'sub': 'Search memories', 'color': AppTheme.cyanNeon},
      {'icon': '⚙', 'title': 'Settings', 'sub': 'Preferences', 'color': AppTheme.systemSlate},
      {'icon': 'ℹ', 'title': 'About', 'sub': 'AI Core OS v11.1', 'color': Colors.white70},
    ];

    return Drawer(
      backgroundColor: AppTheme.deepBlack2,
      width: 300,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16, left: 16, right: 16, bottom: 16),
            child: const Row(children: [Text('Control Center', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)), Spacer(), Icon(Icons.close, size: 18, color: Colors.white54)]),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final item = items[i];
                return GlassCard(
                  borderRadius: 16,
                  padding: const EdgeInsets.all(14),
                  onTap: () {
                    Navigator.pop(context);
                    _openControlPage(item['title'] as String);
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: (item['color'] as Color).withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                        child: Center(child: Text(item['icon'] as String, style: const TextStyle(fontSize: 18))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['title'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                            Text(item['sub'] as String, style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.5))),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, size: 16, color: Colors.white.withOpacity(0.3)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openControlPage(String title) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scroll) {
          return Container(
            decoration: BoxDecoration(color: AppTheme.deepBlack2, borderRadius: const BorderRadius.vertical(top: Radius.circular(24)), border: Border.all(color: AppTheme.glassBorder)),
            child: Column(
              children: [
                Container(margin: const EdgeInsets.only(top: 12), width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
                Padding(padding: const EdgeInsets.all(16), child: Row(children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)), const Spacer(), IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.white60))])),
                Expanded(
                  child: ListView(
                    controller: scroll,
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (title == 'Memory') ...[
                        _buildMemoryContent(),
                      ] else if (title == 'Memory Graph') ...[
                        _buildGraphContent(),
                      ] else ...[
                        Center(
                          child: Column(
                            children: [
                              const SizedBox(height: 40),
                              Icon(Icons.construction, size: 48, color: Colors.white.withOpacity(0.2)),
                              const SizedBox(height: 16),
                              Text(title, style: const TextStyle(fontSize: 16, color: Colors.white)),
                              const SizedBox(height: 8),
                              const Text('This section is under development.', style: TextStyle(fontSize: 12, color: Colors.white54)),
                              const SizedBox(height: 24),
                              GlassCard(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  _isArabic
                                      ? 'هذا القسم قيد التطوير حالياً. سيتم إضافة المزيد من الميزات قريباً.'
                                      : 'This section is currently under development. More features coming soon.',
                                  style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6)),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMemoryContent() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: GlassCard(padding: const EdgeInsets.all(12), child: Column(children: [Text('128', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.memoryIndigo)), Text('Memories', style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.5)))]))),
            const SizedBox(width: 8),
            Expanded(child: GlassCard(padding: const EdgeInsets.all(12), child: Column(children: [Text('92%', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.knowledgeEmerald)), Text('Health', style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.5)))]))),
          ],
        ),
        const SizedBox(height: 16),
        ...List.generate(3, (i) => GlassCard(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Memory ${i+1}', style: const TextStyle(fontSize: 12, color: Colors.white)), Text('2h ago • episodic', style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.5)))])),
              ScoreBadge(score: 90 - i*5),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildGraphContent() {
    return Column(
      children: [
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            height: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Ahmed', style: TextStyle(color: Colors.white, fontSize: 12)),
                  Container(width: 1, height: 20, color: Colors.white24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppTheme.memoryIndigo.withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: const Text('Meeting', style: TextStyle(fontSize: 10, color: Colors.white))),
                      Container(width: 30, height: 1, color: Colors.white24),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppTheme.searchCyan.withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: const Text('Flutter', style: TextStyle(fontSize: 10, color: Colors.white))),
                    ],
                  ),
                  Container(width: 1, height: 20, color: Colors.white24),
                  const Text('OpenAI', style: TextStyle(color: Colors.white, fontSize: 12)),
                  Container(width: 1, height: 20, color: Colors.white24),
                  const Text('API', style: TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text('يمكن التكبير والتصغير • Zoom & Pan', style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.4))),
      ],
    );
  }
}
