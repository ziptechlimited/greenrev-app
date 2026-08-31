import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:greenrev_mobile/core/state/cart_provider.dart';
import 'package:greenrev_mobile/core/models/product_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CartProvider Tests', () {
    test('Initial cart is empty', () async {
      final cart = CartProvider();
      await cart.loadCartFromPrefs();
      expect(cart.itemCount, 0);
      expect(cart.totalPrice, 0.0);
    });

    test('Add vehicle and part to cart', () async {
      final cart = CartProvider();
      
      final vehicle = ProductModel(
        id: 'v1',
        name: 'Avatr 12 GT',
        make: 'Avatr',
        category: 'vehicle',
        price: '₦82,500,000',
        priceValue: 82500000.0,
        image: '',
        images: [],
      );

      final part = ProductModel(
        id: 'p1',
        name: 'Aureum Carbon Aero Wing',
        make: 'Aureum Performance',
        category: 'part',
        price: '\$4,500',
        priceValue: 4500.0,
        image: '',
        images: [],
      );

      cart.addItem(vehicle);
      cart.addItem(part);

      expect(cart.itemCount, 2);
      expect(cart.vehicleItems.length, 1);
      expect(cart.partItems.length, 1);
      expect(cart.totalPrice, 82504500.0);
    });

    test('Update quantities and remove items', () {
      final cart = CartProvider();

      final part = ProductModel(
        id: 'p1',
        name: 'Aureum Carbon Aero Wing',
        make: 'Aureum Performance',
        category: 'part',
        price: '\$4,500',
        priceValue: 4500.0,
        image: '',
        images: [],
      );

      cart.addItem(part);
      expect(cart.items[0].quantity, 1);

      // Increment quantity
      cart.updateQuantity('p1', 3);
      expect(cart.items[0].quantity, 3);
      expect(cart.totalPrice, 13500.0);

      // Remove item
      cart.removeItem('p1');
      expect(cart.itemCount, 0);
      expect(cart.totalPrice, 0.0);
    });

    test('Toggle selection updates total price', () {
      final cart = CartProvider();

      final part1 = ProductModel(
        id: 'p1',
        name: 'Part 1',
        make: 'Make',
        category: 'part',
        price: '\$100',
        priceValue: 100.0,
        image: '',
        images: [],
      );

      final part2 = ProductModel(
        id: 'p2',
        name: 'Part 2',
        make: 'Make',
        category: 'part',
        price: '\$200',
        priceValue: 200.0,
        image: '',
        images: [],
      );

      cart.addItem(part1);
      cart.addItem(part2);
      expect(cart.totalPrice, 300.0);

      // Deselect part1
      cart.toggleSelection('p1');
      expect(cart.totalPrice, 200.0);

      // Select part1 again
      cart.toggleSelection('p1');
      expect(cart.totalPrice, 300.0);
    });
  });
}
