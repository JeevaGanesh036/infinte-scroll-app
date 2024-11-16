import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: InfiniteScrollList(),
      theme: ThemeData.dark(), // Dark theme to enhance transparency effects
    );
  }
}

class InfiniteScrollList extends StatefulWidget {
  const InfiniteScrollList({super.key});

  @override
  _InfiniteScrollListState createState() => _InfiniteScrollListState();
}

class _InfiniteScrollListState extends State<InfiniteScrollList> {
  final ScrollController _scrollController = ScrollController();
  final List<int> _items = List.generate(20, (index) => index); // Initial data
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Triggered when the user scrolls to the end of the first list
  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isLoading) {
      _fetchMoreData();
    }
  }

  // Simulate data fetch with a delay
  Future<void> _fetchMoreData() async {
    setState(() => _isLoading = true);

    // Fake network delay
    await Future.delayed(const Duration(seconds: 2));

    // Adding new data
    setState(() {
      _items.addAll(List.generate(20, (index) => _items.length + index));
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.withOpacity(0.6),
                  Colors.purple.withOpacity(0.6),
                ],
              ),
            ),
          ),
          // Main Vertical List with Multiple Horizontal Lists Inside
          Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    _buildHorizontalList(
                      title: "Infinite Scroll List",
                      items: _items,
                      controller: _scrollController,
                      isLoading: _isLoading,
                    ),
                    _buildHorizontalList(
                      title: "Refreshable List",
                      items: List.generate(20, (index) => index),
                      onRefresh: _refreshData,
                      backgroundColor: Colors.teal.withOpacity(0.1),
                    ),
                    _buildHorizontalList(
                      title: "Interactive Icons",
                      items: List.generate(20, (index) => index),
                      withIcons: true,
                      backgroundColor: Colors.orange.withOpacity(0.1),
                    ),
                    _buildHorizontalList(
                      title: "Profile Avatars",
                      items: List.generate(20, (index) => index),
                      withAvatar: true,
                      backgroundColor: Colors.redAccent.withOpacity(0.1),
                    ),
                    _buildHorizontalList(
                      title: "Static Content",
                      items: List.generate(10, (index) => index),
                      backgroundColor: Colors.green.withOpacity(0.1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Refresh function for the Refreshable List
  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      // Refresh the list by reloading the initial items
    });
  }

  // Build a horizontal list with different optional features
  Widget _buildHorizontalList({
    required String title,
    required List<int> items,
    ScrollController? controller,
    bool isLoading = false,
    Color backgroundColor = Colors.transparent,
    bool withIcons = false,
    bool withAvatar = false,
    Future<void> Function()? onRefresh,
  }) {
    Widget listView = ListView.builder(
      scrollDirection: Axis.horizontal,
      controller: controller,
      itemCount: items.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < items.length) {
          return TransparentListItem(
            itemNumber: items[index],
            backgroundColor: backgroundColor,
            withIcons: withIcons,
            withAvatar: withAvatar,
          );
        } else {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        SizedBox(
          height: 180,
          child: onRefresh != null
              ? RefreshIndicator(onRefresh: onRefresh, child: listView)
              : listView,
        ),
      ],
    );
  }
}

// Custom Transparent List Item with Blur Effect for Horizontal Layout
class TransparentListItem extends StatelessWidget {
  final int itemNumber;
  final Color backgroundColor;
  final bool withIcons;
  final bool withAvatar;

  const TransparentListItem({
    super.key,
    required this.itemNumber,
    this.backgroundColor = Colors.transparent,
    this.withIcons = false,
    this.withAvatar = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            width: 160,
            decoration: BoxDecoration(
              color: backgroundColor.withOpacity(0.6),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (withAvatar)
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    child: Text(
                      itemNumber.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                if (!withAvatar)
                  Text(
                    'Item #$itemNumber',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                const SizedBox(height: 6),
                Text(
                  'Description for item #$itemNumber',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
                if (withIcons) const SizedBox(height: 10),
                if (withIcons)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.favorite_border, color: Colors.white),
                        onPressed: () {
                          // Handle favorite action
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.share, color: Colors.white),
                        onPressed: () {
                          // Handle share action
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
