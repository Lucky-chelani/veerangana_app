import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
const MapScreen({super.key});

@override
State<MapScreen> createState() => _MapScreenState();


}

class _MapScreenState extends State<MapScreen>{
  LatLng myCurrentLocation = const LatLng(27.7172, 85.3248);
late GoogleMapController googleMapController;
Set<Marker> marker = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body: GoogleMap(
      //   myLocationButtonEnabled: false,
      //   markers: marker,
      //   onMapCreated: (GoogleMapController controller){
      //     googleMapController = controller;
      //   },
        
      //   initialCameraPosition: CameraPosition(
      //     target: myCurrentLocation,
      //     zoom: 14,
        
      //   )
        
      //   ),

        //updated button 
        body: Stack(
  children: [
    GoogleMap(
      myLocationButtonEnabled: false,
      markers: marker,
      onMapCreated: (GoogleMapController controller) {
        googleMapController = controller;
      },
      initialCameraPosition: CameraPosition(
        target: myCurrentLocation,
        zoom: 14,
      ),
    ),
    Positioned(
      bottom: 30,
      left: 20,
      right: 20,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.deepPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 6,
        ),
        icon: const Icon(Icons.my_location, size: 24, color: Colors.white),
        label: const Text(
          "Current Location",
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        onPressed: () async {
          Position position = await currentPosition();
          googleMapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
              zoom: 15,
              target: LatLng(position.latitude, position.longitude),
            ),
          ));
          marker.clear();
          marker.add(Marker(
            markerId: const MarkerId("This is my Location"),
            position: LatLng(position.latitude, position.longitude),
          ));
          setState(() {});
        },
      ),
    ),
  ],
),


        // floatingActionButton: FloatingActionButton(
        //   backgroundColor: Colors.white,
        //   onPressed: ()async{
        //     Position position = await currentPosition();
        //     googleMapController.animateCamera(CameraUpdate.newCameraPosition(
              
        //       CameraPosition(
        //         zoom: 15,
        //         target: LatLng(position.latitude, position.longitude),),),);
        //     marker.clear();
        //     marker.add(Marker(markerId: MarkerId("This is my Location"),
        //     position: LatLng(position.latitude, position.longitude)
            
        //     ),
        //     );
        //     setState(() {
              
        //     });

        //   },
        //   child: const Icon(Icons.my_location, size: 30,),
          
          
        //   ),



    );
   
  }

  Future<Position> currentPosition() async{
    bool serviceEnable;
     LocationPermission permission;

     serviceEnable  = await Geolocator.isLocationServiceEnabled();
     if(!serviceEnable){
      return Future.error("Error");
     }


     permission = await Geolocator.checkPermission();
     if(permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
      if(permission == LocationPermission.denied){
        return Future.error("Location permission denied");
      }

     if(permission == LocationPermission.deniedForever){
        return Future.error("Denied");
      }
     }
     Position position = await Geolocator.getCurrentPosition();
     return position;
  }



}