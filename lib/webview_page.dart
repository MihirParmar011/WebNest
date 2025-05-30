import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'url_input.dart';

class WebViewPage extends StatefulWidget {
  final String initialUrl;

  const WebViewPage({Key? key, required this.initialUrl}) : super(key: key);

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late WebViewController _controller;
  bool _isLoading = true;
  bool _showUrlBar = true;
  String _currentUrl = '';
  String _currentTitle = '';
  bool _canGoBack = false;
  bool _canGoForward = false;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.initialUrl;
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading progress
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _currentUrl = url;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
              _currentUrl = url;
            });
            _updateNavigationState();
            _updateTitle();
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
            });
            _showErrorDialog(error.description);
          },
          onNavigationRequest: (NavigationRequest request) {
            // Allow all navigation requests
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl));
  }

  Future<void> _updateNavigationState() async {
    final canGoBack = await _controller.canGoBack();
    final canGoForward = await _controller.canGoForward();
    setState(() {
      _canGoBack = canGoBack;
      _canGoForward = canGoForward;
    });
  }

  Future<void> _updateTitle() async {
    final title = await _controller.getTitle();
    setState(() {
      _currentTitle = title ?? '';
    });
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error Loading Page'),
          content: Text(error),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _controller.reload();
              },
              child: const Text('Retry'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
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
          _controller.loadRequest(Uri.parse(url));
        },
      ),
    );
  }

  void _shareUrl() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('URL: $_currentUrl')),
    );
  }

  void _openInExternalBrowser() async {
    final Uri url = Uri.parse(_currentUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _showMenu() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Refresh'),
                onTap: () {
                  Navigator.pop(context);
                  _controller.reload();
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share'),
                onTap: () {
                  Navigator.pop(context);
                  _shareUrl();
                },
              ),
              ListTile(
                leading: const Icon(Icons.open_in_browser),
                title: const Text('Open in Browser'),
                onTap: () {
                  Navigator.pop(context);
                  _openInExternalBrowser();
                },
              ),
              ListTile(
                leading: Icon(_showUrlBar ? Icons.visibility_off : Icons.visibility),
                title: Text(_showUrlBar ? 'Hide URL Bar' : 'Show URL Bar'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _showUrlBar = !_showUrlBar;
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _showUrlBar ? _buildAppBar() : null,
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    const Text('Loading...'),
                  ],
                ),
              ),
            ),
          if (!_showUrlBar)
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              right: 10,
              child: FloatingActionButton.small(
                onPressed: () {
                  setState(() {
                    _showUrlBar = true;
                  });
                },
                backgroundColor: Colors.black54,
                child: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _showUrlBar ? _buildBottomBar() : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 1,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _currentTitle.isNotEmpty ? _currentTitle : 'Web Browser',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (_currentUrl.isNotEmpty)
            Text(
              _currentUrl,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: _showUrlInput,
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: _showMenu,
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _canGoBack
                ? () {
              _controller.goBack();
            }
                : null,
            color: _canGoBack ? Colors.black : Colors.grey,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: _canGoForward
                ? () {
              _controller.goForward();
            }
                : null,
            color: _canGoForward ? Colors.black : Colors.grey,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _controller.reload();
            },
            color: Colors.black,
          ),
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.of(context).pop();
            },
            color: Colors.black,
          ),
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_up),
            onPressed: () {
              setState(() {
                _showUrlBar = false;
              });
            },
            color: Colors.black,
          ),
        ],
      ),
    );
  }
}