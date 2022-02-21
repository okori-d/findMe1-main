import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as Location;
import 'package:location/location.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

void main() async {
  final client = StreamChatClient(
    'ws37nuwk249r',
    logLevel: Level.INFO,
  );

  await client.connectUser(
    User(id: 'jecxi256'),
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiamVjeGkyNTYifQ.XDxtfrT1oPmaIipKGb0O4d0KbHZ_zs0iWT9VUzL-fC0',
  );

  runApp(
    MyAppx(
      client: client,
    ),
  );
}

class MyAppx extends StatelessWidget {
  const MyAppx({
    Key? key,
    required this.client,
  }) : super(key: key);

  final StreamChatClient client;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      primarySwatch: Colors.green,
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      builder: (context, child) => StreamChat(
        client: client,
        child: child,
      ),
      home: const ChannelListPage(),
    );
  }
}

class ChannelListPage extends StatelessWidget {
  const ChannelListPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Campus Homie'),
        backgroundColor: Colors.green,
      ),
      body: ChannelsBloc(
        child: ChannelListView(
          filter: Filter.in_(
            'members',
            [StreamChat.of(context).currentUser!.id],
          ),
          sort: const [SortOption('last_message_at')],
          limit: 20,
          channelWidget: const ChannelPage(),
        ),
      ),
    );
  }
}

class ChannelPage extends StatefulWidget {
  const ChannelPage({Key? key}) : super(key: key);

  @override
  _ChannelPageState createState() => _ChannelPageState();
}


class _ChannelPageState extends State<ChannelPage> {
  Location.Location? location;
  StreamSubscription<LocationData>? locationSubscription;
  GlobalKey<MessageInputState> _messageInputKey = GlobalKey();
  late Channel _channel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _channel = StreamChannel.of(context).channel;
  }

  Future<bool> setupLocation() async {
    // ignore: prefer_conditional_assignment
    if (location == null) {
      location = Location.Location();
    }
    var _serviceEnabled = await location!.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location!.requestService();
      if (!_serviceEnabled) {
        return false;
      }
    }

    var _permissionGranted = await location!.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location!.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  Future<void> onLocationRequestPressed() async {
    final canSendLocation = await setupLocation();
    if (canSendLocation != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "We can't access your location at this time. Did you allow location access?"),
        ),
      );
    }

    final locationData = await location!.getLocation();
    _messageInputKey.currentState?.addAttachment(
      Attachment(
        type: 'location',
        uploadState: UploadState.success(),
        extraData: {
          'lat': locationData.latitude,
          'long': locationData.longitude,
        },
      ),
    );
    return;
  }

  Future<void> startLocationTracking(
    String messageId,
    String attachmentId,
  ) async {
    final canSendLocation = await setupLocation();
    if (canSendLocation != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "We can't access your location at this time. Did you allow location access?"),
        ),
      );
    }

    locationSubscription = location!.onLocationChanged.listen(
      (LocationData event) {
        _channel.sendEvent(
          Event(
            type: 'location_update',
            extraData: {
              'lat': event.latitude,
              'long': event.longitude,
            },
          ),
        );
      },
    );

    return;
  }

  void cancelLocationSubscription() => locationSubscription?.cancel();

  Widget _buildLocationMessage(
    BuildContext context,
    Message details,
    List<Attachment> _,
  ) {
    final username = details.user!.name;
    final lat = details.attachments.first.extraData['lat'] as double;
    final long = details.attachments.first.extraData['long'] as double;
    return InkWell(
      onTap: () {
        startLocationTracking(details.id, details.attachments.first.id);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => GoogleMapsView(
              onBack: cancelLocationSubscription,
              message: details,
              channelName: username,
              channel: _channel,
            ),
          ),
        );
      },
      child: wrapAttachmentWidget(
        context,
        MapImageThumbnail(
          lat: lat,
          long: long,
        ),
        RoundedRectangleBorder(),
        true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ChannelHeader(),
      body: Column(
        children: <Widget>[
          Expanded(
            child: MessageListView(
              key: _messageInputKey,
               //customAttachmentBuilders: {'location': _buildLocationMessage},
            ),
          ),
          MessageInput(
            key: _messageInputKey,
            attachmentThumbnailBuilders: {
              'location': (context, attachment) => MapImageThumbnail(
                    lat: attachment.extraData['lat'] as double,
                    long: attachment.extraData['long'] as double,
                  )
            },
            actions: [
              IconButton(
                icon: Icon(Icons.location_history),
                onPressed: onLocationRequestPressed,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MapImageThumbnail extends StatelessWidget {
  const MapImageThumbnail({
    Key? key,
    required this.lat,
    required this.long,
  }) : super(key: key);

  final double lat;
  final double long;

  String get _constructUrl => Uri(
        scheme: 'https',
        host: 'maps.googleapis.com',
        port: 443,
        path: '/maps/api/staticmap',
        queryParameters: {
          'center': '$lat,$long',
          'zoom': '18',
          'size': '700x500',
          'maptype': 'roadmap',
          'key': 'AIzaSyCX7vI-UAjpQsj4o2cjlm4VHKlwntoFXRs',
          'markers': 'color:red|$lat,$long'
        },
      ).toString();

  @override
  Widget build(BuildContext context) {
    return Image.network(
      _constructUrl,
      height: 300.0,
      width: 600.0,
      fit: BoxFit.fill,
    );
  }
}

class GoogleMapsView extends StatefulWidget {
  const GoogleMapsView({
    Key? key,
    required this.channelName,
    required this.message,
    required this.channel,
    required this.onBack,
  }) : super(key: key);
  final String channelName;
  final Message message;
  final Channel channel;
  final VoidCallback onBack;

  @override
  _GoogleMapsViewState createState() => _GoogleMapsViewState();
}

class _GoogleMapsViewState extends State<GoogleMapsView> {
  late StreamSubscription _messageSubscription;
  late double lat;
  late double long;

  GoogleMapController? mapController;

  Attachment get _messageAttachment => widget.message.attachments.first;

  @override
  void initState() {
    super.initState();
    lat = _messageAttachment.extraData['lat'] as double;
    long = _messageAttachment.extraData['long'] as double;
    _messageSubscription =
        widget.channel.on('location_update').listen(_updateHandler);
  }

  @override
  void dispose() {
    super.dispose();
    _messageSubscription.cancel();
  }

  void _updateHandler(Event event) {
    double _newLat = event.extraData['lat'] as double;
    double _newLong = event.extraData['long'] as double;

    setState(() {
      lat = _newLat;
      long = _newLong;
    });

    mapController?.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(
          _newLat,
          _newLong,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var _pos = LatLng(lat, long);
    return WillPopScope(
      onWillPop: () async {
        widget.onBack();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.channelName,
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.white,
        ),
        body: AnimatedCrossFade(
          duration: kThemeAnimationDuration,
          crossFadeState: mapController != null
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: ConstrainedBox(
            constraints: BoxConstraints.loose(MediaQuery.of(context).size),
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _pos,
                zoom: 18,
              ),
              onMapCreated: (_controller) =>
                  setState(() => mapController = _controller),
              markers: {
                Marker(
                  markerId: MarkerId("user-location-marker-id"),
                  position: _pos,
                )
              },
            ),
          ),
          secondChild: Container(
            child: Center(
              child: Icon(
                Icons.location_history,
                color: Colors.red.withOpacity(0.76),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
