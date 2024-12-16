import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_market_app/data/model/post.dart';
import 'package:flutter_market_app/data/model/post_summary.dart';

import '../model/file_model.dart';

class PostRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 썸네일 생성 헬퍼 메서드
  FileModel _createThumbnail(String imageUrl) {
    return FileModel(
      id: imageUrl,
      url: imageUrl,
      originName: imageUrl.split('/').last,
      contentType: 'image/${imageUrl.split('.').last}',
      createdAt: DateTime.now().toIso8601String(),
    );
  }

  // 게시글 목록 조회
  Future<List<Post>> getPosts({
    String? userId,
    PostStatus? status,
    String? category,
    String? location,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore.collection('posts');

      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }
      if (status != null) {
        query =
            query.where('status', isEqualTo: status.toString().split('.').last);
      }
      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }
      if (location != null) {
        query = query.where('location', isEqualTo: location);
      }

      query = query.orderBy('createdAt', descending: true).limit(limit);

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) {
            final data = doc.data();
            if (data == null) return null;
            return Post.fromJson(
                {...data as Map<String, dynamic>, 'postId': doc.id});
          })
          .where((post) => post != null)
          .cast<Post>()
          .toList();
    } catch (e) {
      print('Error fetching posts: $e');
      return [];
    }
  }

  // 요약 목록 조회
  Future<List<PostSummary>?> getPostSummaryList(String location) async {
    try {
      final querySnapshot = await _firestore
          .collection('posts')
          .where('location', isEqualTo: location)
          .limit(100)
          .get();

      return querySnapshot.docs
          .map((doc) => PostSummary.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching post summaries: $e');
      return null;
    }
  }

  // 상세 조회
  Future<Post?> getPost(String id) async {
    try {
      final querySnapshot = await _firestore
          .collection('posts')
          .where('postId', isEqualTo: id)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return Post.fromJson(querySnapshot.docs.first.data());
      }
    } catch (e) {
      print('Error fetching post detail: $e');
    }
    return null;
  }

  // 게시글 생성
  // post_repository.dart의 create 메서드 수정
  Future<Post?> create({
    required String postId,
    required String userId,
    required String originalTitle,
    required String translatedTitle,
    required List<String> images,
    required String category,
    required Price price,
    required PostStatus status,
    required bool negotiable,
    required String originalDescription,
    required String translatedDescription,
    required String location,
    required String userNickname,
    required String userProfileImageUrl,
    required String userHomeAddress,
  }) async {
    print("===== PostRepository create 시작 =====");
    print("받은 데이터:");
    print("- PostID: $postId");
    print("- UserID: $userId");
    print("- 제목: $originalTitle");
    print("- 이미지 수: ${images.length}");
    print("- 카테고리: $category");
    print("- 가격: ${price.amount} ${price.currency}");

    try {
      print("Firestore 문서 생성 시도");
      final docRef = _firestore.collection('posts').doc();

      print("썸네일 생성 시도");
      final thumbnail = images.isNotEmpty
          ? _createThumbnail(images.first)
          : _createThumbnail('default_image_url');
      print("생성된 썸네일 URL: ${thumbnail.url}");

      final post = Post(
        postId: postId,
        userId: userId,
        originalTitle: originalTitle,
        translatedTitle: translatedTitle,
        price: price,
        category: category,
        status: status,
        negotiable: negotiable,
        originalDescription: originalDescription,
        translatedDescription: translatedDescription,
        images: images,
        thumbnail: thumbnail,
        location: location,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        likes: 0,
        views: 0,
        userNickname: userNickname,
        userProfileImageUrl: userProfileImageUrl,
        userHomeAddress: userHomeAddress,
      );

      print("Firestore에 데이터 저장 시도");
      await docRef.set(post.toJson());
      print("데이터 저장 성공");

      return post;
    } catch (e, stackTrace) {
      print("===== 게시글 생성 중 에러 발생 =====");
      print("에러 타입: ${e.runtimeType}");
      print("에러 내용: $e");
      print("스택트레이스: $stackTrace");
      return null;
    }
  }

  Future<bool> update({
    required String id,
    required String originalTitle,
    required String translatedTitle,
    required List<String> images,
    required String category,
    required Price price,
    required PostStatus status,
    required bool negotiable,
    required String originalDescription,
    required String translatedDescription,
    required String location,
    required String userNickname,
    required String userProfileImageUrl,
    required String userHomeAddress,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('posts')
          .where('postId', isEqualTo: id)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docRef = querySnapshot.docs.first.reference;

        // 썸네일 업데이트
        final thumbnail = images.isNotEmpty
            ? _createThumbnail(images.first)
            : _createThumbnail('default_image_url');

        await docRef.update({
          'originalTitle': originalTitle,
          'translatedTitle': translatedTitle,
          'images': images,
          'thumbnail': thumbnail.toJson(), // 썸네일 업데이트
          'category': category,
          'price': price.toJson(),
          'status': status.toString().split('.').last,
          'negotiable': negotiable,
          'originalDescription': originalDescription,
          'translatedDescription': translatedDescription,
          'location': location,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
          'userNickname': userNickname,
          'userProfileImageUrl': userProfileImageUrl,
          'userHomeAddress': userHomeAddress,
        });
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating post: $e');
      return false;
    }
  }

  // 게시글 삭제
  Future<bool> delete(String postId) async {
    try {
      final querySnapshot = await _firestore
          .collection('posts')
          .where('postId', isEqualTo: postId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting post: $e');
      return false;
    }
  }

  // 조회수 증가
  Future<void> incrementViews(String postId) async {
    try {
      final querySnapshot = await _firestore
          .collection('posts')
          .where('postId', isEqualTo: postId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docRef = querySnapshot.docs.first.reference;
        await docRef.update({'views': FieldValue.increment(1)});
      }
    } catch (e) {
      print('Error incrementing views: $e');
    }
  }

  // 좋아요 토글
  Future<bool> toggleLike(String postId, String userId) async {
    try {
      final postRef = _firestore.collection('posts').doc(postId);
      final userRef = _firestore.collection('users').doc(userId);

      return await _firestore.runTransaction<bool>((transaction) async {
        final postDoc = await transaction.get(postRef);
        final userDoc = await transaction.get(userRef);

        final likes = List<String>.from(userDoc.data()?['wishlist'] ?? []);
        final isLiked = likes.contains(postId);

        if (isLiked) {
          likes.remove(postId);
          transaction.update(postRef, {'likes': FieldValue.increment(-1)});
        } else {
          likes.add(postId);
          transaction.update(postRef, {'likes': FieldValue.increment(1)});
        }

        transaction.update(userRef, {'wishlist': likes});
        return !isLiked;
      });
    } catch (e) {
      print('Error toggling like: $e');
      return false;
    }
  }

  // 단순 좋아요
  Future<bool?> like(String id) async {
    try {
      final querySnapshot = await _firestore
          .collection('posts')
          .where('postId', isEqualTo: id)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docRef = querySnapshot.docs.first.reference;
        await docRef.update({'likes': FieldValue.increment(1)});
        return true;
      }
      return false;
    } catch (e) {
      print('Error liking post: $e');
      return null;
    }
  }

  // 이미지 업로드를 위한 메서드
  Future<String?> insert({
    required String title,
    required String content,
    required String writer,
    required String imageUrl,
  }) async {
    try {
      final docRef = _firestore.collection('posts').doc();

      final thumbnail = _createThumbnail(imageUrl);

      final data = {
        'postId': docRef.id,
        'originalTitle': title,
        'translatedTitle': title,
        'originalDescription': content,
        'translatedDescription': content,
        'userId': writer,
        'images': [imageUrl],
        'thumbnail': thumbnail.toJson(),
        'price': {'amount': 0, 'currency': 'KRW'},
        'category': '',
        'status': PostStatus.selling.toString().split('.').last,
        'negotiable': false,
        'location': '',
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
        'likes': 0,
        'views': 0,
        'userNickname': writer,
        'userProfileImageUrl': imageUrl,
        'userHomeAddress': '',
      };

      await docRef.set(data);
      return docRef.id;
    } catch (e) {
      print('Error inserting post with image: $e');
      return null;
    }
  }

  // 단일 포스트 조회
  Future<Post?> getOne(String id) async {
    try {
      final doc = await _firestore.collection('posts').doc(id).get();
      if (!doc.exists) return null;

      return Post.fromJson({...doc.data()!, 'postId': doc.id});
    } catch (e) {
      print('Error fetching single post: $e');
      return null;
    }
  }

  // 이미지 URL 업데이트
  Future<bool> updateImage({
    required String postId,
    required String imageUrl,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('posts')
          .where('postId', isEqualTo: postId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docRef = querySnapshot.docs.first.reference;
        final thumbnail = _createThumbnail(imageUrl);

        await docRef.update({
          'images': FieldValue.arrayUnion([imageUrl]),
          'thumbnail': thumbnail.toJson(),
          'userProfileImageUrl': imageUrl,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating image: $e');
      return false;
    }
  }

  // 이미지 삭제
  Future<bool> deleteImage({
    required String postId,
    required String imageUrl,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('posts')
          .where('postId', isEqualTo: postId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docRef = querySnapshot.docs.first.reference;

        await docRef.update({
          'images': FieldValue.arrayRemove([imageUrl]),
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });

        // 썸네일이 삭제된 이미지였다면 다른 이미지로 업데이트
        final doc = await docRef.get();
        final images = List<String>.from(doc.data()?['images'] ?? []);
        if (images.isNotEmpty) {
          final thumbnail = _createThumbnail(images.first);
          await docRef.update({'thumbnail': thumbnail.toJson()});
        }

        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }
}
