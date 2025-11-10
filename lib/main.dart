import 'dart:async';
import 'dart:math' as math;
import 'dart:convert';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, debugPrint, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';

import 'firebase_options.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_web/webview_flutter_web.dart';

class NexColors {
  static const primary = Color(0xFF3C82F6);
  static const secondary = Color(0xFF6366F1);
  static const gradient = [primary, secondary];
  static const backgroundLight = Color(0xFFF9FAFB);
  static const cardSurface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF1E293B);
  static const textSecondary = Color(0xFF64748B);
  static const neutralBorder = Color(0xFFE2E8F0);
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFFACC15);
  static const error = Color(0xFFEF4444);
}

const _mutedTextColor = NexColors.textSecondary;

Color _mutedColor(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFFCBD2FF)
      : _mutedTextColor;
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

ThemeData buildNexTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final colorScheme = ColorScheme(
    brightness: brightness,
    primary: NexColors.primary,
    onPrimary: Colors.white,
    secondary: NexColors.secondary,
    onSecondary: Colors.white,
    error: NexColors.error,
    onError: Colors.white,
    background: isDark ? const Color(0xFF040818) : NexColors.backgroundLight,
    onBackground: isDark ? Colors.white : NexColors.textPrimary,
    surface: isDark ? const Color(0xFF121A2F) : NexColors.cardSurface,
    onSurface: isDark ? Colors.white : NexColors.textPrimary,
    surfaceVariant: isDark ? const Color(0xFF1F2940) : const Color(0xFFF4F6FB),
    onSurfaceVariant: isDark ? Colors.white70 : NexColors.textSecondary,
    tertiary: const Color(0xFF8B5CF6),
    onTertiary: Colors.white,
    outline: NexColors.neutralBorder,
    shadow: Colors.black,
    inverseSurface: isDark ? NexColors.cardSurface : const Color(0xFF1A2033),
    onInverseSurface: isDark ? NexColors.textPrimary : Colors.white,
    inversePrimary: NexColors.secondary,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.background,
    textTheme: GoogleFonts.poppinsTextTheme().apply(
      bodyColor: isDark ? Colors.white : NexColors.textPrimary,
      displayColor: isDark ? Colors.white : NexColors.textPrimary,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: isDark ? const Color(0xFF1E2240) : NexColors.textPrimary,
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? const Color(0xFF1A2239) : Colors.white,
      labelStyle: TextStyle(color: isDark ? const Color(0xFFCBD2FF) : NexColors.textSecondary),
      hintStyle: TextStyle(
        color: isDark ? Colors.white54 : NexColors.textSecondary.withOpacity(0.7),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: isDark ? Colors.white12 : NexColors.neutralBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: isDark ? Colors.white10 : NexColors.neutralBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: colorScheme.primary),
      ),
      prefixIconColor: isDark ? const Color(0xFFB5BAFF) : NexColors.textSecondary,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 18),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: isDark ? Colors.white : NexColors.textPrimary,
        side: BorderSide(color: isDark ? Colors.white24 : NexColors.neutralBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    cardTheme: CardThemeData(
      color: isDark ? const Color(0xFF11182E) : NexColors.cardSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
  );
}

enum DashboardSection {
  home,
  satVocabs,
  questionBank,
  bookmarked,
  answered,
  practiceSessions,
  fullLengthTests,
  satSuite,
  vocabFlashcards,
  vocabPractice,
  practiceRush,
  reviewPractice,
  resources,
}

extension DashboardSectionX on DashboardSection {
  String get label {
    switch (this) {
      case DashboardSection.home:
        return 'Home';
      case DashboardSection.satVocabs:
        return 'SAT Vocabs';
      case DashboardSection.questionBank:
        return 'Question Bank Tracker';
      case DashboardSection.bookmarked:
        return 'Bookmarked Questions';
      case DashboardSection.answered:
        return 'Answered Questions';
      case DashboardSection.practiceSessions:
        return 'Practice Sessions';
      case DashboardSection.fullLengthTests:
        return 'Full-length Practice Tests';
      case DashboardSection.satSuite:
        return 'SAT Suite Questionbank';
      case DashboardSection.vocabFlashcards:
        return 'SAT Vocabs Flashcards';
      case DashboardSection.vocabPractice:
        return 'SAT Vocabs Practice';
      case DashboardSection.practiceRush:
        return 'Practice Rush';
      case DashboardSection.reviewPractice:
        return 'Review Practice';
      case DashboardSection.resources:
        return 'Resources';
    }
  }

  IconData get icon {
    switch (this) {
      case DashboardSection.home:
        return Icons.dashboard_outlined;
      case DashboardSection.satVocabs:
        return Icons.menu_book_outlined;
      case DashboardSection.questionBank:
        return Icons.view_list_outlined;
      case DashboardSection.bookmarked:
        return Icons.bookmark_outline;
      case DashboardSection.answered:
        return Icons.task_alt_outlined;
      case DashboardSection.practiceSessions:
        return Icons.schedule_outlined;
      case DashboardSection.fullLengthTests:
        return Icons.assignment_turned_in_outlined;
      case DashboardSection.satSuite:
        return Icons.school_outlined;
      case DashboardSection.vocabFlashcards:
        return Icons.style_outlined;
      case DashboardSection.vocabPractice:
        return Icons.edit_note_outlined;
      case DashboardSection.practiceRush:
        return Icons.flash_on_outlined;
      case DashboardSection.reviewPractice:
        return Icons.trending_up_outlined;
      case DashboardSection.resources:
        return Icons.extension_outlined;
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    WebViewPlatform.instance = WebWebViewPlatform();
  }
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NexPrep',
      theme: buildNexTheme(Brightness.light),
      darkTheme: buildNexTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const SignedInView();
        }

        return const SignInPage();
      },
    );
  }
}

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthShell();
  }
}

enum AuthView { signIn, signUp }

class AuthShell extends StatefulWidget {
  const AuthShell({super.key});

  @override
  State<AuthShell> createState() => _AuthShellState();
}

class _AuthShellState extends State<AuthShell> with SingleTickerProviderStateMixin {
  AuthView _view = AuthView.signIn;
  DateTime? _lastErrorAt;
  int _errorStreak = 0;
  bool _showCelebration = false;
  late final AnimationController _shakeController =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
  late final Animation<double> _shakeAnimation = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0, end: -8), weight: 1),
    TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 1),
    TweenSequenceItem(tween: Tween(begin: 8, end: -4), weight: 1),
    TweenSequenceItem(tween: Tween(begin: -4, end: 4), weight: 1),
    TweenSequenceItem(tween: Tween(begin: 4, end: 0), weight: 1),
  ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeOutCubic));

  bool get _appleAvailable {
    if (kIsWeb) return true;
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  void _handleError(String message) {
    if (!mounted) return;
    final now = DateTime.now();
    if (_lastErrorAt != null && now.difference(_lastErrorAt!) < const Duration(seconds: 10)) {
      _errorStreak++;
    } else {
      _errorStreak = 1;
    }
    _lastErrorAt = now;
    _shakeController.forward(from: 0);
    final friendly = _errorStreak >= 3
        ? 'Lots of attempts! You can reset your password if you’re stuck.'
        : message;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(friendly)),
    );
  }

  void _handleSuccess() {
    setState(() => _showCelebration = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _showCelebration = false);
      }
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AnimatedGradientBackground(),
          const ParticleField(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= 1100;
                final maxCardWidth = isDesktop ? 480.0 : 520.0;
                final card = AnimatedBuilder(
                  animation: _shakeController,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(_shakeAnimation.value, 0),
                    child: child,
                  ),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.98, end: 1),
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) => Transform.scale(
                      scale: value,
                      child: child,
                    ),
                    child: GlassCard(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _Wordmark(),
                          const SizedBox(height: 16),
                          SegmentedButton<AuthView>(
                            segments: const [
                              ButtonSegment(value: AuthView.signIn, label: Text('Sign in')),
                              ButtonSegment(value: AuthView.signUp, label: Text('Create account')),
                            ],
                            selected: {_view},
                            onSelectionChanged: (selection) {
                              setState(() => _view = selection.first);
                            },
                          ),
                          const SizedBox(height: 16),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            transitionBuilder: (child, animation) => FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.05, 0),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            ),
                            child: _view == AuthView.signIn
                                ? SignInForm(
                                    key: const ValueKey('sign-in'),
                                    appleAvailable: _appleAvailable,
                                    onError: _handleError,
                                    onSuccess: _handleSuccess,
                                    onSwitchToSignUp: () =>
                                        setState(() => _view = AuthView.signUp),
                                  )
                                : SignUpForm(
                                    key: const ValueKey('sign-up'),
                                    appleAvailable: _appleAvailable,
                                    onError: _handleError,
                                    onSuccess: _handleSuccess,
                                    onSwitchToSignIn: () =>
                                        setState(() => _view = AuthView.signIn),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );

                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: isDesktop
                        ? ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1200),
                            child: Row(
                              children: [
                                const Expanded(child: _AuthHeroPanel()),
                                const SizedBox(width: 32),
                                ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: maxCardWidth),
                                  child: card,
                                ),
                              ],
                            ),
                          )
                        : SingleChildScrollView(
                            child: Column(
                              children: [
                                const _AuthHeroPanel(compact: true),
                                const SizedBox(height: 24),
                                ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: maxCardWidth),
                                  child: card,
                                ),
                              ],
                            ),
                          ),
                  ),
                );
              },
            ),
          ),
          if (_showCelebration) const _SuccessCelebration(),
        ],
      ),
    );
  }
}
class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'NexPrep authentication',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NexPrep',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
          ),
          Text(
            'AI-powered SAT mastery',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: _mutedColor(context)),
          ),
        ],
      ),
    );
  }
}

