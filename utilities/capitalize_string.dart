String capitalize(String string) {
  if (string.isEmpty) {
    return '';
  }

  List<String> wordsInString = string.split(' ');

  String capitalizedString = '';
  for (String word in wordsInString) {
    capitalizedString += '${word[0].toUpperCase()}${word.substring(
          1,
        ).toLowerCase()} ';
  }

  //Cut the extra space added to the right of the string with trim.
  return capitalizedString.trimRight();
}
