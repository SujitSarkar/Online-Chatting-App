import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:GlamChat/Widgets/FullImageWidget.dart';
import 'package:GlamChat/Widgets/ProgressWidget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class Chat extends StatelessWidget {

  final String receiverId;
  final String receiverAvatar;
  final String receiverName;

  Chat({ //Constructor...
    Key key,
    @required this.receiverId,
    @required this.receiverAvatar,
    @required this.receiverName
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        actions: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.black,
              backgroundImage: CachedNetworkImageProvider(receiverAvatar),
            ),
          )
        ],
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          receiverName,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ChatScreen(receiverId: receiverId, receiverAvatar: receiverAvatar),
    );
  }
}

class ChatScreen extends StatefulWidget {

  final String receiverId;
  final String receiverAvatar;

  ChatScreen({
    Key key,
    @required this.receiverId,
    @required this.receiverAvatar
  }) : super(key: key);

  @override
  State createState() => ChatScreenState(receiverId: receiverId, receiverAvatar: receiverAvatar);
}




class ChatScreenState extends State<ChatScreen> {

  final String receiverId;
  final String receiverAvatar;

  ChatScreenState({
    Key key,
    @required this.receiverId,
    @required this.receiverAvatar
  });

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  bool isDisplaySticker;
  bool isLoading;

  File imageFile;
  String imageUrl;

  String chatId;
  SharedPreferences preferences;
  String id;
  var listMessage;

  //Local Notification....
  FlutterLocalNotificationsPlugin fltrNotification;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    focusNode.addListener(onFocusChange);
    
    isDisplaySticker = false;
    isLoading = false;

    chatId = "";
    readLocal();