class _AuthHeroPanel extends StatelessWidget {
  const _AuthHeroPanel({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 16 : 0),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            colors: [NexColors.primary, NexColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.25),
              blurRadius: 32,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Chip(
              label: const Text('Trusted by 120k+ learners'),
              avatar: const Icon(Icons.shield_outlined, size: 16),
              backgroundColor: Colors.white.withOpacity(0.18),
              labelStyle: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              'Your SAT copilot',
              style: Theme.of(context)
                  .textTheme
                  .displaySmall
                  ?.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              'Daily adaptive quizzes, AI explanations, and real-time analytics keep you locked into a winning streak.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: const [
                _HeroBullet(icon: Icons.auto_graph_outlined, label: 'Realtime proficiency radar'),
                _HeroBullet(icon: Icons.flash_on_outlined, label: 'Practice rush acceleration'),
                _HeroBullet(icon: Icons.cloud_outlined, label: 'Encrypted progress cloud'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroBullet extends StatelessWidget {
  const _HeroBullet({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isGradient = Theme.of(context).brightness == Brightness.light;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: isGradient ? Colors.white.withOpacity(0.2) : Theme.of(context).colorScheme.primary.withOpacity(0.12),
          child: Icon(icon, size: 18, color: isGradient ? Colors.white : null),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isGradient ? Colors.white : _mutedColor(context),
              ),
        ),
      ],
    );
  }
}

class GlassCard extends StatelessWidget {
  const GlassCard({required this.child, this.padding, super.key});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: padding ?? const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: isDark ? Colors.white.withOpacity(0.16) : null,
            gradient: isDark
                ? null
                : const LinearGradient(
                    colors: [Color(0xFFFDFEFF), Color(0xFFEAF0FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.45 : 0.1),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class SignInForm extends StatefulWidget {
  const SignInForm({
    required this.onError,
    required this.onSuccess,
    required this.onSwitchToSignUp,
    required this.appleAvailable,
    super.key,
  });

  final void Function(String message) onError;
  final VoidCallback onSuccess;
  final VoidCallback onSwitchToSignUp;
  final bool appleAvailable;

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      widget.onError('Please fix the highlighted fields.');
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthService.signInWithEmail(_emailController.text.trim(), _passwordController.text);
      widget.onSuccess();
    } catch (e) {
      widget.onError(e is AuthException ? e.message : 'Unable to sign in right now.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _google() async {
    setState(() => _loading = true);
    try {
      await AuthService.signInWithGoogle();
      widget.onSuccess();
    } catch (e) {
      widget.onError('Google sign-in isn’t ready yet.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _apple() async {
    setState(() => _loading = true);
    try {
      await AuthService.signInWithApple();
      widget.onSuccess();
    } catch (e) {
      widget.onError('Apple sign-in isn’t ready yet.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthTextField(
            controller: _emailController,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _passwordController,
            label: 'Password',
            obscureText: true,
            validator: (value) => (value == null || value.isEmpty) ? 'Password is required' : null,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _loading
                  ? null
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
              child: const Text('Forgot password?'),
            ),
          ),
          const SizedBox(height: 4),
          FilledButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Sign in'),
          ),
          const SizedBox(height: 16),
          const _DividerWithText(label: 'or continue with'),
          const SizedBox(height: 12),
          SocialButton(
            provider: SocialProvider.google,
            label: 'Continue with Google',
            onPressed: _loading ? null : _google,
          ),
          if (widget.appleAvailable) ...[
            const SizedBox(height: 12),
            SocialButton(
              provider: SocialProvider.apple,
              label: 'Continue with Apple',
              onPressed: _loading ? null : _apple,
            ),
          ],
          const SizedBox(height: 16),
          Text(
            'Protected by Firebase Authentication. We never sell or share your data.',
            style: theme.textTheme.bodySmall?.copyWith(color: _mutedColor(context)),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('New here?'),
              TextButton(
                onPressed: _loading ? null : widget.onSwitchToSignUp,
                child: const Text('Create an account'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SignUpForm extends StatefulWidget {
  const SignUpForm({
    required this.onError,
    required this.onSuccess,
    required this.onSwitchToSignIn,
    required this.appleAvailable,
    super.key,
  });

  final void Function(String message) onError;
  final VoidCallback onSuccess;
  final VoidCallback onSwitchToSignIn;
  final bool appleAvailable;

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _acceptTerms = false;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  double get _strength => PasswordStrengthMeter.calculateStrength(_passwordController.text);

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || !_acceptTerms) {
      widget.onError('Make sure all fields are valid and terms are accepted.');
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthService.signUpWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
      widget.onSuccess();
    } catch (e) {
      widget.onError(e is AuthException ? e.message : 'Unable to create your account.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _google() async {
    setState(() => _loading = true);
    try {
      await AuthService.signInWithGoogle();
      widget.onSuccess();
    } catch (e) {
      widget.onError('Google sign-in isn’t ready yet.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _apple() async {
    setState(() => _loading = true);
    try {
      await AuthService.signInWithApple();
      widget.onSuccess();
    } catch (e) {
      widget.onError('Apple sign-in isn’t ready yet.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Use 8 or more characters';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Add an uppercase letter';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Add a number';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthTextField(
            controller: _emailController,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _passwordController,
            label: 'Password',
            obscureText: true,
            validator: _validatePassword,
            onChanged: (_) => setState(() {}),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 8),
          PasswordStrengthMeter(
            strength: _strength,
            requirements: const [
              '8+ characters',
              'Upper & lowercase',
              'At least one number',
            ],
            password: _passwordController.text,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _confirmController,
            label: 'Confirm password',
            obscureText: true,
            validator: (value) {
              if (value != _passwordController.text) return 'Passwords must match';
              return null;
            },
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _acceptTerms,
            onChanged: _loading ? null : (value) => setState(() => _acceptTerms = value ?? false),
            title: const Text('I agree to the Terms of Service and Privacy Policy.'),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Create account'),
          ),
          const SizedBox(height: 16),
          const _DividerWithText(label: 'or continue with'),
          const SizedBox(height: 12),
          SocialButton(
            provider: SocialProvider.google,
            label: 'Continue with Google',
            onPressed: _loading ? null : _google,
          ),
          if (widget.appleAvailable) ...[
            const SizedBox(height: 12),
            SocialButton(
              provider: SocialProvider.apple,
              label: 'Continue with Apple',
              onPressed: _loading ? null : _apple,
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              const Text('Already have an account?'),
              TextButton(
                onPressed: _loading ? null : widget.onSwitchToSignIn,
                child: const Text('Sign in'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DividerWithText extends StatelessWidget {
  const _DividerWithText({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: _mutedColor(context)),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AuthService.sendPasswordResetEmail(_emailController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reset email sent. Check your inbox.')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to send reset email right now.')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset password')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Enter the email associated with your account.'),
              const SizedBox(height: 16),
              AuthTextField(
                controller: _emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Email required' : null,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Send reset link'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthTextField extends StatefulWidget {
  const AuthTextField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.validator,
    this.obscureText = false,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class GradientButton extends StatelessWidget {
  const GradientButton({
    required this.label,
    required this.onPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    this.borderRadius = 999,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final EdgeInsets padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    final colors = disabled
        ? [Colors.white24, Colors.white24]
        : NexColors.gradient;
    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: disabled ? null : onPressed,
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors),
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: disabled
                  ? null
                  : [
                      BoxShadow(
                        color: NexColors.primary.withOpacity(0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
            ),
            padding: padding,
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _obscure = widget.obscureText;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final glowColor = Theme.of(context).colorScheme.primary;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: _focusNode.hasFocus
            ? [
                BoxShadow(
                  color: glowColor.withOpacity(0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        keyboardType: widget.keyboardType,
        obscureText: _obscure,
        validator: widget.validator,
        onChanged: widget.onChanged,
        onFieldSubmitted: widget.onSubmitted,
        textInputAction: widget.textInputAction,
        decoration: InputDecoration(
          labelText: widget.label,
          suffixIcon: widget.obscureText
              ? IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                )
              : null,
        ),
      ),
    );
  }
}

enum SocialProvider { google, apple }

class SocialButton extends StatefulWidget {
  const SocialButton({
    required this.provider,
    required this.label,
    required this.onPressed,
    super.key,
  });

  final SocialProvider provider;
  final String label;
  final VoidCallback? onPressed;

  @override
  State<SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<SocialButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isApple = widget.provider == SocialProvider.apple;
    final background = isApple ? Colors.black : Colors.white;
    final foreground = isApple ? Colors.white : Colors.black87;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 120),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: background,
            foregroundColor: foreground,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(vertical: 14),
            elevation: 0,
          ),
          onPressed: widget.onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(isApple ? Icons.apple : Icons.g_mobiledata, size: 24),
              const SizedBox(width: 8),
              Text(widget.label),
            ],
          ),
        ),
      ),
    );
  }
}

class PasswordStrengthMeter extends StatelessWidget {
  const PasswordStrengthMeter({
    required this.strength,
    required this.requirements,
    required this.password,
    super.key,
  });

  final double strength;
  final List<String> requirements;
  final String password;

  static double calculateStrength(String password) {
    if (password.isEmpty) return 0;
    double score = 0;
    if (password.length >= 8) score += 0.34;
    if (RegExp(r'[A-Z]').hasMatch(password) && RegExp(r'[a-z]').hasMatch(password)) {
      score += 0.33;
    }
    if (RegExp(r'[0-9]').hasMatch(password)) score += 0.2;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) score += 0.13;
    return score.clamp(0, 1);
  }

  @override
  Widget build(BuildContext context) {
    final color = strength > 0.75
        ? Colors.greenAccent
        : strength > 0.4
            ? Colors.orangeAccent
            : Colors.redAccent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: strength,
          minHeight: 6,
          backgroundColor: Colors.white12,
          color: color,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: requirements
              .map(
                (req) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _requirementMet(req, password) ? Icons.check_circle : Icons.radio_button_unchecked,
                      size: 16,
                      color: _requirementMet(req, password)
                          ? Colors.greenAccent
                          : _mutedColor(context),
                    ),
                    const SizedBox(width: 4),
                    Text(req, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  static bool _requirementMet(String requirement, String password) {
    switch (requirement) {
      case '8+ characters':
        return password.length >= 8;
      case 'Upper & lowercase':
        return RegExp(r'[A-Z]').hasMatch(password) && RegExp(r'[a-z]').hasMatch(password);
      case 'At least one number':
        return RegExp(r'[0-9]').hasMatch(password);
      default:
        return false;
    }
  }
}

class AnimatedGradientBackground extends StatefulWidget {
  const AnimatedGradientBackground({super.key});

  @override
  State<AnimatedGradientBackground> createState() => _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const lightPalette = [
      Color(0xFFF7FAFF),
      Color(0xFFDDE9FF),
      Color(0xFFAEC8FF),
    ];
    const darkPalette = [
      Color(0xFF06102B),
      Color(0xFF0B1A3F),
      Color(0xFF172853),
    ];
    final palette = isDark ? darkPalette : lightPalette;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final alignment = Alignment(math.sin(t * math.pi * 2), math.cos(t * math.pi * 2));
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: alignment,
              end: -alignment,
              colors: palette,
            ),
          ),
        );
      },
    );
  }
}

class ParticleField extends StatefulWidget {
  const ParticleField({super.key});

  @override
  State<ParticleField> createState() => _ParticleFieldState();
}

class _ParticleFieldState extends State<ParticleField> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 30))..repeat();
  late final List<_Particle> _particles = List.generate(
    40,
    (index) => _Particle(
      position: Offset(math.Random().nextDouble(), math.Random().nextDouble()),
      size: 2 + math.Random().nextDouble() * 3,
      speed: 0.02 + math.Random().nextDouble() * 0.05,
      tint: math.Random().nextDouble(),
    ),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _ParticlePainter(
            _particles,
            _controller.value,
            Theme.of(context).brightness == Brightness.dark,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _Particle {
  _Particle({
    required this.position,
    required this.size,
    required this.speed,
    required this.tint,
  });
  final Offset position;
  final double size;
  final double speed;
  final double tint;
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter(this.particles, this.progress, this.isDark);

  final List<_Particle> particles;
  final double progress;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final particle in particles) {
      final dx = (particle.position.dx * size.width) +
          math.sin(progress * 2 * math.pi + particle.speed) * 10;
      final dy = (particle.position.dy * size.height + progress * 120 * particle.speed) % size.height;
      final baseColor = isDark ? const Color(0xFF9DB1FF) : const Color(0xFF7DA5FF);
      paint.color = baseColor.withOpacity(isDark ? 0.25 + particle.tint * 0.3 : 0.4);
      canvas.drawCircle(Offset(dx, dy), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _SuccessCelebration extends StatefulWidget {
  const _SuccessCelebration();

  @override
  State<_SuccessCelebration> createState() => _SuccessCelebrationState();
}

class _SuccessCelebrationState extends State<_SuccessCelebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Opacity(
          opacity: 1 - _controller.value,
          child: child,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: 1 + (_controller.value * 0.1),
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Icon(Icons.check, color: Theme.of(context).colorScheme.primary, size: 48),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'You’re in! 🎉',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MilestoneConfettiOverlay extends StatefulWidget {
  const MilestoneConfettiOverlay({required this.milestone, super.key});

  final int milestone;

  @override
  State<MilestoneConfettiOverlay> createState() => _MilestoneConfettiOverlayState();
}

class _MilestoneConfettiOverlayState extends State<MilestoneConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));
  late Animation<double> _animation;
  int _currentMilestone = 0;
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    _currentMilestone = widget.milestone;
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _visible = false);
      }
    });
  }

  @override
  void didUpdateWidget(covariant MilestoneConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.milestone != _currentMilestone) {
      _currentMilestone = widget.milestone;
      _visible = true;
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return IgnorePointer(
      ignoring: true,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final opacity = 1 - _animation.value;
          return Opacity(
            opacity: opacity.clamp(0, 1),
            child: child,
          );
        },
        child: Stack(
          children: [
            ...List.generate(30, (index) {
              final random = math.Random(index * DateTime.now().millisecond);
              final left = random.nextDouble();
              final top = random.nextDouble();
              final size = 12.0 + random.nextDouble() * 18;
              final color = random.nextBool() ? NexColors.primary : NexColors.secondary;
              return Positioned(
                left: left * MediaQuery.of(context).size.width,
                top: top * MediaQuery.of(context).size.height * 0.6,
                child: Icon(Icons.auto_awesome, size: size, color: color.withOpacity(0.8)),
              );
            }),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Milestone unlocked: ${widget.milestone}-day streak!',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(32);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF1B233A) : Colors.white;
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: padding ?? const EdgeInsets.all(28),
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            color: baseColor,
            gradient: isDark
                ? const LinearGradient(
                    colors: [Color(0xFF1F2947), Color(0xFF1B2338)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : const LinearGradient(
                    colors: [Color(0xFFFFFFFF), Color(0xFFF6F8FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            border: Border.all(
              color: isDark ? Colors.white12 : NexColors.neutralBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.35 : 0.08),
                blurRadius: 50,
                spreadRadius: -20,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _NebulaBackground extends StatelessWidget {
  const _NebulaBackground();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFDFDFF), Color(0xFFF4F6FF), Color(0xFFE9ECFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: const [
            _GlowOrb(
              alignment: Alignment.topRight,
              size: 320,
              color: Color(0xFFB3B7FF),
              blur: 180,
            ),
            _GlowOrb(
              alignment: Alignment.bottomLeft,
              size: 360,
              color: Color(0xFF6F73FF),
              blur: 200,
            ),
            _GlowOrb(
              alignment: Alignment.centerLeft,
              size: 240,
              color: Color(0xFF4E5FFF),
              blur: 220,
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Color(0x44FFFFFF)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.alignment,
    required this.size,
    required this.color,
    this.blur = 120,
  });

  final Alignment alignment;
  final double size;
  final Color color;
  final double blur;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: blur,
              spreadRadius: 10,
            ),
          ],
        ),
      ),
    );
  }
}

class SignedInView extends StatefulWidget {
  const SignedInView({super.key});

  @override
  State<SignedInView> createState() => _SignedInViewState();
}

class _SignedInViewState extends State<SignedInView> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  DashboardSection _section = DashboardSection.home;
  bool _isDarkMode = true;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 1024;
    final dashboardTheme = buildNexTheme(_isDarkMode ? Brightness.dark : Brightness.light);
    return PracticeTimeTracker(
      child: Theme(
        data: dashboardTheme,
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.transparent,
          drawerEnableOpenDragGesture: !isWide,
          drawer: isWide
              ? null
              : Drawer(
                  child: DashboardSidebar(
                    isDarkMode: _isDarkMode,
                    selected: _section,
                    onSelect: (section) {
                      setState(() => _section = section);
                      Navigator.of(context).pop();
                    },
                    onToggleDarkMode: () => setState(() => _isDarkMode = !_isDarkMode),
                  ),
                ),
          body: Stack(
            fit: StackFit.expand,
            children: [
              const AnimatedGradientBackground(),
              const ParticleField(),
              SafeArea(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isWide)
                      SizedBox(
                        width: 280,
                        child: DashboardSidebar(
                          isDarkMode: _isDarkMode,
                          selected: _section,
                          onSelect: (section) => setState(() => _section = section),
                          onToggleDarkMode: () => setState(() => _isDarkMode = !_isDarkMode),
                        ),
                      ),
                    Expanded(
                      child: Column(
                        children: [
                          DashboardTopBar(
                            isDarkMode: _isDarkMode,
                            onMenuTap: isWide ? null : () => _scaffoldKey.currentState?.openDrawer(),
                            onToggleTheme: () => setState(() => _isDarkMode = !_isDarkMode),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              switchOutCurve: Curves.easeInCubic,
                              switchInCurve: Curves.easeOutBack,
                              child: _buildSectionView(_section),
                            ),
                          ),
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

  Widget _buildSectionView(DashboardSection section) {
    switch (section) {
      case DashboardSection.home:
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid == null) {
          return const SizedBox.shrink();
        }
        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection(AuthService.usersCollection).doc(uid).snapshots(),
          builder: (context, snapshot) {
            final data = snapshot.data?.data();
            final streak = (data?['streak'] as int?) ?? 1;
            final highestMilestone = (data?['highestMilestone'] as int?) ?? 0;
            final lastMilestoneAt = (data?['lastMilestoneAt'] as Timestamp?);
            final now = DateTime.now();
            final celebrate = lastMilestoneAt != null && _isSameDay(lastMilestoneAt.toDate(), now);
            return StreamBuilder<Duration>(
              stream: PracticeSessionService.totalPracticeDurationStream(uid),
              builder: (context, durationSnapshot) {
                final practiceDuration = durationSnapshot.data ?? Duration.zero;
                return HomeDashboardView(
                  isDarkMode: _isDarkMode,
                  streak: streak,
                  highestMilestone: highestMilestone,
                  practiceDuration: practiceDuration,
                  celebrationMilestone: celebrate ? highestMilestone : null,
                );
              },
            );
          },
        );
      case DashboardSection.satVocabs:
        return const SatVocabsView();
      case DashboardSection.questionBank:
        return const QuestionBankView();
      case DashboardSection.bookmarked:
        return const BookmarkedAnsweredView(initialTab: 0);
      case DashboardSection.answered:
        return const BookmarkedAnsweredView(initialTab: 1);
      case DashboardSection.practiceSessions:
        return const PracticeSessionsView();
      case DashboardSection.fullLengthTests:
        return const FullLengthTestsView();
      case DashboardSection.satSuite:
        return const SatSuiteView();
      case DashboardSection.vocabFlashcards:
        return const VocabFlashcardsView();
      case DashboardSection.vocabPractice:
        return const VocabPracticeView();
      case DashboardSection.practiceRush:
        return const PracticeRushView();
      case DashboardSection.reviewPractice:
        return const ReviewPracticeView();
      case DashboardSection.resources:
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid == null) return const SizedBox.shrink();
        return ResourcesView(uid: uid);
    }
  }
}

class _AccountSecuritySheet extends StatelessWidget {
  const _AccountSecuritySheet();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.9),
        title: const Text('Security overview'),
      ),
      body: Stack(
        children: [
          const _NebulaBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _GlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.fingerprint),
                      title: const Text('UID'),
                      subtitle: Text(user?.uid ?? 'Unknown'),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.timer_outlined),
                      title: const Text('Creation time'),
                      subtitle: Text(
                        user?.metadata.creationTime?.toLocal().toString() ?? 'Unavailable',
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.update),
                      title: const Text('Last sign-in'),
                      subtitle: Text(
                        user?.metadata.lastSignInTime?.toLocal().toString() ?? 'Unavailable',
                      ),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Return'),
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
}

class DashboardTopBar extends StatelessWidget {
  const DashboardTopBar({
    required this.isDarkMode,
    required this.onMenuTap,
    required this.onToggleTheme,
    super.key,
  });

  final bool isDarkMode;
  final VoidCallback? onMenuTap;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (onMenuTap != null)
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: onMenuTap,
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting(),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      '${user?.displayName ?? 'Kumar'}, ready for elite SAT wins?',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: _mutedColor(context)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.08)
                      : const Color(0xFFE7EDFF),
                ),
                child: const Text(
                  'SAT focus',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                tooltip: 'Toggle dark mode',
                onPressed: onToggleTheme,
                icon: Icon(isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

}

class QuestionBankView extends StatelessWidget {
  const QuestionBankView({super.key});

  @override
  Widget build(BuildContext context) {
    final summary = [
      ('Answered', '142'),
      ('Accuracy', '78%'),
      ('Avg. difficulty', '3.2 / 5'),
    ];
    final statuses = [
      ('Linear equations drill', '✅ Answered'),
      ('Vocabulary mix', '🔖 Bookmarked'),
      ('Reading paired passages', '⏳ Unanswered'),
      ('Geometry booster', '✅ Answered'),
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Question bank tracker', subtitle: 'Filters + modular status cards'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilterChip(label: const Text('Section: Math'), selected: true, onSelected: (_) {}),
              FilterChip(label: const Text('Topic: Word problems'), selected: false, onSelected: (_) {}),
              FilterChip(label: const Text('Difficulty: Medium'), selected: false, onSelected: (_) {}),
              FilterChip(label: const Text('Status: Bookmarked'), selected: false, onSelected: (_) {}),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: summary
                .map(
                  (item) => Expanded(
                    child: _GlassPanel(
                      child: Column(
                        children: [
                          Text(item.$1, style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(height: 4),
                          Text(item.$2, style: Theme.of(context).textTheme.titleMedium),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
          ...statuses.map(
            (status) => Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(status.$1),
                subtitle: Text(status.$2),
                trailing: IconButton(icon: const Icon(Icons.arrow_outward), onPressed: () {}),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BookmarkedAnsweredView extends StatelessWidget {
  const BookmarkedAnsweredView({required this.initialTab, super.key});

  final int initialTab;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: initialTab,
      length: 2,
      child: Column(
        children: [
          _SectionHeader(
            title: 'Bookmarks & answered questions',
            subtitle: 'Focus on review and accountability',
          ),
          const TabBar(
            tabs: [
              Tab(text: 'Bookmarked'),
              Tab(text: 'Answered'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _QuestionList(statusEmoji: '🔖', emptyLabel: 'No bookmarks added'),
                _QuestionList(statusEmoji: '✅', emptyLabel: 'No answers logged yet'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionList extends StatelessWidget {
  const _QuestionList({required this.statusEmoji, required this.emptyLabel});
  final String statusEmoji;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    final questions = [
      ('Function transformations', 'Math • Medium'),
      ('Historical narrative tone', 'Reading • Hard'),
      ('Concise sentence rewrite', 'Writing • Easy'),
    ];
    if (questions.isEmpty) {
      return Center(child: Text(emptyLabel));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      primary: false,
      itemBuilder: (context, index) {
        final question = questions[index];
        return ListTile(
          title: Text('$statusEmoji ${question.$1}'),
          subtitle: Text(question.$2),
          trailing: FilledButton.tonal(
            onPressed: () {},
            child: const Text('Open'),
          ),
        );
      },
      separatorBuilder: (_, __) => const Divider(),
      itemCount: questions.length,
    );
  }
}

class PracticeSessionsView extends StatefulWidget {
  const PracticeSessionsView({super.key});

  @override
  State<PracticeSessionsView> createState() => _PracticeSessionsViewState();
}

class _PracticeSessionsViewState extends State<PracticeSessionsView> {
  String? _activeSessionId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _hydrateActiveSession();
  }

  Future<void> _hydrateActiveSession() async {
    final activeId = await PracticeSessionService.fetchActiveSessionId();
    if (!mounted) return;
    setState(() => _activeSessionId = activeId);
  }

  Future<void> _toggleSession() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      if (_activeSessionId == null) {
        final sessionId = await PracticeSessionService.startSession();
        if (!mounted) return;
        setState(() => _activeSessionId = sessionId);
        _showSnack('Practice session started.');
      } else {
        await PracticeSessionService.endSession(sessionId: _activeSessionId);
        if (!mounted) return;
        setState(() => _activeSessionId = null);
        _showSnack('Practice session ended.');
      }
    } on AuthException catch (e) {
      _showSnack(e.message);
    } catch (_) {
      _showSnack('Unable to update practice session. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final isActive = _activeSessionId != null;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Practice sessions', subtitle: 'Filters + real-time progress'),
          _GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: const [
                    _SessionFilter(label: 'Section', value: 'Math'),
                    _SessionFilter(label: 'Topic', value: 'Geometry'),
                    _SessionFilter(label: 'Difficulty', value: 'Medium'),
                    _SessionFilter(label: '# Questions', value: '20'),
                  ],
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _isLoading ? null : _toggleSession,
                  icon: Icon(isActive ? Icons.stop_rounded : Icons.play_arrow_rounded),
                  label: Text(isActive ? 'End session' : 'Start new session'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Session 07 • Math focus', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: 0.45,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFE4E7FF),
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  const SizedBox(height: 12),
                  Text('9 / 20 questions answered'),
                  ButtonBar(
                    alignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () {}, child: const Text('Check answer')),
                      FilledButton.tonal(onPressed: () {}, child: const Text('Show explanation')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionFilter extends StatelessWidget {
  const _SessionFilter({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0xFFF4F6FF),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(width: 6),
          Text(value, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}

class FullLengthTestsView extends StatefulWidget {
  const FullLengthTestsView({super.key});

  @override
  State<FullLengthTestsView> createState() => _FullLengthTestsViewState();
}

class _FullLengthTestsViewState extends State<FullLengthTestsView> {
  final List<(String title, String meta)> _tests = [
    ('SAT Practice Test 1', 'Digital • 154 questions • 2h 14m'),
    ('SAT Practice Test 2', 'Digital • Adaptive • 2h 14m'),
    ('SAT Practice Test 3', 'Adaptive • Official-style timing'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'Full-length practice tests',
            subtitle: 'High-fidelity simulations with pacing + scoring',
          ),
          const SizedBox(height: 20),
          if (_tests.isEmpty)
            _EmptyStateCard(
              message: 'No SAT tests yet — check back soon for fresh releases.',
              buttonLabel: 'Notify me',
            )
          else
            Column(
              children: _tests
                  .map(
                    (test) => _GlassPanel(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(test.$1, style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 4),
                                Text(test.$2, style: Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ),
                          FilledButton(
                            onPressed: () {},
                            child: const Text('Start test'),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class SatSuiteView extends StatelessWidget {
  const SatSuiteView({super.key});

  @override
  Widget build(BuildContext context) {
    final sets = [
      ('Digital SAT QBank 1', '58 questions • Official'),
      ('Digital SAT QBank 2', '64 questions • Official'),
      ('SAT Quick Drill Pack', '30 questions • Mixed practice'),
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: sets.length,
      itemBuilder: (context, index) {
        final set = sets[index];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            title: Text(set.$1),
            subtitle: Text(set.$2),
            trailing: FilledButton(onPressed: () {}, child: const Text('Open')),
          ),
        );
      },
    );
  }
}

class VocabFlashcardsView extends StatelessWidget {
  const VocabFlashcardsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _FlashcardGrid();
  }
}

class VocabPracticeView extends StatelessWidget {
  const VocabPracticeView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _VocabPracticeList();
  }
}

class PracticeRushView extends StatelessWidget {
  const PracticeRushView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            colors: [Color(0xFF141B3A), Color(0xFF2A1F54), Color(0xFF4E5FFF)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4E5FFF).withOpacity(0.4),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Practice Rush',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              '60-second timed challenge with score multiplier',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 1, end: 0),
              duration: const Duration(seconds: 60),
              builder: (context, value, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 160,
                      height: 160,
                      child: CircularProgressIndicator(
                        value: value,
                        strokeWidth: 12,
                        color: Colors.amberAccent,
                        backgroundColor: Colors.white24,
                      ),
                    ),
                    Text('${(value * 60).round()}s',
                        style: const TextStyle(color: Colors.white, fontSize: 28)),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(backgroundColor: Colors.white),
              child: Text('Start rush', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            ),
          ],
        ),
      ),
    );
  }
}

class ReviewPracticeView extends StatelessWidget {
  const ReviewPracticeView({super.key});

  @override
  Widget build(BuildContext context) {
    final weakTopics = [
      'Inference questions',
      'Systems of equations',
      'Transitions & cohesion',
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Review practice', subtitle: 'Accuracy over time & weak topics'),
          _GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Accuracy over time', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                SizedBox(
                  height: 160,
                  child: CustomPaint(
                    painter: _TrendChartPainter(),
                    child: Container(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Weak topics summary', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ...weakTopics.map((topic) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.warning_amber, color: Colors.orange),
                      title: Text(topic),
                    )),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () {},
                  child: const Text('Regenerate custom quiz'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4E5FFF)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final path = Path();
    final points = [
      Offset(0, size.height * 0.7),
      Offset(size.width * 0.2, size.height * 0.5),
      Offset(size.width * 0.4, size.height * 0.6),
      Offset(size.width * 0.6, size.height * 0.4),
      Offset(size.width * 0.8, size.height * 0.35),
      Offset(size.width, size.height * 0.3),
    ];
    path.moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ResourcesView extends StatelessWidget {
  const ResourcesView({required this.uid, super.key});

  final String uid;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          sliver: SliverToBoxAdapter(child: VideoLessonsSection(uid: uid)),
        ),
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(24, 0, 24, 12),
          sliver: SliverToBoxAdapter(child: DesmosMasterySection()),
        ),
      ],
    );
  }
}

class DesmosMasterySection extends StatefulWidget {
  const DesmosMasterySection({super.key});

  @override
  State<DesmosMasterySection> createState() => _DesmosMasterySectionState();
}

class _DesmosMasterySectionState extends State<DesmosMasterySection> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController();
    if (!kIsWeb) {
      _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    }
    if (!kIsWeb) {
      _controller.setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) {
              setState(() => _loading = false);
            }
          },
        ),
      );
    } else {
      _loading = false;
    }
    final html = '''
<!DOCTYPE html>
<html>
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://www.desmos.com/api/v1.11/calculator.js?apiKey=542285d0c5e041669d678eaa40d62fcb"></script>
    <style>
      html, body, #calculator {
        margin: 0;
        padding: 0;
        width: 100%;
        height: 100%;
        background: transparent;
      }
    </style>
  </head>
  <body>
    <div id="calculator"></div>
    <script>
      const elt = document.getElementById('calculator');
      const calculator = Desmos.GraphingCalculator(elt, {
        expressions: true,
        settingsMenu: true,
        zoomButtons: true,
        projectorMode: false,
      });
    </script>
  </body>
</html>
''';
    _controller.loadHtmlString(html);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Desmos Mastery Lab', style: theme.textTheme.titleLarge),
              TextButton.icon(
                onPressed: () => _controller.reload(),
                icon: const Icon(Icons.refresh),
                label: const Text('Reload'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Build calculator fluency with the official Desmos graphing experience used on the SAT.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 16 / 10,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  WebViewWidget(controller: _controller),
                  if (_loading)
                    const Positioned.fill(
                      child: ColoredBox(
                        color: Colors.black12,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: const [
              _DesmosTip(icon: Icons.timeline, text: 'Graph function families & intersections'),
              _DesmosTip(icon: Icons.square_foot, text: 'Practice plotting SAT-style inequalities'),
              _DesmosTip(icon: Icons.touch_app, text: 'Use sliders to model quick “what-if” checks'),
            ],
          ),
        ],
      ),
    );
  }
}

class _DesmosTip extends StatelessWidget {
  const _DesmosTip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}

class VideoLessonsSection extends StatefulWidget {
  const VideoLessonsSection({required this.uid, super.key});

  final String uid;

  @override
  State<VideoLessonsSection> createState() => _VideoLessonsSectionState();
}

class _VideoLessonsSectionState extends State<VideoLessonsSection> {
  late Future<VideoLessonsData> _lessonsFuture;
  String? _selectedVideoId;
  WebViewController? _playerController;

  static const _suggestions = [
    ('Launch Practice Rush', 'Beat your previous time in a 60-second sprint.'),
    ('Review bookmarked questions', 'Revisit tricky items and reinforce learning.'),
    ('Regenerate custom quiz', 'Focus on your weakest math and R&W topics.'),
  ];

  @override
  void initState() {
    super.initState();
    _lessonsFuture = VideoLessonsRepository.fetchLessons(widget.uid);
    _playerController = _createController();
  }

  WebViewController _createController() {
    final controller = WebViewController();
    if (!kIsWeb) {
      controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    }
    return controller;
  }

  void _refreshLessons() {
    setState(() {
      _lessonsFuture = VideoLessonsRepository.fetchLessons(
        widget.uid,
        forceRefresh: true,
      );
    });
  }

  Future<void> _markDone(SatVideo video) async {
    await VideoLessonsRepository.markCompleted(widget.uid, video);
    if (!mounted) return;
    if (_selectedVideoId == video.id) {
      setState(() => _selectedVideoId = null);
    }
    _refreshLessons();
  }

  void _ensureSelection(List<SatVideo> videos) {
    if (videos.isEmpty) return;
    final hasSelected = videos.any((video) => video.id == _selectedVideoId);
    if (_selectedVideoId == null || !hasSelected) {
      final nextId = videos.first.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _selectedVideoId = nextId);
        _loadVideo(nextId);
      });
    }
  }

  void _playVideo(String videoId) {
    if (_selectedVideoId == videoId) return;
    setState(() => _selectedVideoId = videoId);
    _loadVideo(videoId);
  }

  void _loadVideo(String videoId) {
    final url = Uri.parse(
      'https://www.youtube.com/embed/$videoId?rel=0&playsinline=1&modestbranding=1',
    );
    _playerController ??= _createController();
    _playerController!.loadRequest(url);
  }

  @override
  void dispose() {
    _playerController = null;
    super.dispose();
  }

  void _showCompletedDialog(List<SatVideo> completed, BuildContext context) {
    if (completed.isEmpty) {
      showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Completed videos'),
          content: const Text('You have not completed any videos yet.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
          ],
        ),
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 520, maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 12, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Completed videos', style: TextStyle(fontWeight: FontWeight.w600)),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final video = completed[index];
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(video.thumbnailUrl, width: 72, height: 48, fit: BoxFit.cover),
                      ),
                      title: Text(video.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                      subtitle: Text(video.channel),
                      trailing: FilledButton.tonal(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _playVideo(video.id);
                        },
                        child: const Text('Play'),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const Divider(),
                  itemCount: completed.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      child: FutureBuilder<VideoLessonsData>(
        future: _lessonsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SAT Video Lessons', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Text(
                    'Unable to load videos right now. Please try again later.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }
          final payload = snapshot.data ??
              const VideoLessonsData(videos: [], completed: [], exhausted: false);
          final videos = payload.videos;

          if (videos.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SAT Video Lessons', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Text(
                    payload.exhausted
                        ? 'You’ve completed today’s SAT video queue. New lessons arrive every 24 hours.'
                        : 'No SAT video lessons available right now. Please check back soon.',
                  ),
                  const SizedBox(height: 16),
                  if (payload.exhausted)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('While you wait, try:', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        ..._suggestions.map(
                          (suggestion) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.auto_awesome, color: NexColors.secondary),
                            title: Text(suggestion.$1),
                            subtitle: Text(suggestion.$2),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      FilledButton.tonal(
                        onPressed: _refreshLessons,
                        child: const Text('Refresh now'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () => _showCompletedDialog(payload.completed, context),
                        icon: const Icon(Icons.video_library_outlined),
                        label: const Text('View completed'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }

          _ensureSelection(videos);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('SAT Video Lessons', style: Theme.of(context).textTheme.titleLarge),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: _refreshLessons,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () =>
                        _showCompletedDialog(payload.completed, context),
                    icon: const Icon(Icons.video_library_outlined),
                    label: const Text('Completed'),
                  ),
                ],
              ),
            ],
          ),
              const SizedBox(height: 12),
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: _playerController == null
                      ? const Center(child: CircularProgressIndicator())
                      : WebViewWidget(controller: _playerController!),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 250,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(bottom: 8),
                  itemBuilder: (context, index) {
                    final video = videos[index];
                    final selected = video.id == _selectedVideoId;
                    return SizedBox(
                      width: 220,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: selected ? NexColors.secondary.withOpacity(0.12) : null,
                              border: Border.all(
                                color: selected
                                    ? NexColors.secondary
                                    : NexColors.neutralBorder.withOpacity(0.5),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () => _playVideo(video.id),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      video.thumbnailUrl,
                                      height: 90,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  video.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  video.channel,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 32,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                              TextButton(
                                onPressed: () => _playVideo(video.id),
                                child: const Text('Watch'),
                              ),
                              IconButton(
                                tooltip: 'Mark as done',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints.tightFor(width: 32, height: 32),
                                onPressed: () => _markDone(video),
                                icon: const Icon(Icons.check_circle_outline, size: 20),
                              ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemCount: videos.length,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class SatVideo {
  const SatVideo({
    required this.id,
    required this.title,
    required this.channel,
    required this.thumbnailUrl,
  });

  final String id;
  final String title;
  final String channel;
  final String thumbnailUrl;

  factory SatVideo.fromMap(Map<String, dynamic> map) => SatVideo(
        id: map['id'] as String? ?? '',
        title: map['title'] as String? ?? '',
        channel: map['channel'] as String? ?? '',
        thumbnailUrl: map['thumbnailUrl'] as String? ?? '',
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'channel': channel,
        'thumbnailUrl': thumbnailUrl,
      };

  factory SatVideo.placeholder(String id) => SatVideo(
        id: id,
        title: 'Completed video',
        channel: 'SAT Prep',
        thumbnailUrl: 'https://img.youtube.com/vi/$id/mqdefault.jpg',
      );
}

class YoutubeLessonsService {
  YoutubeLessonsService._();

  static const _apiKey = 'AIzaSyDh2DoRnBVIjsmhacfnXGNY74crWT46pQI';
  static const _baseUrl = 'https://www.googleapis.com/youtube/v3/search';

  static Future<List<SatVideo>> fetchSatVideos({int maxResults = 6}) async {
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'key': _apiKey,
      'part': 'snippet',
      'maxResults': '$maxResults',
      'q': 'SAT prep',
      'type': 'video',
      'videoEmbeddable': 'true',
      'safeSearch': 'moderate',
      'order': 'relevance',
    });
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load SAT videos (${response.statusCode})');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final items = (decoded['items'] as List?) ?? [];
    return items
        .map((item) {
          final id = item['id']?['videoId'] as String?;
          final snippet = item['snippet'] as Map<String, dynamic>?;
          if (id == null || snippet == null) return null;
          final thumbnails = snippet['thumbnails'] as Map<String, dynamic>? ?? {};
          final high = thumbnails['high'] as Map<String, dynamic>? ?? {};
          return SatVideo(
            id: id,
            title: snippet['title'] as String? ?? 'SAT Lesson',
            channel: snippet['channelTitle'] as String? ?? 'YouTube',
            thumbnailUrl: high['url'] as String? ?? 'https://img.youtube.com/vi/$id/mqdefault.jpg',
          );
        })
        .whereType<SatVideo>()
        .toList();
  }
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthService {
  static FirebaseAuth get _auth => FirebaseAuth.instance;
  static const usersCollection = 'Users';
  static const List<int> milestones = [3, 7, 14, 30, 60, 100];

  static Future<void> signInWithEmail(String email, String password) async {
    try {
      final credential =
          await _auth.signInWithEmailAndPassword(email: email, password: password);
      final user = credential.user;
      if (user != null) {
        await upsertUserDocument(
          uid: user.uid,
          name: user.displayName ?? '',
          email: user.email ?? email,
        );
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e));
    }
  }

  static Future<void> signUpWithEmail(String email, String password) async {
    try {
      final credential =
          await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final user = credential.user;
      if (user != null) {
        await upsertUserDocument(uid: user.uid, name: user.displayName ?? '', email: email);
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e));
    }
  }

  static Future<void> signInWithGoogle() async {
    try {
      final credential = await _signInWithGoogle();
      final user = credential.user;
      if (user != null) {
        await upsertUserDocument(
          uid: user.uid,
          name: user.displayName ?? '',
          email: user.email ?? '',
        );
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e));
    }
  }

  static Future<void> signInWithApple() async {
    throw const AuthException('Sign in with Apple will be available soon.');
  }

  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e));
    }
  }

  static String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
        return 'Invalid email or password. Please try again.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support.';
      case 'email-already-in-use':
        return 'That email already has an account. Try signing in.';
      case 'weak-password':
        return 'Please choose a stronger password.';
      case 'network-request-failed':
        return 'Check your connection and try again.';
      default:
        return e.message ?? 'Something went wrong. Please try again.';
    }
  }

  static Future<void> upsertUserDocument({
    required String uid,
    required String name,
    required String email,
  }) {
    final safeName = name.isNotEmpty ? name : 'NexPrep Scholar';
    final usersRef = FirebaseFirestore.instance.collection(usersCollection).doc(uid);
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(usersRef);
      final now = DateTime.now().toUtc();
      final loginDay = DateTime(now.year, now.month, now.day);
      int streak = 1;
      int previousMilestone = 0;
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        final lastLoginTs = data['lastLogin'] as Timestamp?;
        final previousStreak = (data['streak'] as int?) ?? 1;
        previousMilestone = (data['highestMilestone'] as int?) ?? 0;
        if (lastLoginTs != null) {
          final last = lastLoginTs.toDate().toUtc();
          final lastDay = DateTime(last.year, last.month, last.day);
          final diff = loginDay.difference(lastDay).inDays;
          if (diff == 0) {
            streak = previousStreak;
          } else if (diff == 1) {
            streak = previousStreak + 1;
          } else {
            streak = 1;
          }
        }
      }
      final payload = {
        'name': safeName,
        'email': email,
        'streak': streak,
        'lastLogin': Timestamp.fromDate(loginDay),
      };
      final milestone = _milestoneForStreak(streak);
      if (milestone > previousMilestone) {
        payload['highestMilestone'] = milestone;
        payload['lastMilestoneAt'] = Timestamp.now();
      }
      transaction.set(
        usersRef,
        payload,
        SetOptions(merge: true),
      );
    });
  }

  static int _milestoneForStreak(int streak) {
    for (final milestone in milestones.reversed) {
      if (streak >= milestone) return milestone;
    }
    return 0;
  }
}

class PracticeSessionService {
  PracticeSessionService._();

  static FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  static FirebaseAuth get _auth => FirebaseAuth.instance;
  static const _sessionsCollection = 'Practice Sessions';
  static const _realtimeDoc = 'Time Stamps';
  static const _startField = 'Start Time';
  static const _endField = 'End Time';
  static const _totalField = 'totalSeconds';
  static const _baselineField = 'baselineSeconds';

  static CollectionReference<Map<String, dynamic>> _sessionsRef(String uid) {
    return _firestore
        .collection(AuthService.usersCollection)
        .doc(uid)
        .collection(_sessionsCollection);
  }

  static DocumentReference<Map<String, dynamic>> _realtimeRef(String uid) =>
      _sessionsRef(uid).doc(_realtimeDoc);

  static Future<String> startSession() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthException('Please sign in to start a practice session.');
    }
    final existing = await fetchActiveSessionId();
    if (existing != null) {
      return existing;
    }
    final doc = await _sessionsRef(user.uid).add({
      _startField: Timestamp.now(),
      _endField: null,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'platform': kIsWeb ? 'web' : defaultTargetPlatform.name,
    });
    return doc.id;
  }

  static Future<void> endSession({String? sessionId}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthException('Please sign in to end a practice session.');
    }
    DocumentReference<Map<String, dynamic>>? target;
    if (sessionId != null) {
      target = _sessionsRef(user.uid).doc(sessionId);
    } else {
      final query =
          await _sessionsRef(user.uid).where('isActive', isEqualTo: true).limit(1).get();
      if (query.docs.isNotEmpty) {
        target = query.docs.first.reference;
      }
    }
    if (target == null) {
      return;
    }
    await target.update({
      _endField: Timestamp.now(),
      'isActive': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<String?> fetchActiveSessionId() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final query =
        await _sessionsRef(user.uid).where('isActive', isEqualTo: true).limit(1).get();
    if (query.docs.isEmpty) return null;
    return query.docs.first.id;
  }

  static Future<DateTime?> beginRealtimeTracking() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final ref = _realtimeRef(user.uid);
    return _firestore.runTransaction((txn) async {
      final snapshot = await txn.get(ref);
      final now = DateTime.now();
      Map<String, dynamic>? data;
      if (snapshot.exists) {
        data = snapshot.data();
        final tracking = (data?['isTracking'] as bool?) ?? false;
        final start = (data?[_startField] as Timestamp?)?.toDate();
        if (tracking && start != null) {
          return start;
        }
      }
      final previousTotal = (data?[_totalField] as int?) ?? 0;
      txn.set(
        ref,
        {
          _startField: Timestamp.fromDate(now),
          _endField: Timestamp.fromDate(now),
          'isTracking': true,
          'sessionType': 'auto',
          _baselineField: previousTotal,
          _totalField: previousTotal,
        },
        SetOptions(merge: true),
      );
      return now;
    });
  }

  static Future<void> updateRealtimeTracking() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final ref = _realtimeRef(user.uid);
    await _firestore.runTransaction((txn) async {
      final snapshot = await txn.get(ref);
      if (!snapshot.exists) return;
      final data = snapshot.data();
      final start = (data?[_startField] as Timestamp?)?.toDate();
      if (start == null) return;
      final now = DateTime.now();
      final baseline = (data?[_baselineField] as int?) ?? (data?[_totalField] as int?) ?? 0;
      final total = baseline + now.difference(start).inSeconds;
      txn.set(
        ref,
        {
          _endField: Timestamp.fromDate(now),
          _totalField: total,
          _baselineField: baseline,
          'isTracking': true,
        },
        SetOptions(merge: true),
      );
    });
  }

  static Future<void> endRealtimeTracking() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final ref = _realtimeRef(user.uid);
    await _firestore.runTransaction((txn) async {
      final snapshot = await txn.get(ref);
      if (!snapshot.exists) return;
      final data = snapshot.data();
      final start = (data?[_startField] as Timestamp?)?.toDate();
      final now = DateTime.now();
      final baseline = (data?[_baselineField] as int?) ?? (data?[_totalField] as int?) ?? 0;
      final totalSeconds = start != null ? baseline + now.difference(start).inSeconds : baseline;
      txn.set(
        ref,
        {
          _endField: Timestamp.fromDate(now),
          _totalField: totalSeconds,
          _baselineField: totalSeconds,
          'isTracking': false,
        },
        SetOptions(merge: true),
      );
    });
  }

  static Stream<Duration> totalPracticeDurationStream(String uid) {
    return _realtimeRef(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) return Duration.zero;
      final data = snapshot.data();
      final seconds = (data?[_totalField] as num?)?.toInt() ?? 0;
      return Duration(seconds: seconds);
    });
  }
}

class VideoLessonsData {
  const VideoLessonsData({
    required this.videos,
    required this.completed,
    required this.exhausted,
  });

