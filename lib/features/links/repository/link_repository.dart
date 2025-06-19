import '../model/link.dart';

class LinkRepository {
  final List<Link> _links = [];

  List<Link> getLinks() {
    return List.unmodifiable(_links);
  }

  void addLink(Link link) {
    _links.add(link);
  }

  void removeLink(String id) {
    _links.removeWhere((link) => link.id == id);
  }

  void updateLink(Link updatedLink) {
    final index = _links.indexWhere((link) => link.id == updatedLink.id);
    if (index != -1) {
      _links[index] = updatedLink;
    }
  }
} 