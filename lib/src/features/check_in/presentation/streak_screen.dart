// lib/src/features/check_in/presentation/streak_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class StreakScreen extends StatefulWidget {
  final int streakCount;
  const StreakScreen({super.key, required this.streakCount});

  @override
  State<StreakScreen> createState() => _StreakScreenState();
}

class _StreakScreenState extends State<StreakScreen>
    with TickerProviderStateMixin {
  int _displayCount = 0;
  int _previousCount = 0;
  bool _isAnimating = false;
  bool _isHeated = false;

  late AnimationController _revealController;
  late AnimationController _bulgeController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _textFadeAnimation;
  late CurvedAnimation _revealCurve;
  late Animation<double> _numberBulgeAnimation;
  late Animation<double> _flameBulgeAnimation;
  late Animation<double> _flameShrinkAnimation;

  @override
  void initState() {
    super.initState();

    _revealController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    _bulgeController = AnimationController(
        duration: const Duration(milliseconds: 100), vsync: this);

    _revealCurve =
        CurvedAnimation(parent: _revealController, curve: Curves.easeInOutCubic);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.7).animate(_revealCurve);
    _textFadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_revealCurve);

    final bulgeCurve =
        CurvedAnimation(parent: _bulgeController, curve: Curves.easeOut);
    _numberBulgeAnimation =
        Tween<double>(begin: 1.0, end: 1.2).animate(bulgeCurve);
    _flameBulgeAnimation =
        Tween<double>(begin: 1.0, end: 1.25).animate(bulgeCurve);
    _flameShrinkAnimation =
        Tween<double>(begin: 1.25, end: 1.0).animate(_revealCurve);
        
    // Start the animations with the streak count passed from the parent
    _startAnimations(widget.streakCount);
  }

  void _startAnimations(int streakCount) {
    
    // Set initial state immediately for the animation
    _previousCount = streakCount > 0 ? streakCount - 1 : 0;
    _displayCount = _previousCount;

    Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _displayCount = streakCount;
          _isAnimating = true;
        });
      }
    });

    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isHeated = true;
        });
        _bulgeController.forward();
      }
    });

    Timer(const Duration(milliseconds: 2250), () {
      if (mounted) {
        _revealController.forward();
      }
    });

    Timer(const Duration(seconds: 4, milliseconds: 500), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _revealController.dispose();
    _bulgeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
          
    final numberTextStyle = theme.textTheme.displayLarge?.copyWith(
      fontWeight: FontWeight.bold,
      fontSize: 90,
      color: _isHeated
          ? Colors.orange.shade700
          : theme.colorScheme.secondary,
    );
    const double numberContainerHeight = 110.0;

    final String capitalizedPeriod =
        'week';
    final String pluralSuffix = widget.streakCount == 1 ? '' : 's';
    final String periodText = '$capitalizedPeriod$pluralSuffix';

    final periodTextStyle = theme.textTheme.headlineLarge?.copyWith(
      color: Colors.orange.shade700,
      fontSize: 82,
      fontWeight: FontWeight.bold,
    );

    final periodTextPainter = TextPainter(
      text: TextSpan(text: periodText, style: periodTextStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    final double periodTextWidth = periodTextPainter.width;

    final numberTextPainter = TextPainter(
      text: TextSpan(text: widget.streakCount.toString(), style: numberTextStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    final double numberWidth = numberTextPainter.width;

    const double gap = 12.0;
    final double numberTranslationX = -(periodTextWidth / 2) - (gap / 2);
    final double periodTextTranslationX = (numberWidth / 2) + (gap / 2);

    Widget numberAnimationWidget() {
      final newStr = _displayCount.toString();
      final oldStr = _previousCount.toString();

      if (newStr.length > oldStr.length && _isAnimating) {
        return TweenAnimationBuilder<double>(
          key: ValueKey('full_roll_$_displayCount'),
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInQuint,
          builder: (context, value, child) {
            return SizedBox(
              height: numberContainerHeight,
              child: ClipRect(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.translate(
                      offset: Offset(0, value * -numberContainerHeight),
                      child: Text(oldStr, style: numberTextStyle),
                    ),
                    Transform.translate(
                      offset:
                          Offset(0, (1 - value) * numberContainerHeight),
                      child: Text(newStr, style: numberTextStyle),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
      
      if (!_isAnimating) {
          return Text(_displayCount.toString(), style: numberTextStyle);
      }

      final maxLength = newStr.length;
      final paddedOldStr = oldStr.padLeft(maxLength, ' ');
      List<Widget> digitWidgets = [];
      for (int i = 0; i < maxLength; i++) {
        final oldDigit = paddedOldStr[i];
        final newDigit = newStr[i];
        final isLastDigit = i == maxLength - 1;

        if (!isLastDigit) {
          digitWidgets.add(Text(newDigit, style: numberTextStyle));
          continue;
        }

        digitWidgets.add(
          TweenAnimationBuilder<double>(
            key: ValueKey('odometer_roll_$_displayCount'),
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInQuint,
            builder: (context, value, child) {
              return SizedBox(
                height: numberContainerHeight,
                child: ClipRect(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Transform.translate(
                        offset:
                            Offset(0, value * -numberContainerHeight),
                        child: Text(oldDigit, style: numberTextStyle),
                      ),
                      Transform.translate(
                        offset: Offset(
                            0, (1 - value) * numberContainerHeight),
                        child: Text(newDigit, style: numberTextStyle),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }
      return Row(mainAxisSize: MainAxisSize.min, children: digitWidgets);
    }
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_revealController, _bulgeController]),
        builder: (context, child) {
          double flameScale;
          if (_revealController.isAnimating || _revealController.isCompleted) {
            flameScale = _flameShrinkAnimation.value;
          } else if (_isHeated) {
            flameScale = _flameBulgeAnimation.value;
          } else {
            flameScale = 1.0;
          }
          return Stack(
            children: [
              Align(
                alignment: const Alignment(0, -0.7),
                child: FadeTransition(
                  opacity: _textFadeAnimation,
                  child: Text('Streak Increased!',
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 225,
                      height: 225,
                      child: Transform.scale(
                        scale: flameScale,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                                Icons.circle,
                                color: _isHeated
                                    ? Colors.yellow.shade600
                                    : theme.colorScheme.surfaceContainerLow,
                                size: 140),
                            FaIcon(FontAwesomeIcons.fire,
                                size: 180,
                                color: _isHeated
                                    ? Colors.orange.shade700
                                    : theme.colorScheme
                                        .surfaceContainerHighest),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 132, // (110.0 base height * 1.2 max scale)
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: ScaleTransition(
                          scale: _numberBulgeAnimation,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              AnimatedBuilder(
                                animation: _revealCurve,
                                builder: (context, child) {
                                  return Transform.translate(
                                      offset: Offset(numberTranslationX *
                                          _revealCurve.value, 0),
                                      child: child);
                                },
                                child: numberAnimationWidget(),
                              ),
                              AnimatedBuilder(
                                animation: _revealCurve,
                                builder: (context, child) {
                                  return Transform.translate(
                                      offset: Offset(periodTextTranslationX *
                                          _revealCurve.value, 0),
                                      child: child);
                                },
                                child: FadeTransition(
                                  opacity: _textFadeAnimation,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.only(left: 8.0),
                                    child: Text(periodText,
                                        style: periodTextStyle),
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
              ),
            ],
          );
        },
      ),
    );
  }
}