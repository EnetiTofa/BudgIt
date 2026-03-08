// lib/src/common_widgets/color_picker_field.dart

import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ColorPickerField extends StatelessWidget {
  const ColorPickerField({
    super.key,
    this.selectedColor,
    required this.onColorSelected,
    this.labelText = 'Color',
  });

  final Color? selectedColor;
  final ValueChanged<Color> onColorSelected;
  final String labelText;

  Future<void> _showColorPicker(BuildContext context) async {
    final color = await showModalBottomSheet<Color>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.85,
          child: Padding(
            padding: EdgeInsets.only(
              left: 24.0,
              right: 24.0,
              top: 24.0,
              bottom: MediaQuery.of(context).padding.bottom + 16.0,
            ),
            child: _UltimateColorPicker(
              initialColor: selectedColor ?? Colors.blue,
            ),
          ),
        );
      },
    );

    if (color != null) {
      onColorSelected(color);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showColorPicker(context),
          borderRadius: BorderRadius.circular(12.0),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 14.0,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: selectedColor ?? Colors.transparent,
                  radius: 12,
                  child: selectedColor == null
                      ? Icon(
                          Icons.color_lens_outlined,
                          size: 16,
                          color: colorScheme.onSurfaceVariant,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedColor == null
                        ? 'Choose a color...'
                        : '#${selectedColor!.value.toRadixString(16).substring(2).toUpperCase()}',
                    style: textTheme.bodyLarge?.copyWith(
                      color: selectedColor == null
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.onSurface,
                      fontWeight: selectedColor == null
                          ? FontWeight.normal
                          : FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _UltimateColorPicker extends StatefulWidget {
  final Color initialColor;

  const _UltimateColorPicker({required this.initialColor});

  @override
  State<_UltimateColorPicker> createState() => _UltimateColorPickerState();
}

class _UltimateColorPickerState extends State<_UltimateColorPicker> {
  late HSVColor _hsvColor;
  late TextEditingController _hexController;

  @override
  void initState() {
    super.initState();
    _hsvColor = HSVColor.fromColor(widget.initialColor);
    _hexController = TextEditingController(
      text: _colorToHex(widget.initialColor),
    );
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  String _colorToHex(Color color) {
    return color.value.toRadixString(16).substring(2).toUpperCase();
  }

  void _updateColorFromPicker(Color newColor) {
    setState(() {
      _hsvColor = HSVColor.fromColor(newColor);
      _hexController.text = _colorToHex(newColor);
    });
  }

  void _updateColorFromHSV(HSVColor newHsv) {
    setState(() {
      _hsvColor = newHsv;
      _hexController.text = _colorToHex(newHsv.toColor());
    });
  }

  void _updateColorFromHex(String hex) {
    if (hex.length == 6) {
      final newColor = Color(int.parse('FF$hex', radix: 16));
      setState(() {
        _hsvColor = HSVColor.fromColor(newColor);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _hsvColor.toColor();
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Color',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(color),
                child: const Text('Apply'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _hexController,
                  decoration: InputDecoration(
                    labelText: 'Hex Code',
                    prefixText: '#',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                  maxLength: 6,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9a-fA-F]')),
                  ],
                  onChanged: _updateColorFromHex,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const TabBar(
            labelPadding: EdgeInsets.symmetric(horizontal: 8),
            tabs: [
              Tab(text: 'Palettes'),
              Tab(text: 'Wheel'),
              Tab(text: 'RGB'),
              Tab(text: 'HSB'),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              children: [
                _buildPalettesTab(theme),
                _buildWheelTab(),
                _buildRGBSliders(theme, color),
                _buildHSVSliders(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPalettesTab(ThemeData theme) {
    // Reverted back to the original standard Material primary colors
    final standardPalette = Colors.primaries;

    final vibrantPalette = [
      const Color(0xFFF44336),
      const Color(0xFFE91E63),
      const Color(0xFF9C27B0),
      const Color(0xFF2196F3),
      const Color(0xFF00BCD4),
      const Color(0xFF4CAF50),
      const Color(0xFFFFEB3B),
      const Color(0xFFFF9800),
      const Color(0xFFFF5722),
    ];

    final saturatedPastels = [
      const Color(0xFFE57373),
      const Color(0xFFF06292),
      const Color(0xFFBA68C8),
      const Color(0xFF64B5F6),
      const Color(0xFF4DD0E1),
      const Color(0xFF81C784),
      const Color(0xFFDCE775),
      const Color(0xFFFFD54F),
      const Color(0xFFFF8A65),
    ];

    final lightPastels = [
      const Color(0xFFFFCDD2),
      const Color(0xFFF8BBD0),
      const Color(0xFFE1BEE7),
      const Color(0xFFBBDEFB),
      const Color(0xFFB2EBF2),
      const Color(0xFFC8E6C9),
      const Color(0xFFFFF9C4),
      const Color(0xFFFFE0B2),
      const Color(0xFFFFCCBC),
    ];

    final darkPalette = [
      const Color(0xFFB71C1C),
      const Color(0xFF880E4F),
      const Color(0xFF4A148C),
      const Color(0xFF0D47A1),
      const Color(0xFF006064),
      const Color(0xFF1B5E20),
      const Color(0xFFF57F17),
      const Color(0xFFE65100),
      const Color(0xFFBF360C),
    ];

    final mutedPalette = [
      const Color(0xFF78909C),
      const Color(0xFF8D6E63),
      const Color(0xFF9E9E9E),
      const Color(0xFFBCAAA4),
      const Color(0xFFB0BEC5),
      const Color(0xFFD7CCC8),
      const Color(0xFFCFD8DC),
      const Color(0xFFE0E0E0),
      const Color(0xFF546E7A),
    ];

    return ListView(
      padding: const EdgeInsets.only(top: 8.0, bottom: 40.0),
      children: [
        _buildPaletteSection('Standard', standardPalette, theme),
        const SizedBox(height: 24),
        _buildPaletteSection('Vibrant', vibrantPalette, theme),
        const SizedBox(height: 24),
        _buildPaletteSection('Saturated Pastels', saturatedPastels, theme),
        const SizedBox(height: 24),
        _buildPaletteSection('Light Pastels', lightPastels, theme),
        const SizedBox(height: 24),
        _buildPaletteSection('Dark & Rich', darkPalette, theme),
        const SizedBox(height: 24),
        _buildPaletteSection('Muted & Neutral', mutedPalette, theme),
      ],
    );
  }

  Widget _buildPaletteSection(
    String title,
    List<Color> colors,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: colors.map((c) {
            final isSelected = _hsvColor.toColor().value == c.value;
            return InkWell(
              onTap: () => _updateColorFromPicker(c),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        color: c.computeLuminance() > 0.5
                            ? Colors.black
                            : Colors.white,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildWheelTab() {
    return SingleChildScrollView(
      child: ColorPicker(
        color: _hsvColor.toColor(),
        onColorChanged: _updateColorFromPicker,
        wheelDiameter: 250,
        enableOpacity: false,
        showColorCode: false,
        showColorName: false,
        showRecentColors: false,
        pickersEnabled: const <ColorPickerType, bool>{
          ColorPickerType.wheel: true,
          ColorPickerType.both: false,
          ColorPickerType.primary: false,
          ColorPickerType.accent: false,
          ColorPickerType.bw: false,
          ColorPickerType.custom: false,
        },
      ),
    );
  }

  Widget _buildHSVSliders(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.only(top: 8.0, bottom: 40.0),
      children: [
        _LargeSlider(
          label: 'Hue',
          value: _hsvColor.hue,
          min: 0,
          max: 360,
          activeColor: HSVColor.fromAHSV(
            1.0,
            _hsvColor.hue,
            1.0,
            1.0,
          ).toColor(),
          onChanged: (val) => _updateColorFromHSV(_hsvColor.withHue(val)),
          valueLabel: '${_hsvColor.hue.toInt()}°',
        ),
        _LargeSlider(
          label: 'Saturation',
          value: _hsvColor.saturation,
          min: 0,
          max: 1.0,
          activeColor: _hsvColor.toColor(),
          onChanged: (val) =>
              _updateColorFromHSV(_hsvColor.withSaturation(val)),
          valueLabel: '${(_hsvColor.saturation * 100).toInt()}%',
        ),
        _LargeSlider(
          label: 'Brightness',
          value: _hsvColor.value,
          min: 0,
          max: 1.0,
          activeColor: Colors.grey.shade700,
          onChanged: (val) => _updateColorFromHSV(_hsvColor.withValue(val)),
          valueLabel: '${(_hsvColor.value * 100).toInt()}%',
        ),
      ],
    );
  }

  Widget _buildRGBSliders(ThemeData theme, Color rgbColor) {
    return ListView(
      padding: const EdgeInsets.only(top: 8.0, bottom: 40.0),
      children: [
        _LargeSlider(
          label: 'Red',
          value: rgbColor.red.toDouble(),
          min: 0,
          max: 255,
          activeColor: Colors.red,
          onChanged: (val) {
            final newColor = rgbColor.withRed(val.toInt());
            _updateColorFromHSV(HSVColor.fromColor(newColor));
          },
          valueLabel: rgbColor.red.toString(),
        ),
        _LargeSlider(
          label: 'Green',
          value: rgbColor.green.toDouble(),
          min: 0,
          max: 255,
          activeColor: Colors.green,
          onChanged: (val) {
            final newColor = rgbColor.withGreen(val.toInt());
            _updateColorFromHSV(HSVColor.fromColor(newColor));
          },
          valueLabel: rgbColor.green.toString(),
        ),
        _LargeSlider(
          label: 'Blue',
          value: rgbColor.blue.toDouble(),
          min: 0,
          max: 255,
          activeColor: Colors.blue,
          onChanged: (val) {
            final newColor = rgbColor.withBlue(val.toInt());
            _updateColorFromHSV(HSVColor.fromColor(newColor));
          },
          valueLabel: rgbColor.blue.toString(),
        ),
      ],
    );
  }
}

class _LargeSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final Color activeColor;
  final ValueChanged<double> onChanged;
  final String valueLabel;

  const _LargeSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.activeColor,
    required this.onChanged,
    required this.valueLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                valueLabel,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 16,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 16),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 32),
              activeTrackColor: activeColor,
              inactiveTrackColor: theme.colorScheme.surfaceContainerHighest,
              thumbColor: theme.colorScheme.surface,
            ),
            child: Semantics(
              label: '$label slider',
              value: valueLabel,
              child: Slider(
                value: value,
                min: min,
                max: max,
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
