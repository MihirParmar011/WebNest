import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'webview_page.dart';
import 'url_input.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> _recentUrls = [];
  List<String> _favoriteUrls = [];

  @override
  void initState() {
    super.initState();
    _loadRecentUrls();
    _loadFavorites();
  }

  Future<void> _loadRecentUrls() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentUrls = prefs.getStringList('recent_urls') ?? [];
    });
  }

  Future<void> _loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoriteUrls = prefs.getStringList('favorite_urls') ?? [];
    });
  }

  Future<void> _saveRecentUrl(String url) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!_recentUrls.contains(url)) {
      _recentUrls.insert(0, url);
      if (_recentUrls.length > 10) {
        _recentUrls = _recentUrls.take(10).toList();
      }
      await prefs.setStringList('recent_urls', _recentUrls);
      setState(() {});
    }
  }

  Future<void> _toggleFavorite(String url) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_favoriteUrls.contains(url)) {
      _favoriteUrls.remove(url);
    } else {
      _favoriteUrls.add(url);
    }
    await prefs.setStringList('favorite_urls', _favoriteUrls);
    setState(() {});
  }

  void _openUrl(String url) {
    _saveRecentUrl(url);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WebViewPage(initialUrl: url),
      ),
    );
  }

  void _showUrlInput() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UrlInput(
        onUrlSubmitted: (url) {
          Navigator.pop(context);
          _openUrl(url);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: Colors.blue,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Web Browser',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue, Colors.purple],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 40),
                      Icon(Icons.web, size: 60, color: Colors.white),
                      SizedBox(height: 10),
                      Text(
                        'Browse the web',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBar(),
                  SizedBox(height: 20),
                  _buildQuickLinks(),
                  SizedBox(height: 20),
                  if (_favoriteUrls.isNotEmpty) ...[
                    _buildSectionTitle('Favorites', Icons.favorite),
                    _buildUrlList(_favoriteUrls, showFavorite: true),
                    SizedBox(height: 20),
                  ],
                  if (_recentUrls.isNotEmpty) ...[
                    _buildSectionTitle('Recent', Icons.history),
                    _buildUrlList(_recentUrls),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showUrlInput,
        backgroundColor: Colors.blue,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: _showUrlInput,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.grey),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Enter URL or search...',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickLinks() {
    List<QuickLink> quickLinks = [
      QuickLink('Google', 'https://www.google.com', Icons.search, Colors.blue),
      QuickLink('YouTube', 'https://www.youtube.com', Icons.play_circle_fill, Colors.red),
      QuickLink('GitHub', 'https://www.github.com', Icons.code, Colors.black),
      QuickLink('Reddit', 'https://www.reddit.com', Icons.forum, Colors.orange),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Quick Links', Icons.link),
        SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: quickLinks.length,
          itemBuilder: (context, index) {
            QuickLink link = quickLinks[index];
            return GestureDetector(
              onTap: () => _openUrl(link.url),
              child: Container(
                decoration: BoxDecoration(
                  color: link.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: link.color.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(link.icon, color: link.color),
                    SizedBox(width: 8),
                    Text(
                      link.name,
                      style: TextStyle(
                        color: link.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade600),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildUrlList(List<String> urls, {bool showFavorite = false}) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: urls.length,
      itemBuilder: (context, index) {
        String url = urls[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: Icon(Icons.web, color: Colors.blue),
            title: Text(
              url,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    _favoriteUrls.contains(url) ? Icons.favorite : Icons.favorite_border,
                    color: _favoriteUrls.contains(url) ? Colors.red : Colors.grey,
                  ),
                  onPressed: () => _toggleFavorite(url),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
            onTap: () => _openUrl(url),
          ),
        );
      },
    );
  }
}

class QuickLink {
  final String name;
  final String url;
  final IconData icon;
  final Color color;

  QuickLink(this.name, this.url, this.icon, this.color);
}