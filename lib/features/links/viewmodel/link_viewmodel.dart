import 'package:flutter/material.dart';
import '../model/link.dart';
import '../repository/link_repository.dart';

class LinkViewModel extends ChangeNotifier {
  final LinkRepository _repository;

  LinkViewModel(this._repository);

  List<Link> get links => _repository.getLinks();

  void addLink(Link link) {
    _repository.addLink(link);
    notifyListeners();
  }

  void removeLink(String id) {
    _repository.removeLink(id);
    notifyListeners();
  }

  void updateLink(Link link) {
    _repository.updateLink(link);
    notifyListeners();
  }
} 