import 'package:flutter/material.dart';

class UrlInput extends StatefulWidget{
  final Function(String) onUrlSubmitted;
  
  const UrlInput({Key? key, required this.onUrlSubmitted}): super(key: key);
  
  @override
  _UrlInputState createState() => _UrlInputState();

}

class _UrlInputState extends State<UrlInput>{
  
  final TextEditingController _urlController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _urlController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _formatUrl(String input) {
    input = input.trim();

    // If it's empty, return empty
    if(input.isEmpty) return input;

    // If it looks like a search query (no dots and no protocol), use Google search
    if(!input.contains('.') && !input.startsWith('http')) {
      return 'https://www.google.com/search?q=${Uri.encodeFull(input)}';
    }

    // If it doesn't start with http:// or https://, add https://
    if(!input.startsWith('http://') && !input.startsWith('https://')) {
      input = 'https://$input';
    }
    return input;
  }
  
  void _submitUrl() {
    String url = _formatUrl(_urlController.text);
    if (url.isNotEmpty) {
      widget.onUrlSubmitted(url);

    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Handle Bar
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              SizedBox(height: 20),

              //Title
              Text(
                'Enter URL or Search',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 20),

              //URL input field
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _urlController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: 'https://example.com or search term',
                    prefixIcon: Icon(Icons.link, color: Colors.blue),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.go,
                  onSubmitted: (_) => _submitUrl(),
                ),
              ),
              SizedBox(height: 16),

              //Helper Text
              Text(
                'Enter a website URL or search term. URLs without http/https will be automatically formatted.',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 20),

              //Action buttons
              Row(
                children: [
                  Expanded(
                      child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: Colors.grey.shade400),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.grey.shade600),
                          ),
                      ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _submitUrl,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        )
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.launch, size: 18),
                          SizedBox(width: 8),
                          Text('Open'),
                        ],
                      ),
                    ),
                  )
                ],
              )
            ],
          )
      ),
    );
  }
}