import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veerangana/location_service.dart';
import 'package:veerangana/widgets/panicmode.dart';
import 'package:veerangana/widgets/sos.dart';
import '../widgets/custom_bottom_nav.dart';
import 'map_screen.dart';
import 'contacts.dart';
import 'details.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:veerangana/ui/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final LocationService _locationService = LocationService();
  final PanicModeService _panicModeService = PanicModeService();
  final sosService _sosService = sosService();
  String? userPhone;
  AnimationController? _animationController;

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  String? _recordingPath;

  @override
  void initState() {
    super.initState();
    _fetchUserPhoneAndTrackLocation();
    _initRecorder();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  Future<void> _initRecorder() async {
    await _recorder.openRecorder();
  }

  Future<void> _fetchUserPhoneAndTrackLocation() async {
    final prefs = await SharedPreferences.getInstance();
    userPhone = prefs.getString('userPhone');
    if (userPhone != null) {
      try {
        await _locationService.initializeLocationTracking(userPhone!);
      } catch (e) {
        print('Error initializing location tracking: $e');
      }
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MapScreen()),
        ).then((_) {
          setState(() {
            _selectedIndex = 0;
          });
        });
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  EmergencyContactScreen(userPhone: userPhone ?? '')),
        ).then((_) {
          setState(() {
            _selectedIndex = 0;
          });
        });
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => DetailsScreen(phone: userPhone ?? '')),
        ).then((_) {
          setState(() {
            _selectedIndex = 0;
          });
        });
        break;
    }
  }

  //Video Recording
  Future<void> _recordVideo() async {
    final cameraStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();

    if (cameraStatus != PermissionStatus.granted ||
        micStatus != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Camera and microphone permissions are required')),
      );
      await openAppSettings();
      return;
    }

    final picker = ImagePicker();
    final XFile? videoFile = await picker.pickVideo(source: ImageSource.camera);

    if (videoFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video recording cancelled')),
      );
      return;
    }

    final savePath = await getVideoSavePath();
    final File savedVideo = await File(videoFile.path).copy(savePath);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Video saved at: ${savedVideo.path}'),
        backgroundColor: AppColors.raspberry,
      ),
    );
  }

  //voice Recording
  Future<void> _startRecording() async {
    final micStatus = await Permission.microphone.request();

    if (micStatus != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please grant microphone permission'),
          backgroundColor: AppColors.deepBurgundy,
        ),
      );
      await openAppSettings();
      return;
    }

    final path = await getRecordingPath();
    await _recorder.startRecorder(toFile: path, codec: Codec.aacMP4);

    setState(() {
      _isRecording = true;
      _recordingPath = path;
    });

    print('Recording started at: $path');
    
    // Start pulsing animation when recording
    _animationController?.repeat(reverse: true);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Recording started...'),
        backgroundColor: AppColors.raspberry,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _stopRecording() async {
    if (_recorder.isStopped) return;

    await _recorder.stopRecorder();
    _animationController?.stop();
    _animationController?.reset();
    
    setState(() => _isRecording = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Recording saved at: $_recordingPath'),
        backgroundColor: AppColors.rosePink,
      ),
    );
  }

  //police contact
  Future<void> _makePhoneCall(String phoneNumber) async {
    bool? res = await FlutterPhoneDirectCaller.callNumber(phoneNumber);
    if (res == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not make the phone call'),
          backgroundColor: AppColors.deepBurgundy,
        ),
      );
    }
  }

  Widget buildGridButton(String label, String assetPath, VoidCallback onTap, {bool isPulsing = false}) {
    return GestureDetector(
      onTap: () async {
        if (await Vibration.hasVibrator() ?? false) {
          Vibration.vibrate(duration: 40); // short, subtle
        }
        onTap();
      },
      child: AnimatedBuilder(
        animation: _animationController ?? const AlwaysStoppedAnimation(0),
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: isPulsing && _animationController != null
                      ? AppColors.raspberry.withOpacity(0.3 + _animationController!.value * 0.3)
                      : Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: child,
          );
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isPulsing ? AppColors.raspberry : Colors.transparent,
              width: isPulsing ? 2.0 : 0.0,
            ),
          ),
          color: Colors.white,
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(
                    assetPath,
                    height: 110,
                    width: 110,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.deepBurgundy,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),

                // Recording indicator
                if (label == "Voice Recording" && _isRecording)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          "REC",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          elevation: 8,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.rosePink, AppColors.raspberry],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
          ),
          centerTitle: true,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Text(
                "Women Safety App",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Your safety, our priority",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.lightPeach, AppColors.salmonPink],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Donation button
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement donation logic or link
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.raspberry,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.favorite, size: 20),
                      SizedBox(width: 8),
                      Text("Donate to Support"),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Section header
              const Padding(
                padding: EdgeInsets.only(left: 8.0, bottom: 12.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Safety Features",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepBurgundy,
                    ),
                  ),
                ),
              ),
              
              // Feature Grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    buildGridButton("Panic Mode", "assets/panic.png", () async {
                      if (userPhone != null) {
                        await _panicModeService.activatePanicMode(userPhone!);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Panic mode activated!'),
                            backgroundColor: AppColors.raspberry,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('User phone number not found.'),
                            backgroundColor: AppColors.deepBurgundy,
                          ),
                        );
                      }
                    }),
                    
                    buildGridButton("Police Contact", "assets/polic.png", () {
                      _makePhoneCall('100');
                    }),
                    
                    buildGridButton("SOS", "assets/sos.png", () async {
                      if (userPhone != null) {
                        await _sosService.activateSosMode(userPhone!);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('SOS message sent to emergency contacts.'),
                            backgroundColor: AppColors.raspberry,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('User phone number not found.'),
                            backgroundColor: AppColors.deepBurgundy,
                          ),
                        );
                      }
                    }),
                    
                    buildGridButton(
                      "Voice Recording", 
                      "assets/audioe.png",
                      () async {
                        if (_isRecording) {
                          await _stopRecording();
                        } else {
                          await _startRecording();
                        }
                      },
                      isPulsing: _isRecording,
                    ),
                    
                    buildGridButton("Video Recording", "assets/video.png", () {
                      _recordVideo();
                    }),
                    
                    buildGridButton("Safe Safar", "assets/travel.png", () {
                      // TODO: Implement safe safar feature
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Safe Safar feature coming soon!'),
                          backgroundColor: AppColors.rosePink,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reset selected index when returning to HomeScreen
    if (_selectedIndex != 0) {
      setState(() {
        _selectedIndex = 0;
      });
    }
  }
}

Future<String> getRecordingPath() async {
  final dir = await getExternalStorageDirectory();
  final path = '${dir!.path}/Recordings';
  final folder = Directory(path);
  if (!await folder.exists()) {
    await folder.create(recursive: true);
  }
  return '$path/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
}

Future<String> getVideoSavePath() async {
  final dir = await getExternalStorageDirectory();
  final videoDir = Directory('${dir!.path}/Videos');
  if (!await videoDir.exists()) {
    await videoDir.create(recursive: true);
  }
  return '${videoDir.path}/video_${DateTime.now().millisecondsSinceEpoch}.mp4';
}