import 'package:flutter/material.dart';

class FAQPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('자주 묻는 질문 (FAQ)'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildSection('구매자', [
            _buildFAQItem(
              '노마드 마켓은 어떤 서비스인가요?',
              '노마드 마켓은 여행자와 구매자를 연결하는 글로벌 P2P 커머스 플랫폼입니다. 여행자가 해외에서 구매한 상품이나 직접 제작한 예술 작품을 국내 구매자에게 판매할 수 있도록 연결해줍니다.',
            ),
            _buildFAQItem(
              '해외 직구 쇼핑몰과 노마드 마켓의 차이점은 무엇인가요?',
              '해외 직구 쇼핑몰은 높은 배송비와 관세, 긴 배송 시간 등의 단점이 있습니다. 노마드 마켓은 여행자가 직접 상품을 배송하기 때문에 보다 저렴한 가격으로 상품을 구매하고 빠른 배송을 받을 수 있습니다. 또한, 해외 직구 쇼핑몰에서는 찾기 어든 한정판 상품이나 특정 국가/지역에서만 판매되는 상품을 구매할 수 있습니다.',
            ),
            _buildFAQItem(
              '개인에게 직접 구매하는 것이 안전한가요?',
              '노마드 마켓은 안전한 에스크로 결제 시스템과 판매자 신뢰도 평가 시스템을 통해 구매자를 보호합니다. 또한, 신원 확인 시스템을 통해 거래 파트너의 신원을 확인할 수 있습니다.',
            ),
            _buildFAQItem(
              '어떤 종류의 상품을 구매할 수 있나요?',
              '해외에서 구매 가능한 모든 상품을 구매할 수 있으며, 특히 국내에서 구하기 어려운 대형 신발 사이즈, 플러스 사이즈 의류, 특정 피부톤 및 헤어 타입에 맞는 상품, 해외 한정판 상품, K-뷰티 제품, 일본 피규어 등을 구매할 수 있습니다.',
            ),
            _buildFAQItem(
              '한국어로 된 상품 정보가 부족하면 어떻게 하나요?',
              '노마드 마켓은 자동 번역 기능을 제공하며, 실시간 채팅을 통해 판매자에게 직접 문의할 수 있습니다.',
            ),
            _buildFAQItem(
              '구매 요청 후 배송 과정은 어떻게 되나요?',
              '배송 추적 시스템을 통해 구매 요청 후 상품의 배송 현황을 실시간으로 확인할 수 있습니다.',
            ),
            _buildFAQItem(
              '문화 교류는 어떻게 이루어지나요?',
              '노마드 마켓은 단순한 상품 거래를 넘어 한국 문화를 중심으로 한 커뮤니티 구축을 목표로 합니다. 직접 구매 커뮤니티 참여 및 한국인과의 교류 기회를 제공합니다.',
            ),
          ]),
          _buildSection('판매자', [
            _buildFAQItem(
              '노마드 마켓에서 어떤 상품을 판매할 수 있나요?',
              '여행 중 구매한 상품뿐 아니라 개인적으로 제작한 예술 작품도 판매할 수 있습니다.',
            ),
            _buildFAQItem(
              '판매 대금은 어떻게 지급받나요?',
              '구매자가 결제를 완료하면 안전한 에스크로 시스템을 통해 대금이 보호되며, 상품 배송 후 판매자에게 지급됩니다.',
            ),
            _buildFAQItem(
              '판매 수수료는 얼마인가요?',
              '판매 금액의 5-7%를 수수료로 부과합니다.',
            ),
            _buildFAQItem(
              '구매자가 상품 구매를 취소하거나 연락이 두절되면 어떻게 하나요?',
              '노마드 마켓은 분쟁 해결 시스템을 통해 판매자의 권익을 보호합니다.',
            ),
            _buildFAQItem(
              '상품을 홍보할 수 있는 방법이 있나요?',
              '노마드 마켓 플랫폼 자체의 홍보 및 마케팅 효과를 통해 상품을 홍보할 수 있으며, 여행자 커뮤니티에 참여하여 정보를 공유하고 상품을 홍보할 수 있습니다.',
            ),
            _buildFAQItem(
              '세금 관련 정보를 얻을 수 있나요?',
              '관세/부가세 자동 계산 서비스 및 세금 안내를 제공합니다.',
            ),
            _buildFAQItem(
              '해외 거주자도 판매자로 활동할 수 있나요?',
              '네, 해외에 거주하는 유학생, 교민, 주재원 등 누구나 판매자로 활동할 수 있습니다.',
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        ...items,
      ],
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(answer),
        ),
        SizedBox(height: 5),
      ],
    );
  }
}
