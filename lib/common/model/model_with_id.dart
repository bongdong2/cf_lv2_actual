abstract class IModelWithId {
  final String id;

  IModelWithId({
    required this.id,
  });
}

// dart sdk 에서 모델에 id가 있는지 알 수 없으므로 해당 인터페이스를 구현하는 모든 모델들은 id가 있는 것으로 간주한다.
// pagination 에서 사용할 모델을에게 이 클래스를 구현하게 한다. last.id 가 필요하다.