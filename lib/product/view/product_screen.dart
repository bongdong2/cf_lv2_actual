import 'package:actual/product/provider/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductScreen extends ConsumerStatefulWidget {
  const ProductScreen({super.key});

  @override
  ConsumerState<ProductScreen> createState() => _ProductTabState();
}

class _ProductTabState extends ConsumerState<ProductScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productProvider.notifier);

    return Center(child: Text('음식'));
  }
}