import 'package:actual/common/provider/pagination_provider.dart';
import 'package:flutter/cupertino.dart';

class PaginationUtils {
  static void paginate({
    required ScrollController controller,
    required PaginationProvider provider,
  }) {
    // 현재 위치가 최대 길이보다 조금 덜 되는 위치까지 왔다면 새로운 데이터를 추가 요청
    // controller.offset : 현재 스크롤한 위치
    // controller.position.maxScrollExtent : 최대 스크롤 가능한 길이
    if (controller.offset > controller.position.maxScrollExtent - 300) {
      provider.paginate(
        fetchMore: true, // 이게 없으면 그냥 처음부터 데이터를 가져오게 된다.
      );
    }
  }
}
