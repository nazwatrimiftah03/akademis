class AppProfile {
  const AppProfile({
    required this.id,
    required this.fullName,
    required this.role,
    required this.aktif,
  });

  final String id;
  final String fullName;
  final String role; // siswa / pengajar / admin
  final bool aktif;

  factory AppProfile.fromMap(Map<String, dynamic> m) => AppProfile(
    id: m['id'] as String,
    fullName: (m['full_name'] as String?) ?? '',
    role: (m['role'] as String?) ?? 'siswa',
    aktif: (m['aktif'] as bool?) ?? true,
  );

  String get roleLabel => switch (role) {
    'pengajar' => 'Pengajar',
    'admin' => 'Admin',
    _ => 'Siswa',
  };
}