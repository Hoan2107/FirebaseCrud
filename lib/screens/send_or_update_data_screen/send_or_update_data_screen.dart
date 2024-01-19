import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class SendOrUpdateData extends StatefulWidget {
  final String name;
  final String age;
  final String email;
  final String id;
  final String location;
  const SendOrUpdateData(
      {this.name = '',
      this.age = '',
      this.email = '',
      this.id = '',
      this.location = ''});
  @override
  State<SendOrUpdateData> createState() => _SendOrUpdateDataState();
}

class _SendOrUpdateDataState extends State<SendOrUpdateData> {
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  bool showProgressIndicator = false;

  @override
  void initState() {
    nameController.text = widget.name;
    ageController.text = widget.age;
    emailController.text = widget.email;
    locationController.text = widget.location;
    super.initState();
  }

  Future<void> _getCurrentLocation() async {
    // Kiểm tra và yêu cầu quyền vị trí
    var locationStatus = await Permission.location.request();
    if (locationStatus.isGranted) {
      try {
        // Nếu quyền được cấp, lấy vị trí
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        setState(() {
          locationController.text =
              "(${position.latitude}, ${position.longitude})";
        });
      } catch (e) {
        print(e);
      }
    } else {
      // Nếu quyền bị từ chối, hiển thị thông báo cho người dùng
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Location permission denied. Please enable it in app settings.'),
          action: SnackBarAction(
            label: 'Open Settings',
            onPressed: () {
              openAppSettings();
            },
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    emailController.dispose();
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red.shade900,
        centerTitle: true,
        title: Text(
          'Send Data',
          style: TextStyle(fontWeight: FontWeight.w300),
        ),
      ),
      body: SingleChildScrollView(
        padding:
            EdgeInsets.symmetric(horizontal: 20).copyWith(top: 60, bottom: 200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(hintText: 'e.g. Zeeshan'),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Age',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            TextField(
              controller: ageController,
              decoration: InputDecoration(hintText: 'e.g. 25'),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Location',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: locationController,
                    decoration:
                        InputDecoration(hintText: 'Latitude, Longitude'),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _getCurrentLocation,
                  child: Text('Get Location'),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Email Address',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            TextField(
              controller: emailController,
              decoration:
                  InputDecoration(hintText: 'e.g. zeerockyf5@gmail.com'),
            ),
            SizedBox(
              height: 40,
            ),
            MaterialButton(
              onPressed: () async {
                setState(() {});
                if (nameController.text.isEmpty ||
                    ageController.text.isEmpty ||
                    locationController.text.isEmpty ||
                    emailController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Fill in all fields')));
                } else {
                  //reference to document
                  final dUser = FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.id.isNotEmpty ? widget.id : null);
                  String docID = '';
                  if (widget.id.isNotEmpty) {
                    docID = widget.id;
                  } else {
                    docID = dUser.id;
                  }
                  final jsonData = {
                    'name': nameController.text,
                    'age': int.parse(ageController.text),
                    'email': emailController.text,
                    'id': docID,
                    'location': locationController.text
                  };
                  showProgressIndicator = true;
                  if (widget.id.isEmpty) {
                    //create document and write data to firebase
                    await dUser.set(jsonData).then((value) {
                      nameController.text = '';
                      ageController.text = '';
                      emailController.text = '';
                      locationController.text = '';
                      showProgressIndicator = false;
                      setState(() {});
                    });
                  } else {
                    await dUser.update(jsonData).then((value) {
                      nameController.text = '';
                      ageController.text = '';
                      emailController.text = '';
                      locationController.text = '';
                      showProgressIndicator = false;
                      setState(() {});
                    });
                  }
                }
              },
              minWidth: double.infinity,
              height: 50,
              color: Colors.red.shade400,
              child: showProgressIndicator
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Submit',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w300),
                    ),
            )
          ],
        ),
      ),
    );
  }
}
