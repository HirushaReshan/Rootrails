import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryService {
  // Use your Cloudinary account info
  final cloudinary = CloudinaryPublic(
    'duvfuekhq',            //  Cloud name
    'rootrails_unsigned',    //  unsigned preset
    cache: false,
  );

  Future<String> uploadImage(File file, String folder) async {
    try {
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(file.path, folder: folder),
      );
      return response.secureUrl; // URL to store in Firestore
    } catch (e) {
      print('Upload error: $e');
      return ''; // return empty string if failed
    }
  }
}
