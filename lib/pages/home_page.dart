import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data_barang_page.dart';
import 'peminjaman_form.dart';
import 'package:sisfo_sarpras/pages/pengembalian_page.dart';
import 'riwayat_page.dart';
import 'profil_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  String? _token;
  String? _email;
  int? _userId;
  // Remove _idPeminjaman if not needed, or keep it for other purposes

  List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token');
      _email = prefs.getString('user_name');
      _userId = prefs.getInt('user_id');

      if (_token != null && _email != null && _userId != null) {
        _pages = [
          DataBarangPage(token: _token!),
          PeminjamanFormPage(token: _token!, userId: _userId!),
          PengembalianFormPage(
              token: _token!,
              userId: _userId!), // Add required userId parameter
          RiwayatPage(token: _token!, userId: _userId!),
          ProfilPage(email: _email!),
        ];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_token == null || _email == null || _userId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Add this for 5+ items
        currentIndex: _currentIndex,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Data Barang',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Peminjaman',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_return),
            label: 'Pengembalian',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
