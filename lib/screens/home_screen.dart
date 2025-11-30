import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:nir_app/models/settings.dart';
import 'package:nir_app/screens/settings_screen.dart';
import 'package:nir_app/services/speech_service.dart';
import 'package:nir_app/services/text_compare.dart';

class HomeScreen extends StatefulWidget {
  final AppSettings settings;
  final SpeechService speechService;

  const HomeScreen({
    super.key,
    required this.settings,
    required this.speechService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _originalController = TextEditingController();

  double? _similarity;

  @override
  void initState() {
    super.initState();
    widget.speechService.addListener(_onSpeechUpdate);
    widget.settings.addListener(_onSettingsUpdate);
  }

  @override
  void dispose() {
    widget.speechService.removeListener(_onSpeechUpdate);
    widget.settings.removeListener(_onSettingsUpdate);
    _originalController.dispose();
    super.dispose();
  }

  void _onSpeechUpdate() {
    _computeSimilarity();
  }

  void _onSettingsUpdate() {
    _computeSimilarity();
  }

  Future<void> _start() async {
    final ok = await widget.speechService.init(
      localeId: widget.settings.localeId,
    );
    if (!ok) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Распознавание речи недоступно или разрешение отклонено',
            ),
          ),
        );
      }
      return;
    }
    await widget.speechService.start(localeId: widget.settings.localeId);
  }

  Future<void> _stopAndCompare() async {
    await widget.speechService.stop();
    _computeSimilarity();
  }

  void _clear() {
    _similarity = null;
    widget.speechService.cancel();
    setState(() {});
  }

  void _computeSimilarity() {
    final original = _originalController.text;
    final recognized = widget.speechService.recognizedText;
    if (original.isEmpty || recognized.isEmpty) {
      setState(() {
        _similarity = null;
      });
      return;
    }
    double percent;
    switch (widget.settings.metric) {
      case Metric.levenshtein:
        percent = TextCompareService.levenshteinSimilarity(
          original,
          recognized,
        );
        break;
      case Metric.wer:
        percent = TextCompareService.werSimilarity(original, recognized);
        break;
    }
    setState(() {
      _similarity = percent;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Сравнение речи'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SettingsScreen(settings: widget.settings),
                ),
              ).then((_) {
                // Recompute similarity when returning from settings
                _computeSimilarity();
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: TextField(
                    controller: _originalController,
                    maxLines: 5,
                    textInputAction: TextInputAction.newline,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                      labelText: 'Оригинальный текст (например, стихотворение)',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                    onChanged: (_) => _computeSimilarity(),
                  ),
                ),
                if (widget.speechService.isListening)
                  Positioned.fill(
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(color: Colors.transparent),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: widget.speechService.isListening ? null : _start,
                  icon: const Icon(Icons.mic),
                  label: const Text('Старт'),
                ),
                ElevatedButton.icon(
                  onPressed: widget.speechService.isListening
                      ? _stopAndCompare
                      : null,
                  icon: const Icon(Icons.stop),
                  label: const Text('Стоп'),
                ),
                OutlinedButton.icon(
                  onPressed: _clear,
                  icon: const Icon(Icons.clear),
                  label: const Text('Очистить'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    widget.speechService.recognizedText.isEmpty
                        ? '—'
                        : widget.speechService.recognizedText,
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Text(
                  'Результат:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(width: 8),
                Text(
                  _similarity == null
                      ? '—'
                      : '${_similarity!.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _similarity != null && _similarity! >= 80
                        ? Colors.green
                        : _similarity != null && _similarity! >= 50
                        ? Colors.orange
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_similarity != null) ...[
              Text(
                _similarity! < 90
                    ? 'Попробуй еще раз!'
                    : 'Отлично! Можно переходить к следующему стихотворению!',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: _similarity! >= 90 ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
