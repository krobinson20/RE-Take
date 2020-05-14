import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gallery_saver/gallery_saver.dart';


int _selectedIndex = 0; //global variable for what icon is selected on the bottom bar
File StoredImage;
var selimage = 0;
double transval = 0.4;
const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
const List<Widget> _widgetOptions = <Widget>[

  Text(
    'Index 1: Take Picture',
    style: optionStyle,
  ),
  Text(
    'Index 0: Select Immage',
    style: optionStyle,
  )
];


Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: TakePictureScreen(
        // Pass the appropriate camera to the TakePictureScreen widget.
        camera: firstCamera,
      ),
    ),
  );
}

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  Future<File> imageFile;
  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }
pickImageFromGallery(ImageSource source) async {

  File tempimg = await ImagePicker.pickImage(source: source);
  selimage = 1;


    setState(() {
      // imageFile = ImagePicker.pickImage(source: source);
       StoredImage = tempimg;
    });

}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('RE-Take')),
      // Wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner
      // until the controller has finished initializing.

    bottomNavigationBar: BottomNavigationBar(
    items: const<BottomNavigationBarItem>[
    BottomNavigationBarItem(
    icon: Icon(Icons.photo_library),
    title: Text('Select a Picture'),
    ),

    BottomNavigationBarItem(
    icon:  Icon(Icons.camera),
    title : Text('Take a Picture'),
    )
    ],

    currentIndex: _selectedIndex,
      onTap: (currentIndex){
      setState(() {
        switch(currentIndex){
          case 0:
            pickImageFromGallery(ImageSource.gallery);

            break;
          case 1:
            getTemporaryDirectory().then((d){
              var path = join(d.path, '${DateTime.now()}.png');
              _controller.takePicture(path).then((v){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DisplayPictureScreen(imagePath: path),
                  ),
                );
              });
            });
            break;

    }
      });
    },
    ),

      body: FutureBuilder<void>(
        future: _initializeControllerFuture,

        builder: (context, snapshot) {
    if (selimage != 0) {
      if (snapshot.connectionState == ConnectionState.done) {
        // If the Future is complete, display the preview.
        return Stack(
          children: <Widget>[
            CameraPreview(_controller),
            Container(
              decoration: BoxDecoration(
                image: new DecorationImage(
                    colorFilter: new ColorFilter.mode(Colors.black.withOpacity(transval), BlendMode.dstATop),
                    //OPACITY
                    image: new FileImage(StoredImage),
                    fit: BoxFit.fitHeight),
              ),
            ),

          Container(
            alignment: Alignment.bottomCenter,
            child: Slider.adaptive(value: transval,
                onChanged: (newValue){
                  setState(() => transval = newValue);
                },
             ),
            ),
          ],

        );
        //return CameraPreview(_controller);
      } else {
        // Otherwise, display a loading indicator.
        return Center(child: CircularProgressIndicator());
      }
    }else{
      return  Center(child: Text("Plese Select an Image"));
    }
          },

      ),
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  const DisplayPictureScreen({Key key, this.imagePath}) : super(key: key);


  @override
Widget build(BuildContext context) => new Scaffold(

    appBar: new AppBar(
      title: new Text('RE-Take'),
    ),


    
    body: Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            image: new DecorationImage(
                colorFilter: new ColorFilter.mode(Colors.black.withOpacity(1), BlendMode.dstATop), //OPACITY
                image: new FileImage(File(imagePath)),
                fit: BoxFit.fitHeight),

          ),
         
        ),
        Container(
          child: new Row(
            children: <Widget>[
        
        
      new RaisedButton.icon(
          icon: Icon(Icons.autorenew),
          color: Colors.cyanAccent[100],
          textColor: Colors.black,
          label: Text('Compare'),
          elevation: 55,
          onPressed: () {
           Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Compare(imagePath: imagePath),
                  ),
                );
            },
        ),

     
      new RaisedButton.icon(
          icon: Icon(Icons.save),
          color: Colors.cyanAccent[100],
          textColor: Colors.black,
          label: Text('Save'),
          elevation: 55,
          onPressed: () {
            GallerySaver.saveImage(imagePath).then((bool success) {
              print(success);
  });},
        ),


     


      ],
          )

        )
         
        
       
      ],
    ),
    
  );
  
}


class Compare extends StatelessWidget{
  final String imagePath;
  const Compare({Key key, this.imagePath}) : super(key: key);
  

  @override
Widget build(BuildContext context) => new Scaffold(

    appBar: new AppBar(
      title: new Text('RE-Take'),
    ),

    
    body: Stack(
      children: [
        new Column(children:[
          Container(
            alignment: Alignment.topCenter,
            height: (MediaQuery.of(context).size.height * 0.5)-50,
            width: MediaQuery.of(context).size.width,
            //color: Colors.green,
            decoration: BoxDecoration(
            image: new DecorationImage(
                colorFilter: new ColorFilter.mode(Colors.black.withOpacity(1), BlendMode.dstATop), //OPACITY
                image: new FileImage(File(imagePath)),
                fit: BoxFit.fitHeight),

          ),
            
             ),
            
          Container(
            alignment: Alignment.bottomCenter,
            height: (MediaQuery.of(context).size.height * 0.5)-50,
            width: MediaQuery.of(context).size.width,
            //color: Colors.blue,
            decoration: BoxDecoration(
            image: new DecorationImage(
                colorFilter: new ColorFilter.mode(Colors.black.withOpacity(1), BlendMode.dstATop), //OPACITY
                image: new FileImage(StoredImage),
                fit: BoxFit.fitHeight),

          ),
             )
          
      ],),
      RaisedButton.icon(
          icon: Icon(Icons.save),
          color: Colors.cyanAccent[100],
          textColor: Colors.black,
          label: Text('Save'),
          elevation: 55,
          onPressed: () {
            GallerySaver.saveImage(imagePath).then((bool success) {
              print(success);
  });},
        ),
      ],
          )
);
  
}
