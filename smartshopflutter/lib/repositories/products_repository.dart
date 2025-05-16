// lib/repositories/products_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:smartshopflutter/models/Product.dart';

class ProductsRepository {
  // In–memory caches
  static List<Product>? _allProducts;
  static List<Product>? _popularProducts;
  static List<Product>? _userProducts;

  /// Fetch **all** products not by the current user.
  static Future<List<Product>> fetchAllProducts() async {
    if (_allProducts != null) return _allProducts!;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    final snap = await FirebaseFirestore.instance
        .collection('products')
        .where('userId', isNotEqualTo: uid)
        .get();

    _allProducts = await _resolveDocs(snap.docs);
    return _allProducts!;
  }

  /// Fetch only the **popular** products, excluding current user.
  static Future<List<Product>> fetchPopularProducts() async {
    if (_popularProducts != null) return _popularProducts!;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('products')
        .where('isPopular', isEqualTo: true);

    // Optionally do client‐side filter if you don’t want to index userId !=
    if (uid != null) query = query.where('userId', isNotEqualTo: uid);

    final snap = await query.get();
    _popularProducts = await _resolveDocs(snap.docs);

    // If you couldn’t apply the isNotEqualTo filter server-side, do:
    // if (uid != null) {
    //   _popularProducts =
    //     _popularProducts!.where((p) => p.userId != uid).toList();
    // }

    return _popularProducts!;
  }

  /// Fetch only the **current user’s** products.
  static Future<List<Product>> fetchUserProducts() async {
    if (_userProducts != null) return _userProducts!;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    final snap = await FirebaseFirestore.instance
        .collection('products')
        .where('userId', isEqualTo: uid)
        .get();

    _userProducts = await _resolveDocs(snap.docs);
    return _userProducts!;
  }

  /// Clears *all* in‐memory caches.
  static void clearCache() {
    _allProducts = null;
    _popularProducts = null;
    _userProducts = null;
  }

  /// Shared helper: given a list of QueryDocumentSnapshots,
  /// fetch each storage path’s download-URL and return List<Product>.
  static Future<List<Product>> _resolveDocs(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) async {
    final List<Product> list = [];
    for (var doc in docs) {
      final data = doc.data();
      final rawPaths = List<String>.from(data['images'] ?? []);
      final downloadUrls = await Future.wait(
        rawPaths.map((p) => FirebaseStorage.instance.ref(p).getDownloadURL()),
      );
      data['images'] = downloadUrls;
      list.add(Product.fromFirestore(data, doc.id));
    }
    return list;
  }
}
