import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';

class CartProvider extends ChangeNotifier {
  List<CartItemModel> _items = [];

  List<CartItemModel> get items => _items;

  List<CartItemModel> get vehicleItems =>
      _items.where((i) => i.product.category == 'vehicle').toList();

  List<CartItemModel> get partItems =>
      _items.where((i) => i.product.category == 'part').toList();

  int get itemCount => _items.length;

  double get totalPrice {
    double total = 0.0;
    for (var item in _items) {
      if (item.isSelected) {
        total += item.product.priceValue * item.quantity;
      }
    }
    return total;
  }

  CartProvider() {
    loadCartFromPrefs();
  }

  Future<void> loadCartFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = prefs.getString('cart_items');
      if (cartData != null) {
        final List<dynamic> decodedList = jsonDecode(cartData);
        _items = decodedList.map((item) => CartItemModel.fromJson(item)).toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> saveCartToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final listData = _items.map((item) => item.toJson()).toList();
      await prefs.setString('cart_items', jsonEncode(listData));
    } catch (_) {}
  }

  void addItem(ProductModel product) {
    final existingIndex = _items.indexWhere((i) => i.product.id == product.id);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity += 1;
    } else {
      _items.add(CartItemModel(product: product));
    }
    saveCartToPrefs();
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    saveCartToPrefs();
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index].quantity = quantity;
      saveCartToPrefs();
      notifyListeners();
    }
  }

  void toggleSelection(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index].isSelected = !_items[index].isSelected;
      saveCartToPrefs();
      notifyListeners();
    }
  }

  void toggleAllSelection(bool selected) {
    for (var item in _items) {
      item.isSelected = selected;
    }
    saveCartToPrefs();
    notifyListeners();
  }

  void clearSelected() {
    _items.removeWhere((item) => item.isSelected);
    saveCartToPrefs();
    notifyListeners();
  }

  void clearAll() {
    _items.clear();
    saveCartToPrefs();
    notifyListeners();
  }
}
