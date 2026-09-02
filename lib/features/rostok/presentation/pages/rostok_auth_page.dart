import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stay_alive/core/config/app_flavor.dart';
import 'package:stay_alive/core/di/injection_container.dart';
import 'package:stay_alive/core/error/failures.dart';
import 'package:stay_alive/core/l10n/l10n.dart';
import 'package:stay_alive/core/theme/app_text_styles.dart';
import 'package:stay_alive/core/usecase/usecase.dart';
import 'package:stay_alive/features/auth/domain/entities/auth_user.dart';
import 'package:stay_alive/features/auth/domain/repositories/auth_repository.dart';
import 'package:stay_alive/features/auth/domain/usecases/sign_in_anonymously_usecase.dart';
import 'package:stay_alive/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:stay_alive/features/auth/presentation/cubit/auth_state.dart';
import 'package:stay_alive/core/widgets/animations/sprout_growth_animation.dart';
import 'package:stay_alive/features/rostok/presentation/theme/rostok_colors.dart';
import 'package:stay_alive/features/rostok/presentation/theme/rostok_text.dart';

/// Which mode the unified auth screen opens in.
enum RostokAuthMode { signIn, register }

const Color _errorColor = Color(0xFFDB5A4B);

/// Росток unified auth screen — a single modern sign-in surface with an
/// animated Вход⇄Регистрация toggle. Serves both `/login` (signIn) and
/// `/sign-up` (register). Wired to the real [AuthCubit] (email/password +
/// OAuth), with a dev-only anonymous "mock" shortcut.
///
/// Animations are transform/opacity-only (60fps, Impeller-friendly) and honor
/// the platform "reduce motion" setting.
class RostokAuthPage extends StatefulWidget {
  const RostokAuthPage({this.initialMode = RostokAuthMode.signIn, super.key});

  final RostokAuthMode initialMode;

  @override
  State<RostokAuthPage> createState() => _RostokAuthPageState();
}

