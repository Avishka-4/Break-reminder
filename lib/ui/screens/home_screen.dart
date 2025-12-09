import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../logic/break_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<BreakController>();
    final cs = Theme.of(context).colorScheme;
    final remaining = controller.remaining();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Break Reminder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 0,
              color: cs.primary.withOpacity(0.08),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.isOnBreak ? 'Break Time' : 'Focus Time',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDuration(remaining),
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: cs.primary,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      controller.isOnBreak
                          ? 'Stretch, hydrate, and rest your eyes.'
                          : 'Stay focused. Micro-break coming soon.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: controller.isRunning ? null : controller.start,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start'),
                ),
                ElevatedButton.icon(
                  onPressed: controller.isRunning ? controller.pause : null,
                  icon: const Icon(Icons.pause),
                  label: const Text('Pause'),
                ),
                ElevatedButton.icon(
                  onPressed: controller.isRunning ? controller.stop : null,
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop'),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.push('/timer'),
                  icon: const Icon(Icons.timer),
                  label: const Text('Timer View'),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.push('/summary'),
                  icon: const Icon(Icons.insights),
                  label: const Text('Summary'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final h = d.inHours;
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }
}
