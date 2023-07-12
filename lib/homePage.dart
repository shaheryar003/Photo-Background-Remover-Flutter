import 'dart:io';
import 'dart:typed_data';

import 'package:background_remover/api.dart';
import 'package:background_remover/dottedborder.dart';
import 'package:before_after_image_slider_nullsafty/before_after_image_slider_nullsafty.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:screenshot/screenshot.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var loaded = false;
  var removebg = false;
  var isloading = false;
  Uint8List? image;
  ScreenshotController screenshotController = ScreenshotController();

  String imagePath = "";

  pickImage() async {
    final img = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 100);
    if (img != null) {
      imagePath = img.path;
      loaded = true;
      loaded = true;
      setState(() {});
    } else {}
  }

  downloadImage() async {
    final filename = "${DateTime.now().millisecondsSinceEpoch}.png";
    final permission = Permission.storage;
    final status = await permission.status;
    debugPrint('>>>Status $status');

    /// here it is coming as PermissionStatus.granted
    if (status != PermissionStatus.granted) {
      await permission.request();
      if (await permission.status.isGranted) {
        final path = Directory('/storage/emulated/0/DCIM/BG-Remover');

        ///perform other stuff to download file
        if (await path.exists()) {
          screenshotController.captureAndSave(path.path,
              delay: Duration(milliseconds: 100),
              fileName: filename,
              pixelRatio: 1.0);
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Saved to ${path.path}")));
        } else {
          await path.create();
          screenshotController.captureAndSave(path.path,
              delay: Duration(milliseconds: 100),
              fileName: filename,
              pixelRatio: 1.0);
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Saved to ${path.path}")));
        }
      } else {
        await permission.request();
      }
      debugPrint('>>> ${await permission.status}');
    }
    final path = Directory('/storage/emulated/0/DCIM/BG-Remover');

    await path.create();
    screenshotController.captureAndSave(path.path,
        delay: Duration(milliseconds: 100),
        fileName: filename,
        pixelRatio: 1.0);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Saved to ${path.path}")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.limeAccent.shade200,
        actions: [
          IconButton(
            onPressed: () {
              removebg
                  ? Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => HomePage()))
                  : null;
            },
            icon: Icon(Icons.home_filled),
            color: Colors.black,
          )
        ],
        title: const Text(
          "Background Remover",
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
        elevation: 0,
        centerTitle: true,
        leading: InkWell(
          onTap: () {
            QuickAlert.show(
                context: context,
                type: QuickAlertType.success,
                title: 'Version 1.0',
                text: 'Thankyou for using our services',
                confirmBtnColor: Colors.limeAccent.shade200,
                confirmBtnText: "Close",
                confirmBtnTextStyle: TextStyle(color: Colors.black));
          },
          child: const Icon(
            Icons.sort_rounded,
            color: Colors.black,
          ),
        ),
      ),
      body: Center(
          child: GestureDetector(
        onTap: () {
          pickImage();
        },
        child: removebg
            ? BeforeAfter(
                beforeImage: Image.file(File(imagePath)),
                afterImage: Screenshot(
                    controller: screenshotController,
                    child: Image.memory(image!)))
            : loaded
                ? Image.file(File(imagePath))
                : DottedBorderButton(
                    text: "Select Image",
                    ontap: () {
                      setState(() {
                        pickImage();
                      });
                    },
                  ),
      )),
      bottomNavigationBar: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.08,
          child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: loaded
                    ? MaterialStateProperty.all(Colors.limeAccent.shade200)
                    : MaterialStateProperty.all(Colors.grey.shade300),
              ),
              onPressed: loaded
                  ? () async {
                      setState(() {
                        isloading = true;
                      });
                      image = await Api.removeBg(imagePath);

                      if (image != null) {
                        removebg = true;
                        isloading = false;
                        setState(() {});
                      }
                    }
                  : null,
              child: isloading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    )
                  : const Text(
                      "REMOVE BACKGROUND",
                      style: TextStyle(color: Colors.black),
                    ))),
      floatingActionButton: removebg
          ? FloatingActionButton(
              elevation: 2,
              backgroundColor: Colors.limeAccent.shade200,
              tooltip: "Download",
              onPressed: () {
                downloadImage();
              },
              child: const Icon(
                Icons.download_for_offline_outlined,
                color: Colors.black,
              ),
            )
          : null,
    );
  }
}
