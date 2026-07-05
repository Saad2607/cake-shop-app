import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../services/server_settings_service.dart';
import '../../theme/app_theme.dart';

class ServerSettingsScreen extends StatefulWidget {
  const ServerSettingsScreen({super.key});

  @override
  State<ServerSettingsScreen> createState() => _ServerSettingsScreenState();
}

class _ServerSettingsScreenState extends State<ServerSettingsScreen> {
  late final TextEditingController _hostController;
  bool _testing = false;
  String? _testResult;

  @override
  void initState() {
    super.initState();
    final settings = context.read<ServerSettingsService>();
    _hostController = TextEditingController(text: settings.wifiHost);
  }

  @override
  void dispose() {
    _hostController.dispose();
    super.dispose();
  }

  Future<void> _saveWifi() async {
    final settings = context.read<ServerSettingsService>();
    await settings.saveWifi(_hostController.text.trim());
    if (!mounted) return;
    setState(() => _testResult = null);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Server saved'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _test() async {
    setState(() {
      _testing = true;
      _testResult = null;
    });

    final api = context.read<ApiService>();
    final settings = context.read<ServerSettingsService>();
    if (settings.mode == ServerConnectionMode.wifi) {
      await settings.saveWifi(_hostController.text.trim());
    }

    final ok = await api.testConnection();
    if (!mounted) return;
    setState(() {
      _testing = false;
      _testResult = ok ? 'Connected successfully' : 'Could not reach server';
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<ServerSettingsService>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Server connection'),
        backgroundColor: AppTheme.background,
        elevation: 0,
        foregroundColor: AppTheme.textDark,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [AppTheme.cardShadow],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current URL',
                  style: AppTheme.labelBold.copyWith(color: AppTheme.textMuted),
                ),
                const SizedBox(height: 6),
                SelectableText(
                  settings.baseUrl,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Connection type', style: AppTheme.labelBold),
          const SizedBox(height: 10),
          _modeTile(
            settings,
            ServerConnectionMode.wifi,
            Icons.wifi_rounded,
            'Wi‑Fi (real phone)',
            'Enter your laptop IP — change when you switch networks',
          ),
          _modeTile(
            settings,
            ServerConnectionMode.usb,
            Icons.usb_rounded,
            'USB cable',
            'Run: adb reverse tcp:3000 tcp:3000 — no IP changes',
          ),
          _modeTile(
            settings,
            ServerConnectionMode.emulator,
            Icons.phone_android_rounded,
            'Android emulator',
            'Uses 10.0.2.2 automatically',
          ),
          if (settings.mode == ServerConnectionMode.wifi) ...[
            const SizedBox(height: 20),
            Text('Your PC IP address', style: AppTheme.labelBold),
            const SizedBox(height: 8),
            TextField(
              controller: _hostController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'e.g. 192.168.1.8',
                prefixIcon: const Icon(Icons.computer_rounded),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'On Windows run ipconfig → Wi‑Fi → IPv4. Phone and PC must be on the same Wi‑Fi.',
              style: AppTheme.bodySmall.copyWith(color: AppTheme.textMuted),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveWifi,
                child: const Text('Save IP'),
              ),
            ),
          ],
          if (settings.mode == ServerConnectionMode.usb) ...[
            const SizedBox(height: 20),
            _hintCard(
              'Connect phone by USB, enable USB debugging, then run in terminal:\n\n'
              'adb reverse tcp:3000 tcp:3000\n\n'
              'Works on any Wi‑Fi — no IP to change.',
            ),
          ],
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _testing ? null : _test,
            icon: _testing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.network_check_rounded),
            label: Text(_testing ? 'Testing…' : 'Test connection'),
          ),
          if (_testResult != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  _testResult == 'Connected successfully'
                      ? Icons.check_circle_rounded
                      : Icons.error_outline_rounded,
                  color: _testResult == 'Connected successfully'
                      ? Colors.green
                      : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(_testResult!)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _modeTile(
    ServerSettingsService settings,
    ServerConnectionMode mode,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final selected = settings.mode == mode;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: selected ? AppTheme.primary.withValues(alpha: 0.08) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => settings.setMode(mode),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(icon, color: selected ? AppTheme.primary : AppTheme.textMuted),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: selected ? AppTheme.primary : AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTheme.bodySmall.copyWith(color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  const Icon(Icons.check_circle_rounded, color: AppTheme.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _hintCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.goldLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3)),
      ),
      child: Text(text, style: AppTheme.bodySmall.copyWith(height: 1.5)),
    );
  }
}
