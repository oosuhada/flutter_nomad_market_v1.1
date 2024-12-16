// firebase_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

// Firebase 서비스들의 기본 설정을 관리하는 추상 클래스
abstract class FirebaseRepository {
  // Firestore 인스턴스
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Firebase Auth 인스턴스
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Firebase Storage 인스턴스
  final FirebaseStorage storage = FirebaseStorage.instance;

  // 현재 로그인한 사용자의 ID getter
  String? get currentUserId => auth.currentUser?.uid;

  // 로그인 상태 확인
  bool get isLoggedIn => auth.currentUser != null;
}
