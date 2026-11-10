class KasusUji {
  const KasusUji({
    required this.id,
    required this.kode,
    required this.fitur,
    required this.skenario,
    required this.langkah,
    required this.hasilDiharapkan,
    required this.karakteristik,
  });

  final int id;
  final String kode;
  final String fitur;
  final String skenario;
  final String langkah;
  final String hasilDiharapkan;
  final String karakteristik;

  factory KasusUji.fromMap(Map<String, dynamic> m) => KasusUji(
        id: m['id'] as int,
        kode: m['kode'] as String,
        fitur: m['fitur'] as String,
        skenario: m['skenario'] as String,
        langkah: m['langkah'] as String,
        hasilDiharapkan: m['hasil_diharapkan'] as String,
        karakteristik: m['karakteristik'] as String,
      );
}

class HasilUji {
  const HasilUji({
    required this.kasusId,
    required this.status,
    required this.catatan,
  });

  final int kasusId;
  final String status; // berhasil / gagal
  final String catatan;

  factory HasilUji.fromMap(Map<String, dynamic> m) => HasilUji(
        kasusId: m['kasus_id'] as int,
        status: m['status'] as String,
        catatan: (m['catatan'] as String?) ?? '',
      );
}
