import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AllCategoriesProvider with ChangeNotifier{
  List<Map<String, dynamic>> allCategoriesList = [
    {
      'icon': Icons.fastfood_outlined,
      'name': 'Groceries',
      'color': Color(0xff27aae1),
    },
    {
      'icon': Icons.medical_information_outlined,
      'name': 'Health',
      'color': Color(0xffFD3C4A),
    },
    {
      'icon': Icons.menu_book_outlined,
      'name': 'Education',
      'color': Color(0xffC77DFF),
    },

    {
      'icon': Icons.directions_bus_outlined,
      'name': 'Transport',
      'color': Color(0xffFFD93D),
    },
    {
      'icon': Icons.lightbulb_circle_outlined,
      'name': 'Bills',
      'color': Color(0xff1DC3F7),
    },
    {
      'icon': Icons.apartment_outlined,
      'name': 'Rent',
      'color': Color(0xff00A86B),
    },

    {
      'icon': Icons.credit_score_outlined,
      'name': 'Salaries',
      'color': Color(0xff4D96FF),
    },

    {
      'icon': Icons.volunteer_activism_outlined,
      'name': 'Charity',
      'color': Color(0xff6BCB77),
    },

    {
      'icon': Icons.shopping_cart_outlined,
      'name': 'Shopping',
      'color': Color(0xffFF6B6B),
    },

    {
      'icon': Icons.handyman_outlined,
      'name': 'Maintenance',
      'color': Color(0xff566D7E),
    },
    {
      'icon': Icons.chair_outlined,
      'name': 'Household',
      'color': Color(0xffA0522D),
    },
    {
      'icon': Icons.pets_outlined,
      'name': 'Pets',
      'color': Color(0xffFF9A3C),
    },

    {
      'icon': Icons.sports_tennis_outlined,
      'name': 'Sports',
      'color': Color(0xff00CED1),
    },
    {
      'icon': Icons.movie_filter_outlined,
      'name': 'Entertainment',
      'color': Color(0xffFF1493),
    },
    {
      'icon': Icons.card_giftcard_outlined,
      'name': 'Gifts',
      'color': Color(0xffFFD700),
    },

    {
      'icon': Icons.beach_access,
      'name': 'Vacations',
      'color': Color(0xff1E90FF),
    },
    {
      'icon': Icons.restaurant_menu_outlined,
      'name': 'Restaurant',
      'color': Color(0xffFF4500),
    },
    {
      'icon': Icons.note_alt_outlined,
      'name': 'Others',
      'color': Color(0xff808080),
    },
  ];

}