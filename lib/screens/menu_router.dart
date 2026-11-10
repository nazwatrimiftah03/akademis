import 'package:flutter/material.dart';

import 'admin/data_pengguna_screen.dart';
import 'admin/jadwal_admin_screen.dart';
import 'admin/laporan_screen.dart';
import 'admin/master_data_screen.dart';
import 'admin/pengumuman_admin_screen.dart';
import 'evaluasi/blackbox_screen.dart';
import 'evaluasi/kuesioner_screen.dart';
import 'pengajar/absensi_kelas_screen.dart';
import 'pengajar/input_nilai_screen.dart';
import 'pengajar/jadwal_mengajar_screen.dart';
import 'pengajar/materi_guru_screen.dart';
import 'pengajar/tugas_guru_screen.dart';
import 'pengajar/ujian_guru_screen.dart';
import 'siswa/absensi_screen.dart';
import 'siswa/jadwal_screen.dart';
import 'siswa/materi_screen.dart';
import 'siswa/nilai_screen.dart';
import 'siswa/tugas_screen.dart';
import 'siswa/ujian_screen.dart';

/// Menentukan layar yang dibuka saat sebuah menu diketuk.
/// Mengembalikan null kalau layarnya belum dibuat.
Widget? screenForMenu(String role, String label) {
  if (role == 'Siswa') {
    switch (label) {
      case 'Jadwal':
        return const JadwalSiswaScreen();
      case 'Absensi':
        return const AbsensiSiswaScreen();
      case 'Materi':
        return const MateriSiswaScreen();
      case 'Tugas':
        return const TugasSiswaScreen();
      case 'Ujian':
        return const UjianSiswaScreen();
      case 'Nilai':
        return const NilaiSiswaScreen();
      case 'Evaluasi':
        return const KuesionerScreen(staf: false);
    }
  }

  if (role == 'Pengajar') {
    switch (label) {
      case 'Jadwal Mengajar':
        return const JadwalMengajarScreen();
      case 'Absensi Kelas':
        return const AbsensiKelasScreen();
      case 'Materi':
        return const MateriGuruScreen();
      case 'Tugas':
        return const TugasGuruScreen();
      case 'Ujian':
        return const UjianGuruScreen();
      case 'Input Nilai':
        return const InputNilaiScreen();
      case 'Black Box Testing':
        return const BlackBoxScreen();
      case 'Evaluasi':
        return const KuesionerScreen(staf: true);
    }
  }

  if (role == 'Admin') {
    switch (label) {
      case 'Data Siswa':
        return const DataPenggunaScreen(pengajar: false);
      case 'Data Pengajar':
        return const DataPenggunaScreen(pengajar: true);
      case 'Kelas':
        return const MasterDataScreen(
          judul: 'Kelas',
          ikon: Icons.class_rounded,
          label: 'kelas',
          hint: 'Contoh: XII IPA 1',
          awal: ['X IPA 1', 'X IPA 2', 'XI IPS 1', 'XI IPS 2', 'XII IPA 1'],
        );
      case 'Mata Pelajaran':
        return const MasterDataScreen(
          judul: 'Mata Pelajaran',
          ikon: Icons.library_books_rounded,
          label: 'mata pelajaran',
          hint: 'Contoh: Ekonomi',
          awal: [
            'Matematika',
            'Bahasa Indonesia',
            'Bahasa Inggris',
            'Fisika',
            'Kimia',
            'Biologi',
            'Sejarah',
            'Informatika',
          ],
        );
      case 'Jadwal':
        return const JadwalAdminScreen();
      case 'Pengumuman':
        return const PengumumanAdminScreen();
      case 'Black Box Testing':
        return const BlackBoxScreen();
      case 'Laporan & Evaluasi':
        return const LaporanScreen();
    }
  }

  return null;
}
