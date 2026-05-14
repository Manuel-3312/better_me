class SearchHelper {
  static List<T> filterAndSort<T>({
    required List<T> items,
    required String searchQuery,
    required String sortOption,
    required String Function(T) getName,
    required String Function(T) getObjective,
    required int Function(T) getId,
  }) {
    var filteredList = items.where((item) {
      final query = searchQuery.toLowerCase();
      final nameMatches = getName(item).toLowerCase().contains(query);
      final objectiveMatches = getObjective(item).toLowerCase().contains(query);

      return nameMatches || objectiveMatches;
    }).toList();

    if (sortOption == 'az') {
      filteredList.sort(
            (a, b) => getName(a).toLowerCase().compareTo(getName(b).toLowerCase()),
      );
    } else if (sortOption == 'za') {
      filteredList.sort(
            (a, b) => getName(b).toLowerCase().compareTo(getName(a).toLowerCase()),
      );
    } else {
      filteredList.sort((a, b) => getId(b).compareTo(getId(a)));
    }

    return filteredList;
  }
}