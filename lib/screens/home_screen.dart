import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veerangana/location_service.dart';
import 'package:veerangana/screens/donation.dart';
import 'package:veerangana/widgets/panicmode.dart';
import 'package:veerangana/widgets/sos.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:veerangana/ui/colors.dart';
import 'package:veerangana/sakhi/sakhi_chat_screen.dart';
import 'donate_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final LocationService _locationService = LocationService();
  final PanicModeService _panicModeService = PanicModeService();
  final sosService _sosService = sosService();
  String? userPhone;
  AnimationController? _animationController;

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  String? _recordingPath;
  
  // Button press states
  Map<String, bool> _buttonPressStates = {};

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

  // Open website URL
  Future<void> _launchWebsite() async {
    final Uri url = Uri.parse(''); // Replace with your actual website URL
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open the website'),
          backgroundColor: AppColors.deepBurgundy,
        ),
      );
    }
  }

  // Provide haptic feedback based on action type
  void _provideHapticFeedback(String actionType) async {
    if (await Vibration.hasVibrator() ?? false) {
      if (actionType == 'panic' || actionType == 'sos') {
        // Strong feedback for emergency actions
        Vibration.vibrate(pattern: [0, 100, 50, 100]); 
      } else if (actionType == 'recording') {
        // Medium feedback for recording actions
        Vibration.vibrate(duration: 60, amplitude: 180);
      } else {
        // Standard feedback for regular actions
        Vibration.vibrate(duration: 40, amplitude: 150);
      }
    }
  }

  Widget buildGridButton(String label, String assetPath, VoidCallback onTap, {bool isPulsing = false, String buttonType = 'standard'}) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isPressed = _buttonPressStates[label] ?? false;
        
        return GestureDetector(
          onTapDown: (_) {
            setState(() => _buttonPressStates[label] = true);
          },
          onTapUp: (_) {
            setState(() => _buttonPressStates[label] = false);
            _provideHapticFeedback(buttonType);
            onTap();
          },
          onTapCancel: () {
            setState(() => _buttonPressStates[label] = false);
          },
          child: AnimatedBuilder(
            animation: _animationController ?? const AlwaysStoppedAnimation(0),
            builder: (context, child) {
              return TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: isPressed ? 0.95 : 1.0),
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeInOut,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: isPulsing && _animationController != null
                                ? AppColors.raspberry.withOpacity(0.3 + _animationController!.value * 0.3)
                                : isPressed 
                                  ? Colors.black.withOpacity(0.05)
                                  : Colors.black.withOpacity(0.15),
                            blurRadius: isPressed ? 4 : 12,
                            offset: isPressed ? const Offset(0, 2) : const Offset(0, 6),
                            spreadRadius: isPressed ? 1 : 2,
                          ),
                        ],
                      ),
                      child: child,
                    ),
                  );
                },
                child: child,
              );
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(
                  color: isPulsing 
                      ? AppColors.raspberry 
                      : isPressed 
                          ? AppColors.deepBurgundy.withOpacity(0.4)
                          : Colors.transparent,
                  width: isPulsing ? 2.0 : isPressed ? 1.5 : 0.0,
                ),
              ),
              color: isPressed ? Colors.white.withOpacity(0.9) : Colors.white,
              elevation: isPressed ? 0 : 0, // Control elevation with the container shadow instead
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        height: 110,
                        width: 110,
                        child: Stack(
                          children: [
                            Image.asset(
                              assetPath,
                              height: 110,
                              width: 110,
                              fit: BoxFit.cover,
                            ),
                            if (isPressed)
                              Container(
                                height: 110,
                                width: 110,
                                color: Colors.white.withOpacity(0.2),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Flexible(
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isPressed ? AppColors.raspberry : AppColors.deepBurgundy,
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
    );
  }

  Widget buildDonateButton() {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isPressed = _buttonPressStates['donate'] ?? false;
        
        return GestureDetector(
          onTapDown: (_) {
            setState(() => _buttonPressStates['donate'] = true);
          },
          onTapUp: (_) {
            setState(() => _buttonPressStates['donate'] = true);
            _provideHapticFeedback('standard');
            // TODO: Implement donation logic
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DonateScreen()),
            );
          },
          onTapCancel: () {
            setState(() => _buttonPressStates['donate'] = false);
          },
          child: TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: isPressed ? 0.95 : 1.0),
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeInOut,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isPressed 
                          ? [AppColors.rosePink, AppColors.raspberry.withOpacity(0.8)]
                          : [AppColors.rosePink, AppColors.raspberry],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.raspberry.withOpacity(isPressed ? 0.3 : 0.5),
                        blurRadius: isPressed ? 8 : 15,
                        offset: isPressed ? const Offset(0, 2) : const Offset(0, 5),
                        spreadRadius: isPressed ? 0 : 1,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Donate to Support",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 0.5,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget buildWebsiteButton() {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isPressed = _buttonPressStates['website'] ?? false;
        
        return GestureDetector(
          onTapDown: (_) {
            setState(() => _buttonPressStates['website'] = true);
          },
          onTapUp: (_) {
            setState(() => _buttonPressStates['website'] = false);
            _provideHapticFeedback('standard');
            _launchWebsite();
          },
          onTapCancel: () {
            setState(() => _buttonPressStates['website'] = false);
          },
          child: TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: isPressed ? 0.95 : 1.0),
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeInOut,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isPressed 
                          ? [AppColors.deepBurgundy.withOpacity(0.8), AppColors.raspberry.withOpacity(0.8)]
                          : [AppColors.deepBurgundy, AppColors.raspberry],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.deepBurgundy.withOpacity(isPressed ? 0.3 : 0.5),
                        blurRadius: isPressed ? 8 : 15,
                        offset: isPressed ? const Offset(0, 2) : const Offset(0, 5),
                        spreadRadius: isPressed ? 0 : 1,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.language,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Visit Our Website",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 0.5,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Donation button
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const DonateScreen()));
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
                
                // Feature Grid with enhanced buttons - using non-scrolling GridView
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true, // Important to make grid work in SingleChildScrollView
                  physics: const NeverScrollableScrollPhysics(), // Disable grid scrolling
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
                    }, buttonType: 'panic'),
                    
                    buildGridButton("Police Contact", "assets/polic.png", () {
                      _makePhoneCall('100');
                    }, buttonType: 'emergency'),
                    
                    buildGridButton("SOS", "assets/sosbutton.png", () async {
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
                    }, buttonType: 'sos'),
                    
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
                      buttonType: 'recording',
                    ),
                    
                    buildGridButton("Video Recording", "assets/videobutton.png", () {
                      _recordVideo();
                    }, buttonType: 'recording'),
                    
                    // Sakhi AI Bot button
                    buildGridButton("Sakhi AI Bot", "assets/aibot.png", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SakhiChatScreen()),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Launching Sakhi - Your personal AI guide!'),
                          backgroundColor: AppColors.rosePink,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }, buttonType: 'standard'),

                    buildGridButton("Women Helpline", "assets/helpline.png", () {
                      _makePhoneCall('1090');
                    }, buttonType: 'emergency'),
                    
                    
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
                
                // Add extra space and then the website button at the very bottom
                const SizedBox(height: 40),
                
                // Website button section with divider for visual separation
                Column(
                  children: [
                    const Divider(
                      color: AppColors.deepBurgundy,
                      thickness: 0.5,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Want to learn more about Veerangana?",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.deepBurgundy,
                      ),
                    ),
                    const SizedBox(height: 16),
                    buildWebsiteButton(),
                    const SizedBox(height: 20), // Add bottom padding
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