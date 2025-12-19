import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';

class UrlInputView extends StatefulWidget {
  const UrlInputView({super.key});

  @override
  State<UrlInputView> createState() => _UrlInputViewState();
}

class _UrlInputViewState extends State<UrlInputView> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  bool _isHovered = false;
  int _maxPages = 20;
  bool _isSmartMode = false;

  @override
  void dispose() {
    _urlController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<ChatProvider>(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF0D0D0D),
                  const Color(0xFF1A1A2E),
                  const Color(0xFF16213E),
                ],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.blue.shade50,
                  Colors.purple.shade50,
                ],
              ),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Logo with Gradient
                TweenAnimationBuilder(
                  duration: const Duration(seconds: 2),
                  tween: Tween<double>(begin: 0, end: 1),
                  builder: (context, double value, child) {
                    return Transform.scale(
                      scale: 0.8 + (value * 0.2),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.secondary,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.4),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.insights_rounded,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                
                // Title
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ).createShader(bounds),
                  child: Text(
                    'DeepInsight AI',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Uncover hidden patterns in any corner of the web',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Mode Selector
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildModeTab(
                          'Deep Research', 
                          Icons.radar_rounded, 
                          !_isSmartMode, 
                          () => setState(() => _isSmartMode = false),
                          isDark, theme
                        ),
                      ),
                      Expanded(
                        child: _buildModeTab(
                          'Smart Capture', 
                          Icons.psychology_rounded, 
                          _isSmartMode, 
                          () => setState(() => _isSmartMode = true),
                          isDark, theme
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Input Card
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(_isSmartMode ? 'Capture Goal' : 'Target Website', 
                        _isSmartMode ? Icons.auto_fix_high_rounded : Icons.language_rounded, theme, isDark),
                      const SizedBox(height: 16),
                      
                      // URL Field
                      _buildTextField(
                        controller: _urlController,
                        hint: 'https://example.com',
                        icon: Icons.link_rounded,
                        isDark: isDark,
                        theme: theme,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Dynamic Extra Field
                      if (_isSmartMode) ...[
                        _buildTextField(
                          controller: _goalController,
                          hint: 'What specific info are you looking for?',
                          icon: Icons.track_changes_rounded,
                          isDark: isDark,
                          theme: theme,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'AI will only index pages relevant to your goal.',
                          style: TextStyle(fontSize: 11, color: theme.colorScheme.secondary, fontWeight: FontWeight.w500),
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Icon(Icons.layers_outlined, size: 16, color: Colors.grey[500]),
                            const SizedBox(width: 8),
                            Text(
                              'Scale: $_maxPages pages',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.grey[300] : Colors.grey[700]),
                            ),
                          ],
                        ),
                        Slider(
                          value: _maxPages.toDouble(),
                          min: 1,
                          max: 50,
                          divisions: 49,
                          activeColor: theme.colorScheme.primary,
                          onChanged: (val) => setState(() => _maxPages = val.toInt()),
                        ),
                      ],
                      
                      const SizedBox(height: 24),
                      
                      // Action Button
                      _buildActionButton(
                        onPressed: () {
                          if (_urlController.text.isNotEmpty) {
                            provider.crawlWebsite(
                              _urlController.text, 
                              maxPages: _maxPages,
                              researchGoal: _isSmartMode ? _goalController.text : null,
                            );
                          }
                        },
                        label: _isSmartMode ? 'Start Smart Capture' : 'Launch Deep Scan',
                        theme: theme,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Feature Pills
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildFeaturePill(Icons.security_rounded, 'Private & Secure', isDark),
                    _buildFeaturePill(Icons.speed_rounded, 'Lightning Fast', isDark),
                    _buildFeaturePill(Icons.psychology_rounded, 'AI Powered', isDark),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturePill(IconData icon, String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isDark ? Colors.grey[400] : Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeTab(String label, IconData icon, bool isActive, VoidCallback onTap, bool isDark, ThemeData theme) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? (isDark ? const Color(0xFF2A2A2A) : Colors.white) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive ? [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))
          ] : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: isActive ? theme.colorScheme.primary : Colors.grey),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? (isDark ? Colors.white : Colors.black87) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String title, IconData icon, ThemeData theme, bool isDark) {
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 20),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    required ThemeData theme,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 13),
        prefixIcon: Icon(icon, color: theme.colorScheme.primary, size: 20),
        filled: true,
        fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[200]!, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildActionButton({required VoidCallback onPressed, required String label, required ThemeData theme}) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.secondary]),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(_isHovered ? 0.5 : 0.3),
                blurRadius: _isHovered ? 16 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.bolt_rounded, size: 22),
            label: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ),
    );
  }
}
