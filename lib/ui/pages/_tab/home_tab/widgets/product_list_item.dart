import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_market_app/core/date_time_utils.dart';
import 'package:flutter_market_app/data/model/post_summary.dart';
import 'package:flutter_market_app/ui/pages/post_detail/post_detail_page.dart';
import 'package:intl/intl.dart';

class ProductListItem extends StatelessWidget {
  ProductListItem(this.postSummary);

  final PostSummary postSummary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) {
            return PostDetailPage(postSummary.id);
          }),
        );
      },
      child: Container(
        height: 120,
        width: double.infinity,
        color: Colors.transparent,
        child: Row(
          children: [
            Container(
              width: 120,
              height: 120,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  postSummary.thumbnail.url,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    postSummary.originalTitle, // title 대신 translatedTitle 사용
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    '${postSummary.address.fullNameKR} ${DateTimeUtils.formatString(postSummary.updatedAt)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    NumberFormat('#,###${postSummary.currency}')
                        .format(postSummary.price), // 원 대신 currency 사용
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        CupertinoIcons.heart,
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${postSummary.likes}', // likes로 변경된 필드지만 PostSummary 모델에서 likeCnt로 매핑됨
                        style: TextStyle(
                          fontSize: 12,
                          height: 1,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
