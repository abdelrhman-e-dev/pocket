import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/user_profile_provider.dart';

class EnterNamePage extends ConsumerStatefulWidget {
  const EnterNamePage({super.key});

  @override
  ConsumerState<EnterNamePage> createState() => _EnterNamePageState();
}

class _EnterNamePageState extends ConsumerState<EnterNamePage> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref.read(userProfileRepositoryProvider).saveName(_controller.text);
      if (mounted) context.go('/dashboard');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 48),
              Text(
                'ما الذي يمكنني مناداتك به؟',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'سنستخدم اسمك لتخصيص تجربتك في Pocket.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: _controller,
                autofocus: true,
                textDirection: TextDirection.rtl,
                decoration: const InputDecoration(labelText: 'اسمك'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'من فضلك أدخل اسمك'
                    : null,
                onFieldSubmitted: (_) => _save(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const CircularProgressIndicator()
                      : const Text('ابدأ استخدام Pocket'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