  final List<SatVideo> videos;
  final List<SatVideo> completed;
  final bool exhausted;
}

class VideoLessonsRepository {
  VideoLessonsRepository._();

  static const _contentCollection = 'content';
  static const _docId = 'videoLessons';
  static const _cachedField = 'cachedVideos';
  static const _completedField = 'completedIds';
  static const _completedMetaField = 'completedVideos';
  static const _refreshedField = 'lastRefreshed';

  static DocumentReference<Map<String, dynamic>> _doc(String uid) {
    return FirebaseFirestore.instance
        .collection(AuthService.usersCollection)
        .doc(uid)
        .collection(_contentCollection)
        .doc(_docId);
  }

  static Future<VideoLessonsData> fetchLessons(
    String uid, {
    int maxResults = 8,
    bool forceRefresh = false,
  }) async {
    final docRef = _doc(uid);
    final snapshot = await docRef.get();
    List<dynamic> cached = [];
    List<dynamic> completed = [];
    DateTime? lastRefreshed;
    Map<String, dynamic> completedMeta = {};
    if (snapshot.exists) {
      final data = snapshot.data();
      cached = (data?[_cachedField] as List?) ?? [];
      completed = (data?[_completedField] as List?) ?? [];
      final ts = data?[_refreshedField] as Timestamp?;
      lastRefreshed = ts?.toDate();
      completedMeta = (data?[_completedMetaField] as Map<String, dynamic>?) ?? {};
    }
    final now = DateTime.now();
    final shouldRefresh = forceRefresh ||
        cached.isEmpty ||
        lastRefreshed == null ||
        now.difference(lastRefreshed).inHours >= 24;

    final completedIds = completed.cast<String>().toSet();
    List<SatVideo> cachedVideos = cached
        .map((item) =>
            SatVideo.fromMap(Map<String, dynamic>.from(item as Map<dynamic, dynamic>)))
        .toList();

    if (shouldRefresh) {
      final retained = cachedVideos.where((v) => !completedIds.contains(v.id)).toList();
      final freshVideos = await YoutubeLessonsService.fetchSatVideos(maxResults: maxResults * 2);
      final merged = <SatVideo>[];
      void addIfNew(SatVideo video) {
        if (completedIds.contains(video.id)) return;
        if (merged.any((v) => v.id == video.id)) return;
        merged.add(video);
      }

      for (final video in retained) {
        addIfNew(video);
      }
      for (final video in freshVideos) {
        addIfNew(video);
        if (merged.length >= maxResults) break;
      }

      cachedVideos = merged;
      await docRef.set(
        {
          _cachedField: cachedVideos.map((v) => v.toMap()).toList(),
          _refreshedField: Timestamp.fromDate(now),
        },
        SetOptions(merge: true),
      );
    }

    final filtered = cachedVideos.where((v) => !completedIds.contains(v.id)).toList();
    final completedVideos = completedIds
        .map((id) {
          if (completedMeta[id] is Map<String, dynamic>) {
            return SatVideo.fromMap(Map<String, dynamic>.from(completedMeta[id]));
          }
          return cachedVideos.firstWhere(
            (v) => v.id == id,
            orElse: () => SatVideo.placeholder(id),
          );
        })
        .toList();
    final exhausted = filtered.isEmpty && cachedVideos.isNotEmpty;

    return VideoLessonsData(
      videos: filtered,
      completed: completedVideos,
      exhausted: exhausted,
    );
  }

