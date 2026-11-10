import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/pengumuman_store.dart';

const _merahPenting = Color(0xFFE11D48);

/// Membuka isi lengkap pengumuman di bottom sheet.
void tampilkanPengumuman(BuildContext context, Pengumuman p) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (p.penting) ...[
                  const LabelPengumuman('Penting', _merahPenting),
                  const SizedBox(width: 8),
                ],
                LabelPengumuman('Untuk ${p.untuk}', AppColors.teal),
                const Spacer(),
                Text(
                  waktuRelatif(p.waktu),
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              p.judul,
              style: Theme.of(ctx).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text(p.isi, style: const TextStyle(height: 1.6)),
          ],
        ),
      ),
    ),
  );
}

class LabelPengumuman extends StatelessWidget {
  const LabelPengumuman(this.teks, this.warna, {super.key});

  final String teks;
  final Color warna;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: warna.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        teks,
        style: TextStyle(
          color: warna,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Bagian "Pengumuman" di beranda. Otomatis tersembunyi kalau kosong.
class PengumumanSection extends StatelessWidget {
  const PengumumanSection({super.key, required this.peran});

  final String peran;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = dark ? const Color(0xFF16231F) : Colors.white;

    return ValueListenableBuilder<List<Pengumuman>>(
      valueListenable: PengumumanStore.daftar,
      builder: (context, _, __) {
        final items = PengumumanStore.untukPeran(peran);
        if (items.isEmpty) return const SizedBox.shrink();

        final tampil = items.take(3).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              'Pengumuman',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            for (final p in tampil)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(18),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => tampilkanPengumuman(context, p),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color:
                              (p.penting ? _merahPenting : AppColors.teal)
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              p.penting
                                  ? Icons.priority_high_rounded
                                  : Icons.campaign_rounded,
                              color: p.penting ? _merahPenting : AppColors.teal,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.judul,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  waktuRelatif(p.waktu),
                                  style: const TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}