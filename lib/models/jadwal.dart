class Jadwal {
  const Jadwal({
    this.id,
    required this.hari,
    required this.jam,
    required this.mapel,
    required this.kelas,
    required this.guru,
    required this.ruang,
  });

  final int? id;
  final String hari;
  final String jam; // format "07.00"
  final String mapel;
  final String kelas;
  final String guru;
  final String ruang;

  factory Jadwal.fromMap(Map<String, dynamic> m) => Jadwal(
    id: (m['id'] as num?)?.toInt(),
    hari: (m['hari'] as String?) ?? '',
    jam: (m['jam'] as String?) ?? '',
    mapel: (m['mapel'] as String?) ?? '',
    kelas: (m['kelas'] as String?) ?? '',
    guru: (m['guru'] as String?) ?? '',
    ruang: (m['ruang'] as String?) ?? '',
  );

  /// Tanpa id, supaya aman dipakai untuk insert maupun update.
  Map<String, dynamic> toMap() => {
    'hari': hari,
    'jam': jam,
    'mapel': mapel,
    'kelas': kelas,
    'guru': guru,
    'ruang': ruang,
  };
}