  static Future<void> markCompleted(String uid, SatVideo video) {
    return _doc(uid).set({
      _completedField: FieldValue.arrayUnion([video.id]),
      '$_completedMetaField.${video.id}': video.toMap(),
    }, SetOptions(merge: true));
  }
}

class PracticeTimeTracker extends StatefulWidget {
  const PracticeTimeTracker({required this.child, super.key});

  final Widget child;

  @override
  State<PracticeTimeTracker> createState() => _PracticeTimeTrackerState();
}

class _PracticeTimeTrackerState extends State<PracticeTimeTracker>
    with WidgetsBindingObserver {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startTracking();
  }

  Future<void> _startTracking() async {
    await PracticeSessionService.beginRealtimeTracking();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      PracticeSessionService.updateRealtimeTracking();
    });
    await PracticeSessionService.updateRealtimeTracking();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startTracking();
    } else if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _timer?.cancel();
      PracticeSessionService.endRealtimeTracking();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    PracticeSessionService.endRealtimeTracking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}


class HomeDashboardView extends StatelessWidget {
  const HomeDashboardView({
    required this.isDarkMode,
    required this.streak,
    required this.highestMilestone,
    required this.practiceDuration,
    this.celebrationMilestone,
    super.key,
  });

  final bool isDarkMode;
  final int streak;
  final int highestMilestone;
  final Duration practiceDuration;
  final int? celebrationMilestone;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.clamp(320.0, 1600.0);
        final columns = width > 1280
            ? 3
            : width > 900
                ? 2
                : 1;
        final cardWidth = columns == 1 ? width : (width - (24 * (columns - 1))) / columns;

