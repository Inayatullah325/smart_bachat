import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  const RoundedButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height*0.06,
      //  width: MediaQuery.of(context).size.width*0.3,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(child: Text('Add Income', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),)),
    );
  }
}
