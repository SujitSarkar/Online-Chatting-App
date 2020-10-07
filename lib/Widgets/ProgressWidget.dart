import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';


circularProgress() {
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.only(top: 12.0),
    child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.lightBlueAccent),),
  );
}

linearProgress() {
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.only(top: 12.0),
    child: LinearProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.lightGreenAccent),),
  );
}

customLoadingBar(){
  return Container(
    alignment: Alignment.center,
    child: SpinKitThreeBounce(
      color: Colors.white,
      size: 50.0,
    ),
  );
}

threeBounceLoadingBar(){
  return Container(
    alignment: Alignment.center,
    child: SpinKitThreeBounce(
      color: Colors.lightBlueAccent,
      size: 50.0,
    ),
  );
}

