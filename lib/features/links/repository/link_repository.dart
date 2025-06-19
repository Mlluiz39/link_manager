import '../model/link.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LinkRepository {
  final List<Link> _links = [];

  List<Link> getLinks() {
    return List.unmodifiable(_links);
  }

  void addLink(Link link) {
    _links.add(link);
    saveLinks();
  }

  void removeLink(String id) {
    _links.removeWhere((link) => link.id == id);
    saveLinks();
  }

  void updateLink(Link updatedLink) {
    final index = _links.indexWhere((link) => link.id == updatedLink.id);
    if (index != -1) {
      _links[index] = updatedLink;
      saveLinks();
    }
  }

  Future<void> saveLinks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonLinks = jsonEncode(_links.map((e) => e.toMap()).toList());
    await prefs.setString('links', jsonLinks);
  }

  Future<void> loadLinks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('links');
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      _links.clear();
      _links.addAll(jsonList.map((e) => Link.fromMap(e)));
    }
  }
}
