// // users 컬렉션
// interface User {
//   userId: string;          // 문서 ID
//   email: string;          // 이메일 주소
//   password: string | null; // 이메일 로그인시에만 사용, Google 로그인은 null
//   nickname: string;       // 사용자 이름/닉네임
//   profileImageUrl: string; // 프로필 이미지 URL
//   preferences: {
//     language: string;     // 'ko' 형식으로 통일
//     currency: string;     // 'KRW' 형식으로 통일
//     homeAddress: string;  // 주소
//   };
//   signInMethod: 'email' | 'google';  // 로그인 방식 구분
//   createdAt: Timestamp;   // 생성 시간
//   lastLoginAt: Timestamp; // 마지막 로그인 시간
//   status: 'active' | 'inactive' | 'blocked'; // 계정 상태
// }

// // products 컬렉션
// interface Product {
//   postId: string;         // Firestore 자동 생성 ID
//   userId: string;         // 판매자 ID
//   originaltitle: string;  // 상품명
//   translatedtitle: string;  
//   price: {
//     amount: number;      // 가격
//     currency: string;    // 통화 단위
//   };
//   category: string;      // 상품 카테고리
//   status: 'selling' | 'sold' | 'reserved'; // 상품 상태
//   negotiable: boolean;   // 가격제안 가능 여부
//   originaldescription: string;   // 상품 설명
//   translateddescription: string; 
//   images: string[];      // 이미지 URL 배열
//   location: string;      // 거래 위치
//   createdAt: Timestamp; // 등록일시
//   updatedAt: Timestamp; // 수정일시
//   likes: number;        // 좋아요 수
//   views: number;        // 조회수
// }


// // chattings 컬렉션
// interface Chatting {
//   chatId: string;       // Firestore 자동 생성 ID
//   postId: string;       // 관련 상품 ID
//   sellerId: string;     // 판매자 ID
//   buyerId: string;      // 구매자 ID
//   lastMessage: {
//     content: string;    // 마지막 메시지 내용
//     timestamp: Timestamp; // 전송 시간
//     senderId: string;   // 발신자 ID
//   };
//   messages: {
//     messageId: string;  // 메시지 ID
//     senderId: string;   // 발신자 ID
//     originalcontent: string;    // 메시지 내용
//     translatedcontent: string; 
//     timestamp: Timestamp; // 전송 시간
//     isRead: boolean;    // 읽음 여부
//   }[];
//   status: 'active' | 'completed' | 'cancelled'; // 채팅방 상태
// }