        Widget buildCard(Widget child, {int span = 1}) {
          final w = columns == 1 ? width : cardWidth * span + 24 * (span - 1);
          return SizedBox(width: w, child: child);
        }

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1280),
                  child: Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    children: [
                      buildCard(
                        _StreakBanner(
                          isDarkMode: isDarkMode,
                          streak: streak,
                          highestMilestone: highestMilestone,
                        ),
                        span: columns,
                      ),
                      buildCard(_SkillsInsightCard(
                        title: 'Reading & Writing skills',
                        subtitle: 'Accuracy by topic',
                        topics: const [
                          _TopicStat('Grammar structures', 0.78),
                          _TopicStat('Expression of ideas', 0.66),
                          _TopicStat('Vocabulary-in-context', 0.58),
                        ],
                      )),
                      buildCard(_SkillsInsightCard(
                        title: 'Math skills',
                        subtitle: 'Accuracy by topic',
                        topics: const [],
                      )),
                      buildCard(
                        _ActivityProgressCard(practiceDuration: practiceDuration),
                      ),
                      buildCard(const _TodayGoalsCard()),
                      buildCard(const _ProgressOverviewCard()),
                      buildCard(const _RecentActivityCard(), span: columns),
                    ],
                  ),
                ),
              ),
            ),
            if (celebrationMilestone != null)
              Positioned.fill(
                child: MilestoneConfettiOverlay(
                  milestone: celebrationMilestone!,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _StreakBanner extends StatelessWidget {
  const _StreakBanner({
    required this.isDarkMode,
    required this.streak,
    required this.highestMilestone,
  });

  final bool isDarkMode;
  final int streak;
  final int highestMilestone;

  @override
  Widget build(BuildContext context) {
    final displayStreak = streak < 1 ? 1 : streak;
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          color: isDarkMode ? Colors.white : null,
        );
    return _GlassPanel(
      padding: const EdgeInsets.all(28),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🔥 $displayStreak-day streak', style: titleStyle),
                const SizedBox(height: 4),
                Text(
                  'Keep the energy up to unlock premium streak confetti!',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: _mutedColor(context)),
                ),
                const SizedBox(height: 16),
                _StreakBadgeRow(currentStreak: streak, highestMilestone: highestMilestone),
                const SizedBox(height: 16),
                GradientButton(
                  label: 'Start today’s practice',
                  onPressed: () {},
                  padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: NexColors.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 30,
                ),
              ],
            ),
            child: const _ConfettiSparkle(),
          ),
        ],
      ),
    );
  }
}

