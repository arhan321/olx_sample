import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'dart:io';
import 'package:http_parser/http_parser.dart';

class AddCarPage extends StatefulWidget {
  const AddCarPage({super.key});

  @override
  _AddCarPageState createState() => _AddCarPageState();
}

class _AddCarPageState extends State<AddCarPage> {
  final _namaController = TextEditingController();
  final _merkController = TextEditingController();
  final _modelController = TextEditingController();
  final _transmisiController = TextEditingController();
  final _bahanBakarController = TextEditingController();
  final _ccController = TextEditingController();
  final _warnaController = TextEditingController();
  final _tahunController = TextEditingController();
  final _hargaController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      print("Image picked: ${pickedFile.path}");
    }
  }

  Future<void> _submitCarData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.triastrapersada.com/api/v1/mobil'),
    );

    // Validate and collect the form fields
    request.fields['nama'] = _namaController.text.trim();
    request.fields['merk'] = _merkController.text.trim();
    request.fields['model'] = _modelController.text.trim();
    request.fields['transmisi'] = _transmisiController.text.trim();
    request.fields['bahan_bakar'] = _bahanBakarController.text.trim();
    request.fields['cc'] = _ccController.text.trim();
    request.fields['warna'] = _warnaController.text.trim();
    request.fields['tahun'] = _tahunController.text.trim();
    request.fields['harga'] = _hargaController.text.trim();

    // Handle image upload if present
    if (_imageFile != null) {
      String? mimeType = lookupMimeType(_imageFile!.path);
      if (mimeType != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _imageFile!.path,
          contentType: MediaType.parse(mimeType),
        ));
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Mime type tidak dikenali';
        });
        return;
      }
    }

    try {
      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        setState(() {
          _isLoading = false;
        });

        // Menampilkan notifikasi sukses
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mobil berhasil ditambahkan!')),
        );

        // Setelah berhasil menambah data, kembali ke halaman utama dan lakukan refresh
        Navigator.pushReplacementNamed(
            context, '/home'); // Gunakan navigator untuk menggantikan halaman
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Gagal meng-upload data mobil';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Terjadi kesalahan jaringan: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Mobil')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _namaController,
              decoration: const InputDecoration(
                labelText: 'Nama Mobil',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _merkController,
              decoration: const InputDecoration(
                labelText: 'Merk Mobil',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _modelController,
              decoration: const InputDecoration(
                labelText: 'Model Mobil',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _transmisiController,
              decoration: const InputDecoration(
                labelText: 'Transmisi',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _bahanBakarController,
              decoration: const InputDecoration(
                labelText: 'Bahan Bakar',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _ccController,
              decoration: const InputDecoration(
                labelText: 'CC Mobil',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _warnaController,
              decoration: const InputDecoration(
                labelText: 'Warna Mobil',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _tahunController,
              decoration: const InputDecoration(
                labelText: 'Tahun Mobil',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _hargaController,
              decoration: const InputDecoration(
                labelText: 'Harga Mobil',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Pilih Gambar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (_imageFile != null) ...[
              const SizedBox(height: 10),
              Image.file(_imageFile!, width: 100, height: 100),
            ],
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton(
                onPressed: _submitCarData,
                child: const Text(
                  'Tambah Mobil',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                  textStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  elevation: 10,
                  shadowColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }
}