import 'package:flutter/material.dart';
import 'package:memory_game/widgets/home_page.dart';

const Color darkGreen = Color.fromARGB(255, 70, 140, 71),
            lightGreen1 = Color.fromARGB(255, 197, 252, 195),
            lightGreen2 = Color.fromARGB(255, 169, 240, 167),
            lightPink = Color.fromARGB(255, 255, 175, 151);

class CardCatalog extends StatefulWidget {
  const CardCatalog({super.key});
  @override
  State<CardCatalog> createState() => _CardCatalogState();
}


class _CardCatalogState extends State<CardCatalog> {
  List<String> scientificNames
                      = ['Tyrannosaurus rex', 'Parasaurolophus', 'Pachycephalosaurus',
                        'Spinosaurus aegyptiacus', 'Ankylosaurus', 'Apatosaurus',
                        'Dilophosaurus', 'Styracosaurus', 'Ichthyosaurus', 
                        'Velociraptor', 'Brontosaurus', 'Elasmosaurus',
                        'Pliosaurus', 'Triceratops', 'Pteranodon',
                        'Stegosaurus', 'Allosaurus', 'Mosasaurus']; 
 
  List<String> periods
                      = ['Late Cretaceous', 'Late Cretaceous', 'Late Cretaceous',
                        'Early Cretaceous', 'Late Cretaceous', 'Late Jurassic',
                        'Early Cretaceous', 'Late Cretaceous', 'Early Jurassic',
                        'Late Cretaceous', 'Late Jurassic', 'Late Cretaceous',
                        'Jurassic', 'Late Cretaceous', 'Late Cretaceous',
                        'Late Jurassic','Late Jurassic','Late Cretaceous']; 
  
  List<String> habitats 
                      = ['Woodlands and plains', 'Floodplains and forests', 'Woodlands and plains',
                          'River deltas and swamps', 'Woodlands and plains', 'Floodplains and forests',
                          'Woodlands and plains', 'Woodlands and plains', 'Shallow seas',
                          'Woodlands and plains', 'Floodplains and forests', 'Shallow seas',
                          'Oceans', 'Woodlands and plains', 'Coastal regions',
                          'Woodlands and plains','Woodlands and plains', 'Oceans and Coastal regions']; 
  
  List<String> sizes
                      = ['Around 40 feet long, 15-20 feet tall', 'Around 30-40 feet long, 10-15 feet tall', 'About 15 feet long, 10 feet tall',
                        'Around 40-50 feet long, possibly larger', 'About 20-30 feet long, 6 feet tall', 'Approximately 70-90 feet long, 15-20 feet tall',
                        'Around 20 feet long, 6-7 feet tall', 'Approximately 16-18 feet long, 6 feet tall', 'Typically around 6-10 feet long',
                        'About 6 feet long, 2 feet tall', 'Approximately 70-90 feet long, 15-20 feet tall', 'Around 30-40 feet long',
                        'Up to 40-50 feet long', 'Around 26-30 feet long, 9-10 feet tall', 'Wingspan up to 30 feet',
                        'Around 30 feet long, 9 feet tall', 'Approximately 28-33 feet long, 10-12 feet tall', 'Around 50-60 feet long']; 

  List<String> physicalCharacteristics
                      = ['Large head, powerful jaws, short arms, long tail', 'Crested head, long tail, bipedal', 'Thick skull, bipedal, small arms',
                        'Sail-like structure on its back, long snout, semi-aquatic adaptations', 'Armored body, club-like tail, low-slung posture', 'Long neck, long tail, quadrupedal',
                        'Crests on its head, slender body, bipedal', 'Large frill adorned with spikes, horned nose, quadrupedal', 'Streamlined body, fish-like appearance, large eyes',
                        'Sickle-shaped claws on feet, feathered body, long tail', 'Long neck, long tail, quadrupedal', 'Long neck, small head, streamlined body, flippers',
                        'Large head, short neck, powerful jaws, four large flippers', 'Large frill, three horns on the face, quadrupedal', 'Large crest on the back of the head, toothless beak, wings for flight',
                        'Double row of plates along the back, spiked tail, quadrupedal', 'Large skull with sharp teeth, three-fingered hands, bipedal', 'Streamlined body, powerful jaws with conical teeth, flippers for swimming']; 

