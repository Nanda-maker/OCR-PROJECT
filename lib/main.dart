import 'dart:async';
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
import 'package:ocr_project/utils/common.dart';
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
  //late Size _imageSize;
 // List<TextElement> _elements = [];
  //late File _file;
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
                // child: CustomPaint(
                //   foregroundPainter:
                //   TextDetectorPainter(_imageSize, _elements),
                //   child: AspectRatio(
                //     aspectRatio: _imageSize.aspectRatio,
                //     child: Image.file(
                //       File(path),
                //     ),
                //   ),
                // ),
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
  // Future<void> _getImageSize(XFile imageFile) async {
  //   final Completer<Size> completer = Completer<Size>();
  //
  //   final Image image = Image.file(File(imageFile!.path));
  //   image.image.resolve(const ImageConfiguration()).addListener(
  //     ImageStreamListener((ImageInfo info, bool _) {
  //       completer.complete(Size(
  //         info.image.width.toDouble(),
  //         info.image.height.toDouble(),
  //       ));
  //     }),
  //   );
  //
  //   final Size imageSize = await completer.future;
  //   setState(() {
  //     _imageSize = imageSize;
  //   });
  // }


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

    List<String> recognisedTexts = [];
    var bankDetected = false;
    List<TextBlock> filteredBlocks = [];
    for (TextBlock block in recognisedText.blocks) {
      for (TextLine line in block.lines) {
        if(line.text == 'MPay' || line.text=='MBOB') {
          filteredBlocks = recognisedText.blocks.sublist(startIndex);
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
    for(TextBlock block in filteredBlocks){
      for(TextLine line in block.lines){
          recognisedTexts.add(line.text);

      }
    }

    switch (bank){
      case "MPay" :
        // Map<String, dynamic> userMap = transactionDetail.toMap();
        // var user = jsonEncode(userMap);
        // print(user.toString());
        { MapDataValueForMpay(recognisedTexts);}

        break;
      case "MBOB":
        {MapDataValueForBob(recognisedTexts);}
        break;
      default: {

        print("Invalid"); }
      break;
    }

    textScanning = false;
    setState(() {});
  }
//bnb to bnb or bob???
  void MapDataValueForMpay(List<String> recognisedTexts) async{
    var ocrValueMpay= {};
    List<String> listLabels = ["Reference","RRN","From","To","Date","Time","Remarks"];

    for(String label in listLabels ){
      test(String value) => value.replaceAll(" ", "").toLowerCase().contains(label.replaceAll(" ", '').toLowerCase());
      if(recognisedTexts.any(test)){
        final index = recognisedTexts.indexWhere((text) =>  text.replaceAll(" ", "").toLowerCase().contains(label.replaceAll(" ", '').toLowerCase())); // 1

        ocrValueMpay[label] = recognisedTexts.elementAt(index+1);
      }
    }

    print(recognisedTexts);
    print(ocrValueMpay);
  }


  //   var index =0;
  //   var ocrValues= {};
  //   for (TextBlock block in filteredBlocks) {
  //
  //     for (TextLine line in block.lines) {
  //       index++;
  //       if(index == 1){
  //         ocrValues['bank'] = line.text;
  //       }
  //       if(index == 3){
  //         ocrValues['amount'] = line.text;
  //       }
  //       if(index == 4){
  //         ocrValues['reference No.'] = line.text.substring(14);
  //       }
  //       if(index == 6){
  //         ocrValues['from A/C'] = line.text;
  //       }
  //       if(index == 7){
  //         ocrValues['from A/C'] =  ocrValues['from A/C'] +", "+ line.text;
  //       }
  //       if(index == 9){
  //         ocrValues['to A/C'] = line.text;
  //       }
  //       if(index == 10){
  //         ocrValues['to A/C'] = ocrValues['to A/C']+", "+line.text;
  //       }
  //       if(index == 11){
  //         ocrValues['date'] = line.text.substring(6);
  //       }
  //       if(index == 12){
  //         ocrValues['date'] = ocrValues['date']+" "+line.text;
  //       }
  //       if(index == 13){
  //         ocrValues['time'] = line.text.substring(6);
  //       }
  //       if(index == 14){
  //         ocrValues['remark'] = line.text.substring(10);
  //       }
  //       scannedText = scannedText + line.text + "\n";
  //       // for (TextElement element in line.elements) {
  //       //   _elements.add(element);
  //       // }
  //
  //       print(line.text.replaceAll(" ", ''));
  //
  //     }
  //   }
  //   print(ocrValues);
  //   Transaction transaction = new Transaction(id: allTransactions.length, bank: ocrValues["bank"], refrenceNumber: ocrValues["reference No."],rrno: "", amount: double.parse(ocrValues["amount"].substring(3)), fromAC: ocrValues["from A/C"], toAC: ocrValues["to A/C"],date: ocrValues["date"],time: ocrValues["time"], remark: ocrValues["remark"]);
  //   allTransactions.insert(0,transaction);
  //   Navigator.push(context, MaterialPageRoute(builder: (context) => TransactionDetails(transaction)));
  // }
//Bob to Bob
  void MapDataValueForBob(List<String> recognisedTexts) async{
    var ocrValuebob= {};
    List<String> listLabels = ["Jrnl.No","RRNO","From","To","Purpose","Date"];

    for(String label in listLabels ){
      test(String value) => value.replaceAll(" ", "").toLowerCase().contains(label.replaceAll(" ", '').toLowerCase());
      if(recognisedTexts.any(test)){
        final index = recognisedTexts.indexWhere((text) =>  text.replaceAll(" ", "").toLowerCase().contains(label.replaceAll(" ", '').toLowerCase())); // 1

        ocrValuebob[label] = recognisedTexts.elementAt(index+1);
      }
    }
  
    print(recognisedTexts);
    print(ocrValuebob);
   // Transaction transaction = new Transaction(id: allTransactions.length, bank: ocrValuebob["bank"], refrenceNumber: ocrValuebob["Jrnl. No"],rrno: ocrValuebob["RRNO."], amount: double.parse(ocrValuebob["amount"].substring(3)), fromAC: ocrValuebob["From A/C"], toAC: ocrValuebob["To A/C"],date: ocrValuebob["Date"], remark: ocrValuebob["Purpose/Bill QR"],time:"");
   // allTransactions.insert(0,transaction);
    //Navigator.push(context, MaterialPageRoute(builder: (context) => TransactionDetails(transaction)));
  }


  @override
  void initState() {
    super.initState();
  }
}


// class TextDetectorPainter extends CustomPainter {
//   TextDetectorPainter(this.absoluteImageSize, this.elements);
//
//   final Size absoluteImageSize;
//   final List<TextElement> elements;
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final double scaleX = size.width / absoluteImageSize.width;
//     final double scaleY = size.height / absoluteImageSize.height;
//
//     Rect scaleRect(TextContainer container) {
//       return Rect.fromLTRB(
//         container.boundingBox.left * scaleX,
//         container.boundingBox.top * scaleY,
//         container.boundingBox.right * scaleX,
//         container.boundingBox.bottom * scaleY,
//       );
//     }
//
//     final Paint paint = Paint()
//       ..style = PaintingStyle.stroke
//       ..color = Colors.red
//       ..strokeWidth = 2.0;
//
//     for (TextElement element in elements) {
//       canvas.drawRect(scaleRect(element), paint);
//     }
//   }
//
//   @override
//   bool shouldRepaint(TextDetectorPainter oldDelegate) {
//     return true;
//   }
// }
