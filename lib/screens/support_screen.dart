import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bantuan & Dukungan'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCard(
            title: 'FAQ',
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• Bagaimana cara mencatat langkah?\nAplikasi membaca data langkah dari sensor perangkat (demo).'),
                SizedBox(height: 8),
                Text('• Bagaimana cara mengatur notifikasi?\nBuka menu Pengaturan Notifikasi dari tab Profil.'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildCard(
            title: 'Kontak Kami',
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Email: support@sehatpantau.app (demo)'),
                SizedBox(height: 8),
                Text('Jam Operasional: 09.00 - 17.00 WIB'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Terima kasih atas penilaiannya!')),
              );
            },
            icon: const Icon(Icons.star_rate_rounded),
            label: const Text('Beri Rating Aplikasi'),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}


