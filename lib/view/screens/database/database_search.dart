import 'package:flutter/material.dart';

class DatabaseSearch extends StatefulWidget {
  const DatabaseSearch({super.key});

  @override
  State<DatabaseSearch> createState() => _DatabaseSearchState();
}

class _DatabaseSearchState extends State<DatabaseSearch> {
  int selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
          children: [
          
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.symmetric(horizontal:25 ),
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, size: 24,color: Colors.black,),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Food Database",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), 
                ],
              ),
            ),
            const SizedBox(height: 15),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "What are you looking for?",
                  hintStyle: const TextStyle(color: Colors.black, fontSize: 14),
                  filled: true,
                  fillColor: const Color(0xffEBEBEB),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTab("All", 0),
                _buildTab("My meals", 1),
                _buildTab("My foods", 2),
                _buildTab("Saved Scans", 3),
              ],
            ),
            const SizedBox(height: 40),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(bottom: 20),
                itemCount: 8, 
                separatorBuilder: (context, index) =>  SizedBox(height: 40),
                itemBuilder: (context, index) {
                  return const CustomContainer();
                },
                
              ),
            ),
          ],
        ),
      );
   
  }

  Widget _buildTab(String label, int index) {
    bool isSelected = selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTabIndex = index;
        });
      },
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? const Color(0xffFF0F3C) : Colors.black,
          fontWeight: FontWeight.bold ,
          fontSize: 14,
        ),
      ),
    );
  }
}

class CustomContainer extends StatelessWidget {
  const CustomContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Container(
        width: 334, 
        height: 66, 
      
        decoration: BoxDecoration(
          color: const Color(0xffEBEBEB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 10,right: 20),
          child: Row(
            children: [
              
              Image.asset(
                'assets/images/pancakes.png', 
               
              ),
              const SizedBox(width: 12),
              
             
              const Expanded(
                child: 
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Pancakes",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 5,),
                    Row(
                      children: [
                       Image(image:   AssetImage('assets/images/flame bta3et saf7et el database.png'))
                        ,SizedBox(width: 4),
                        Text(
                          "94 cal",
                          style: TextStyle(fontSize: 12, color: Colors.black,fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            
              const Icon(Icons.add, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}