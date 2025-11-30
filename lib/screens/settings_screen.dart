import 'package:flutter/material.dart';
import 'package:nir_app/models/settings.dart';

class SettingsScreen extends StatelessWidget {
  final AppSettings settings;

  const SettingsScreen({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Метод сравнения',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListenableBuilder(
              listenable: settings,
              builder: (context, child) => SegmentedButton<Metric>(
                segments: const [
                  ButtonSegment(
                    value: Metric.levenshtein,
                    label: Text('Levenshtein'),
                  ),
                  ButtonSegment(value: Metric.wer, label: Text('WER')),
                ],
                selected: <Metric>{settings.metric},
                onSelectionChanged: (sel) {
                  if (sel.isEmpty) return;
                  settings.updateMetric(sel.first);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
