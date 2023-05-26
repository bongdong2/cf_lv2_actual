import 'package:actual/common/model/cursor_pagination_model.dart';
import 'package:actual/restaurant/model/restaurant_detail_model.dart';
import 'package:dio/dio.dart' hide Headers; // 임시 헤더로 인해서 Dio 헤더는 숨긴다.
import 'package:retrofit/http.dart';

import '../model/restaurant_model.dart';

part 'restaurant_repository.g.dart';

@RestApi()
abstract class RestaurantRepository { // 인스턴스화 되지 않게 abstract
  factory RestaurantRepository(Dio dio, {String baseUrl})
  = _RestaurantRepository;

  @GET('/')
  @Headers({
    'accessToken': 'true',
  })
  Future<CursorPagination<RestaurantModel>> paginate();

  // 임시, 포스트맨 /auth/login으로 받은 accessToken을 넣어 준다.
  @GET('/{id}')
  @Headers({
    'accessToken': 'true',
  })
  Future<RestaurantDetailModel> getRestaurantDetail({
    @Path() required String id,
  });
}