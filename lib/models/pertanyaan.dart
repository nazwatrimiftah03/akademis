class Pertanyaan {
  const Pertanyaan({
    required this.id,
    required this.karakteristik,
    required this.teks,
    required this.untuk,
  });

  final int id;
  final String karakteristik;
  final String teks;
  final String untuk; // semua / staf

  factory Pertanyaan.fromMap(Map<String, dynamic> m) => Pertanyaan(
        id: m['id'] as int,
        karakteristik: m['karakteristik'] as String,
        teks: m['pertanyaan'] as String,
        untuk: m['untuk'] as String,
      );
}