class _StreakBadgeRow extends StatelessWidget {
  const _StreakBadgeRow({required this.currentStreak, required this.highestMilestone});

  final int currentStreak;
  final int highestMilestone;

  @override
  Widget build(BuildContext context) {
    final milestones = AuthService.milestones;
    final nextMilestone = milestones.firstWhere(
      (m) => m > highestMilestone,
      orElse: () => milestones.last,
    );
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: milestones.map((milestone) {
          final achieved = highestMilestone >= milestone;
          final isNext = !achieved && milestone == nextMilestone;
          final color = achieved
              ? const LinearGradient(colors: NexColors.gradient)
              : isNext
                  ? const LinearGradient(colors: [Color(0xFFE0E9FF), Color(0xFFD1D9FF)])
                  : const LinearGradient(colors: [Color(0xFFE5E7EB), Color(0xFFE5E7EB)]);
          return Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: color,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                Icon(
                  achieved ? Icons.check_circle : Icons.lock_open,
                  size: 16,
                  color: achieved ? Colors.white : const Color(0xFF4B5563),
                ),
                const SizedBox(width: 6),
                Text(
                  '${milestone}d',
                  style: TextStyle(
                    color: achieved ? Colors.white : const Color(0xFF4B5563),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ConfettiSparkle extends StatefulWidget {
  const _ConfettiSparkle();

  @override
  State<_ConfettiSparkle> createState() => _ConfettiSparkleState();
}

class _ConfettiSparkleState extends State<_ConfettiSparkle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 3))
        ..repeat();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _controller.value * 2 * 3.14,
            child: child,
          );
        },
        child: const Icon(Icons.auto_awesome, size: 42, color: Colors.white),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _TopicStat {
  const _TopicStat(this.label, this.accuracy);
  final String label;
  final double accuracy;
}

class _SkillsInsightCard extends StatelessWidget {
  const _SkillsInsightCard({
    required this.title,
    required this.subtitle,
    required this.topics,
  });

  final String title;
  final String subtitle;
  final List<_TopicStat> topics;

  @override
  Widget build(BuildContext context) {
    final hasData = topics.isNotEmpty;
    return _GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              TextButton(onPressed: () {}, child: const Text('Start practice')),
            ],
          ),
          const SizedBox(height: 16),
          if (hasData)
            Column(
              children: topics
                  .map(
                    (topic) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Expanded(child: Text(topic.label)),
                          SizedBox(
                            width: 160,
                            child: LinearProgressIndicator(
                              value: topic.accuracy,
                              backgroundColor: NexColors.neutralBorder.withOpacity(0.6),
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('${(topic.accuracy * 100).round()}%'),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            )
          else
            _EmptyStateCard(
              message: 'No data yet — start practice to unlock analytics.',
              buttonLabel: 'Start practice',
            ),
        ],
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({required this.message, required this.buttonLabel});

  final String message;
  final String buttonLabel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFF6F7FF),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : NexColors.neutralBorder,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_graph_outlined, color: _mutedColor(context)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _mutedColor(context),
                  ),
            ),
          ),
          GradientButton(
            label: buttonLabel,
            onPressed: () {},
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
        ],
      ),
    );
  }
}

