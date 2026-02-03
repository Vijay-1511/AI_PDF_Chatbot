// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:http/http.dart' as http;
// import 'chat_screen.dart';

// class UploadScreen extends StatelessWidget {
//   const UploadScreen({super.key});

//   Future<void> uploadPDF(BuildContext context) async {
//     FilePickerResult? result =
//         await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);

//     if (result == null) return;
     
    
//     File file = File(result.files.single.path!);

//     var request = http.MultipartRequest(
//       'POST',
//       Uri.parse('http://localhost:8000/upload'),
//     );

//     request.files.add(await http.MultipartFile.fromPath('file', file.path));
//     await request.send();

//     Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Upload PDF")),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () => uploadPDF(context),
//           child: const Text("Upload PDF"),
//         ),
//       ),
//     );
//   }
// }

import 'dart:io' show File; // Only works on mobile/desktop
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb; // To detect web
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'chat_screen.dart';

class UploadScreen extends StatelessWidget {
  const UploadScreen({super.key});

  Future<void> uploadPDF(BuildContext context) async {
    // Pick the file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: kIsWeb, // For web, load file bytes
    );

    if (result == null) return;

    http.MultipartRequest request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:8000/upload'), // Use localhost for web
    );

    if (kIsWeb) {
      // Web: use bytes
      Uint8List fileBytes = result.files.single.bytes!;
      String fileName = result.files.single.name;

      request.files.add(
        http.MultipartFile.fromBytes('file', fileBytes, filename: fileName),
      );
    } else {
      // Mobile/Desktop: use File
      File file = File(result.files.single.path!);
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
    }

    // Send request
    var response = await request.send();

    if (response.statusCode == 200) {
      // Navigate to chat screen if upload is successful
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ChatScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed with status ${response.statusCode}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload PDF")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => uploadPDF(context),
          child: const Text("Upload PDF"),
        ),
      ),
    );
  }
}
