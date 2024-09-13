import 'package:json_annotation/json_annotation.dart';

part 'cursor_pagination_model.g.dart';

abstract class CursorPaginationBase {}

class CursorPaginationError extends CursorPaginationBase {
  final String message;

  CursorPaginationError({
    required this.message,
  });
}

class CursorPaginationLoading extends CursorPaginationBase {}

@JsonSerializable(genericArgumentFactories: true)
class CursorPagination<T> extends CursorPaginationBase {
  // CursorPagination<T> is CursorPaginationBase == true
  final CursorPaginationMeta meta;
  final List<T> data;

  CursorPagination({
    required this.meta,
    required this.data,
  });

  CursorPagination copyWith({
    CursorPaginationMeta? meta,
    final List<T>? data,
  }) {
    return CursorPagination<T>(
      meta: meta ?? this.meta,
      data: data ?? this.data,
    );
  }

  factory CursorPagination.fromJson(
          Map<String, dynamic> json, T Function(Object? json) fromJsonT) =>
      _$CursorPaginationFromJson(json, fromJsonT);
}

@JsonSerializable()
class CursorPaginationMeta {
  final int count;
  final bool hasMore;

  CursorPaginationMeta({
    required this.count,
    required this.hasMore,
  });

  CursorPaginationMeta copyWith({
    int? count,
    bool? hasMore,
  }) {
    return CursorPaginationMeta(
      count: count ?? this.count,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  factory CursorPaginationMeta.fromJson(Map<String, dynamic> json) =>
      _$CursorPaginationMetaFromJson(json);
}

// 리스트의 맨 아래로 내려서 추가 데이터를 요청하는 중에 로딩 중인 경우
class CursorPaginationFetchingMore<T> extends CursorPagination<T> {
  CursorPaginationFetchingMore({
    required super.meta,
    required super.data,
  });
}

// 새로고침 할 때(맨 위에서 아래로 튕기는 제스쳐)
// extends CursorPagination 이유 : 새로고침 할 때 이미 데이터가 있는 것을 가정하기 때문에
// CursorPaginationBase 도 자연스럽게 상속받는다.
// CursorPaginationRefetching가 이 프로젝트에서는 안 쓰일 듯
class CursorPaginationRefetching<T> extends CursorPagination<T> {
  // CursorPaginationRefetching is CursorPagination  == true
  // CursorPaginationRefetching is CursorPaginationBase == true

  CursorPaginationRefetching({
    required super.meta,
    required super.data,
  });
}
