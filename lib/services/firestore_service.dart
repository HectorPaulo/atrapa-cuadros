import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> guardarUsuario(Usuario usuario) async {
    await _db.collection('usuarios').doc(usuario.uid).set(usuario.toMap());
  }

  Future<Usuario?> obtenerUsuario(String uid) async {
    final doc = await _db.collection('usuarios').doc(uid).get();
    if (doc.exists) {
      return Usuario.fromMap(doc.data()!, uid);
    }
    return null;
  }

  Future<void> actualizarUsuario(String uid, Map<String, dynamic> datos) async {
    await _db.collection('usuarios').doc(uid).update(datos);
  }
}
