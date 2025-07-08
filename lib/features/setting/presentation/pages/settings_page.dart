import 'package:fairsplit/features/setting/presentation/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = ref.read(themeColorProvider);
  }

  void _onColorTap(Color color) {
    setState(() {
      _selectedColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Chọn màu giao diện:', style: TextStyle(fontSize: 18)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ThemeColorCircle(
                color: const Color.fromARGB(255, 0, 140, 255),
                selected:
                    _selectedColor.toARGB32() ==
                    const Color.fromARGB(255, 0, 140, 255).toARGB32(),
                onTap: () =>
                    _onColorTap(const Color.fromARGB(255, 0, 140, 255)),
              ),
              const SizedBox(width: 24),
              _ThemeColorCircle(
                color: Colors.yellow,
                selected: _selectedColor == Colors.yellow,
                onTap: () => _onColorTap(Colors.yellow),
              ),
              const SizedBox(width: 24),
              _ThemeColorCircle(
                color: const Color.fromARGB(255, 255, 0, 85),
                selected:
                    _selectedColor.toARGB32() ==
                    const Color.fromARGB(255, 255, 0, 85).toARGB32(),
                onTap: () => _onColorTap(const Color.fromARGB(255, 255, 0, 85)),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Center(
            child: ElevatedButton(
              onPressed: () {
                ref
                    .read(themeColorProvider.notifier)
                    .updateColor(_selectedColor);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã áp dụng màu giao diện!')),
                );
              },
              child: const Text('Apply'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeColorCircle extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeColorCircle({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? Colors.black : Colors.grey,
            width: selected ? 3 : 1,
          ),
        ),
      ),
    );
  }
}
