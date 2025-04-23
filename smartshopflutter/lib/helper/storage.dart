import 'package:firebase_storage/firebase_storage.dart';

Future<String> getDownloadUrl(String path) async {
  return await FirebaseStorage.instance.ref(path).getDownloadURL();
}
