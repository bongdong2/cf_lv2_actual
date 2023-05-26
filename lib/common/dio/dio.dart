import 'package:actual/common/const/data.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CustomInterceptor extends Interceptor {
  final FlutterSecureStorage storage;

  CustomInterceptor({
    required this.storage,
  });

  // 1) 요청을 보낼 때
  // 요청 헤더에 'accessToken': 'true'이면 FlutterSecureStorage에서 실제 토큰을 할당한다.
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    print("[REQ] [${options.method}] ${options.uri}");

    if(options.headers['accessToken'] == 'true') {
      // 헤더 삭제
      options.headers.remove('accessToken');

      final token = await storage.read(key: ACCESS_TOKEN_KEY);

      // 실제 토큰으로 대체
      options.headers.addAll(({
        'authorization': 'Bearer $token',
      }));
    }

    if(options.headers['refreshToken'] == 'true') {
      // 헤더 삭제
      options.headers.remove('refreshToken');

      final token = await storage.read(key: REFRESH_TOKEN_KEY);

      // 실제 토큰으로 대체
      options.headers.addAll(({
        'authorization': 'Bearer $token',
      }));
    }

    // handler를 가지고 요청을 보낼 지, 에러를 보낼 지에 대한 결정이 이루어진다.
    return super.onRequest(options, handler);
  }

  // 2) 응답을 받을 때
  // 정상적인 응답을 받았을 떄 실행되기 때문에 현재 따로 작업할 내용은 없다.
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print("[RES] [${response.requestOptions.method}] ${response.requestOptions.uri}");
    return super.onResponse(response, handler);
  }

  // 3) 에러가 났을 때
  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    // 401 에러가 났을 때(status code)
    // 토큰을 재발급 받는 시도를 하고 토큰이 재발급 되면
    // 다시 새로운 토큰으로 요청을 한다.
    print("[ERR] [${err.requestOptions.method}] ${err.requestOptions.uri}");
    final refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);

    // refreshToken이 없으면
    if(refreshToken == null) {
      // handler.reject : 에러를 발생시킨다. 그리고 return으로 돌려준다.
      return handler.reject(err);
    }

    final isStatus401 = err.response?.statusCode == 401;
    // 이것이 true이면 토큰을 요청받다가 난 에러이므로 refreshToken 자체에 문제가 있다.
    final isPathRefresh = err.requestOptions.path == '/auth/token';

    // 401 이고, 토큰발급 url이 아니면
    if(isStatus401 && !isPathRefresh) {
      try {
        final dio = Dio();
        final resp = await dio.post(
          'http://$ip/auth/token',
          options: Options(
              headers: {
                'authorization': 'Bearer $refreshToken',
              }
          ),
        );

        final accessToken = resp.data['accessToken'];

        final options = err.requestOptions;

        // 토큰 변경하기
        options.headers.addAll({
          'authrization': 'Bearer $accessToken',
        });

        // 스토리지에 다시 넣어준다.
        await storage.write(key: ACCESS_TOKEN_KEY, value: accessToken);

        // 요청 재전송
        final response = await dio.fetch(options);

        // 실제 에러가 없었던 것처럼 에러를 던지지 않고 해결(resolve)
        return handler.resolve(response);

      } on DioError catch(e){
        return handler.reject(e);
      }
    }

    return handler.reject(err);
    //super.onError(err, handler);
  }
}