class _ActivityProgressCard extends StatelessWidget {
  const _ActivityProgressCard({required this.practiceDuration});

  final Duration practiceDuration;

  @override
  Widget build(BuildContext context) {
    final practiceMinutes = practiceDuration.inMinutes;
    final minutesRemainder = practiceMinutes % 60;
    final practiceLabel = practiceMinutes >= 60
        ? '${practiceMinutes ~/ 60}h${minutesRemainder > 0 ? ' ${minutesRemainder}m' : ''}'
        : '$practiceMinutes min';
    const practiceGoalMinutes = 120;
    final practiceProgress =
        (practiceMinutes / practiceGoalMinutes).clamp(0.0, 1.0).toDouble();
    final stats = [
      ('XP earned', 0.52, '1,240 XP'),
      (
        'Practice time',
        practiceProgress.isNaN ? 0.0 : practiceProgress,
        practiceMinutes > 0 ? practiceLabel : '0 min'
      ),
      ('Success rate', 0.68, '68%'),
    ];
    return _GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Activity progress', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          Row(
            children: stats
                .map(
                  (stat) => Expanded(
                    child: _CircularStat(
                      label: stat.$1,
                      progress: stat.$2,
                      detail: stat.$3,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _CircularStat extends StatelessWidget {
  const _CircularStat({required this.label, required this.progress, required this.detail});

  final String label;
  final double progress;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: progress),
          duration: const Duration(milliseconds: 900),
          builder: (context, value, child) {
          return SizedBox(
            width: 90,
            height: 90,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: value,
                  strokeWidth: 8,
                  backgroundColor: NexColors.neutralBorder.withOpacity(0.6),
                  valueColor:
                      AlwaysStoppedAnimation(Theme.of(context).colorScheme.primary),
                ),
                  Center(
                    child: Text('${(value * 100).round()}%'),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        Text(detail, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: _mutedColor(context))),
      ],
    );
  }
}

class _TodayGoalsCard extends StatelessWidget {
  const _TodayGoalsCard();

  @override
  Widget build(BuildContext context) {
    final goals = [
      ('Complete 10 questions', true),
      ('Study 30 minutes', false),
      ('Review mistakes', false),
    ];
    return _GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Today’s goals', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          ...goals.map(
            (goal) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                goal.$2 ? Icons.check_circle : Icons.radio_button_unchecked,
                color: goal.$2 ? Theme.of(context).colorScheme.primary : _mutedColor(context),
              ),
              title: Text(goal.$1),
              trailing: goal.$2
                  ? const Text('Done', style: TextStyle(color: Colors.green))
                  : TextButton(onPressed: () {}, child: const Text('Do now')),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressOverviewCard extends StatelessWidget {
  const _ProgressOverviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: NexColors.gradient,
        ),
        boxShadow: [
          BoxShadow(
            color: NexColors.primary.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Level 07', style: TextStyle(color: Colors.white, fontSize: 18)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text('Scholar badge', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('XP progress', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 0.62),
              duration: const Duration(milliseconds: 900),
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 10,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFFFDE68A)),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _ProgressStat(title: 'XP', value: '1,240'),
              _ProgressStat(title: 'Accuracy', value: '82%'),
              _ProgressStat(title: 'Answered', value: '312'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressStat extends StatelessWidget {
  const _ProgressStat({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        Text(title, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}

class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard();

  @override
  Widget build(BuildContext context) {
    final logs = [
      ('Answered 5 math questions', '2 correct • 3:24 PM'),
      ('Reviewed bookmarked vocab', '12 cards • 1:02 PM'),
      ('Practice rush sprint', 'Score 680 • 10:11 AM'),
      ('AI explained mistakes', 'Reading set • 9:45 AM'),
      ('Session summary exported', 'Yesterday • 7:18 PM'),
    ];
    return _GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent activity', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          ...logs.map(
            (log) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.timeline_outlined),
              title: Text(log.$1),
              subtitle: Text(log.$2),
            ),
          ),
        ],
      ),
    );
  }
}

