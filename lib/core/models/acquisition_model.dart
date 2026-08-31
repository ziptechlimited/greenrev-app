class AcquisitionModel {
  final String id;
  final String? productId;
  final String? productName;
  final String? productImage;
  final String status;
  final int quantity;
  final String? message;
  final String createdAt;

  AcquisitionModel({
    required this.id,
    this.productId,
    this.productName,
    this.productImage,
    required this.status,
    this.quantity = 1,
    this.message,
    required this.createdAt,
  });

  factory AcquisitionModel.fromJson(Map<String, dynamic> json) {
    final product = json['product'];
    String? pName;
    String? pImg;
    if (product is Map<String, dynamic>) {
      pName = product['name'];
      pImg = product['image'];
    }

    return AcquisitionModel(
      id: json['_id'] ?? json['id'] ?? '',
      productId: json['productId'] is String ? json['productId'] : product?['_id'],
      productName: pName ?? json['productName'] ?? 'Vehicle Valuation Request',
      productImage: pImg ?? json['productImage'],
      status: json['status'] ?? 'REQUESTED',
      quantity: json['quantity'] ?? 1,
      message: json['message'],
      createdAt: json['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'productName': productName,
        'productImage': productImage,
        'status': status,
        'quantity': quantity,
        'message': message,
        'createdAt': createdAt,
      };
}
