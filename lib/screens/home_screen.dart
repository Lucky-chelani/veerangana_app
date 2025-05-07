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
//import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocationService _locationService = LocationService();
  final PanicModeService _panicModeService = PanicModeService();
  final sosService _sosService = sosService();
  String? userPhone;

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  String? _recordingPath;

  @override
  void initState() {
    super.initState();
    _fetchUserPhoneAndTrackLocation();
    _initRecorder();
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
      SnackBar(content: Text('Video saved at: ${savedVideo.path}')),
    );
  }

//voice Recording
  Future<void> _startRecording() async {
    final micStatus = await Permission.microphone.request();

    if (micStatus != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please grant microphone permission')),
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
  }

  Future<void> _stopRecording() async {
    if (_recorder.isStopped) return;

    await _recorder.stopRecorder();
    setState(() => _isRecording = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Recording saved at: $_recordingPath')),
    );
  }

//police contact
  Future<void> _makePhoneCall(String phoneNumber) async {
    bool? res = await FlutterPhoneDirectCaller.callNumber(phoneNumber);
    if (res == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not make the phone call'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget buildGridButton(String label, String assetPath, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () async {
        if (await Vibration.hasVibrator() ?? false) {
          Vibration.vibrate(duration: 40); // short, subtle
        }
        onTap(); // your button action
      },

      // onTap: () {
      //   HapticFeedback
      //       .lightImpact(); // native, works even without vibration permission
      //   onTap();
      // },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
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
                    color: Color.fromARGB(255, 137, 6, 160),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          elevation: 6,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false, // <- This removes the back arrow
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF9C27B0), Color(0xFFE040FB)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
          ),
          centerTitle: true,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Women Safety App",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                "Your safety, our priority",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // TODO: Implement donation logic or link
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                textStyle: TextStyle(fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text("Donate"),
            ),
            SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  // Your builderButtons go here

                  buildGridButton("Panic Mode", "assets/download.png",
                      () async {
                    if (userPhone != null) {
                      await _panicModeService.activatePanicMode(userPhone!);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('User phone number not found.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }),
                  buildGridButton("Police Contact", "assets/download (1).png",
                      () {
                    _makePhoneCall('100');
                  }),
buildGridButton("SOS", "assets/download (2).png", () async {
  if (userPhone != null) {
    await _sosService.activateSosMode(userPhone!); // Call the SOS service
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('SOS message sent to emergency contacts.'),
        backgroundColor: Colors.green,
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('User phone number not found.'),
        backgroundColor: Colors.red,
      ),
    );
  }
}),
                  buildGridButton("Voice Recording", "assets/download (4).png",
                      () async {
                    if (_isRecording) {
                      await _stopRecording();
                    } else {
                      await _startRecording();
                    }
                  }),
                  buildGridButton("Video Recording", "assets/download (5).png",
                      () {
                    _recordVideo();
                    // TODO: implement video recording logic
                  }),
                ],
              ),
            ),
          ],
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
