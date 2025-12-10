import 'package:chelsy_restaurant/presentation/pages/home/featured_dishes_page.dart';
import 'package:chelsy_restaurant/presentation/pages/home/popular_dishes_page.dart';
import 'package:flutter/material.dart';
import 'package:chelsy_restaurant/presentation/pages/home/home_page.dart';
import 'package:chelsy_restaurant/presentation/pages/profile/profile_page.dart';
import 'package:chelsy_restaurant/presentation/widgets/main_bottom_nav.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const FeaturedDishesPage(),
    const PopularDishesPage(),
    const ProfilePage(),
  ];

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
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
