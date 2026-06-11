import 'dart:async';

import 'package:flutter/material.dart';

class InterviewConceptsPage extends StatefulWidget {
  const InterviewConceptsPage({super.key});

  @override
  State<InterviewConceptsPage> createState() => _InterviewConceptsPageState();
}

class _InterviewConceptsPageState extends State<InterviewConceptsPage>
    with WidgetsBindingObserver {
  final ValueNotifier<int> _counter = ValueNotifier<int>(0);
  final StreamController<int> _streamController =
      StreamController<int>.broadcast();

  late final Future<String> _cachedFuture;
  AppLifecycleState? _lifecycleState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cachedFuture = Future<String>.delayed(
      const Duration(milliseconds: 300),
      () => 'Future completed once and is cached in initState.',
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _lifecycleState = state;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _counter.dispose();
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Interview Concepts')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ConceptCard(
            title: 'Ephemeral state with ValueNotifier',
            child: ValueListenableBuilder<int>(
              valueListenable: _counter,
              builder: (context, value, child) {
                return Row(
                  children: [
                    Text(
                      'Count: $value',
                      key: const Key('concept_counter_value'),
                    ),
                    const Spacer(),
                    FilledButton(
                      key: const Key('concept_counter_button'),
                      onPressed: () => _counter.value++,
                      child: const Text('Increment'),
                    ),
                  ],
                );
              },
            ),
          ),
          _ConceptCard(
            title: 'FutureBuilder',
            child: FutureBuilder<String>(
              future: _cachedFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const LinearProgressIndicator();
                }
                return Text(snapshot.data ?? 'No future result');
              },
            ),
          ),
          _ConceptCard(
            title: 'StreamBuilder',
            child: StreamBuilder<int>(
              stream: _streamController.stream,
              initialData: 0,
              builder: (context, snapshot) {
                final value = snapshot.data ?? 0;
                return Row(
                  children: [
                    Text('Latest event: $value'),
                    const Spacer(),
                    FilledButton.tonal(
                      onPressed: () => _streamController.add(value + 1),
                      child: const Text('Emit event'),
                    ),
                  ],
                );
              },
            ),
          ),
          _ConceptCard(
            title: 'App lifecycle',
            child: Text(
              'Current state: ${_lifecycleState?.name ?? 'resumed/unknown'}',
            ),
          ),
          _ConceptCard(
            title: 'Responsive layout with LayoutBuilder',
            child: LayoutBuilder(
              builder: (context, constraints) {
                final layout = constraints.maxWidth >= 600
                    ? 'wide layout'
                    : 'compact layout';
                return Text(
                  'Available width: '
                  '${constraints.maxWidth.toStringAsFixed(0)} ($layout)',
                );
              },
            ),
          ),
          const _ConceptCard(
            title: 'Why keys matter',
            child: Text(
              'Keys preserve widget identity when siblings move and provide '
              'stable targets for widget and integration tests.',
            ),
          ),
        ],
      ),
    );
  }
}

class _ConceptCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _ConceptCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
