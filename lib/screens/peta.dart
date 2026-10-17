import 'package:flutter/material.dart';

class Peta extends StatelessWidget {
  const Peta({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peta Restoran'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchBar(
              hintText: 'Cari makanan di sekitarmu...',
              leading: const Icon(Icons.search),
              trailing: [
                IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('Area Google Maps API', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
                    Text('(Integrasi menyusul)', style: TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
            ),
          ),
          const ListTile(
            leading: CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.location_on, color: Colors.white)),
            title: Text('Ditemukan 5 tempat di radius 2 km'),
            subtitle: Text('Tarik ke atas untuk melihat daftar'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}