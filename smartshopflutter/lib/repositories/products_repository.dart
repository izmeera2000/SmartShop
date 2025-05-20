import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:smartshopflutter/models/Product.dart';

class ProductsRepository {
  // In-memory caches
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

  /// Fetch **popular** products (excluding current user's).
  static Future<List<Product>> fetchPopularProducts() async {
    if (_popularProducts != null) return _popularProducts!;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('products')
        .where('popular', isEqualTo: true);

    final snap = await query.get();

    if (uid != null) {
      final filteredDocs = snap.docs.where((doc) => doc['userId'] != uid).toList();
      _popularProducts = await _resolveDocs(filteredDocs);
    } else {
      _popularProducts = await _resolveDocs(snap.docs);
    }

    return _popularProducts!;
  }

  /// Fetch **only the current user's** products.
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

  /// Real-time stream of current user's products.
  static Stream<List<Product>> userProductsStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('products')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .asyncMap((snapshot) async {
          // For each doc, resolve images URLs async
          final List<Product> products = [];
          for (final doc in snapshot.docs) {
            final data = doc.data();
            final rawPaths = List<String>.from(data['images'] ?? []);
            final downloadUrls = await Future.wait(
              rawPaths.map((p) => FirebaseStorage.instance.ref(p).getDownloadURL()),
            );
            data['images'] = downloadUrls;
            products.add(Product.fromFirestore(data, doc.id));
          }
          return products;
        });
  }

  /// Clears *all* in-memory caches.
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
