import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:edge_detection/edge_detection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Labs extractor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Labs extractor - by Thomas Reyes'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //String _urlControllerReplace = '';
  late TextEditingController _formattedTextController;
  String _ocrText = '';
  String _formattedText = '';
  bool bForm = false;
  String _ocrHocr = '';
  // Map<String, String> tessimgs = {
  //   "kor":
  //       "https://raw.githubusercontent.com/khjde1207/tesseract_ocr/master/example/assets/test1.png",
  //   "en": "https://tesseract.projectnaptha.com/img/eng_bw.png",
  //   "ch_sim": "https://tesseract.projectnaptha.com/img/chi_sim.png",
  //   "ru": "https://tesseract.projectnaptha.com/img/rus.png",
  // };
  //var LangList = ["kor", "eng", "deu", "chi_sim"];
  //var selectList = ["eng"];
  String path = "";
  bool bload = false;

  bool bDownloadtessFile = false;
  // "https://img1.daumcdn.net/thumb/R1280x0/?scode=mtistory2&fname=https%3A%2F%2Fblog.kakaocdn.net%2Fdn%2FqCviW%2FbtqGWTUaYLo%2FwD3ZE6r3ARZqi4MkUbcGm0%2Fimg.png";
  // var urlEditController = TextEditingController()
  //   ..text = "https://tesseract.projectnaptha.com/img/eng_bw.png";

  Future<void> writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return new File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  void runFilePiker() async {
    String? imagePath;

    // android && ios only
    if (kIsWeb) {
    } else {
      final pickedFile =
          await ImagePicker().getImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _imagePath = pickedFile.path;
        //_ocr(_imagePath);
      }
    }
    if (imagePath != null) {
      _imagePath = imagePath;
    }
    setState(() {});
  }

  void _ocr(url) async {
    // if (selectList.length <= 0) {
    //   print("Please select language");
    //   return;
    // }
    path = url;
    if (kIsWeb == false &&
        (url.indexOf("http://") == 0 || url.indexOf("https://") == 0)) {
      Directory tempDir = await getTemporaryDirectory();
      HttpClient httpClient = new HttpClient();
      HttpClientRequest request = await httpClient.getUrl(Uri.parse(url));
      HttpClientResponse response = await request.close();
      Uint8List bytes = await consolidateHttpClientResponseBytes(response);
      String dir = tempDir.path;
      print('$dir/test.jpg');
      File file = new File('$dir/test.jpg');
      await file.writeAsBytes(bytes);
      url = file.path;
    }
    //var langs = selectList.join("+");

    bload = true;
    bForm = false;
    setState(() {});

    _ocrText =
        await FlutterTesseractOcr.extractText(url, language: "eng", args: {
      "preserve_interword_spaces": "1",
    });
    //  ========== Test performance  ==========
    // DateTime before1 = DateTime.now();
    // print('init : start');
    // for (var i = 0; i < 10; i++) {
    //   _ocrText =
    //       await FlutterTesseractOcr.extractText(url, language: langs, args: {
    //     "preserve_interword_spaces": "1",
    //   });
    // }
    // DateTime after1 = DateTime.now();
    // print('init : ${after1.difference(before1).inMilliseconds}');
    //  ========== Test performance  ==========

    // _ocrHocr =
    //     await FlutterTesseractOcr.extractHocr(url, language: langs, args: {
    //   "preserve_interword_spaces": "1",
    // });
    // print(_ocrText);
    // print(_ocrText);

    // === web console test code ===
    // var worker = Tesseract.createWorker();
    // await worker.load();
    // await worker.loadLanguage("eng");
    // await worker.initialize("eng");
    // // await worker.setParameters({ "tessjs_create_hocr": "1"});
    // var rtn = worker.recognize("https://tesseract.projectnaptha.com/img/eng_bw.png");
    // console.log(rtn.data);
    // await worker.terminate();
    // === web console test code ===

    bload = false;
    setState(() {});
  }

  String? _imagePath;
  @override
  void initState() {
    super.initState();
    _formattedTextController = TextEditingController();
  }

  @override
  void dispose() {
    _formattedTextController.dispose();
    super.dispose();
  }

  Future<void> getImage() async {
    String? imagePath;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      imagePath = (await EdgeDetection.detectEdge);
      print("$imagePath");
    } on PlatformException catch (e) {
      imagePath = e.toString();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _imagePath = imagePath;
      //_urlControllerReplace = imagePath!;
    });
  }

  @override
  Widget build(BuildContext context) {
    var formatOCRButton = ElevatedButton(
        onPressed: () {
          if (_ocrText != null) {
            String getCBC(
                String start, String end, String source, String shorthand) {
              int startLength = start.length;
              var startIndex = source.indexOf(start);

              if (startIndex == -1) return "";

              var value = '';
              bool numberfoundFlag = false;
              int spacesFound = 0;
              bool spaceFoundYet = false;
              for (var i = startIndex + startLength;
                  source.substring(i, i + 1) != "\n";
                  i++) {
                var currentChar = source.substring(i, i + 1);

                bool isNumeric(String s) {
                  if (s == null) {
                    return false;
                  }
                  if (s == ".") {
                    return true;
                  }
                  return double.tryParse(s) != null;
                }

                if (!spaceFoundYet && currentChar == " ") {
                  spaceFoundYet = true;
                  spacesFound++;
                } else if (currentChar == " ") {
                  spacesFound++;
                } else {}
                var spaceThresh = 0;
                if (spaceFoundYet && spacesFound > spaceThresh) {
                  if (currentChar == "-" || currentChar == "+") {
                    value += currentChar;
                    var nextChar = source.substring(i + 1, i + 2);
                    if (!isNumeric(nextChar)) {
                      break;
                    }
                  }
                  if (isNumeric(currentChar)) {
                    numberfoundFlag = true;
                    value += currentChar;
                  } else if (numberfoundFlag) {
                    break;
                  }
                }
                //print(currentChar);
              }
              if (value == '') {
                return "";
              } else {
                return (shorthand + " " + value + ", ");
              }
            }

            String onlyReturnOne(List<String> labsArray) {
              String labsReturned = "";
              for (var result in labsArray) {
                if (result != "") {
                  labsReturned = result;
                  break;
                }
              }
              return labsReturned;
            }

            String capture(
                String start, String end, String input, String shorthand) {
              final startIndex = input.indexOf(start);
              final endIndex = input.indexOf(end, startIndex + start.length);
              if (startIndex == -1) {
                return "";
              } else {
                return shorthand +
                    input
                        .substring(startIndex + start.length, endIndex)
                        .replaceAll(new RegExp(r'[^0-9.]'), '') +
                    ", ";
                ;
              }
            }

            String captureText(
                String start, String end, String input, String shorthand) {
              final startIndex = input.indexOf(start);
              final endIndex = input.indexOf(end, startIndex + start.length);
              if (startIndex == -1) {
                return "";
              } else {
                return shorthand +
                    input.substring(startIndex + start.length, endIndex).trim();
                ;
              }
            }

            String captureBed(
                String start, String end, String input, String shorthand) {
              final startIndex = input.indexOf(start);
              final endIndex = input.indexOf(end, startIndex + start.length);
              if (startIndex == -1) {
                return "";
              } else {
                return shorthand +
                    input
                        .substring(startIndex + start.length, endIndex)
                        .replaceAll(new RegExp(r'[^0-9]'), '') +
                    " ";
                ;
              }
            }

            bForm = true;

            String bedNo = captureBed("ed No:", "S", _ocrText, "");
            String name = captureText("ame:", "H", _ocrText, "");
            String cleanedOCR = _ocrText.replaceAll(RegExp(' +'), ' ');
            String creatinine = capture("reatinine ", "m", cleanedOCR, "Crea ");
            String sodium = capture("odium ", "m", cleanedOCR, "Na ");
            String potassium = capture("otassium ", "m", cleanedOCR, "K ");
            String ica = capture("alcium ", "m", cleanedOCR, "iCa ");
            String chloride = capture("hloride ", "m", cleanedOCR, "Cl ");
            // Hemoglobin time

            var CBCs = [
              getCBC("GLOBIN", "\n", _ocrText, "Hgb"),
              getCBC("CRIT", "\n", _ocrText, "Hct"),
              getCBC("LET COU", "\n", _ocrText, "PLT"),
              getCBC("WBC)", "\n", _ocrText, "WBC"),
              getCBC("PHILS", "\n", _ocrText, "N"),
              getCBC("MENTERS", "\n", _ocrText, "S"),
              getCBC("PHOCYTES", "\n", _ocrText, "L"),
              getCBC("MONOCY", "\n", _ocrText, "M"),
              getCBC("EOSINO", "\n", _ocrText, "E"),
              getCBC("BASOPH", "\n", _ocrText, "B"),
            ];

            //initialize formatted text
            _formattedText = "";
            if (bedNo != '' || name != '') {
              _formattedText += "$bedNo$name\n";
            }
            _formattedText += "$creatinine$sodium$potassium$ica$chloride";
            //new cbc strat
            _formattedText += CBCs.join();
            //old cbc
            //_formattedText +=
            //    "$hemoglobin$hematocrit$platelet$wbc$neutrophils$segmenters$lympho$mono$eos$baso";

            //ALP ALT SGPT
            var alpast = [
              getCBC("lbumin", "\n", _ocrText, "Albumin"),
              getCBC("Globulin", "\n", _ocrText, "Globulin"),
              getCBC("G Ratio", "\n", _ocrText, "A/G"),
              getCBC("ma Glucose", "\n", _ocrText, "FBS"),
              getCBC("Cholesterol", "\n", _ocrText, "Choles"),
              getCBC("riglycerides", "\n", _ocrText, "Trig"),
              getCBC("HDL - Di", "\n", _ocrText, "HDL"),
              getCBC("LDL - Di", "\n", _ocrText, "LDL"),
              getCBC("LDH", "\n", _ocrText, "LDH"),
              getCBC("Total Protein", "\n", _ocrText, "Total Protein"),
              getCBC("Protein/Creatinine Ratio", "\n", _ocrText, "P/C ratio"),
              getCBC(" Urine", "\n", _ocrText, "Total Protein - Urine"),
              getCBC("rogen", "\n", _ocrText, "BUN"),
              getCBC("ganic Phos", "\n", _ocrText, "iPo"),
              getCBC("icarbonate", "\n", _ocrText, "HCO3"),
              getCBC("agnesi", "\n", _ocrText, "Mg"),
              getCBC("HBA1C", "\n", _ocrText, "HbA1c"),
              getCBC("Free T3", "\n", _ocrText, "FT3"),
              getCBC("Free T4", "\n", _ocrText, "FT4"),
              getCBC("TSH)", "\n", _ocrText, "TSH"),
              getCBC("TIME", "\n", _ocrText, "PT"),
              getCBC("NORMALIZED", "\n", _ocrText, "INR"),
              getCBC("D PTT", "\n", _ocrText, "aPTT"),
              getCBC("phatase", "\n", _ocrText, "ALP"),
              getCBC("anine Amino", "\n", _ocrText, "ALT"),
              getCBC("ALT", "\n", _ocrText, "ALT"),
              getCBC("mylase", "\n", _ocrText, "Amy"),
              getCBC("BLAST", "\n", _ocrText, "BLAST"),
              getCBC("tate Amino", "\n", _ocrText, "AST"),
              getCBC("AST)", "\n", _ocrText, "AST"),
              getCBC("AST", "\n", _ocrText, "AST"),
              onlyReturnOne([
                getCBC("Total Bilirubin", "\n", _ocrText, "Total Bilirubin"),
                getCBC("bin, Tot", "\n", _ocrText, "Bil, Tot"),
              ]),
              onlyReturnOne([
                getCBC("bin, Di", "\n", _ocrText, "B-Dir"),
                getCBC("Direct B", "\n", _ocrText, "Direct Bilirubin"),
              ]),
              onlyReturnOne([
                getCBC("bin, In", "\n", _ocrText, "B-Indir"),
                getCBC("Indirect B", "\n", _ocrText, "Indirect Bilirubin"),
              ]),
              getCBC("ipase", "\n", _ocrText, "Lipase")
            ];

            _formattedText += alpast.join();
            // ABG
            var ABG = [
              onlyReturnOne([
                getCBC("Fl", "\n", _ocrText, "FiO2"),
                getCBC("FIOz%:", "\n", _ocrText, "FiO2"),
                getCBC("FIO", "\n", _ocrText, "FiO2"),
                getCBC("FIOz", "\n", _ocrText, "FiO2"),
                getCBC("FiO", "\n", _ocrText, "FiO2")
              ]),
              //_ocrText.indexOf("FIOz"),
              getCBC("pH", "\n", _ocrText, "pH"),
              getCBC("pCO", "\n", _ocrText, "pCO2"),
              onlyReturnOne([
                getCBC("pOz", "\n", _ocrText, "pO2"),
                getCBC("pO;", "\n", _ocrText, "pO2"),
                getCBC("pO", "\n", _ocrText, "pO2"),
                getCBC("pOz", "\n", _ocrText, "pO2")
              ]),
              onlyReturnOne([
                getCBC("SPO2", "\n", _ocrText, "SpO2"),
                getCBC("S0", "\n", _ocrText, "SpO2"),
                getCBC("0:%", "\n", _ocrText, "SpO2")
              ]),
              getCBC("Hct", "\n", _ocrText, "Hct"),
              getCBC("Hb", "\n", _ocrText, "Hgb"),
              getCBC("HCO", "\n", _ocrText, "HCO3"),
              getCBC("BE", "\n", _ocrText, "BE")
            ];
            _formattedText += ABG.join();

            // urinalysis
            // var urinalysis = [
            //   getCBC("Color", "\n", _ocrText, "Color"),
            // ];
            // _formattedText += urinalysis.join();

            // additional
            var additional = [
              getCBC("ESR", "\n", _ocrText, "ESR"),
              getCBC("AFP)", "\n", _ocrText, "AFP"),
              getCBC("CRP", "\n", _ocrText, "CRP"),
            ];
            _formattedText += additional.join();

            //trim white spaces
            _formattedText = _formattedText.trim();
            //Deletes last character ","
            if (_formattedText.length > 0)
              _formattedText =
                  _formattedText.substring(0, _formattedText.length - 1);

            // Set text from text field
            _formattedTextController.text = _formattedText;
          }
          setState(() {});
        },
        child: Text("3. Format OCR"));
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Wrap(
                  children: [
                    ElevatedButton(
                      onPressed: getImage,
                      child: Text('1. Scan camera'),
                    ),
                    // Expanded(
                    //   child: TextField(
                    //     decoration: InputDecoration(
                    //       border: OutlineInputBorder(),
                    //       labelText: 'input image url',
                    //     ),
                    //     controller: urlEditController,
                    //   ),
                    // ),
                    ElevatedButton(
                        onPressed: () {
                          runFilePiker();
                          // _ocr("");
                        },
                        child: Text("1. from Gallery")),
                    ElevatedButton(
                        onPressed: () {
                          if (_imagePath != null) _ocr(_imagePath);
                        },
                        child: Text("2. Run")),
                  ],
                ),
                // Visibility(
                //   visible: false,
                //   child: Row(
                //     children: [
                //       ...LangList.map((e) {
                //         return Row(children: [
                //           Checkbox(
                //               value: selectList.indexOf(e) >= 0,
                //               onChanged: (v) async {
                //                 // dynamic add Tessdata
                //                 if (kIsWeb == false) {
                //                   Directory dir = Directory(
                //                       await FlutterTesseractOcr
                //                           .getTessdataPath());
                //                   if (!dir.existsSync()) {
                //                     dir.create();
                //                   }
                //                   bool isInstalled = false;
                //                   dir.listSync().forEach((element) {
                //                     String name = element.path.split('/').last;
                //                     // if (name == 'deu.traineddata') {
                //                     //   element.delete();
                //                     // }
                //                     isInstalled |= name == '$e.traineddata';
                //                   });
                //                   if (!isInstalled) {
                //                     bDownloadtessFile = true;
                //                     setState(() {});
                //                     HttpClient httpClient = new HttpClient();
                //                     HttpClientRequest request =
                //                         await httpClient.getUrl(Uri.parse(
                //                             'https://github.com/tesseract-ocr/tessdata/raw/main/${e}.traineddata'));
                //                     HttpClientResponse response =
                //                         await request.close();
                //                     Uint8List bytes =
                //                         await consolidateHttpClientResponseBytes(
                //                             response);
                //                     String dir = await FlutterTesseractOcr
                //                         .getTessdataPath();
                //                     print('$dir/${e}.traineddata');
                //                     File file =
                //                         new File('$dir/${e}.traineddata');
                //                     await file.writeAsBytes(bytes);
                //                     bDownloadtessFile = false;
                //                     setState(() {});
                //                   }
                //                   print(isInstalled);
                //                 }
                //                 if (selectList.indexOf(e) < 0) {
                //                   selectList.add(e);
                //                 } else {
                //                   selectList.remove(e);
                //                 }
                //                 setState(() {});
                //               }),
                //           Text(e)
                //         ]);
                //       }).toList(),
                //     ],
                //   ),
                // ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    //Text('Cropped image path:'),
                    // Padding(
                    //   padding: const EdgeInsets.only(top: 0, left: 0, right: 0),
                    //   child: Text(
                    //     _imagePath.toString(),
                    //     textAlign: TextAlign.center,
                    //     style: TextStyle(fontSize: 14),
                    //   ),
                    // ),
                  ],
                ),
                Expanded(
                    child: ListView(
                  children: [
                    Visibility(
                      visible: _imagePath != null,
                      child: Container(
                        constraints: BoxConstraints(
                          //minWidth: 100,
                          //maxWidth: 200,
                          //minHeight: 50,
                          maxHeight: 200,
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.file(File(_imagePath ?? ''),
                                fit: BoxFit.fitHeight),
                          ),
                        ),
                      ),
                    ),
                    // path.length <= 0
                    //     ? Container()
                    //     : path.indexOf("http") >= 0
                    //         ? Image.network(path)
                    //         : Image.file(File(path)),
                    if (bload)
                      Column(children: [CircularProgressIndicator()])
                    else
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                                constraints: BoxConstraints(
                                  //minWidth: 100,
                                  //maxWidth: 200,
                                  //minHeight: 50,
                                  maxHeight: 200,
                                ),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: Text('$_ocrText',
                                      style: TextStyle(fontSize: 6)),
                                )),
                            Wrap(
                              children: [
                                formatOCRButton,
                                // ElevatedButton(
                                //     onPressed: () async {
                                //       await Clipboard.setData(
                                //           ClipboardData(text: _ocrText));
                                //     },
                                //     child: Text("Copy RAW")),
                                ElevatedButton(
                                    onPressed: () async {
                                      await Clipboard.setData(ClipboardData(
                                          text: _formattedTextController.text));
                                    },
                                    child: Text("4. Copy Processed")),
                              ],
                            ),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  bForm
                                      ? TextField(
                                          controller: _formattedTextController,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(fontSize: 20),
                                          maxLines: 10,
                                        )
                                      : Text("empty"),
                                ])
                          ]),
                  ],
                ))
              ],
            ),
          ),
          Container(
            color: Colors.black26,
            child: bDownloadtessFile
                ? Center(
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      Text('download Trained language files')
                    ],
                  ))
                : SizedBox(),
          )
        ],
      ),

      floatingActionButton: kIsWeb
          ? Container()
          : FloatingActionButton(
              onPressed: () {
                runFilePiker();
                // _ocr("");
              },
              tooltip: 'OCR',
              child: Icon(Icons.add),
            ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
