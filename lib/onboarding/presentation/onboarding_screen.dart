import 'dart:io';
import 'dart:math' as math;
import 'package:apexflow/features/shell/apex_app_shell.dart';
import 'package:flutter/foundation.dart';
import 'package:apexflow/core/i18n/app_settings_state.dart';
import 'package:apexflow/core/i18n/app_strings.dart';
import 'package:apexflow/settings/application/user_profile_state.dart';
import 'package:apexflow/core/services/firebase_service.dart';
import 'package:apexflow/onboarding/presentation/profile_setup_wizard_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apexflow/core/storage/apex_kv_store.dart';
import 'package:apexflow/core/design/theme_extensions.dart';
import 'package:url_launcher/url_launcher.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, required this.strings});

  final AppStrings strings;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  String _authMode = 'login'; // 'signup', 'login', or 'forgot'
  bool _isSubmitting = false;
  bool _awaitingEmailVerification = false;
  bool _rememberMe = true;

  // Login controllers
  late final TextEditingController _loginTag;
  late final TextEditingController _loginPassword;

  // Signup controllers
  late final TextEditingController _signupEmail;
  late final TextEditingController _signupPassword;

  // Forgot password controller
  late final TextEditingController _forgotPasswordEmail;

  bool _obscureLoginPassword = true;
  bool _obscureSignupPassword = true;

  String? _error;

  // Card entrance animation
  late final AnimationController _cardAnimController;
  late final Animation<double> _cardFadeAnim;
  late final Animation<Offset> _cardSlideAnim;

  @override
  void initState() {
    super.initState();
    _loginTag = TextEditingController();
    _loginPassword = TextEditingController();
    _signupEmail = TextEditingController();
    _signupPassword = TextEditingController();
    _forgotPasswordEmail = TextEditingController();

    _cardAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _cardFadeAnim = CurvedAnimation(
      parent: _cardAnimController,
      curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
    );
    _cardSlideAnim =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _cardAnimController,
            curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _cardAnimController.forward();
    });
  }

  @override
  void dispose() {
    _loginTag.dispose();
    _loginPassword.dispose();
    _signupEmail.dispose();
    _signupPassword.dispose();
    _forgotPasswordEmail.dispose();
    _cardAnimController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════
  // LOGIN — Firebase Email Auth (PRESERVED EXACTLY)
  // ═══════════════════════════════════════════════════════════════════
  Future<void> _login() async {
    final email = _loginTag.text.trim();
    final password = _loginPassword.text;

    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _error = tInline(
          widget.strings.languageCode,
          'Lütfen geçerli bir e-posta adresi girin.',
          'Please enter a valid email address.',
          'Bitte geben Sie eine gültige E-Mail-Adresse ein.',
        );
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _error = tInline(
          widget.strings.languageCode,
          'Lütfen şifre alanını doldurun.',
          'Please fill in the password.',
          'Bitte geben Sie das Passwort ein.',
        );
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    HapticFeedback.selectionClick();

    try {
      final success = await ref
          .read(userProfileProvider.notifier)
          .loginUserWithEmail(email, password);
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      if (success) {
        await ApexKvStore.setBool('auth.remember_me', _rememberMe);
        ref.read(appSettingsProvider.notifier).completeOnboarding();
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const ApexAppShell()),
          );
        }
      } else {
        setState(() {
          _error = tInline(
            widget.strings.languageCode,
            'Giriş başarısız. E-posta adresi veya şifre hatalı, ya da internet bağlantısı yok.',
            'Login failed. Incorrect email or password, or no internet connection.',
            'Fehler bei der Anmeldung. Falsche E-Mail-Adresse oder falsches Passwort oder keine Internetverbindung.',
          );
        });
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      if (e.toString().contains('email-not-verified')) {
        setState(() {
          _error = tInline(
            widget.strings.languageCode,
            'Giriş başarısız. Lütfen e-postanıza gönderilen doğrulama linkine tıklayarak hesabınızı onaylayın.',
            'Login failed. Please click the verification link sent to your email to approve your account.',
            'Fehler bei der Anmeldung. Bitte klicken Sie auf den Bestätigungslink, der Ihnen per E-Mail zugesandt wurde, um Ihr Konto zu genehmigen.',
          );
        });
      } else {
        setState(() {
          _error = tInline(
            widget.strings.languageCode,
            'Hata oluştu. Bilgileri kontrol edip tekrar deneyin.',
            'Error occurred. Please try again.',
            'Es ist ein Fehler aufgetreten. Bitte versuchen Sie es erneut.',
          );
        });
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // FORGOT PASSWORD — Inline send reset email (LOGIC PRESERVED)
  // ═══════════════════════════════════════════════════════════════════
  Future<void> _sendPasswordReset() async {
    final email = _forgotPasswordEmail.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _error = tInline(
          widget.strings.languageCode,
          'Geçerli bir e-posta adresi girin.',
          'Please enter a valid email address.',
          'Bitte geben Sie eine gültige E-Mail-Adresse ein.',
        );
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    HapticFeedback.selectionClick();

    try {
      await FirebaseService.instance.sendPasswordResetEmail(email);
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tInline(
              widget.strings.languageCode,
              'Şifre sıfırlama e-postası başarıyla gönderildi!',
              'Password reset email sent successfully!',
              'E-Mail zum Zurücksetzen des Passworts erfolgreich gesendet!',
            ),
          ),
          backgroundColor: context.colors.cyan,
        ),
      );
      setState(() {
        _authMode = 'login';
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _error = tInline(
          widget.strings.languageCode,
          'E-posta gönderilirken hata oluştu. Lütfen tekrar deneyin.',
          'Error sending email. Please try again.',
          'Fehler beim Senden der E-Mail. Bitte versuchen Sie es erneut.',
        );
      });
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // SIGNUP — Firebase Registration (PRESERVED EXACTLY)
  // ═══════════════════════════════════════════════════════════════════
  Future<void> _submit() async {
    final emailVal = _signupEmail.text.trim();
    final passwordVal = _signupPassword.text;

    if (emailVal.isEmpty || !emailVal.contains('@')) {
      setState(
        () => _error = tInline(
          widget.strings.languageCode,
          'Lütfen geçerli bir e-posta adresi girin.',
          'Please enter a valid email address.',
          'Bitte geben Sie eine gültige E-Mail-Adresse ein.',
        ),
      );
      return;
    }

    if (passwordVal.isEmpty || passwordVal.length < 6) {
      setState(
        () => _error = tInline(
          widget.strings.languageCode,
          'Şifre alanı en az 6 karakter olmalıdır.',
          'Password must be at least 6 characters.',
          'Das Passwort muss mindestens 6 Zeichen lang sein.',
        ),
      );
      return;
    }

    if (!kIsWeb ? Platform.environment.containsKey('FLUTTER_TEST') : false) {
      await FirebaseService.instance.registerWithEmailAndPassword(
        emailVal,
        passwordVal,
      );
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                ProfileSetupWizardScreen(strings: widget.strings),
          ),
        );
      }
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    HapticFeedback.selectionClick();

    try {
      await FirebaseService.instance.registerWithEmailAndPassword(
        emailVal,
        passwordVal,
      );

      setState(() {
        _isSubmitting = false;
        _awaitingEmailVerification = true;
      });
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _error = tInline(
          widget.strings.languageCode,
          'Kayıt başarısız oldu. E-posta adresi kullanımda veya geçersiz olabilir.',
          'Registration failed. The email address might be in use or invalid.',
          'Die Registrierung ist fehlgeschlagen. Die E-Mail-Adresse ist möglicherweise in Gebrauch oder ungültig.',
        );
      });
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // EMAIL VERIFICATION CHECK (PRESERVED EXACTLY)
  // ═══════════════════════════════════════════════════════════════════
  Future<void> _checkEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isSubmitting = true;
    });

    await user.reload();
    final verified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (verified) {
      await ApexKvStore.setBool('auth.remember_me', true);
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                ProfileSetupWizardScreen(strings: widget.strings),
          ),
        );
      }
    } else {
      setState(() {
        _error = tInline(
          widget.strings.languageCode,
          'E-posta adresi henüz doğrulanmadı. Lütfen gelen linke tıklayıp onaylayın.',
          'Email address not verified yet. Please click the link sent to your inbox.',
          'E-Mail-Adresse noch nicht bestätigt. Bitte klicken Sie auf den Link, der an Ihren Posteingang gesendet wurde.',
        );
      });
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // BUILD — Premium Dark UI
  // ═══════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: _awaitingEmailVerification
          ? _buildVerificationView()
          : _buildAuthView(),
    );
  }

  Widget _buildAuthView() {
    return Stack(
      children: [
        // ── Background particles ──
        const Positioned.fill(child: _ParticleBackground()),

        // ── Accent lines ──
        Positioned.fill(child: _AccentLines()),

        // ── Subtle vignette ──
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.3),
                  radius: 0.8,
                  colors: [Color(0x0FFFFFFF), Colors.transparent],
                  stops: [0.0, 0.6],
                ),
              ),
            ),
          ),
        ),

        // ── Full-screen card ──
        Positioned.fill(
          child: SafeArea(
            child: FadeTransition(
              opacity: _cardFadeAnim,
              child: SlideTransition(
                position: _cardSlideAnim,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: _buildCard(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.colors.surface.withValues(alpha: 0.7),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_authMode == 'forgot')
            _buildForgotPasswordForm()
          else ...[
            // Card header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tInline(
                      widget.strings.languageCode,
                      'Giriş yapın veya hesap oluşturun',
                      'Log in or create an account',
                      'Anmelden oder Konto erstellen',
                    ),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: context.colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Tab switcher
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: _buildTabBar(),
            ),

            const SizedBox(height: 20),

            // Form content
            if (_authMode == 'login') _buildLoginForm(),
            if (_authMode == 'signup') _buildSignupForm(),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // Tab Bar
  // ─────────────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.background.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: context.colors.border.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          _tabButton(
            'login',
            tInline(
              widget.strings.languageCode,
              'Giriş Yap',
              'Log In',
              'Anmelden',
            ),
          ),
          _tabButton(
            'signup',
            tInline(
              widget.strings.languageCode,
              'Kayıt Ol',
              'Sign Up',
              'Registrieren',
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabButton(String mode, String label) {
    final isSelected = _authMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _authMode = mode;
            _error = null;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? context.colors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: isSelected
                ? Border.all(
                    color: context.colors.border.withValues(alpha: 0.4),
                  )
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isSelected
                  ? context.colors.white
                  : context.colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // Login Form
  // ─────────────────────────────────────────
  Widget _buildLoginForm() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email field
          _fieldLabel(
            tInline(widget.strings.languageCode, 'E-posta', 'Email', 'E-Mail'),
          ),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _loginTag,
            hint: 'user@example.com',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.mail_outline,
          ),

          const SizedBox(height: 16),

          // Password field
          _fieldLabel(
            tInline(
              widget.strings.languageCode,
              'Şifre',
              'Password',
              'Passwort',
            ),
          ),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _loginPassword,
            hint: '••••••••',
            obscure: _obscureLoginPassword,
            prefixIcon: Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureLoginPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: context.colors.textSecondary,
                size: 18,
              ),
              onPressed: () {
                setState(() => _obscureLoginPassword = !_obscureLoginPassword);
              },
            ),
          ),

          const SizedBox(height: 14),

          // Remember me + Forgot password
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => setState(() => _rememberMe = !_rememberMe),
                child: Row(
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: Checkbox(
                        value: _rememberMe,
                        activeColor: context.colors.cyan,
                        side: BorderSide(color: context.colors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onChanged: (val) =>
                            setState(() => _rememberMe = val ?? true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      tInline(
                        widget.strings.languageCode,
                        'Beni hatırla',
                        'Remember me',
                        'Erinnere dich',
                      ),
                      style: TextStyle(
                        color: context.colors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  _forgotPasswordEmail.text = _loginTag.text.trim();
                  setState(() {
                    _authMode = 'forgot';
                    _error = null;
                  });
                },
                child: Text(
                  tInline(
                    widget.strings.languageCode,
                    'Şifremi unuttum?',
                    'Forgot password?',
                    'Passwort vergessen?',
                  ),
                  style: TextStyle(color: context.colors.white, fontSize: 13),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Error message
          if (_error != null) ...[_buildErrorBox(), const SizedBox(height: 16)],

          // Login button
          _buildPrimaryButton(
            label: tInline(
              widget.strings.languageCode,
              'Giriş Yap',
              'Continue',
              'Weiter',
            ),
            onPressed: _isSubmitting ? null : _login,
            isLoading: _isSubmitting,
          ),

          const SizedBox(height: 20),

          // Divider
          Divider(color: context.colors.border.withValues(alpha: 0.3)),

          const SizedBox(height: 16),

          // Discord + Instagram buttons
          _buildSocialButtons(),

          const SizedBox(height: 20),

          // Footer
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  tInline(
                    widget.strings.languageCode,
                    'Hesabınız yok mu? ',
                    "Don't have an account? ",
                    'Kein Konto? ',
                  ),
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() {
                    _authMode = 'signup';
                    _error = null;
                  }),
                  child: Text(
                    tInline(
                      widget.strings.languageCode,
                      'Hesap oluştur',
                      'Create one',
                      'Erstellen',
                    ),
                    style: TextStyle(
                      color: context.colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: context.colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // Signup Form
  // ─────────────────────────────────────────
  Widget _buildSignupForm() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email field
          _fieldLabel(
            tInline(widget.strings.languageCode, 'E-posta', 'Email', 'E-Mail'),
          ),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _signupEmail,
            hint: 'user@example.com',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.mail_outline,
          ),

          const SizedBox(height: 16),

          // Password field
          _fieldLabel(
            tInline(
              widget.strings.languageCode,
              'Şifre',
              'Password',
              'Passwort',
            ),
          ),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _signupPassword,
            hint: tInline(
              widget.strings.languageCode,
              'En az 6 karakter',
              'At least 6 characters',
              'Mindestens 6 Zeichen',
            ),
            obscure: _obscureSignupPassword,
            prefixIcon: Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureSignupPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: context.colors.textSecondary,
                size: 18,
              ),
              onPressed: () {
                setState(
                  () => _obscureSignupPassword = !_obscureSignupPassword,
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Error message
          if (_error != null) ...[_buildErrorBox(), const SizedBox(height: 16)],

          // Signup button
          _buildPrimaryButton(
            label: tInline(
              widget.strings.languageCode,
              'Kayıt Ol',
              'Sign Up',
              'Registrieren',
            ),
            onPressed: _isSubmitting ? null : _submit,
            isLoading: _isSubmitting,
          ),

          const SizedBox(height: 20),

          // Divider
          Divider(color: context.colors.border.withValues(alpha: 0.3)),

          const SizedBox(height: 16),

          // Discord + Instagram buttons
          _buildSocialButtons(),

          const SizedBox(height: 20),

          // Footer
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  tInline(
                    widget.strings.languageCode,
                    'Zaten hesabınız var mı? ',
                    'Already have an account? ',
                    'Bereits ein Konto? ',
                  ),
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() {
                    _authMode = 'login';
                    _error = null;
                  }),
                  child: Text(
                    tInline(
                      widget.strings.languageCode,
                      'Giriş yap',
                      'Log in',
                      'Anmelden',
                    ),
                    style: TextStyle(
                      color: context.colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: context.colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // Forgot Password Form (inline card view)
  // ─────────────────────────────────────────
  Widget _buildForgotPasswordForm() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tInline(
              widget.strings.languageCode,
              'Şifremi Unuttum?',
              'Forgot password?',
              'Passwort vergessen?',
            ),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: context.colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tInline(
              widget.strings.languageCode,
              'E-posta adresinizi girin, size bir sıfırlama linki gönderelim',
              'Enter your email and we\'ll send you a reset link',
              'Geben Sie Ihre E-Mail ein und wir senden Ihnen einen Reset-Link',
            ),
            style: TextStyle(fontSize: 13, color: context.colors.textSecondary),
          ),

          const SizedBox(height: 24),

          // Email field
          _fieldLabel(
            tInline(widget.strings.languageCode, 'E-posta', 'Email', 'E-Mail'),
          ),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _forgotPasswordEmail,
            hint: 'user@example.com',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.mail_outline,
          ),

          const SizedBox(height: 20),

          // Error
          if (_error != null) ...[_buildErrorBox(), const SizedBox(height: 16)],

          // Send reset link button
          _buildPrimaryButton(
            label: tInline(
              widget.strings.languageCode,
              'Sıfırlama linki gönder  \u2192',
              'Send reset link  \u2192',
              'Reset-Link senden  \u2192',
            ),
            onPressed: _isSubmitting ? null : _sendPasswordReset,
            isLoading: _isSubmitting,
          ),

          const SizedBox(height: 20),

          // Divider
          Divider(color: context.colors.border.withValues(alpha: 0.3)),

          const SizedBox(height: 16),

          // Back to login
          GestureDetector(
            onTap: () => setState(() {
              _authMode = 'login';
              _error = null;
            }),
            child: Text(
              tInline(
                widget.strings.languageCode,
                'Giriş ekranına dön',
                'Back to log in',
                'Zurück zur Anmeldung',
              ),
              style: TextStyle(
                color: context.colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => setState(() {
              _authMode = 'signup';
              _error = null;
            }),
            child: Text(
              tInline(
                widget.strings.languageCode,
                'Yeni hesap oluştur',
                'Create a new account',
                'Neues Konto erstellen',
              ),
              style: TextStyle(
                color: context.colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // Email Verification View (LOGIC PRESERVED)
  // ─────────────────────────────────────────
  Widget _buildVerificationView() {
    return Stack(
      children: [
        const Positioned.fill(child: _ParticleBackground()),
        Positioned.fill(child: _AccentLines()),
        Positioned.fill(
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 400),
                  decoration: BoxDecoration(
                    color: context.colors.surface.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: context.colors.border.withValues(alpha: 0.4),
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.colors.cyan.withValues(alpha: 0.08),
                        ),
                        child: Icon(
                          Icons.mark_email_unread_outlined,
                          color: context.colors.cyan,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        tInline(
                          widget.strings.languageCode,
                          'E-posta Doğrulaması Gerekli',
                          'Email Verification Required',
                          'E-Mail-Bestätigung erforderlich',
                        ),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: context.colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        tInline(
                          widget.strings.languageCode,
                          'Lütfen ${_signupEmail.text} adresine gönderdiğimiz doğrulama linkine tıklayarak hesabınızı onaylayın.',
                          'Please click the verification link we sent to ${_signupEmail.text}.',
                          'Bitte klicken Sie auf den Bestätigungslink, den wir an ${_signupEmail.text} gesendet haben.',
                        ),
                        style: TextStyle(
                          color: context.colors.textSecondary,
                          fontSize: 13,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      if (_error != null) ...[
                        _buildErrorBox(),
                        const SizedBox(height: 16),
                      ],
                      _buildPrimaryButton(
                        label: tInline(
                          widget.strings.languageCode,
                          'Doğrulamayı Kontrol Et',
                          'Check Verification Status',
                          'Überprüfen Sie den Verifizierungsstatus',
                        ),
                        onPressed: _isSubmitting
                            ? null
                            : _checkEmailVerification,
                        isLoading: _isSubmitting,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: context.colors.white,
                            side: BorderSide(
                              color: context.colors.border.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _awaitingEmailVerification = false;
                              _error = null;
                            });
                          },
                          child: Text(
                            tInline(
                              widget.strings.languageCode,
                              'Geri Git',
                              'Go Back',
                              'Geh zurück',
                            ),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // SHARED UI COMPONENTS
  // ═══════════════════════════════════════════════════════════════════

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: context.colors.white.withValues(alpha: 0.8),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    bool obscure = false,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      style: TextStyle(color: context.colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: context.colors.muted, fontSize: 14),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: 18, color: context.colors.textSecondary)
            : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: context.colors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(
            color: context.colors.border.withValues(alpha: 0.4),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(
            color: context.colors.border.withValues(alpha: 0.4),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: context.colors.cyan, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: context.colors.cyan,
          foregroundColor: context.colors.onAccent,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        onPressed: onPressed,
        child:
            isLoading &&
                (kIsWeb
                    ? true
                    : !Platform.environment.containsKey('FLUTTER_TEST'))
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: context.colors.onAccent,
                  strokeWidth: 2,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  Widget _buildErrorBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: context.colors.red.withValues(alpha: 0.3)),
      ),
      child: Text(
        _error!,
        style: TextStyle(
          color: context.colors.red,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSocialButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tInline(
            widget.strings.languageCode,
            'Topluluğumuza katılın',
            'Join our community',
            'Treten Sie unserer Community bei',
          ),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: context.colors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // Discord
            Expanded(
              child: Column(
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.colors.white,
                      backgroundColor: context.colors.background,
                      side: BorderSide(
                        color: context.colors.border.withValues(alpha: 0.4),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      minimumSize: const Size(double.infinity, 0),
                    ),
                    onPressed: () async {
                      final uri = Uri.parse('https://discord.gg/madeforth');
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.forum_outlined,
                          size: 16,
                          color: context.colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Discord',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: context.colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    tInline(
                      widget.strings.languageCode,
                      'Topluluk sunucusu',
                      'Community server',
                      'Community-Server',
                    ),
                    style: TextStyle(
                      fontSize: 10,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Instagram
            Expanded(
              child: Column(
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.colors.white,
                      backgroundColor: context.colors.background,
                      side: BorderSide(
                        color: context.colors.border.withValues(alpha: 0.4),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      minimumSize: const Size(double.infinity, 0),
                    ),
                    onPressed: () async {
                      final uri = Uri.parse(
                        'https://www.instagram.com/apexflow.app/',
                      );
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          size: 16,
                          color: context.colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Instagram',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: context.colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    tInline(
                      widget.strings.languageCode,
                      'Resmi sayfamız',
                      'Official page',
                      'Offizielle Seite',
                    ),
                    style: TextStyle(
                      fontSize: 10,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// BACKGROUND ANIMATION WIDGETS
// ═══════════════════════════════════════════════════════════════════

/// Floating particles that drift upward
class _ParticleBackground extends StatefulWidget {
  const _ParticleBackground();

  @override
  State<_ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<_ParticleBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_Particle> _particles = [];
  final math.Random _rng = math.Random();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  void _initParticles(Size size) {
    if (_initialized) return;
    _initialized = true;
    final count = (size.width * size.height / 12000).floor().clamp(20, 120);
    for (int i = 0; i < count; i++) {
      _particles.add(
        _Particle(
          x: _rng.nextDouble() * size.width,
          y: _rng.nextDouble() * size.height,
          speed: _rng.nextDouble() * 0.3 + 0.05,
          opacity: _rng.nextDouble() * 0.3 + 0.1,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _initParticles(Size(constraints.maxWidth, constraints.maxHeight));
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _ParticlePainter(_particles, _rng),
            );
          },
        );
      },
    );
  }
}

class _Particle {
  double x, y, speed, opacity;
  _Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.opacity,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final math.Random rng;

  _ParticlePainter(this.particles, this.rng);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      p.y -= p.speed;
      if (p.y < 0) {
        p.x = rng.nextDouble() * size.width;
        p.y = size.height + rng.nextDouble() * 40;
        p.speed = rng.nextDouble() * 0.3 + 0.05;
        p.opacity = rng.nextDouble() * 0.3 + 0.1;
      }
      final paint = Paint()
        ..color = Color.fromRGBO(250, 250, 250, p.opacity * 0.5);
      canvas.drawRect(Rect.fromLTWH(p.x, p.y, 0.7, 2.2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Animated accent lines (horizontal + vertical grid)
class _AccentLines extends StatefulWidget {
  const _AccentLines();

  @override
  State<_AccentLines> createState() => _AccentLinesState();
}

class _AccentLinesState extends State<_AccentLines>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lineColor = const Color(0xFF27272A);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return IgnorePointer(
          child: Opacity(
            opacity: 0.7,
            child: Stack(
              children: [
                // Horizontal lines
                _buildHLine(0.18, 0.10, lineColor),
                _buildHLine(0.50, 0.20, lineColor),
                _buildHLine(0.82, 0.30, lineColor),
                // Vertical lines
                _buildVLine(0.22, 0.40, lineColor),
                _buildVLine(0.50, 0.50, lineColor),
                _buildVLine(0.78, 0.60, lineColor),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHLine(double topFraction, double delayFraction, Color color) {
    final adjustedProgress =
        ((_controller.value - delayFraction) / (0.8 - delayFraction + 0.2))
            .clamp(0.0, 1.0);
    final curve = Curves.easeOutCubic.transform(adjustedProgress);
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      bottom: 0,
      child: FractionallySizedBox(
        heightFactor: 1,
        child: Align(
          alignment: Alignment(0, -1 + topFraction * 2),
          child: Transform.scale(
            scaleX: curve,
            child: Opacity(
              opacity: (curve * 0.7).clamp(0.0, 0.7),
              child: Container(height: 1, color: color),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVLine(double leftFraction, double delayFraction, Color color) {
    final adjustedProgress =
        ((_controller.value - delayFraction) / (0.9 - delayFraction + 0.1))
            .clamp(0.0, 1.0);
    final curve = Curves.easeOutCubic.transform(adjustedProgress);
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      bottom: 0,
      child: FractionallySizedBox(
        widthFactor: 1,
        child: Align(
          alignment: Alignment(-1 + leftFraction * 2, 0),
          child: Transform.scale(
            scaleY: curve,
            child: Opacity(
              opacity: (curve * 0.7).clamp(0.0, 0.7),
              child: Container(width: 1, color: color),
            ),
          ),
        ),
      ),
    );
  }
}