  List<String> dietsAndBehaviors
                      = ['Carnivore; apex predator, likely scavenged too', 'Herbivore; likely traveled in herds, used crest for communication', 'Herbivore; possibly head-butted for defense or mating display',
                          'Carnivore; likely specialized in hunting fish, possibly scavenged as well', 'Herbivore; likely used tail for defense against predators', 'Herbivore; probably traveled in herds, used long neck to reach vegetation',
                          'Carnivore; likely hunted small to medium-sized prey, possibly lived in packs', 'Herbivore; likely grazed on vegetation, used frill for display or defense', 'Carnivore; likely hunted fish and squid, gave birth to live young in the water',
                          'Carnivore; likely hunted in packs, may have been an intelligent predator', 'Herbivore; likely grazed on vegetation, had a small brain relative to its body size', 'Carnivore; likely hunted fish and other marine prey',
                          'Apex predator; hunted marine reptiles and large fish', 'Herbivore; likely grazed on low-lying vegetation, possibly lived in herds', 'Piscivore (fish-eater); soared over oceans, likely hunted by diving into water',
                          'Herbivore; probably used tail spikes for defense against predators', 'Carnivore; apex predator, likely hunted in packs', 'Apex predator; carnivore, hunted fish, marine reptiles, and possibly other large prey'];


  int _selectedIndex = 0; // set first card as default card when opening card catalog
  final int _itemCount = 18; // total number of unique dino cards

  void _handleCardTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          titleSpacing: 20,
          title: Image.asset(
            "assets/logo-title.png",
            width: 115,
          ),
          backgroundColor: Colors.transparent,
          actions: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 25),
              decoration: BoxDecoration(
                border: Border.all(color: darkGreen, width: 4.0),
                borderRadius: BorderRadius.circular(50),
                color: lightGreen1,
                boxShadow: [
                  BoxShadow(
                    color: lightPink.withOpacity(1),
                    offset: const Offset(1.85, 3),
                  )
                ]
              ),
              child: IconButton(
                icon: const Icon(Icons.close),
                color: darkGreen,
                iconSize: 30,
                onPressed: () {
                  Navigator.pushReplacement(
                            context, MaterialPageRoute(builder: (context) => const HomePage())
                          );
                },),
            )
          ],
        ),
        body: Stack(
          children: [

            // Background Image
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/bg-1.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Main Column
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1st Row: Title "Card Catalog"
                Expanded(
                  flex: 12,
                  child: Center(
                    child: Image.asset(
                        'assets/card-catalog-text.png',
                        width: 250.0,
                        height: 250.0,
                      ),
                  ),
                ),

                // 2nd Row: horizontal card display
                Expanded(
                  flex: 23,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: darkGreen, width: 4.0),
                      borderRadius: BorderRadius.circular(10),
                      color: lightGreen2,
                    ),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _itemCount,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {
                            _handleCardTap(index);
                          },
                            child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Container(
                              width: 85,
                              decoration: BoxDecoration(
                                border: Border.all(
                                   color: _selectedIndex == index ? const Color.fromARGB(255, 255, 228, 50) : Colors.transparent,
                                   width: 4
                                ),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.asset(
                                  'assets/cards/${index+1}.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // 3rd Row: real dino pic display
                Expanded(
                  flex: 34,
                  child: Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 45),
                        child: Image.asset(
                            "assets/striped-rec.png",
                            fit: BoxFit.cover,
                          ),
                        ),
                      // background striped rectangle
                      
                      // real dino image
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: Center(
                          child: Image.asset(
                            'assets/realdinos/${_selectedIndex+1}.png',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 4th Row: dino details
                Expanded(
                  flex: 42,
                  child: Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        // background striped rectangle
                        child: Image.asset(
                            "assets/rectangle-info.png",
                            fit: BoxFit.cover,
                          ),
                        ),
                      
                      
                      // real dino image
                      Container(
                        //color: Colors.red,
                        margin: const EdgeInsets.symmetric(horizontal: 47, vertical: 28),
                        height: 160,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildRichText("Scientific Name: ", scientificNames[_selectedIndex]),
                            buildRichText("Period: ", periods[_selectedIndex]),
                            buildRichText("Habitat: ", habitats[_selectedIndex]),
                            buildRichText("Size: ", sizes[_selectedIndex]),
                            buildRichText("Physical Characteristics: ", physicalCharacteristics[_selectedIndex]),
                            buildRichText("Diet and Behavior: ", dietsAndBehaviors[_selectedIndex]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildRichText(String label, String detail) {
  return RichText(
    text: TextSpan(
      children: [
        
        TextSpan(
          text: label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: darkGreen,
          ),
        ),

        TextSpan(
          text: detail,
          style: const TextStyle(
            fontSize: 14,
            color: Color.fromARGB(255, 182, 132, 121),
          ),
        ),
        
      ],
    ),
  );
}
