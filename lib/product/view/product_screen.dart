import 'package:actual/common/component/pagination_list_view.dart';
import 'package:actual/product/provider/product_provider.dart';
import 'package:flutter/material.dart';

import '../component/product_card.dart';
import '../model/product_model.dart';

class ProductScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PaginationListView<ProductModel>(
      provider: productProvider,
      itemBuilder: <ProductModel>(_, index, model) {
        return ProductCard.fromProductModel(
          model: model,
        );
      },
    );
  }
}