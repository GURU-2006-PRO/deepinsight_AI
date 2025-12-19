import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';

class UrlInputView extends StatefulWidget {
  const UrlInputView({super.key});

  @override
  State<UrlInputView> createState() => _UrlInputViewState();
}

class _UrlInputViewState extends State<UrlInputView> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isValid = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a URL';
    }
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return 'Please enter a valid URL (e.g., https://example.com)';
    }
    return null;
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<ChatProvider>().crawlWebsite(_controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.05),
            theme.colorScheme.secondary.withValues(alpha: 0.02),
            theme.scaffoldBackgroundColor,
          ],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Futuristic Logo Icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                ),
                child: Icon(
                  Icons.biotech_rounded,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
              ).animate().fadeIn().scale(duration: 600.ms, curve: Curves.easeOutBack),
              
              const SizedBox(height: 32),
              
              Text(
                'Professional RAG Engine',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
              
              const SizedBox(height: 12),
              
              Text(
                'Turn any website into a verified, local intelligence hub.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ).animate().fadeIn(delay: 300.ms),
              
              const SizedBox(height: 48),
              
              // Search Command Center
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.05),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _controller,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          hintText: 'Enter Source URL (e.g. college.edu)',
                          prefixIcon: Icon(Icons.language, color: theme.colorScheme.primary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        ),
                        keyboardType: TextInputType.url,
                        validator: _validateUrl,
                        onChanged: (value) => setState(() => _isValid = _validateUrl(value) == null),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: FilledButton(
                          onPressed: _isValid ? _submit : null,
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            backgroundColor: theme.colorScheme.primary,
                          ),
                          child: const Text(
                            'Initialize Intelligence Engine',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.9, 0.9)),
              
              const SizedBox(height: 48),
              
              _buildFeatures(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatures(ThemeData theme) {
    final features = [
      (Icons.verified_user_outlined, 'Verifiable AI', 'Zero Hallucinations'),
      (Icons.speed_rounded, 'Groq LPU', 'Sub-second Inference'),
      (Icons.security_rounded, 'Edge-Locked', '100% Data Privacy'),
    ];

    return Row(
      children: features.map((f) => Expanded(
        child: Column(
          children: [
            Icon(f.$1, color: theme.colorScheme.primary.withValues(alpha: 0.6), size: 24),
            const SizedBox(height: 12),
            Text(
              f.$2,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              f.$3,
              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )).toList(),
    ).animate().fadeIn(delay: 600.ms);
  }
}
