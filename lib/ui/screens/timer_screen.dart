import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/break_controller.dart';

class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<BreakController>();
    final cs = Theme.of(context).colorScheme;
    final remaining = controller.remaining();

    return Scaffold(
      appBar: AppBar(title: const Text('Timer')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              controller.isOnBreak ? 'Break' : 'Focus',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: cs.primary, width: 8),
              ),
              alignment: Alignment.center,
              child: Text(
                _formatDuration(remaining),
                style: Theme.of(context).textTheme.displayLarge?.copyWith(color: cs.primary),
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              children: [
                ElevatedButton(
                  onPressed: controller.isRunning ? controller.pause : controller.start,
                  child: Text(controller.isRunning ? 'Pause' : 'Start'),
                ),
                OutlinedButton(onPressed: controller.stop, child: const Text('Stop')),
              ],
            )
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
