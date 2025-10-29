import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  final AuthService _auth = AuthService();
  bool _biometric = false;
  bool _analytics = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _biometric = prefs.getBool('pref_biometric') ?? false;
      _analytics = prefs.getBool('pref_analytics') ?? true;
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pref_biometric', _biometric);
    await prefs.setBool('pref_analytics', _analytics);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privasi & Keamanan'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Gunakan biometrik untuk login'),
            subtitle: const Text('Fingerprint/Face ID (simulasi)'),
            value: _biometric,
            onChanged: (v) { setState(() => _biometric = v); _save(); },
          ),
          SwitchListTile(
            title: const Text('Izinkan data anonim untuk analitik'),
            value: _analytics,
            onChanged: (v) { setState(() => _analytics = v); _save(); },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.password),
            title: const Text('Ganti Password'),
            subtitle: const Text('Ubah password akun demo Anda'),
            onTap: _showChangePasswordDialog,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Kebijakan Privasi'),
            onTap: () => _showTextDialog(
              'Kebijakan Privasi',
              'Data Anda disimpan lokal di perangkat ini untuk keperluan demo.',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.rule_folder_outlined),
            title: const Text('Syarat & Ketentuan'),
            onTap: () => _showTextDialog(
              'Syarat & Ketentuan',
              'Aplikasi ini bersifat demo dan tidak menggantikan saran medis profesional.',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showChangePasswordDialog() async {
    final oldCtl = TextEditingController();
    final newCtl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ganti Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldCtl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password Lama'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newCtl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password Baru'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Simpan')),
        ],
      ),
    );

    if (ok == true) {
      final result = await _auth.changePassword(oldCtl.text, newCtl.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result ? 'Password berhasil diubah' : 'Gagal mengubah password'),
            backgroundColor: result ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  void _showTextDialog(String title, String text) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(text),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
        ],
      ),
    );
  }
}


