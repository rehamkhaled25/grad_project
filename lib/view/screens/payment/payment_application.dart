import 'package:flutter/material.dart';
import 'package:graduation_project/view/custom%20_widget/continue_button.dart';
import 'package:graduation_project/view/custom%20_widget/payment_options.dart';

class PaymentApplication extends StatelessWidget {
  const PaymentApplication({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        Row(
          children: [
            IconButton(onPressed: (){
              //navigate lwara 
              Navigator.pop(context);
            },
             icon:Icon(Icons.arrow_back),),
      
            Text("Payment method",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,),),
            
          ],
        ),
        SizedBox(height: 40,),
        Padding(
          padding: const EdgeInsets.only(left:20),
          child: Text("Add Payment Method", textAlign: TextAlign.start,style :TextStyle(fontSize:15,fontWeight: FontWeight.bold),),
        ),
        SizedBox(height: 30,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
       custom_image_holder(img: "assets/images/mastercard-full-svgrepo-com 1.png"),
      custom_image_holder(img: 'assets/images/paypal-svgrepo-com 1.png'),
       custom_image_holder(img: 'assets/images/google-pay-svgrepo-com 2.png'),
       custom_image_holder(img: 'assets/images/apple-pay-svgrepo-com 1.png')
          ],
        ),
        SizedBox(height: 40,),
        Center(child: Image(image: AssetImage('assets/images/credit card.png'))),
         SizedBox(height: 70,),
         Padding(
           padding: const EdgeInsets.symmetric(horizontal: 60),
           child: Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
           Text("Total Payment",style:TextStyle(fontSize: 16 , fontWeight: FontWeight.bold)),
           Row(
             children: [
               Text("\$50.98",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
               Text(" USD",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Color(0xff8E8E93)))
             ],
           )
            ],
           ),
         ),
         SizedBox(height: 70,),
         ContinueButton(onPressed: (){},txt:"Confirm Order")
          ],
        ),
      ),
    );
  }
}

