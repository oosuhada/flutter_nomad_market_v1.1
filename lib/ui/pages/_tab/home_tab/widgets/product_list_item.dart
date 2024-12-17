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
    // https://picsum.photos/200/300
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
                    postSummary.originalTitle,
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
                  // 숫자 서식 문자열
                  // 000 => 001
                  // ### => 1
                  // ###,###
                  Text(
                    NumberFormat('#,###원').format(postSummary.price),
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
                        '${postSummary.likes}',
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
