import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'data/models.dart';
import 'providers/app_provider.dart';

class DayflowApp extends ConsumerWidget {
  const DayflowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTheme = ref.watch(themeModeProvider);

    final themeMode = switch (selectedTheme) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    return MaterialApp(
      title: 'Dayflow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    const pages = [
      HomeTab(),
      CalendarTab(),
      TasksTab(),
      HabitsTab(),
      SettingsTab(),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: index, children: pages),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Create new item',
        onPressed: () => _createItem(context),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            selectedIcon: Icon(Icons.check_circle),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.spa_outlined),
            selectedIcon: Icon(Icons.spa),
            label: 'Habits',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Future<void> _createItem(BuildContext context) async {
    final type = await showModalBottomSheet<ItemType>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final item in [
              (ItemType.event, 'New event', Icons.event),
              (ItemType.reminder, 'New reminder', Icons.notifications),
              (ItemType.task, 'New task', Icons.check_circle),
              (ItemType.note, 'Quick note', Icons.note),
              (ItemType.habit, 'New habit', Icons.spa),
            ])
              ListTile(
                leading: Icon(item.$3),
                title: Text(item.$2),
                onTap: () => Navigator.pop(context, item.$1),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );

    if (!mounted || type == null) return;

    final titleController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    try {
      final title = await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text('Create ${type.name}'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: titleController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter a title';
                }
                return null;
              },
              onFieldSubmitted: (_) {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(
                    dialogContext,
                    titleController.text.trim(),
                  );
                }
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(
                    dialogContext,
                    titleController.text.trim(),
                  );
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      );

      if (!mounted || title == null) return;

      await ref.read(organizerProvider.notifier).add(
            type: type,
            title: title,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${type.name} created')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save item: $error')),
        );
      }
    } finally {
      titleController.dispose();
    }
  }
}

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(organizerProvider);
    final tasks = state.items
        .where((item) => item.type == ItemType.task)
        .toList();
    final completed = tasks.where((item) => item.completed).length;
    final now = DateTime.now();

    return _Page(
      title: _greeting(now),
      subtitle: 'Make today count, one step at a time.',
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.auto_awesome, size: 32),
                const SizedBox(height: 16),
                Text(
                  '${now.day}/${now.month}/${now.year}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '$completed of ${tasks.length} tasks completed',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: tasks.isEmpty ? 0 : completed / tasks.length,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(8),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Your latest items',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        if (state.loading)
          const Center(child: CircularProgressIndicator())
        else if (state.items.isEmpty)
          const _EmptyState(
            icon: Icons.event_available,
            title: 'A fresh start',
            subtitle: 'Tap + to create your first item.',
          )
        else
          ...state.items.take(10).map((item) => _ItemCard(item: item)),
        if (state.error != null)
          Text(
            state.error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
      ],
    );
  }

  String _greeting(DateTime date) {
    if (date.hour < 12) return 'Good morning!';
    if (date.hour < 17) return 'Good afternoon!';
    return 'Good evening!';
  }
}

class CalendarTab extends ConsumerStatefulWidget {
  const CalendarTab({super.key});

  @override
  ConsumerState<CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends ConsumerState<CalendarTab> {
  DateTime selected = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(organizerProvider).items.where((item) {
      final date = item.dueAt;
      return date != null &&
          date.year == selected.year &&
          date.month == selected.month &&
          date.day == selected.day;
    }).toList();

    return _Page(
      title: 'Calendar',
      subtitle: 'Choose a date to see your plans.',
      children: [
        Card(
          child: CalendarDatePicker(
            initialDate: selected,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            onDateChanged: (date) => setState(() => selected = date),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '${selected.day}/${selected.month}/${selected.year}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        if (items.isEmpty)
          const _EmptyState(
            icon: Icons.event_note,
            title: 'Nothing scheduled',
            subtitle: 'Create an item using the + button.',
          )
        else
          ...items.map((item) => _ItemCard(item: item)),
      ],
    );
  }
}

class TasksTab extends ConsumerWidget {
  const TasksTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(organizerProvider).items
        .where((item) => item.type == ItemType.task)
        .toList();

    return _Page(
      title: 'Tasks',
      subtitle: '${tasks.where((item) => !item.completed).length} remaining',
      children: tasks.isEmpty
          ? const [
              _EmptyState(
                icon: Icons.check_circle_outline,
                title: 'Nothing on your list',
                subtitle: 'Create a task with the + button.',
              ),
            ]
          : tasks.map((item) => _ItemCard(item: item)).toList(),
    );
  }
}

class HabitsTab extends ConsumerWidget {
  const HabitsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(organizerProvider).items
        .where((item) => item.type == ItemType.habit)
        .toList();

    return _Page(
      title: 'Habits',
      subtitle: 'Build consistency, one day at a time.',
      children: habits.isEmpty
          ? const [
              _EmptyState(
                icon: Icons.spa_outlined,
                title: 'Start a new habit',
                subtitle: 'Create your first habit with +.',
              ),
            ]
          : habits.map((item) => _ItemCard(item: item)).toList(),
    );
  }
}

class SettingsTab extends ConsumerWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTheme = ref.watch(themeModeProvider);

    return _Page(
      title: 'Settings',
      subtitle: 'Personalize your experience.',
      children: [
        Card(
          child: Column(
            children: [
              const ListTile(
                leading: Icon(Icons.palette_outlined),
                title: Text('Appearance'),
                subtitle: Text('Choose your preferred theme'),
              ),
              for (final mode in ['system', 'light', 'dark'])
                RadioListTile<String>(
                  value: mode,
                  groupValue: selectedTheme,
                  title: Text(
                    '${mode[0].toUpperCase()}${mode.substring(1)} mode',
                  ),
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(themeModeProvider.notifier).state = value;
                    }
                  },
                ),
            ],
          ),
        ),
        const Card(
          child: ListTile(
            leading: Icon(Icons.storage_outlined),
            title: Text('Local storage'),
            subtitle: Text('Organizer data is saved on this device.'),
          ),
        ),
        const Card(
          child: ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Dayflow'),
            subtitle: Text('Your personal organizer'),
          ),
        ),
      ],
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 6),
          Text(subtitle),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 16),
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(icon, size: 36),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(subtitle, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _ItemCard extends ConsumerWidget {
  const _ItemCard({required this.item});

  final OrganizerItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        leading: Checkbox(
          value: item.completed,
          onChanged: (_) async {
            try {
              await ref.read(organizerProvider.notifier).toggle(item.id);
            } catch (_) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Could not save change.')),
                );
              }
            }
          },
        ),
        title: Text(
          item.title,
          style: TextStyle(
            decoration: item.completed ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(
          item.dueAt == null
              ? item.type.name
              : '${item.type.name} • ${item.dueAt!.day}/${item.dueAt!.month}/${item.dueAt!.year}',
        ),
        trailing: IconButton(
          tooltip: 'Delete',
          icon: const Icon(Icons.delete_outline),
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Delete item?'),
                content: Text('Delete "${item.title}"?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            );

            if (confirm == true && context.mounted) {
              try {
                await ref.read(organizerProvider.notifier).delete(item.id);
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not delete item.')),
                  );
                }
              }
            }
          },
        ),
      ),
    );
  }
}
