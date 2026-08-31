import 'product_model.dart';

class CartItemModel {
  final ProductModel product;
  int quantity;
  bool isSelected;

  CartItemModel({
    required this.product,
    this.quantity = 1,
    this.isSelected = true,
  });

  Map<String, dynamic> toJson() => {
    'product': product.toJson(),
    'quantity': quantity,
    'isSelected': isSelected,
  };

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      product: ProductModel.fromJson(json['product']),
      quantity: json['quantity'] ?? 1,
      isSelected: json['isSelected'] ?? true,
    );
  }
}
