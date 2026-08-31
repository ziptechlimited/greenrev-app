class ProductColor {
  final String name;
  final String hex;

  ProductColor({required this.name, required this.hex});

  factory ProductColor.fromJson(Map<String, dynamic> json) {
    return ProductColor(
      name: json['name'] ?? '',
      hex: json['hex'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'hex': hex};
}

class ProductSpecs {
  final double? acceleration;
  final int? horsepower;
  final String? torque;
  final String? transmission;
  final String? topSpeed;
  final String? compatibility;
  final String? warranty;

  ProductSpecs({
    this.acceleration,
    this.horsepower,
    this.torque,
    this.transmission,
    this.topSpeed,
    this.compatibility,
    this.warranty,
  });

  factory ProductSpecs.fromJson(Map<String, dynamic> json) {
    return ProductSpecs(
      acceleration: (json['acceleration'] as num?)?.toDouble() ?? (json['0_100'] as num?)?.toDouble(),
      horsepower: json['horsepower'] as int?,
      torque: json['torque']?.toString(),
      transmission: json['transmission']?.toString(),
      topSpeed: json['topSpeed']?.toString(),
      compatibility: json['compatibility']?.toString(),
      warranty: json['warranty']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'acceleration': acceleration,
    'horsepower': horsepower,
    'torque': torque,
    'transmission': transmission,
    'topSpeed': topSpeed,
    'compatibility': compatibility,
    'warranty': warranty,
  };
}

class ProductModel {
  final String id;
  final String name;
  final String make;
  final String category; // 'vehicle' or 'part'
  final String price;
  final double priceValue;
  final int? year;
  final String? mileage;
  final ProductColor? color;
  final String image;
  final List<String> images;
  final ProductSpecs? specs;
  final String? description;
  final bool inStock;
  final int stockQuantity;
  final String? vendorId;
  final String? vendorName;

  ProductModel({
    required this.id,
    required this.name,
    required this.make,
    required this.category,
    required this.price,
    required this.priceValue,
    this.year,
    this.mileage,
    this.color,
    required this.image,
    required this.images,
    this.specs,
    this.description,
    this.inStock = true,
    this.stockQuantity = 1,
    this.vendorId,
    this.vendorName,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      make: json['make'] ?? '',
      category: json['category'] ?? 'vehicle',
      price: json['price'] ?? '',
      priceValue: (json['priceValue'] as num?)?.toDouble() ?? 0.0,
      year: json['year'] as int?,
      mileage: json['mileage']?.toString(),
      color: json['color'] != null ? ProductColor.fromJson(json['color']) : null,
      image: json['image'] ?? '',
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      specs: json['specs'] != null ? ProductSpecs.fromJson(json['specs']) : null,
      description: json['description'],
      inStock: json['inStock'] ?? true,
      stockQuantity: json['stockQuantity'] ?? 1,
      vendorId: json['vendorId'],
      vendorName: json['vendorName'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'make': make,
    'category': category,
    'price': price,
    'priceValue': priceValue,
    'year': year,
    'mileage': mileage,
    'color': color?.toJson(),
    'image': image,
    'images': images,
    'specs': specs?.toJson(),
    'description': description,
    'inStock': inStock,
    'stockQuantity': stockQuantity,
    'vendorId': vendorId,
    'vendorName': vendorName,
  };
}
