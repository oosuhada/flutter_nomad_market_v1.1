import 'package:flutter/material.dart';
import 'package:flutter_market_app/ui/widgets/home_tab_list_view.dart';

class TransactionAccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {},
          ),
        ],
        elevation: 0,
        title: Text('거래 가계부'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.purple.shade900,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.purpleAccent.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '우수상님의',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '가계부',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 75),
                Text('노마드마켓 활동을 통해 만들어낸 가치를 확인해보세요.'),
                SizedBox(height: 1),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildTransactionItem(
                  '전체거래',
                  '950,000원',
                  isDarkMode,
                ),
                const Divider(height: 30),
                _buildTransactionItem(
                  '판매 1건',
                  '950,000원',
                  isDarkMode,
                ),
                _buildTransactionItem(
                  '구매',
                  '0원',
                  isDarkMode,
                ),
                _buildTransactionItem(
                  '나눔',
                  '0번',
                  isDarkMode,
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('우수상님의 거래가 갖는 가치'),
                const SizedBox(height: 16),
                _buildValueItem(
                  '🌲',
                  '소나무 6그루를 심은 것과 같아요.',
                  isDarkMode,
                ),
                const SizedBox(height: 12),
                _buildValueItem(
                  '🚗',
                  '자동차를 3187.9km 덜 탄 것과 같아요.',
                  isDarkMode,
                ),
                const SizedBox(height: 12),
                _buildValueItem(
                  '🔥',
                  '보일러를 202시간 덜 켠 것과 같아요.',
                  isDarkMode,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(String label, String value, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildValueItem(String emoji, String text, bool isDarkMode) {
    return Row(
      children: [
        Text(emoji),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text),
        ),
      ],
    );
  }
}
