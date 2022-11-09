import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:developer' as developer;
import 'dart:convert';
import 'package:ocr_project/TransactionDetail.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool textScanning = false;

  XFile? imageFile;

  String scannedText = "";
  //TransactionDetail transactionDetail = new TransactionDetail();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Text Recognition"),
      ),
      body: Center(
          child: SingleChildScrollView(
            child: Container(
                margin: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (textScanning) const CircularProgressIndicator(),
                    if (!textScanning && imageFile == null)
                      Container(
                        width: 300,
                        height: 300,
                        color: Colors.grey[300]!,
                      ),
                    if (imageFile != null) Image.file(File(imageFile!.path)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            padding: const EdgeInsets.only(top: 10),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.white,
                                onPrimary: Colors.grey,
                                shadowColor: Colors.grey[400],
                                elevation: 10,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0)),
                              ),
                              onPressed: () {
                                getImage(ImageSource.gallery);
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 5),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.image,
                                      size: 30,
                                    ),
                                    Text(
                                      "Gallery",
                                      style: TextStyle(
                                          fontSize: 13, color: Colors.grey[600]),
                                    )
                                  ],
                                ),
                              ),
                            )),
                        Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            padding: const EdgeInsets.only(top: 10),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.white,
                                onPrimary: Colors.grey,
                                shadowColor: Colors.grey[400],
                                elevation: 10,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0)),
                              ),
                              onPressed: () {
                                getImage(ImageSource.camera);
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 5),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.camera_alt,
                                      size: 30,
                                    ),
                                    Text(
                                      "Camera",
                                      style: TextStyle(
                                          fontSize: 13, color: Colors.grey[600]),
                                    )
                                  ],
                                ),
                              ),
                            )),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      child: Text(
                        scannedText,
                        style: TextStyle(fontSize: 20),
                      ),
                    )
                  ],
                )),
          )),
    );
  }

  void getImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage != null) {
        textScanning = true;
        imageFile = pickedImage;
        setState(() {});
        getRecognisedText(pickedImage);
      }
    } catch (e) {
      textScanning = false;
      imageFile = null;
      scannedText = "Error occured while scanning";
      setState(() {});
    }
  }

  void getRecognisedText(XFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final textDetector = GoogleMlKit.vision.textDetector();
    RecognisedText recognisedText = await textDetector.processImage(inputImage);
    await textDetector.close();
    scannedText = "";
    String bank = recognisedText.blocks[0].lines[0].text;


    switch (bank){
      case "MPay" :
        // Map<String, dynamic> userMap = transactionDetail.toMap();
        // var user = jsonEncode(userMap);
        // print(user.toString());
        { MapDataValueForMpay(recognisedText);}

        break;
      case "MBOB":
        {MapDataValueForBob(recognisedText);}
        break;
      default: { print("Invalid"); }
      break;
    }

    textScanning = false;
    setState(() {});
  }
//bnb to bnb or bob???
  void MapDataValueForMpay(RecognisedText recognisedText) async{
    var index =0;
    var ocrValues= {};
    for (TextBlock block in recognisedText.blocks) {

      for (TextLine line in block.lines) {
        index++;
        if(index == 1){
          ocrValues['bank'] = line.text;
        }
        if(index == 3){
          ocrValues['amount'] = line.text;
        }
        if(index == 4){
          ocrValues['reference No.'] = line.text.substring(14);
        }
        if(index == 6){
          ocrValues['from A/C'] = line.text;
        }
        if(index == 9){
          ocrValues['to A/C'] = line.text;
        }
        if(index == 11){
          ocrValues['date'] = line.text.substring(6);
        }
        if(index == 13){
          ocrValues['time'] = line.text.substring(6);
        }
        if(index == 14){
          ocrValues['remark'] = line.text.substring(10);
        }
        scannedText = scannedText + line.text + "\n";

        //print(line.text);

      }
    }
    print(ocrValues);
  }
//Bob to Bob
  void MapDataValueForBob(RecognisedText recognisedText) async{
    var index =0;
    var ocrValuebob= {};
    for (TextBlock block in recognisedText.blocks) {

      for (TextLine line in block.lines) {
        index++;
        if(index == 1){
          ocrValuebob['bank'] = line.text;
        }
        if(index == 4){
          ocrValuebob['amount'] = line.text;
        }

        if(index == 6) {
          ocrValuebob['Jrnl. No'] = line.text;
        }

        if(index == 8) {
            ocrValuebob['RRNO.'] = line.text;
        }
        if(index == 10){
          ocrValuebob['From A/C'] = line.text;
        }
        if(index == 12){
          ocrValuebob['To A/C'] = line.text.substring(0,14);
        }
        if(index == 15){
          ocrValuebob['Purpose/Bill QR'] = line.text;
        }
        if(index == 17){
          ocrValuebob['Date'] = line.text;
        }

        scannedText = scannedText + line.text + "\n";

        //print(line.text);

      }
    }
    print(ocrValuebob);
  }

  @override
  void initState() {
    super.initState();
  }
}
