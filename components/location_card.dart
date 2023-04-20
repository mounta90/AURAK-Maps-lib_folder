import 'package:flutter/material.dart';

class LocationCard extends StatelessWidget {
  final String cardLocationName;
  final void Function()? onNavigationButtonPressed;

  const LocationCard({
    super.key,
    required this.cardLocationName,
    required this.onNavigationButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10,
      child: AspectRatio(
        aspectRatio: 3 / 1,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade500,
                blurStyle: BlurStyle.outer,
                blurRadius: 2.0,
              )
            ],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(5.0),
              topRight: Radius.circular(5.0),
              bottomLeft: Radius.circular(5.0),
              bottomRight: Radius.circular(5.0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Image
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                child: Image(
                  width: (MediaQuery.of(context).size.width - 32) * 0.5,
                  fit: BoxFit.cover,
                  image: const AssetImage(
                    'lib/assets/images/saqr_library.jpg',
                  ),
                ),
              ),
              // Content information
              Container(
                width: (MediaQuery.of(context).size.width - 32) * 0.5,
                decoration: const BoxDecoration(
                    // color: Colors.red,
                    ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 0.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        cardLocationName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(50.0),
                            child: Material(
                              color: Colors.white,
                              child: IconButton(
                                splashRadius: 30.0,
                                splashColor: Colors.blueGrey,
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.favorite,
                                  color: Colors.pink,
                                  size: 32,
                                ),
                              ),
                            ),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(50.0),
                            child: Material(
                              color: Colors.white,
                              child: IconButton(
                                splashRadius: 30.0,
                                splashColor: Colors.blueGrey,
                                onPressed: onNavigationButtonPressed,
                                icon: const Icon(
                                  Icons.location_pin,
                                  color: Colors.lightBlue,
                                  size: 32,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