class _RostokAuthPageState extends State<RostokAuthPage>
    with TickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 750),
  );
  late final AnimationController _mode = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
    value: widget.initialMode == RostokAuthMode.register ? 1 : 0,
  );
  late final AnimationController _mascot = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );
  late final Animation<double> _nameReveal = CurvedAnimation(
    parent: _mode,
    curve: Curves.easeOutCubic,
  );

  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  RostokAuthMode _currentMode = RostokAuthMode.signIn;
  bool _submitted = false;
  bool _obscure = true;
  bool _mockLoading = false;

  @override
  void initState() {
    super.initState();
    _currentMode = widget.initialMode;
    _mascot.repeat(reverse: true);
    for (final TextEditingController c in <TextEditingController>[
      _name,
      _email,
      _password,
    ]) {
      c.addListener(_onFieldChanged);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) {
      _entrance.value = 1;
      _mascot.stop();
    } else if (_entrance.status == AnimationStatus.dismissed) {
      _entrance.forward();
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _mascot.dispose();
    _mode.dispose();
    _entrance.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    // Live-refresh inline validation only after the first submit attempt,
    // to avoid rebuilding the whole screen on every keystroke.
    if (_submitted) {
      setState(() {});
    }
  }

  bool get _isRegister => _currentMode == RostokAuthMode.register;
  bool get _emailValid {
    final String t = _email.text.trim();
    return t.length >= 5 && t.contains('@') && t.contains('.');
  }

  static const int _minPasswordLength = 8;

  bool get _passwordValid => _password.text.length >= _minPasswordLength;
  bool get _nameValid => _name.text.trim().length >= 2;
  bool get _formValid =>
      _emailValid && _passwordValid && (!_isRegister || _nameValid);

  void _setMode(RostokAuthMode mode) {
    if (_currentMode == mode) {
      return;
    }
    HapticFeedback.selectionClick();
    setState(() => _currentMode = mode);
    if (mode == RostokAuthMode.register) {
      _mode.forward();
    } else {
      _mode.reverse();
    }
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    setState(() => _submitted = true);
    if (!_formValid) {
      HapticFeedback.lightImpact();
      return;
    }
    HapticFeedback.mediumImpact();
    final AuthCubit cubit = context.read<AuthCubit>();
    if (_isRegister) {
      cubit.signUpWithEmail(
        name: _name.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
      );
    } else {
      cubit.signInWithEmail(
        email: _email.text.trim(),
        password: _password.text,
      );
    }
  }

  Future<void> _mockLogin() async {
    if (_mockLoading) {
      return;
    }
    setState(() => _mockLoading = true);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final AuthCubit authCubit = context.read<AuthCubit>();
    final result = await sl<SignInAnonymouslyUseCase>()(const NoParams());
    if (!mounted) {
      return;
    }
    result.fold((Failure failure) {
      setState(() => _mockLoading = false);
      messenger.showSnackBar(
        SnackBar(content: Text('Mock login failed: ${failure.message}')),
      );
    }, (AuthUser user) => authCubit.restoreAuthenticatedUser(user));
  }

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listenWhen: (AuthState previous, AuthState current) =>
              previous.runtimeType != current.runtimeType,
          listener: (BuildContext context, AuthState state) {
            if (state is AuthError) {
              HapticFeedback.heavyImpact();
            } else if (state is AuthAuthenticated) {
              HapticFeedback.selectionClick();
            }
          },
          builder: (BuildContext context, AuthState state) {
            final bool busy = state is AuthLoading;
            final String? errorMessage = state is AuthError
                ? state.message
                : null;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _staggered(0, _buildBrand()),
                  const SizedBox(height: 20),
                  _staggered(1, _buildMascot(reduceMotion)),
                  const SizedBox(height: 22),
                  _staggered(2, _buildHeadline()),
                  const SizedBox(height: 22),
                  _staggered(
                    3,
                    _ModeToggle(
                      mode: _currentMode,
                      animation: _mode,
                      onChanged: _setMode,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _staggered(4, _buildErrorBanner(errorMessage)),
                  _staggered(5, _buildForm(busy)),
                  const SizedBox(height: 18),
                  _staggered(
                    6,
                    _PrimaryButton(
                      label: _isRegister
                          ? context.l10n.authCreateAccountButton
                          : context.l10n.authSignInButton,
                      loading: busy,
                      onTap: busy ? null : _submit,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _staggered(7, _buildDivider()),
                  const SizedBox(height: 18),
                  _staggered(8, _buildOAuth(busy)),
                  if (sl.isRegistered<AppFlavor>() &&
                      sl<AppFlavor>().isDevelopment)
                    _staggered(9, _buildMockButton()),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _staggered(int index, Widget child) {
    final double start = (index * 0.05).clamp(0.0, 0.5);
    final Animation<double> anim = CurvedAnimation(
      parent: _entrance,
      curve: Interval(
        start,
        (start + 0.5).clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(anim),
        child: child,
      ),
    );
  }

  Widget _buildBrand() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 16,
          height: 16,
          decoration: const BoxDecoration(
            color: RostokColors.accent,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 9),
        Text(
          context.l10n.authBrandName,
          style: RostokText.display(
            size: 26,
            weight: FontWeight.w600,
            color: context.colors.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildMascot(bool reduceMotion) {
    final Widget core = Container(
      width: 132,
      height: 132,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: <Color>[
            RostokColors.accent.withValues(alpha: 0.35),
            RostokColors.accent.withValues(alpha: 0),
          ],
          stops: const <double>[0.1, 1],
        ),
      ),
      child: Container(
        width: 92,
        height: 92,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          // White in light, the dark card tone in dark — the sprout art is
          // green/lime, so it reads on both.
          color: Theme.of(context).cardTheme.color,
          shape: BoxShape.circle,
          boxShadow: RostokDimens.softShadow,
        ),
        child: const SproutGrowthAnimation(
          size: 54,
          delay: Duration(milliseconds: 250),
        ),
      ),
    );
    if (reduceMotion) {
      return Center(child: core);
    }
    return Center(
      child: AnimatedBuilder(
        animation: _mascot,
        builder: (BuildContext context, Widget? child) {
          final double t = Curves.easeInOut.transform(_mascot.value);
          return Transform.translate(
            offset: Offset(0, t * 8 - 4),
            child: child,
          );
        },
        child: core,
      ),
    );
  }

  Widget _buildHeadline() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      transitionBuilder: (Widget child, Animation<double> anim) =>
          FadeTransition(opacity: anim, child: child),
      child: Column(
        key: ValueKey<bool>(_isRegister),
        children: <Widget>[
          Text(
            _isRegister
                ? context.l10n.authRegisterHeadline
                : context.l10n.authSignInHeadline,
            textAlign: TextAlign.center,
            style: RostokText.display(
              size: 28,
              color: context.colors.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _isRegister
                ? context.l10n.authRegisterSubtitle
                : context.l10n.authSignInSubtitle,
            textAlign: TextAlign.center,
            style: RostokText.body(
              size: 14,
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String? message) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: message == null
          ? const SizedBox(width: double.infinity)
          : Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _errorColor.withValues(alpha: 0.10),
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                border: Border.all(color: _errorColor.withValues(alpha: 0.35)),
              ),
              child: Row(
                children: <Widget>[
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 18,
                    color: _errorColor,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      message,
                      style: RostokText.body(
                        size: 13,
                        weight: FontWeight.w600,
                        color: _errorColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildForm(bool busy) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizeTransition(
          sizeFactor: _nameReveal,
          alignment: Alignment.topCenter,
          child: FadeTransition(
            opacity: _nameReveal,
            child: ExcludeSemantics(
              excluding: !_isRegister,
              child: Column(
                children: <Widget>[
                  _AuthField(
                    controller: _name,
                    label: context.l10n.authNameLabel,
                    icon: Icons.person_outline_rounded,
                    textInputAction: TextInputAction.next,
                    enabled: !busy,
                    errorText: _submitted && _isRegister && !_nameValid
                        ? context.l10n.authNameError
                        : null,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
        _AuthField(
          controller: _email,
          label: context.l10n.authEmailLabel,
          icon: Icons.alternate_email_rounded,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          enabled: !busy,
          errorText: _submitted && !_emailValid
              ? context.l10n.authEmailError
              : null,
        ),
        const SizedBox(height: 12),
        _AuthField(
          controller: _password,
          label: context.l10n.authPasswordLabel,
          icon: Icons.lock_outline_rounded,
          obscure: _obscure,
          enabled: !busy,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          onToggleObscure: () => setState(() => _obscure = !_obscure),
          errorText: _submitted && !_passwordValid
              ? context.l10n.authPasswordError(_minPasswordLength)
              : null,
        ),
      ],
    );
  }

  Widget _buildDivider() {
    final Widget line = Expanded(
      child: Divider(color: context.colors.outlineVariant, thickness: 1),
    );
    return Row(
      children: <Widget>[
        line,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            context.l10n.authDividerOr,
            style: RostokText.body(
              size: 13,
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
        line,
      ],
    );
  }

  Widget _buildOAuth(bool busy) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _SocialButton(
            label: 'Apple',
            icon: Icons.apple,
            onTap: busy
                ? null
                : () => context.read<AuthCubit>().signInWithOAuth(
                    provider: OAuthSignInProvider.apple,
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SocialButton(
            label: 'Google',
            icon: Icons.g_mobiledata_rounded,
            onTap: busy
                ? null
                : () => context.read<AuthCubit>().signInWithOAuth(
                    provider: OAuthSignInProvider.google,
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildMockButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: OutlinedButton.icon(
        onPressed: _mockLoading ? null : _mockLogin,
        icon: _mockLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.science_outlined),
        label: const Text('Mock login (dev)'),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          foregroundColor: RostokColors.accentOrange,
          side: const BorderSide(color: RostokColors.accentOrange),
        ),
      ),
    );
  }
}

/// Animated segmented Вход⇄Регистрация toggle with a sliding indicator.
class _ModeToggle extends StatelessWidget {
  const _ModeToggle({
    required this.mode,
    required this.animation,
    required this.onChanged,
  });

  final RostokAuthMode mode;
  final Animation<double> animation;
  final ValueChanged<RostokAuthMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.all(Radius.circular(18)),
      ),
      child: Stack(
        children: <Widget>[
          AnimatedBuilder(
            animation: animation,
            builder: (BuildContext context, Widget? child) {
              return Align(
                alignment: Alignment(
                  Alignment.lerp(
                    Alignment.centerLeft,
                    Alignment.centerRight,
                    animation.value,
                  )!.x,
                  0,
                ),
                child: child,
              );
            },
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                decoration: BoxDecoration(
                  color: context.colors.primary,
                  borderRadius: const BorderRadius.all(Radius.circular(14)),
                ),
              ),
            ),
          ),
          Row(
            children: <Widget>[
              _segment(
                context,
                context.l10n.authModeSignIn,
                RostokAuthMode.signIn,
              ),
              _segment(
                context,
                context.l10n.authModeRegister,
                RostokAuthMode.register,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _segment(
    BuildContext context,
    String label,
    RostokAuthMode segmentMode,
  ) {
    final bool selected = mode == segmentMode;
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onChanged(segmentMode),
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              style: RostokText.body(
                size: 14,
                weight: FontWeight.w700,
                color: selected
                    ? context.colors.onPrimary
                    : context.colors.onSurface,
              ),
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}

/// White pill text field with an animated focus border, optional password
/// show/hide, and an inline error line.
class _AuthField extends StatefulWidget {
  const _AuthField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.onToggleObscure,
    this.errorText,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onToggleObscure;
  final String? errorText;

  @override
  State<_AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<_AuthField> {
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    super.dispose();
  }

  void _onFocusChanged() => setState(() => _focused = _focusNode.hasFocus);

  @override
  Widget build(BuildContext context) {
    final bool hasError = widget.errorText != null;
    final Color borderColor = hasError
        ? _errorColor
        : (_focused ? RostokColors.mascot : Colors.transparent);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            boxShadow: RostokDimens.softShadow,
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                widget.icon,
                size: 20,
                color: _focused
                    ? context.colors.onSurface
                    : context.colors.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  obscureText: widget.obscure,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  onSubmitted: widget.onSubmitted,
                  cursorColor: context.colors.onSurface,
                  style: RostokText.body(
                    size: 16,
                    weight: FontWeight.w600,
                    color: context.colors.onSurface,
                  ),
                  // Override the global InputDecorationTheme's OutlineInputBorder
                  // in every state — that stray rounded outline was showing
                  // inside the pill. The container's own border handles visuals.
                  decoration: InputDecoration(
                    isCollapsed: true,
                    filled: false,
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    hintText: widget.label,
                    hintStyle: RostokText.body(
                      size: 16,
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              if (widget.onToggleObscure != null)
                Semantics(
                  button: true,
                  label: widget.obscure
                      ? context.l10n.authShowPassword
                      : context.l10n.authHidePassword,
                  child: IconButton(
                    onPressed: widget.onToggleObscure,
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      widget.obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.topLeft,
          child: hasError
              ? Padding(
                  padding: const EdgeInsets.only(left: 8, top: 6),
                  child: Text(
                    widget.errorText!,
                    style: RostokText.body(
                      size: 12,
                      weight: FontWeight.w600,
                      color: _errorColor,
                    ),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, this.loading = false, this.onTap});

  final String label;
  final bool loading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.primary,
        borderRadius: const BorderRadius.all(Radius.circular(22)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(22)),
          onTap: onTap,
          child: SizedBox(
            height: 60,
            child: Center(
              child: loading
                  ? SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        // Lime on the dark pill (light), dark ink on the lime
                        // pill (dark) — the spinner tracks the button.
                        valueColor: AlwaysStoppedAnimation<Color>(
                          context.colors.brightness == Brightness.dark
                              ? context.colors.onPrimary
                              : RostokColors.accent,
                        ),
                      ),
                    )
                  : AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: Text(
                        label,
                        key: ValueKey<String>(label),
                        style: RostokText.display(
                          size: 18,
                          weight: FontWeight.w600,
                          color: context.colors.onPrimary,
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.label, required this.icon, this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: const BorderRadius.all(Radius.circular(18)),
        boxShadow: RostokDimens.buttonShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(18)),
          onTap: onTap,
          child: SizedBox(
            height: 54,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(icon, size: 22, color: context.colors.onSurface),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: RostokText.body(
                    size: 15,
                    weight: FontWeight.w600,
                    color: context.colors.onSurface,
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
