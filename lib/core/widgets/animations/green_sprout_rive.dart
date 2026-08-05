import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:stay_alive/core/motion/motion_config.dart';
import 'package:stay_alive/core/rive/rive_bootstrap.dart';
import 'package:stay_alive/core/theme/app_colors.dart';
import 'package:stay_alive/core/widgets/animations/sprout_growth_animation.dart';
import 'package:stay_alive/core/widgets/sprout_icon.dart';

const String _kGreenSproutAsset = 'assets/animations/green_sprout.riv';
const String _kGreenSproutArtboard = 'GreenSprout';
const String _kGreenSproutAnimation = 'grow';

/// Rive runtime for the green sprout asset (`green_sprout.riv`).
///
/// [replayKey] bumps force a fresh grow animation (e.g. after logging).
class GreenSproutRive extends StatefulWidget {
  const GreenSproutRive({
    this.size = 80,
    this.replayKey = 0,
    this.wilting = false,
    super.key,
  });

  final double size;
  final int replayKey;
  final bool wilting;

  @override
  State<GreenSproutRive> createState() => _GreenSproutRiveState();
}

class _GreenSproutRiveState extends State<GreenSproutRive> {
  File? _file;
  Artboard? _artboard;
  SingleAnimationPainter? _painter;
  bool _useFallback = false;
  bool _loading = true;
  bool _started = false;

  @override
  void didUpdateWidget(covariant GreenSproutRive oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.replayKey != widget.replayKey) {
      _painter?.dispose();
      _artboard?.dispose();
      _file?.dispose();
      _file = null;
      _artboard = null;
      _painter = null;
      _started = false;
      _loading = true;
      _useFallback = false;
      _load();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) {
      return;
    }
    _started = true;
    _load();
  }

  Future<void> _load() async {
    if (MotionConfig.reduceMotionOf(context)) {
      if (mounted) {
        setState(() {
          _loading = false;
          _useFallback = true;
        });
      }
      return;
    }

    final bool ready = await RiveBootstrap.ensureInitialized();
    if (!ready) {
      if (mounted) {
        setState(() {
          _loading = false;
          _useFallback = true;
        });
      }
      return;
    }

    try {
      final File file = (await File.asset(
        _kGreenSproutAsset,
        riveFactory: Factory.flutter,
      ))!;
      final Artboard? artboard =
          file.artboard(_kGreenSproutArtboard) ?? file.defaultArtboard();
      final SingleAnimationPainter painter =
          SingleAnimationPainter(_kGreenSproutAnimation);

      if (!mounted) {
        painter.dispose();
        artboard?.dispose();
        file.dispose();
        return;
      }

      setState(() {
        _file = file;
        _artboard = artboard;
        _painter = painter;
        _loading = false;
        _useFallback = artboard == null;
      });
    } catch (error, stackTrace) {
      debugPrint('GreenSproutRive: failed to load asset — $error');
      debugPrint('$stackTrace');
      if (mounted) {
        setState(() {
          _file = null;
          _artboard = null;
          _painter = null;
          _loading = false;
          _useFallback = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _painter?.dispose();
    _artboard?.dispose();
    _file?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_useFallback) {
      return SproutGrowthAnimation(size: widget.size);
    }

    if (_loading) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.green,
          ),
        ),
      );
    }

    final Artboard? artboard = _artboard;
    final SingleAnimationPainter? painter = _painter;
    if (artboard == null || painter == null) {
      return SproutGrowthAnimation(size: widget.size);
    }

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: RiveArtboardWidget(
        artboard: artboard,
        painter: painter,
      ),
    );
  }
}

/// Sprout emblem with the Rive growth loop — used on premium paywalls.
class GreenSproutRiveEmblem extends StatelessWidget {
  const GreenSproutRiveEmblem({
    this.size = 120,
    this.glowColor = AppColors.lime,
    this.replayKey = 0,
    this.wilting = false,
    super.key,
  });

  final double size;
  final Color glowColor;
  final int replayKey;
  final bool wilting;

  @override
  Widget build(BuildContext context) {
    if (MotionConfig.reduceMotionOf(context)) {
      return SproutEmblem(size: size, glowColor: glowColor);
    }

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: <Color>[
            glowColor.withValues(alpha: 0.35),
            glowColor.withValues(alpha: 0),
          ],
          stops: const <double>[0.1, 1],
        ),
      ),
      child: Container(
        width: size * 0.68,
        height: size * 0.68,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: GreenSproutRive(
          size: size * 0.52,
          replayKey: replayKey,
          wilting: wilting,
        ),
      ),
    );
  }
}
