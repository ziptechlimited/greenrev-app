import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/image_helper.dart';
import '../../../acquisitions/presentation/screens/acquisitions_screen.dart';
import '../../../inquiries/presentation/widgets/inquiry_modal.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openAiConcierge(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AiConciergeSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cinematic HUD Hero Header
            Stack(
              children: [
                Container(
                  height: size.height * 0.55,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: safeImageProvider('/images/home/showroom.jpeg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Gradient overlay
                Container(
                  height: size.height * 0.55,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.4),
                        Colors.black.withValues(alpha: 0.2),
                        AppTheme.background,
                      ],
                    ),
                  ),
                ),
                // HUD Callouts overlay
                Positioned(
                  left: 24,
                  bottom: 32,
                  right: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.accent,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'THE SHOWROOM',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                              color: AppTheme.accent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'AVATR 12 GT',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: 36,
                              letterSpacing: -1.0,
                            ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'QUANTUM SILVER SPECIFICATION',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1.5,
                          color: AppTheme.textSubtle,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildHudStat('3.9s', '0 - 100 KM/H'),
                          _buildHudStat('578 HP', 'POWER'),
                          _buildHudStat('650 Nm', 'TORQUE'),
                          _buildHudStat('220 KM/H', 'LIMIT'),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),

            // AI Concierge CTA
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: GestureDetector(
                onTap: () => _openAiConcierge(context),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: AppTheme.glassBoxDecoration(),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppTheme.accent,
                        child: Icon(Icons.psychology_outlined, color: Colors.black),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI CONCIERGE ASSISTANT',
                              style: TextStyle(
                                fontSize: 11,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accent,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Ask anything about specifications or configurations',
                              style: TextStyle(fontSize: 12, color: AppTheme.textSubtle),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.accent.withValues(alpha: 0.7)),
                    ],
                  ),
                ),
              ),
            ),

            // Quick Actions: Relinquish & Inquiry
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AcquisitionsScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: AppTheme.glassBoxDecoration(color: AppTheme.accent.withValues(alpha: 0.05)),
                        child: const Row(
                          children: [
                            Icon(Icons.swap_horiz, color: AppTheme.accent, size: 20),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('MY REQUESTS', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                                  Text('Track acquisitions', style: TextStyle(color: AppTheme.textSubtle, fontSize: 10)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        InquiryModalSheet.show(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: AppTheme.glassBoxDecoration(color: Colors.white.withValues(alpha: 0.03)),
                        child: const Row(
                          children: [
                            Icon(Icons.support_agent, color: AppTheme.accent, size: 20),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('GENERAL INQUIRY', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                                  Text('Custom Requests', style: TextStyle(color: AppTheme.textSubtle, fontSize: 10)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Section: Ecosystem Services
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Text(
                'SERVICES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: Colors.white,
                ),
              ),
            ),

            // Services Grid Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  _buildServiceCard(
                    context,
                    'THE SHOWROOM',
                    'Explore vehicle listings from independent dealers and sellers.',
                    '/images/home/showroom.jpeg',
                  ),
                  const SizedBox(height: 16),
                  _buildServiceCard(
                    context,
                    'PARTS & PERFORMANCE',
                    'Enhance your car with highest-grade components and custom accessories.',
                    '/images/home/parts.png',
                  ),
                  const SizedBox(height: 16),
                  _buildServiceCard(
                    context,
                    'EXPERT CARE',
                    'Access our elite network of mechanics and specialized service centers.',
                    '/images/home/expert.jpeg',
                  ),
                  const SizedBox(height: 16),
                  _buildServiceCard(
                    context,
                    'VEHICLE RENTALS (COMING SOON)',
                    'Short-term and long-term vehicle rental services.',
                    '/images/home/showroom.jpeg',
                  ),
                  const SizedBox(height: 16),
                  _buildServiceCard(
                    context,
                    'LOGISTICS & MOBILITY (COMING SOON)',
                    'Professional transport and cross-country logistics.',
                    '/images/home/expert.jpeg',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100), // Padding to avoid clipping under the floating bottom bar
          ],
        ),
      ),
    );
  }

  Widget _buildHudStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSubtle,
            fontSize: 9,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard(BuildContext context, String title, String subtitle, String imageUrl) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: DecorationImage(
          image: safeImageProvider(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withValues(alpha: 0.85),
              Colors.black.withValues(alpha: 0.3),
            ],
          ),
          border: Border.all(color: Colors.white10),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppTheme.textSubtle,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Interactive AI Concierge Chat Sheet
class AiConciergeSheet extends StatefulWidget {
  const AiConciergeSheet({super.key});

  @override
  State<AiConciergeSheet> createState() => _AiConciergeSheetState();
}

class _AiConciergeSheetState extends State<AiConciergeSheet> {
  final List<Map<String, String>> _messages = [
    {
      'role': 'assistant',
      'text': 'Greetings. I am the GreenRev AI Concierge. How may I assist you with finding vehicles, parts, or services today?'
    }
  ];
  final _controller = TextEditingController();

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    final text = _controller.text.trim();
    _controller.clear();

    setState(() {
      _messages.add({'role': 'user', 'text': text});
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      String response = "Understood. I am indexing our marketplace for listings matching your criteria. Is there a specific vehicle, part, or service you need?";
      final lower = text.toLowerCase();
      if (lower.contains('g63') || lower.contains('g-wagon') || lower.contains('mercedes')) {
        response = "There are several independent dealers listing Mercedes-Benz vehicles. The Mercedes-Benz G63 AMG is currently listed by a vendor for ₦270,000,000.";
      } else if (lower.contains('xiaomi') || lower.contains('su7')) {
        response = "The Xiaomi SU7 Max is currently listed by a verified dealer in our ecosystem for ₦67,500,000.";
      } else if (lower.contains('exhaust') || lower.contains('parts') || lower.contains('titanium')) {
        response = "You can discover automotive parts and components from vendors through the GreenRev marketplace. Search the Parts tab for exhaust systems.";
      } else if (lower.contains('mechanic') || lower.contains('repair') || lower.contains('expert')) {
        response = "To schedule service appointments, you can navigate to the 'Experts' tab to search for local mechanics and automotive experts.";
      }

      setState(() {
        _messages.add({'role': 'assistant', 'text': response});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75 + bottomInset,
      decoration: const BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Row(
              children: [
                Icon(Icons.psychology, color: AppTheme.accent),
                SizedBox(width: 12),
                Text(
                  'AI CONCIERGE ASSISTANT',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white10),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isUser ? AppTheme.accent.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                        bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                      ),
                      border: Border.all(
                        color: isUser ? AppTheme.accent.withValues(alpha: 0.3) : Colors.white10,
                      ),
                    ),
                    child: Text(
                      msg['text'] ?? '',
                      style: TextStyle(
                        color: isUser ? Colors.white : AppTheme.textSubtle,
                        fontSize: 13.5,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(color: Colors.white10),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Ask about vehicles, parts, or services...',
                      hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.03),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.white10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.white10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppTheme.accent),
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 12),
                CircleAvatar(
                  backgroundColor: AppTheme.accent,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.black, size: 18),
                    onPressed: _sendMessage,
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
