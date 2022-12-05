
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_diary_front/controller/diary_repository.dart';

import '../dto/TravelList_travels.dart';

class TravelListProvider extends ChangeNotifier {

  DiaryRepository _diaryRepository = DiaryRepository();
  List<Travels> _travels = [];
  bool isdelete = false;
  bool isupdate = false;

  List<Travels> get travels => _travels;
  travelList(LatLng travelLatLng) async {
    List<Travels> travels = await _diaryRepository.fetchTravelList(travelLatLng);
    _travels = travels;
    notifyListeners();
  }

  travelDelete(int id) async {
    notifyListeners();
    int response = (await _diaryRepository.fetchTravelDelete(id))!;
    if (response == 200) {
      isdelete == true;
    }
    notifyListeners();
  }
}