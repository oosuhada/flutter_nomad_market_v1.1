import 'package:flutter/material.dart';

class TermsAndPoliciesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('노마드 마켓 약관 및 정책'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          buildSection('이용 약관', [
            '제1조 (목적): 본 서비스는 전 세계 여행자와 구매자를 연결하는 글로벌 P2P 커머스 플랫폼으로, 안전하고 신뢰할 수 있는 거래 환경을 제공합니다.',
            '제2조 (서비스 이용 계약): 회원가입 시 본 약관에 동의한 것으로 간주되며, 플랫폼의 서비스를 이용할 수 있습니다.',
            '제3조 (회원 의무): 회원은 정확한 정보 제공, 타인의 권리 존중, 서비스 오남용 금지의 의무가 있습니다.',
            '제4조 (서비스 이용 제한): 부적절한 행위, 사기, 사기성 거래 등에 대해 서비스 이용을 제한할 수 있습니다.',
            '제5조 (책임 제한): 플랫폼은 회원 간 거래의 중개자로서, 상품의 실제 거래 및 품질에 대한 직접적인 책임을 지지 않습니다.',
          ]),
          buildSection('개인정보 처리방침', [
            '제1조 (개인정보 수집): 서비스 이용을 위해 최소한의 개인정보를 수집하며, 회원의 동의 없이 제3자에게 제공하지 않습니다.',
            '제2조 (수집 정보): 이름, 연락처, 이메일, 여행 정보, 거래 이력 등을 수집합니다.',
            '제3조 (정보 이용 목적): 서비스 제공, 본인 확인, 거래 안전성 확보, 맞춤형 서비스 제공에 활용됩니다.',
            '제4조 (정보 보호): 개인정보는 암호화되어 안전하게 관리되며, 서비스 제공 목적 달성 시 지체 없이 파기됩니다.',
            '제5조 (정보 열람 및 정정): 회원은 언제든 자신의 개인정보를 열람하고 정정할 권리가 있습니다.',
          ]),
          buildSection('판매자 정책', [
            '제1조 (판매자 자격): 신뢰할 수 있는 여행자, 해외 거주자, 현지 방문자 등이 판매자로 등록 가능합니다.',
            '제2조 (상품 등록 기준): 합법적이고 안전한 상품만 등록 가능하며, 허위 정보 제공은 엄격히 금지됩니다.',
            '제3조 (금지 품목): 불법 상품, 위조품, 규제 상품, 윤리에 어긋나는 상품의 판매는 금지됩니다.',
            '제4조 (판매자 의무): 정확한 상품 정보 제공, 신속한 배송, 구매자와의 원활한 소통을 보장해야 합니다.',
            '제5조 (수수료): 거래 금액의 5-7%의 플랫폼 수수료가 부과됩니다.',
          ]),
          buildSection('구매자 정책', [
            '제1조 (구매 절차): 신뢰할 수 있는 여행자와의 매칭, 안전한 에스크로 결제 시스템을 통해 구매가 진행됩니다.',
            '제2조 (결제 방법): 다양한 결제 수단 지원, 실시간 환율 반영, 안전한 결제 시스템을 제공합니다.',
            '제3조 (배송 및 통관): 배송 추적 시스템, 통관/관세 자동 계산 서비스를 제공합니다.',
            '제4조 (반품 및 환불): 상품 상태, 배송 문제에 따른 명확한 반품 및 환불 절차를 제공합니다.',
            '제5조 (분쟁 해결): 공정하고 투명한 분쟁 해결 절차를 운영합니다.',
          ]),
          buildSection('커뮤니티 가이드라인', [
            '제1조 (소통 원칙): 상호 존중, 문화적 차이 인정, 건설적이고 긍정적인 소통을 지향합니다.',
            '제2조 (콘텐츠 기준): 혐오성, 차별적, 폭력적, 불쾌한 콘텐츠는 엄격히 금지됩니다.',
            '제3조 (문화 교류): 진정성 있는 문화 교류와 상호 이해를 촉진하는 소통을 장려합니다.',
            '제4조 (신고 및 제재): 부적절한 행동에 대한 명확한 신고 및 제재 절차를 운영합니다.',
            '제5조 (지적재산권): 타인의 지적재산권을 존중하고 무단 사용을 금지합니다.',
          ]),
        ],
      ),
    );
  }

  Widget buildSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        ...items.map((item) => buildItem(item)).toList(),
        SizedBox(height: 16),
      ],
    );
  }

  Widget buildItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.circle, size: 8, color: Colors.grey),
          SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
