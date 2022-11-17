import 'dart:io';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:ocr_project/TransactionDetail.dart';
import 'package:ocr_project/TransactionDetails.dart';
import 'package:ocr_project/model/transaction.dart';
import 'package:ocr_project/pages/sortable_page.dart';
import 'package:ocr_project/widget/bottom_bar.dart';
import 'data/transactions.dart';
import 'utils/constants.dart';
import 'login_screens/login_screen.dart';


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
        scaffoldBackgroundColor: kBackgroundColor,
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: kPrimaryColor,
          fontFamily: 'Montserrat',
        ),
      ),
      //home: const MyHomePage(),
      home: const LoginScreen(),
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
  bool shadowColor = false;
  double? scrolledUnderElevation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text('Zap'),
        scrolledUnderElevation: scrolledUnderElevation,
        shadowColor:
        shadowColor ? Theme.of(context).colorScheme.shadow : null,
        backgroundColor: Color(0xDB4BE8CC),
        automaticallyImplyLeading: false,
      ),
      bottomNavigationBar: BottomNavBar(1),
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

    var startIndex = 0;
    var bankDetected = false;
     List<TextBlock> filteredBlocks = [];
    for (TextBlock block in recognisedText.blocks) {


      for (TextLine line in block.lines) {

        if(line.text == 'MPay' || line.text=='MBOB'){
          filteredBlocks =  recognisedText.blocks.sublist(startIndex);
          bankDetected = true;
          break;
        }
      }
      if(bankDetected){
        break;
      }
      startIndex++;
    }
    print(filteredBlocks);
    String bank = filteredBlocks[0].lines[0].text;

    switch (bank){
      case "MPay" :
        // Map<String, dynamic> userMap = transactionDetail.toMap();
        // var user = jsonEncode(userMap);
        // print(user.toString());
        { MapDataValueForMpay(filteredBlocks);}

        break;
      case "MBOB":
        {MapDataValueForBob(filteredBlocks);}
        break;
      default: {

        print("Invalid"); }
      break;
    }

    textScanning = false;
    setState(() {});
  }
//bnb to bnb or bob???
  void MapDataValueForMpay(List<TextBlock> filteredBlocks) async{
    var index =0;
    var ocrValues= {};
    for (TextBlock block in filteredBlocks) {

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
        if(index == 7){
          ocrValues['from A/C'] =  ocrValues['from A/C'] +", "+ line.text;
        }
        if(index == 9){
          ocrValues['to A/C'] = line.text;
        }
        if(index == 10){
          ocrValues['to A/C'] = ocrValues['to A/C']+", "+line.text;
        }
        if(index == 11){
          ocrValues['date'] = line.text.substring(6);
        }
        if(index == 12){
          ocrValues['date'] = ocrValues['date']+" "+line.text;
        }
        if(index == 13){
          ocrValues['time'] = line.text.substring(6);
        }
        if(index == 14){
          ocrValues['remark'] = line.text.substring(10);
        }
        scannedText = scannedText + line.text + "\n";

        print(line.text);

      }
    }
    print(ocrValues);
    Transaction transaction = new Transaction(id: allTransactions.length, bank: ocrValues["bank"], refrenceNumber: ocrValues["reference No."],rrno: "", amount: double.parse(ocrValues["amount"].substring(3)), fromAC: ocrValues["from A/C"], toAC: ocrValues["to A/C"],date: ocrValues["date"],time: ocrValues["time"], remark: ocrValues["remark"]);
    allTransactions.insert(0,transaction);
    Navigator.push(context, MaterialPageRoute(builder: (context) => TransactionDetails(transaction)));
  }
//Bob to Bob
  void MapDataValueForBob(List<TextBlock> filteredBlocks) async{
    var index =0;
    var ocrValuebob= {};
    //var jumpValues = false;
    for (TextBlock block in filteredBlocks) {

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

        if(index == 7 && line.text[0] == 'R'){
          //jumpValues = true;
          if(index == 8 || index == 9) {
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
        }
        // if(jumpValues){
        //
        //
        // }
        else{

          if(index == 8){
            ocrValuebob['From A/C'] = line.text;
          }
          if(index == 10){
            ocrValuebob['To A/C'] = line.text;
          }
          if(index == 12){
            ocrValuebob['Purpose/Bill QR'] = line.text;
          }
          if(index == 14){
            ocrValuebob['Date'] = line.text;
          }
        }

        scannedText = scannedText + line.text + "\n";

        //print(line.text);

      }
    }
    print(ocrValuebob);
    Transaction transaction = new Transaction(id: allTransactions.length, bank: ocrValuebob["bank"], refrenceNumber: ocrValuebob["Jrnl. No"],rrno: ocrValuebob["RRNO."], amount: double.parse(ocrValuebob["amount"].substring(3)), fromAC: ocrValuebob["From A/C"], toAC: ocrValuebob["To A/C"],date: ocrValuebob["Date"], remark: ocrValuebob["Purpose/Bill QR"],time:"");
    allTransactions.insert(0,transaction);
    Navigator.push(context, MaterialPageRoute(builder: (context) => TransactionDetails(transaction)));
  }

  @override
  void initState() {
    super.initState();
  }
}