    //Local Notification....
    var androidInitialize = new AndroidInitializationSettings('glam_chat');
    var iosInitialize = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(androidInitialize, iosInitialize);
    fltrNotification = new FlutterLocalNotificationsPlugin();
    fltrNotification.initialize(initializationSettings
    /*,onSelectNotification: notificationSelected*/);

  }


  readLocal() async{
    preferences = await SharedPreferences.getInstance();
    id = preferences.getString("id") ?? "";

    if(id.hashCode <= receiverId.hashCode){
      chatId = '$id-$receiverId';
    }
    else{
      chatId = '$receiverId-$id';
    }
    Firestore.instance.collection("users").document(id).updateData({
      'chattingWith': receiverId,
    });
    setState(() {

    });
  }

  onFocusChange(){
    if(focusNode.hasFocus){
      //hide stickers whenever keypad appears...
      setState(() {
        isDisplaySticker = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Stack(
          children: [
            Column(
              children: [
                //create list of messages....
                createListMessages(),

                //Show Stickers....
                (isDisplaySticker ? createStickers() : Container()),

                //Input Controller....
                createInput(),
              ],
            ),
            createLoading(),
          ],
        ),
      onWillPop: onBackPress,
    );

    Future notificationSelected() async{}
  }

  createLoading(){
    return Positioned(
      child: isLoading ? threeBounceLoadingBar() : Container(),
    );
  }

  Future<bool> onBackPress(){

    if(isDisplaySticker){
      setState(() {
        isDisplaySticker = false;
      });
    }
    else{
      Navigator.pop(context);
    }
    return Future.value(false);
  }

  createStickers(){
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              FlatButton(
                onPressed:() => onSendMessage("mimi1", 2),
                child: Image.asset(
                  "images/mimi1.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed:() => onSendMessage("mimi2", 2),
                child: Image.asset(
                  "images/mimi2.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed:() => onSendMessage("mimi3", 2),
                child: Image.asset(
                  "images/mimi3.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),

          Row(
            children: [
              FlatButton(
                onPressed:() => onSendMessage("mimi4", 2),
                child: Image.asset(
                  "images/mimi4.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed:() => onSendMessage("mimi5", 2),
                child: Image.asset(
                  "images/mimi5.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed:() => onSendMessage("mimi6", 2),
                child: Image.asset(
                  "images/mimi6.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),

          Row(
            children: [
              FlatButton(
                onPressed:() => onSendMessage("mimi7", 2),
                child: Image.asset(
                  "images/mimi7.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed:() => onSendMessage("mimi8", 2),
                child: Image.asset(
                  "images/mimi8.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed:() => onSendMessage("mimi9", 2),
                child: Image.asset(
                  "images/mimi9.gif",
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ),
      decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey, width: 0.5),
          ),
        color: Colors.white,
      ),
      padding: EdgeInsets.all(5.0),
      height: 180.0,
    );
  }

  void getSticker(){
    focusNode.unfocus();
    setState(() {
      isDisplaySticker = !isDisplaySticker;
    });
  }

  createListMessages(){
    return Flexible(
      child: chatId == ""
        ? Center(
          child: threeBounceLoadingBar(),
        // child: CircularProgressIndicator(
        //   valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
        // ),
        )
      : StreamBuilder(
        stream: Firestore.instance.collection("messages")
            .document(chatId)
            .collection(chatId)
            .orderBy("timeStamp", descending: true)
            .limit(1000).snapshots(),
        builder: (context, snapshot){
          if(!snapshot.hasData){
            return Center(
            child: threeBounceLoadingBar(),
          );
          }
          else{
            listMessage = snapshot.data.documents;
            return ListView.builder(
                padding: EdgeInsets.all(10.0),
                itemBuilder: (context, index) => createItem(index, snapshot.data.documents[index]),
                itemCount: snapshot.data.documents.length,
                reverse: true,
                controller: listScrollController,
            );
          }
        },
      ),
    );
  }

  bool isLastMgsLeft(int index){
    if((index > 0 && listMessage != null && listMessage[index-1]["idFrom"] == id) || index == 0){
      return true;
    }
    else{ return false;}
  }

  bool isLastMgsRight(int index){
    if((index > 0 && listMessage != null && listMessage[index-1]["idFrom"] != id) || index == 0){
      return true;
    }
    else{ return false;}
  }

  launchURL(String url) async {
    //const url = 'https://flutter.dev';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget createItem(int index, DocumentSnapshot document){

    //My messages - Right Side...
    if(document["idFrom"] == id){
      return Row(
        children: [

          //Text Mgs...
          document["type"] == 0
              ? Container(
                    child: Text(
                      document["content"],
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                    padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                    width: 200.0,
                    decoration: BoxDecoration(
                        color: Colors.lightBlueAccent,
                        borderRadius:BorderRadius.circular(8.0),
                    ),
                    margin: EdgeInsets.only(bottom: isLastMgsRight(index) ? 20.0 : 10.0, right: 10.0),
              )

              //Image Mgs...
              :document["type"] == 1
              ? Container(
                  child: FlatButton(
                    child: Material(
                      child: CachedNetworkImage(
                        placeholder: (context, url) => Container(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                          ),
                          width: 200.0,
                          height: 200.0,
                          padding: EdgeInsets.all(70.0),
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          ),
                        ),
                        errorWidget: (context, url, error) => Material(
                          child: Image.asset("images/img_not_available.jpeg", width: 200.0, height: 200.0, fit: BoxFit.cover,),
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          clipBehavior: Clip.hardEdge,
                        ),
                        imageUrl: document["content"],
                        width: 200.0,
                        height: 200.0,
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      clipBehavior: Clip.hardEdge,
                    ),
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) => FullPhoto(url: document["content"])
                      ));
                    },
                  ),
                  margin: EdgeInsets.only(bottom: isLastMgsRight(index) ? 20.0 : 10.0, right: 10.0),
                )

              //Sticker mgs...
              :Container(
                child: Image.asset(
                  "images/${document['content']}.gif",
                  width: 100.0,
                  height: 100.0,
                  fit: BoxFit.cover,
                ),
                margin: EdgeInsets.only(bottom: isLastMgsRight(index) ? 20.0 : 10.0, right: 10.0),
              ),
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    }

    //Receiver messages - Left side
    else{
      _showNotification(document["content"]);
      return Container(
        child: Column(
          children: [
            Row(
              children: [
                isLastMgsLeft(index)
                    ? Material(
                      //Display receiver profile image...
                      child: CachedNetworkImage(
                        placeholder: (context, url) => Container(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                          ),
                          width: 35.0,
                          height: 35.0,
                          padding: EdgeInsets.all(10.0),
                        ),
                        imageUrl: receiverAvatar,
                        width: 35.0,
                        height: 35.0,
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(18.0)),
                      clipBehavior: Clip.hardEdge,
                    )
                    : Container(width: 35.0,),


                //displayMessages....
                //Text messages...
                document["type"] == 0
                    ? Container(
                        child: Text(
                          document["content"],
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400),
                        ),
                        padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                        width: 200.0,
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius:BorderRadius.circular(8.0),
                        ),
                        margin: EdgeInsets.only(left: 10.0),
                    )

                //Image Mgs...
                :document["type"] == 1
                 ? Container(
                  child: FlatButton(
                    child: Material(
                      child: CachedNetworkImage(
                        placeholder: (context, url) => Container(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                          ),
                          width: 200.0,
                          height: 200.0,
                          padding: EdgeInsets.all(70.0),
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          ),
                        ),
                        errorWidget: (context, url, error) => Material(
                          child: Image.asset("images/img_not_available.jpeg", width: 200.0, height: 200.0, fit: BoxFit.cover,),
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          clipBehavior: Clip.hardEdge,
                        ),
                        imageUrl: document["content"],
                        width: 200.0,
                        height: 200.0,
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      clipBehavior: Clip.hardEdge,
                    ),
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => FullPhoto(url: document["content"])
                      ));
                    },
                  ),
                  margin: EdgeInsets.only(left: 10.0),
                )

                //Sticker mgs...
                :Container(
                  child: Image.asset(
                    "images/${document['content']}.gif",
                    width: 100.0,
                    height: 100.0,
                    fit: BoxFit.cover,
                  ),
                  margin: EdgeInsets.only(left: 10.0),
                ),
              ],
            ),

            //Last mgs time...
            isLastMgsLeft(index)
                ? Container(
                  child: Text(
                    DateFormat("dd MMMM, yyyy - hh:mm:aa")
                        .format(DateTime.fromMillisecondsSinceEpoch(int.parse(document["timeStamp"]))),
                    style: TextStyle(
                      color: Colors.grey, fontSize: 12.0, fontStyle: FontStyle.italic,
                    ),
                  ),
                  margin: EdgeInsets.only(left: 50.0, top: 50.0, bottom: 5.0),
                )
                : Container()
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }

  openUrl(String url){
    //launch(url);
    Fluttertoast.showToast(msg: url);
  }

  createInput(){
    return Container(
      child: Row(
        children: [
          //Pick image icon button....
          Material(
            child: Container(
              //margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.image,),
                color: Colors.lightBlueAccent,
                onPressed: getImageFromGallery,
              ),
            ),
            color: Colors.white,
          ),

          //emoji icon button....
          Material(
            child: Container(
              //margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                  icon: Icon(Icons.face,),
                  color: Colors.orangeAccent,
                  onPressed: getSticker, //getImageFromGallery,
              ),
            ),
            color: Colors.white,
          ),

          //Text Field....
          Flexible(
            child: Container(
              child: TextField(
                style: TextStyle(
                  color: Colors.black, fontSize: 15.0,
                ),
                controller: textEditingController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration.collapsed(
                  hintText: "Write here...",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                focusNode: focusNode,
              ),
            ),
          ),

          //Send Message icon button....
          Material(
            child: Container(
              //margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: Icon(Icons.send),
                color: Colors.lightBlueAccent,
                onPressed:() => onSendMessage(textEditingController.text, 0),
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey,
            width: 0.5,
          )
        ),
        color: Colors.white,
      ),
    );
  }

  void onSendMessage(String contentMsg, int type){
    //type=0 means mgs
    //type=1 means imageFile
    //type=2 means emojies
    if(contentMsg != ""){

      textEditingController.clear();

      var docRef = Firestore.instance.collection("messages")
      .document(chatId)
      .collection(chatId)
      .document(DateTime.now().millisecondsSinceEpoch.toString());
      
      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(docRef, {
          "idFrom": id,
          "idTo": receiverId,
          "timeStamp": DateTime.now().millisecondsSinceEpoch.toString(),
          "content": contentMsg,
          "type": type,
        },);
      });
      listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    }
    else{
      Fluttertoast.showToast(msg: "Write something to sent");
    }
  }

  Future getImageFromGallery() async{
    imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    if(imageFile != null){
      isLoading = true;
    }
    uploadImageFile();
  }

  Future uploadImageFile() async{
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference storageReference = FirebaseStorage.instance.ref().child("Chat Images").child(fileName);

    StorageUploadTask storageUploadTask = storageReference.putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot = await storageUploadTask.onComplete;

    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl){
      imageUrl = downloadUrl;
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, 1);
      });
    }, onError: (error){
      setState(() => isLoading = false);
      Fluttertoast.showToast(msg: "Error: "+ error);
    });
  }

  //Local Notification....
  Future _showNotification(String mgs) async{
    int temp;

    QuerySnapshot result = await Firestore.instance.collection("messages").document(chatId).collection(chatId).getDocuments();
    List<DocumentSnapshot> documentSnapshot = result.documents;
    int length = documentSnapshot.length;

    if(length> temp){
      var androidDetails = new AndroidNotificationDetails("ID", "Someone", mgs, importance: Importance.Max);
      var iosDetails = new IOSNotificationDetails();
      var generalNotificationDetails = new NotificationDetails(androidDetails, iosDetails);
      await fltrNotification.show(0, "GlamChat Notification","Someone is Messaged you", generalNotificationDetails);
      temp = length;
    }

   }
}
