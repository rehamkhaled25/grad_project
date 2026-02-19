import 'package:flutter/material.dart';

class custom_image_holder extends StatelessWidget {
 final String img;
  const custom_image_holder({
    super.key,required this.img
  });

  @override
  Widget build(BuildContext context) {
    return 
        GestureDetector(
          onTap: (){},
          child: Container(
            decoration: BoxDecoration(
             color:   Colors.white,
              boxShadow: [
            BoxShadow(
              offset: const Offset(0, 2),
              color: Colors.black.withOpacity(0.25),
            ),
            
              ]
            ),
           
            width:82.55,
            height: 53.79,
            child: Image(image: AssetImage(img)), 
              ),
        );
  }
}