class SatVocabsView extends StatelessWidget {
  const SatVocabsView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          _SectionHeader(title: 'SAT Vocabs', subtitle: 'Flashcards, practice, leaderboard'),
          const TabBar(
            tabs: [
              Tab(text: 'Flashcards'),
              Tab(text: 'Practice'),
              Tab(text: 'Leaderboard'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _FlashcardGrid(),
                _VocabPracticeList(),
                _LeaderboardView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          FilledButton(onPressed: () {}, child: const Text('New session')),
        ],
      ),
    );
  }
}

class _FlashcardGrid extends StatelessWidget {
  const _FlashcardGrid({super.key});

  final words = const [
    ('lucid', 'Expressed clearly; easy to understand'),
    ('mitigate', 'Make less severe or serious'),
    ('ubiquitous', 'Present everywhere'),
    ('candor', 'The quality of being honest'),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width < 800 ? 1 : 2;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: GridView.builder(
        primary: false,
        shrinkWrap: false,
        physics: const BouncingScrollPhysics(),
        itemCount: words.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 4 / 3,
        ),
        itemBuilder: (context, index) {
          final word = words[index];
          return _FlashCard(word: word.$1, definition: word.$2);
        },
      ),
    );
  }
}

class _FlashCard extends StatefulWidget {
  const _FlashCard({required this.word, required this.definition});
  final String word;
  final String definition;

  @override
  State<_FlashCard> createState() => _FlashCardState();
}

class _FlashCardState extends State<_FlashCard> {
  bool _flipped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _flipped = !_flipped),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: _flipped
                ? const [Color(0xFFA06CFF), Color(0xFF4E5FFF)]
                : const [Color(0xFFF6F7FF), Color(0xFFECEFFF)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _flipped
                ? Text(
                    widget.definition,
                    key: const ValueKey('definition'),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  )
                : Text(
                    widget.word,
                    key: const ValueKey('word'),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }
}

class _VocabPracticeList extends StatelessWidget {
  const _VocabPracticeList();

  @override
  Widget build(BuildContext context) {
    const questions = [
      ('“Greg’s tone was ______.”', ['acerbic', 'mellifluous', 'placid', 'stoic']),
      ('“To assuage” most nearly means…', ['Eat quickly', 'Relieve', 'Admire', 'Predict']),
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: questions.length,
      primary: false,
      itemBuilder: (context, index) {
        final question = questions[index];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(question.$1, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                ...question.$2.map(
                  (choice) => RadioListTile<String>(
                    value: choice,
                    groupValue: null,
                    onChanged: (_) {},
                    title: Text(choice),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.tonal(onPressed: () {}, child: const Text('Check answer')),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LeaderboardView extends StatelessWidget {
  const _LeaderboardView();

  @override
  Widget build(BuildContext context) {
    final leaders = [
      ('Ava', '3,400 XP'),
      ('Noah', '3,120 XP'),
      ('Kumar', '2,980 XP'),
      ('Lia', '2,760 XP'),
    ];
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      shrinkWrap: true,
      primary: false,
      itemBuilder: (context, index) {
        final leader = leaders[index];
        return ListTile(
          leading: CircleAvatar(child: Text('${index + 1}')),
          title: Text(leader.$1),
          trailing: Text(leader.$2),
        );
      },
      separatorBuilder: (_, __) => const Divider(),
      itemCount: leaders.length,
    );
  }
}

class DashboardSidebar extends StatelessWidget {
  const DashboardSidebar({
    required this.selected,
    required this.onSelect,
    required this.isDarkMode,
    required this.onToggleDarkMode,
    super.key,
  });

  final DashboardSection selected;
  final ValueChanged<DashboardSection> onSelect;
  final bool isDarkMode;
  final VoidCallback onToggleDarkMode;

  static const _platform = [
    DashboardSection.home,
    DashboardSection.satVocabs,
    DashboardSection.questionBank,
    DashboardSection.bookmarked,
    DashboardSection.answered,
    DashboardSection.practiceSessions,
    DashboardSection.fullLengthTests,
  ];

  static const _explore = [
    DashboardSection.satSuite,
    DashboardSection.vocabFlashcards,
    DashboardSection.vocabPractice,
    DashboardSection.practiceRush,
    DashboardSection.reviewPractice,
    DashboardSection.resources,
  ];

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF0D1329) : const Color(0xFFF4F7FF),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [accent, accent.withOpacity(0.6)],
                  ),
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('NexPrep', style: Theme.of(context).textTheme.titleMedium),
                  Text('AI SAT Coach', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                _SidebarSectionHeader(text: 'Platform'),
                ..._platform.map((section) => _SidebarDestination(
                      section: section,
                      selected: selected == section,
                      onTap: () => onSelect(section),
                    )),
                const SizedBox(height: 12),
                _SidebarSectionHeader(text: 'Explore & Learn'),
                ..._explore.map((section) => _SidebarDestination(
                      section: section,
                      selected: selected == section,
                      onTap: () => onSelect(section),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Text('🌗', style: TextStyle(fontSize: 20)),
            title: const Text('Dark mode'),
            trailing: Switch(value: isDarkMode, onChanged: (_) => onToggleDarkMode()),
          ),
        ],
      ),
    );
  }
}

class _SidebarSectionHeader extends StatelessWidget {
  const _SidebarSectionHeader({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              letterSpacing: 1.2,
              color: _mutedColor(context),
            ),
      ),
    );
  }
}

class _SidebarDestination extends StatelessWidget {
  const _SidebarDestination({
    required this.section,
    required this.selected,
    required this.onTap,
  });

  final DashboardSection section;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? accent.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? accent.withOpacity(0.4) : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(section.icon, size: 20, color: selected ? accent : _mutedColor(context)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  section.label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      ),
                ),
              ),
              if (selected)
                const Icon(
                  Icons.arrow_right_alt,
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<UserCredential> _signInWithGoogle() async {
  if (kIsWeb) {
    final provider = GoogleAuthProvider()..setCustomParameters({'prompt': 'select_account'});
    return FirebaseAuth.instance.signInWithPopup(provider);
  }
  final googleUser = await GoogleSignIn().signIn();
  if (googleUser == null) {
    throw FirebaseAuthException(code: 'aborted-by-user', message: 'Sign-in aborted');
  }
  final googleAuth = await googleUser.authentication;
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );
  return FirebaseAuth.instance.signInWithCredential(credential);
}
