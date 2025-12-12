import 'package:flutter/material.dart';
import 'package:chelsy_restaurant/presentation/pages/home/featured_dishes_page.dart';
import 'package:chelsy_restaurant/presentation/pages/home/home_page.dart';
import 'package:chelsy_restaurant/presentation/pages/cart/cart_page.dart';
// import 'package:chelsy_restaurant/presentation/pages/orders/orders_page.dart';
import 'package:chelsy_restaurant/presentation/pages/profile/profile_page.dart';
import 'package:chelsy_restaurant/presentation/widgets/main_bottom_nav.dart';
import 'package:chelsy_restaurant/core/bindings/home_binding.dart';
// import 'package:chelsy_restaurant/core/bindings/order_binding.dart';
import 'package:chelsy_restaurant/core/bindings/profile_binding.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const CartPage(),
    const FeaturedDishesPage(),
    // const OrdersPage(),
    const ProfilePage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();

    HomeBinding().dependencies();
    // OrderBinding().dependencies();
    ProfileBinding().dependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: MainBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
