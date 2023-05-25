import 'package:actual/restaurant/model/restaurant_detail_model.dart';
import 'package:dio/dio.dart' hide Headers; // 임시 헤더로 인해서 Dio 헤더는 숨긴다.
import 'package:retrofit/http.dart';

part 'restaurant_repository.g.dart';

@RestApi()
abstract class RestaurantRepository { // 인스턴스화 되지 않게 abstract
  factory RestaurantRepository(Dio dio, {String baseUrl})
  = _RestaurantRepository;

  // @GET('/')
  // pagenate();

  // 임시, 포스트맨 /auth/login으로 받은 accessToken을 넣어 준다.
  @GET('/{id}')
  @Headers({
    'authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6InRlc3RAY29kZWZhY3RvcnkuYWkiLCJzdWIiOiJmNTViMzJkMi00ZDY4LTRjMWUtYTNjYS1kYTlkN2QwZDkyZTUiLCJ0eXBlIjoiYWNjZXNzIiwiaWF0IjoxNjg0OTczNzczLCJleHAiOjE2ODQ5NzQwNzN9.jBlBLrM9S6V_XLqaeJPvZ4XDcQThol94flHg6Db_xV4'
  })
  Future<RestaurantDetailModel> getRestaurantDetail({
    @Path() required String id,
  });
}