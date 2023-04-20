import 'package:flutter/material.dart';
import 'package:flutter_processing/flutter_processing.dart';

import 'package:maps/constants/colors.dart';
import 'package:maps/models/location.dart';

class IndoorFloorPlanPage extends StatefulWidget {
  final Location? location;
  final PageController pageController;

  const IndoorFloorPlanPage({
    super.key,
    required this.location,
    required this.pageController,
  });

  @override
  State<IndoorFloorPlanPage> createState() => _IndoorFloorPlanPageState();
}

class _IndoorFloorPlanPageState extends State<IndoorFloorPlanPage> {
  @override
  void initState() {
    super.initState();
  }

  int? xUser;
  int? yUser;
  int? xDestination;
  int? yDestination;

  @override
  Widget build(BuildContext context) {
    // --------

    // --------
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              splashRadius: 20.0,
              onPressed: () {
                widget.pageController.previousPage(
                    duration: const Duration(
                      milliseconds: 500,
                    ),
                    curve: Curves.linear);
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              border: Border.all(
                color: primaryGrey,
                width: 2.0,
              ),
            ),
            height: MediaQuery.of(context).size.height * 0.5,
            width: MediaQuery.of(context).size.width - 32,
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              child: InteractiveViewer(
                maxScale: 2.5,
                boundaryMargin: const EdgeInsets.symmetric(
                  vertical: 270.0,
                  horizontal: 555,
                ),
                minScale: 0.001,
                child: Processing(
                  sketch: MySketch(
                    xPosUserPosition: xUser,
                    yPosUserPosition: yUser,
                    xPosDestinationPosition: xDestination,
                    yPosDestinationPosition: yDestination,
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
          Container(
            margin: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 2.0,
              bottom: 1.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "WHERE ARE YOU CURRENTLY?",
                  style: TextStyle(
                      color: Colors.blueGrey, fontWeight: FontWeight.bold),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: _buildStartingPositionChips(),
                ),
              ],
            ),
          ),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(
                color: Colors.blueGrey,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 2.0,
              bottom: 1.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "DESTINATION ROOM?",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: _buildDestinationPositionChips(),
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildStartingPositionChips() => Wrap(
        spacing: 2.5,
        children: widget.location!.rooms.map((room) {
          return ActionChip(
            backgroundColor: primaryRedColor,
            label: Text(
              room['room_number'].toString().toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () {
              setState(() {
                xUser = room['coordinates']['x'];
                yUser = room['coordinates']['y'];
              });
            },
          );
        }).toList(),
      );

  Widget _buildDestinationPositionChips() => Wrap(
        spacing: 2.5,
        children: widget.location!.rooms.map((room) {
          return ActionChip(
            backgroundColor: primaryYellowColor,
            label: Text(
              room['room_number'].toString().toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () {
              setState(() {
                xDestination = room['coordinates']['x'];
                yDestination = room['coordinates']['y'];
              });
            },
          );
        }).toList(),
      );
}

// ---------------

class MySketch extends Sketch {
  late final PImage _imageFloorPlan;
  final int _rows = 100;
  final int _columns = 100;
  late final double _tileWidth;
  late final double _tileHeight;

  final int? xPosUserPosition;
  final int? yPosUserPosition;

  final int? xPosDestinationPosition;
  final int? yPosDestinationPosition;

  late final List<List<GridTile>> _occupancyGrid = [];
  List<GridTile> path = [];

  MySketch({
    required this.xPosUserPosition,
    required this.yPosUserPosition,
    required this.xPosDestinationPosition,
    required this.yPosDestinationPosition,
  });

  @override
  Future<void> setup() async {
    _imageFloorPlan = await loadImage(
        './lib/assets/images/AURAK_Master_Plan_BuildingK_AlgorithmImage.jpg');
    size(
      width: _imageFloorPlan.width,
      height: _imageFloorPlan.height,
    );

    await image(image: _imageFloorPlan);

    await _imageFloorPlan.loadPixels(); // load the pixels of the image.

    await loadPixels(); // load the pixels of the sketch object canvas.

    var imagePixelList = _imageFloorPlan.pixels.buffer.asUint32List();
    var canvasPixelList = pixels!.buffer.asUint32List();

    for (int x = 0; x < _imageFloorPlan.width; x++) {
      for (int y = 0; y < _imageFloorPlan.height; y++) {
        int pixelColorValue = imagePixelList[x + y * _imageFloorPlan.width];
        if (Color(pixelColorValue).computeLuminance() < 0.3) {
          canvasPixelList[x + y * _imageFloorPlan.width] = Colors.black.value;
        } else {
          canvasPixelList[x + y * _imageFloorPlan.width] = Colors.white.value;
        }
      }
    }

    await updatePixels();

    _tileWidth = width / _columns;
    _tileHeight = height / _rows;

    await loadPixels();

    for (int x = 0; x < _columns; x++) {
      List<GridTile> gridColumn = [];
      for (int y = 0; y < _rows; y++) {
        // TODO: taken out (optimization)
        // var currentImageTile = await getRegion(
        //   x: (x * _tileWidth).toInt(),
        //   y: (y * _tileHeight).toInt(),
        //   width: _tileWidth.toInt(),
        //   height: _tileHeight.toInt(),
        // );

        // var imageTileData = await currentImageTile.toByteData();
        // var imageList = imageTileData!.buffer.asUint32List();

        // bool isWalkableRegion = true;
        // for (int i = 0; i < imageList.length; i++) {
        //   if (Color(imageList[i]) == Colors.black) {
        //     isWalkableRegion = false;
        //     break;
        //   }
        // }
        // TODO: taken out (optimization)

        bool isWalkableRegion = true;

        double regionStartX = x * _tileWidth;
        double regionStartY = y * _tileHeight;
        double regionEndX = regionStartX + _tileWidth;
        double regionEndY = regionStartY + _tileHeight;

        outerLoop:
        for (double i = regionStartX; i < regionEndX; i++) {
          for (double j = regionStartY; j < regionEndY; j++) {
            int pixelColorValue =
                pixels!.buffer.asUint32List()[i.toInt() + j.toInt() * width];

            if (Color(pixelColorValue) == Colors.black) {
              isWalkableRegion = false;
              break outerLoop;
            }
          }
        }

        if (isWalkableRegion) {
          GridTile gridTile = GridTile(
            isWalkable: true,
            posX: x,
            posY: y,
          );
          gridColumn.add(gridTile);

          // Uncomment to display walkable tiles.
          // fill(color: Colors.green);
          // rect(
          //   rect: Rect.fromLTWH(
          //     x * _tileWidth,
          //     y * _tileHeight,
          //     _tileWidth,
          //     _tileHeight,
          //   ),
          // );
          // Uncomment to display walkable tiles.
        } else {
          GridTile gridTile = GridTile(
            isWalkable: false,
            posX: x,
            posY: y,
          );
          gridColumn.add(gridTile);
          // Uncomment to display unwalkable tiles.
          // fill(color: Colors.red);
          // rect(
          //   rect: Rect.fromLTWH(
          //     x * _tileWidth,
          //     y * _tileHeight,
          //     _tileWidth,
          //     _tileHeight,
          //   ),
          // );
          // Uncomment to display unwalkable tiles.
        }
      }
      _occupancyGrid.add(gridColumn);
    }

    _imageFloorPlan =
        await loadImage('./lib/assets/images/AURAK_Master_Plan_BuildingK.jpg');

    await image(image: _imageFloorPlan);

    // Optimization: No need to add neighbors for each GridTile.
    // for (int x = 0; x < _columns; x++) {
    //   for (int y = 0; y < _rows; y++) {
    //     _occupancyGrid[x][y].addNeighbors(_occupancyGrid, _columns, _rows);
    //   }
    // }
    // TODO: No need to add neighbors for each GridTile.
  }

  @override
  Future<void> draw() async {
    noLoop(); // Draw once and don't loop the draw() function.

    if (xPosUserPosition != null &&
        yPosUserPosition != null &&
        xPosDestinationPosition != null &&
        yPosDestinationPosition != null) {
      GridTile destinationTile =
          _occupancyGrid[xPosDestinationPosition!][yPosDestinationPosition!];
      GridTile startingTile =
          _occupancyGrid[xPosUserPosition!][yPosUserPosition!];

      fill(color: primaryYellowColor);
      noStroke();
      circle(
        center: Offset(
          destinationTile.posX.toDouble() * _tileWidth + _tileWidth / 2,
          destinationTile.posY.toDouble() * _tileHeight + _tileHeight / 2,
        ),
        diameter: _tileWidth * 1.5,
      );

      fill(color: primaryRedColor);
      noStroke();
      circle(
        center: Offset(
          startingTile.posX.toDouble() * _tileWidth + _tileWidth / 2,
          startingTile.posY.toDouble() * _tileHeight + _tileHeight / 2,
        ),
        diameter: _tileWidth * 1.5,
      );

      path = aStarAlgorithm(
        _occupancyGrid,
        startingTile,
        destinationTile,
      );

      // DISPLAY THE PATHLIST PATH (BEGINNING)
      beginShape();
      for (int i = 0; i < path.length; i++) {
        GridTile currentTile = path[i];
        // if (currentTile != startingTile && currentTile != destinationTile) {
        noFill();
        stroke(color: Colors.blue);
        strokeWeight(3);

        vertex(currentTile.posX * _tileWidth + _tileWidth / 2,
            currentTile.posY * _tileHeight + _tileHeight / 2);
        // }
      }
      endShape();
      // DISPLAY THE PATHLIST PATH (END)
    }
  }
}

// -=-=--=----=-=-=-=-=-=-=-==-=-=-=-=-=-=-=-==-=-=-=-=-

double getManhattanHeuristic(GridTile gridTile1, GridTile gridTile2) {
  return ((gridTile1.posX - gridTile2.posX).abs() +
          (gridTile1.posY - gridTile2.posY).abs())
      .toDouble();
}

class GridTile {
  bool isWalkable;
  //
  int posX;
  int posY;
  //
  double f = 1 / 0;
  double g = 1 / 0;
  double h = 1 / 0;
  //
  GridTile? previousGridTile;
  List<GridTile> neighbors = [];

  GridTile({
    required this.isWalkable,
    required this.posX,
    required this.posY,
  });

  void addNeighbors(List<List<GridTile>> grid, int gridWidth, int gridHeight) {
    // We will only consider vertical and horizontal movement to eliminate 'cutting corners'.
    // No diagonol movement.

    // Add the tile above... only if posY is greater than 0
    // Tile cant have anything on top of it if it is already at the top edge.
    if (posY > 0 && grid[posX][posY - 1].isWalkable) {
      neighbors.add(grid[posX][posY - 1]);
    }

    // Add the tile below... only if posY is less than (height - 1).
    // Tile cant have anything below it if it is already at the bottom edge.
    if (posY < (gridHeight - 1) && grid[posX][posY + 1].isWalkable) {
      neighbors.add(grid[posX][posY + 1]);
    }

    // Add the tile to the left... only if posX is greater than 0.
    // Tile cant have anything to the left of it if it is already at the left edge.
    if (posX > 0 && grid[posX - 1][posY].isWalkable) {
      neighbors.add(grid[posX - 1][posY]);
    }

    // Add the tile to the right... only if posX is less than (width - 1).
    // Tile cant have anything to the right of it if it is already at the right edge.
    if (posX < (gridWidth - 1) && grid[posX + 1][posY].isWalkable) {
      neighbors.add(grid[posX + 1][posY]);
    }
  }
}

List<GridTile> aStarAlgorithm(
  List<List<GridTile>> gridMatrix,
  GridTile startNode,
  GridTile destinationNode,
) {
  List<GridTile> openList = [];
  List<GridTile> closedList = [];
  List<GridTile> finalPathList = [];

  startNode.g = 0;
  startNode.h = getManhattanHeuristic(startNode, destinationNode);
  startNode.f = startNode.h;

  openList.add(startNode);

  while (openList.isNotEmpty) {
    // Get the node with the least 'f' score. (BEGINNING)
    int fLowestScoreIndex = 0;
    for (int i = 0; i < openList.length; i++) {
      if (openList[i].f < openList[fLowestScoreIndex].f) {
        fLowestScoreIndex = i;
      }
    }

    GridTile currentNode = openList[fLowestScoreIndex];
    // Get the node with the least 'f' score. (END)

    openList.remove(currentNode);
    closedList.add(currentNode);

    // Destination Reached, therefore backtrack to find path. (BEGINNING)
    if (currentNode == destinationNode) {
      finalPathList.add(currentNode);
      while (currentNode.previousGridTile != null) {
        finalPathList.add(currentNode.previousGridTile!);
        currentNode = currentNode.previousGridTile!;
      }
      return finalPathList;
    }
    // Destination Reached, therefore backtrack to find path. (END)

    currentNode.addNeighbors(
      gridMatrix,
      gridMatrix[0].length,
      gridMatrix.length,
    );

    for (GridTile neighbor in currentNode.neighbors) {
      if (closedList.contains(neighbor)) {
        continue;
      } else {
        double gPotentialScore = currentNode.g + 1;

        if (openList.contains(neighbor)) {
          if (gPotentialScore < neighbor.g) {
            neighbor.g = gPotentialScore;
            neighbor.f = neighbor.g + neighbor.h;
            neighbor.previousGridTile = currentNode;
          }
        } else {
          neighbor.g = gPotentialScore;
          neighbor.h = getManhattanHeuristic(neighbor, destinationNode);
          neighbor.f = neighbor.g + neighbor.h;
          neighbor.previousGridTile = currentNode;

          openList.add(neighbor);
        }
      }
    }
  }

  return [];
}
