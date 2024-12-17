// 게시글 유형 구분 (판매/구매)
enum PostType {
  selling, // 팝니다
  buying,
  unknown // 삽니다
}

// 게시글 거래 상태
enum PostStatus {
  active, // 거래중 (판매중/구매중)
  completed, // 거래완료
  reserved,
  unknown // 예약중
}
