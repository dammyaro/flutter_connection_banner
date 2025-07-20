child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Animation Style'),
                    DropdownButton<BannerAnimation>(
                      value: _selectedAnimation,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedAnimation = value);
                        }
                      },
                      items: BannerAnimation.values.map((animation) {
                        return DropdownMenuItem(
                          value: animation,
                          child: Text(animation.name),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Toggle Options
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CheckboxListTile(
                      title: const Text('Show Quality Indicator'),
                      value: _showQuality,
                      onChanged: (value) {
                        setState(() => _showQuality = value ?? false);
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Show Connected Banner'),
                      value: _showConnectedBanner,
                      onChanged: (value) {
                        setState(() => _showConnectedBanner = value ?? false);
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Example Content
            const Expanded(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sample App Content',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'This is a sample app to demonstrate the Connection Banner. '
                        'Try turning off your internet connection to see the banner in action!',
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Features:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 8),
                      Text('• Automatic connection detection'),
                      Text('• Beautiful animations'),
                      Text('• Customizable themes'),
                      Text('• Quality indicators'),
                      Text('• Action buttons'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Connection Banner Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: ConnectionBanner(
        animation: _selectedAnimation,
        showQuality: _showQuality,
        showConnectedBanner: _showConnectedBanner,
        onConnectionChanged: (status) {
          setState(() {
            _currentStatus = status;
          });
        },
        child: _buildContent(),
      ),
    );
  }
}