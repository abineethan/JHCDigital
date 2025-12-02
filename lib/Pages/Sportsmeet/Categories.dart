import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jhc_app/Pages/Sportsmeet/Service.dart';
import 'package:jhc_app/Pages/Sportsmeet/View.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class SportsmeetCategories extends StatefulWidget {
  final String year;
  final String category;

  const SportsmeetCategories({
    required this.year,
    required this.category,
  });

  @override
  _SportsmeetCategoriesState createState() => _SportsmeetCategoriesState();
}

class _SportsmeetCategoriesState extends State<SportsmeetCategories> {
  final SportsmeetService _sportsmeetService = SportsmeetService();
  List<QueryDocumentSnapshot> _events = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final snapshot = await _sportsmeetService.getCategoryEvents(
          widget.year, widget.category);
      setState(() {
        _events = snapshot.docs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load events';
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshEvents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    await _loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    final displayName =
        _sportsmeetService.getCategoryDisplayName(widget.category);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 15, 20, 25),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(
              "$displayName - ${widget.year}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            toolbarHeight: 55,
            backgroundColor: const Color.fromARGB(255, 25, 30, 32),
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
          ),
          _isLoading
              ? SliverToBoxAdapter(child: _buildLoadingWidget())
              : _error != null
                  ? SliverToBoxAdapter(child: _buildErrorWidget())
                  : _events.isEmpty
                      ? SliverToBoxAdapter(child: _buildEmptyWidget())
                      : _buildEventGrid(),
        ],
      ),
    );
  }

  Widget _buildEventGrid() {
    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.05,
        vertical: 16.0,
      ),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 600,
          mainAxisExtent: MediaQuery.of(context).size.width > 800 ? 350 : 280,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, index) {
            final event = _events[index];
            final eventData = event.data() as Map<String, dynamic>;
            return _EventCard(
              eventData: eventData,
              eventId: event.id,
              onTap: () => _navigateToEventDetails(eventData),
            );
          },
          childCount: _events.length,
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      color: const Color.fromARGB(255, 15, 20, 25),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 25, 30, 32),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 25,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: LoadingAnimationWidget.staggeredDotsWave(
            color: Colors.white,
            size: 80,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return SliverToBoxAdapter(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 25, 30, 32),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    size: 50,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Connection Error",
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "We couldn't load the events. Please check your internet connection and try again.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _refreshEvents,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1a237e),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh_rounded, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "Try Again",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.maybePop(context);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white70,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    "Go Back",
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    final displayName =
        _sportsmeetService.getCategoryDisplayName(widget.category);

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      color: const Color.fromARGB(255, 15, 20, 25),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 25, 30, 32),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 25,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.event_busy, size: 80, color: Colors.white70),
              const SizedBox(height: 20),
              const Text(
                "No Events Found",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "No events have been added for $displayName in ${widget.year}.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Events will appear here once they are added to the system.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToEventDetails(Map<String, dynamic> eventData) {
    final images = eventData['images'] as List<dynamic>?;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SportsmeetView(
          txts: eventData['title'] ?? '',
          images: images ?? [], 
          first: eventData['first'] ?? '',
          second: eventData['second'] ?? '',
          third: eventData['third'] ?? '',
          fourth: eventData['fourth'] ?? '',
          fifth: eventData['fifth'] ?? '',
          description: eventData['description'] ?? '',
        ),
      ),
    );
  }
}

class _EventCard extends StatefulWidget {
  final Map<String, dynamic> eventData;
  final String eventId;
  final VoidCallback onTap;

  const _EventCard({
    required this.eventData,
    required this.eventId,
    required this.onTap,
  });

  @override
  State<_EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<_EventCard> {
  late String _displayImage;
  bool _imageError = false;

  @override
  void initState() {
    super.initState();
    final images = widget.eventData['images'] as List<dynamic>?;
    _displayImage = images != null && images.isNotEmpty 
        ? images[0].toString()
        : 'https://i.ibb.co/Y7sbhNrV/f24fe5746117.jpg';
  }

  ImageProvider _getImageProvider() {
    if (_imageError) {
      return const NetworkImage('https://i.ibb.co/Y7sbhNrV/f24fe5746117.jpg');
    }

    return CachedNetworkImageProvider(
      _displayImage,
      errorListener: (err) => setState(() {
        _imageError = true;
        _displayImage = 'https://i.ibb.co/Y7sbhNrV/f24fe5746117.jpg';
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasWinner = (widget.eventData['first'] ?? '').isNotEmpty;
    final screenHeight = MediaQuery.of(context).size.height;

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(30.0),
      child: Hero(
        tag: _imageError 
            ? 'https://i.ibb.co/Y7sbhNrV/f24fe5746117.jpg' 
            : _displayImage,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              margin: EdgeInsets.symmetric(
                vertical: constraints.maxHeight * 0.02,
              ),
              height: constraints.maxHeight * 0.43,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: _getImageProvider(),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.eventData['title'] ?? 'Untitled Event',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenHeight * 0.022,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    if (hasWinner)
                      Row(
                        children: [
                          Icon(
                            Icons.emoji_events,
                            color: Colors.amber,
                            size: screenHeight * 0.02,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "${widget.eventData['first']}",
                              style: TextStyle(
                                color: Colors.amber,
                                fontSize: screenHeight * 0.018,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            color: Colors.white70,
                            size: screenHeight * 0.02,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Results pending",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: screenHeight * 0.018,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}