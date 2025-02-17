import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:my_diary_front/controller/provider/diary_image_delete_provider.dart';
import 'package:my_diary_front/controller/provider/diary_image_input_provider.dart';
import 'package:my_diary_front/controller/provider/diary_image_provider.dart';
import 'package:my_diary_front/controller/provider/diary_provider.dart';
import 'package:my_diary_front/util/validator_util.dart';
import 'package:my_diary_front/view/components/ui_view_model.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../../controller/provider/diary_update_provider.dart';
import '../../components/custom_date_picker.dart';
import '../../components/custom_elevated_button.dart';
import '../../components/custom_text_form_field.dart';
import '../../components/custom_textarea.dart';
import 'diary_list_page.dart';

class UpdatePage extends StatefulWidget {
  final int id;
  final int travelId;

  const UpdatePage(this.id, this.travelId);

  @override
  State<UpdatePage> createState() => _UpdatePageState(id, travelId);
}

class _UpdatePageState extends State<UpdatePage> {
  DiaryProvider diaryProvider = DiaryProvider();
  DiaryImageProvider diaryImageProvider = DiaryImageProvider();
  DiaryUpdateProvider diaryUpdateProvider = DiaryUpdateProvider();
  DiaryImageDeleteProvider diaryImageDeleteProvider =
      DiaryImageDeleteProvider();
  DiaryImageInputProvider diaryImageInputProvider = DiaryImageInputProvider();

  final int id;
  final int travelId;

  _UpdatePageState(this.id, this.travelId);

  bool isAwait = false;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    setState(() {
      isAwait = true;
    });
    DiaryProvider diaryProvider =
        Provider.of<DiaryProvider>(context, listen: false);
    await diaryProvider.getdiary(id);
    diaryImageProvider =
        Provider.of<DiaryImageProvider>(context, listen: false);
    await diaryImageProvider.getdiaryImage(id);
    setState(() {
      isAwait = false;
    });
  }

  final _formKey = GlobalKey<FormState>();

  final _title = TextEditingController();
  final _content = TextEditingController();
  final _travel = TextEditingController();
  final _date = TextEditingController();

  final _valueList = ['맑음', '흐림', '약간 흐림', '비', '눈', '바람'];
  var _selectedTitle;
  var _selectedContent;
  var _selectedTravel;
  var _selectedWeather;
  var _selectedDate;

  ScrollController controller = ScrollController();
  final ImagePicker _picker = ImagePicker();
  bool nextIconView = false;
  List<File> updateImage = [];
  List<String> diaryImage = [];

  //List<String> updateImagebase64 = [];

  Widget build(BuildContext context) {
    diaryProvider = Provider.of<DiaryProvider>(context, listen: false);
    diaryImageDeleteProvider =
        Provider.of<DiaryImageDeleteProvider>(context, listen: false);
    diaryImageInputProvider =
        Provider.of<DiaryImageInputProvider>(context, listen: false);

    //DioUpdateImage dioUpdateImage = DioUpdateImage(id);

    UriData? data;
    Uint8List? bytes;

    String inputImage;

    return Stack(
      children: [Container(
        decoration: BoxDecoration(
            image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage('img/bg_write.png'),
        )),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            backgroundColor: Colors.transparent,
            elevation: 0.0,
          ),
          extendBodyBehindAppBar: true,
          body: Consumer<DiaryProvider>(
              builder: (context, DiaryProvider value, child) {
            _travel.text = value.diary.travel!;
            _title.text = value.diary.title!;
            _content.text = value.diary.content!;

            return UiViewModel.buildBackgroundContainer(
              context: context,
              backgroundType: BackgroundType.write,
              child: UiViewModel.buildSizedLayout(
                context,
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Row(
                        children: <Widget>[
                          Expanded(
                              child: CustomDatePicker(
                                  controller: _date,
                                  init: "여행 날짜 선택",
                                  funValidator: validateDate())),
                          Expanded(
                              child: DropdownButton(
                            value: value.diary.weather,
                            items: _valueList.map(
                              (value) {
                                return DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                );
                              },
                            ).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedWeather = value!;
                              });
                            },
                          )),
                          Expanded(
                            child: TextFormField(
                              controller: _travel,
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 10),
                      CustomTextFormField(
                          controller: _title,
                          hint: " ",
                          funValidator: validateTitle()),
                      SizedBox(height: 5),
                      CustomTextArea(
                          controller: _content,
                          hint: " ",
                          funValidator: validateContent()),
                      Consumer<DiaryImageProvider>(
                          builder: (context, DiaryImageProvider value, child) {
                        diaryImage.clear();
                        for (int i = 0;
                            i < value.diaryImage.images!.length;
                            i++) {
                          diaryImage.add(value.diaryImage.images![i].imagefile!);
                        }
                        // int count = 0;
                        // int limitImage() {
                        //   for(int i=0; i<value.diaryImage.images!.length; i++) {
                        //     if(value.diaryImage.images![i] != " ")
                        //       count ++;
                        //   }
                        //   return count;
                        // }
                        // print(diaryImage.length);
                        return Column(
                          children: [
                            SingleChildScrollView(
                                    child: Column(children: <Widget>[
                              Stack(
                                children: <Widget>[
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 200.0,
                                    child: diaryImage[0] == " " &&
                                            diaryImage.length == 1
                                        ? Center(child: Text("이미지를 등록해주세요"))
                                        : ListView.builder(
                                            padding: EdgeInsets.all(10.0),
                                            scrollDirection: Axis.horizontal,
                                            controller: this.controller,
                                            itemCount: diaryImage[0] == "" &&
                                                    diaryImage.length == 1
                                                ? 0
                                                : diaryImage.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              diaryImage[index] == " " ||
                                                      diaryImage[index] == null
                                                  ? data = null
                                                  : data =
                                                      Uri.parse(diaryImage[index])
                                                          .data;
                                              data == null
                                                  ? bytes = null
                                                  : bytes =
                                                      data!.contentAsBytes();
                                              if (bytes != null) {
                                                return Stack(
                                                  children: <Widget>[
                                                    GestureDetector(
                                                      child: Container(
                                                        width: 200.0,
                                                        child: Card(
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20.0)),
                                                          clipBehavior:
                                                              Clip.antiAlias,
                                                          borderOnForeground:
                                                              false,
                                                          child: bytes == null
                                                              ? null
                                                              : Image.memory(
                                                                  bytes!,
                                                                  fit: BoxFit
                                                                      .cover),
                                                        ),
                                                        padding:
                                                            EdgeInsets.all(10.0),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      top: 0,
                                                      right: 0,
                                                      child: GestureDetector(
                                                        onTap: () async {
                                                          //setState(() {
                                                          //diaryImage.removeWhere((element) =>  element.image_id == diaryImage[index].image_id);

                                                          value.getdiaryImage(id);
                                                          if (!(bytes == null)) {
                                                            if (value
                                                                    .diaryImage
                                                                    .images!
                                                                    .length ==
                                                                1) {
                                                              diaryImage.add(" ");
                                                              await diaryImageInputProvider
                                                                  .imageInput(
                                                                      id, " ");
                                                              await diaryImageDeleteProvider
                                                                  .diaryImageDelete(value
                                                                      .diaryImage
                                                                      .images![
                                                                          index]
                                                                      .image_id!);
                                                              await diaryImage
                                                                  .remove(
                                                                      diaryImage[
                                                                          index]);
                                                            } else {
                                                              await diaryImageDeleteProvider
                                                                  .diaryImageDelete(value
                                                                      .diaryImage
                                                                      .images![
                                                                          index]
                                                                      .image_id!);
                                                              await diaryImage
                                                                  .remove(
                                                                      diaryImage[
                                                                          index]);
                                                            }
                                                          }
                                                          value.getdiaryImage(id);

                                                          // if (value.diaryImage.images!.length >= 2) {
                                                          //   nextIconView = true;
                                                          //   return;
                                                          // }
                                                          // nextIconView = false;

                                                          //}});
                                                        },
                                                        child: Container(
                                                            width: 30.0,
                                                            height: 30.0,
                                                            margin:
                                                                EdgeInsets.all(
                                                                    5.0),
                                                            alignment:
                                                                Alignment.center,
                                                            decoration: BoxDecoration(
                                                                color: Colors.red,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            30.0)),
                                                            child: Center(
                                                                child: Icon(
                                                              Icons.close,
                                                              size: 20.0,
                                                              color: Colors.white,
                                                            ))),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              } else {
                                                return SizedBox();
                                              }
                                            }),
                                  ),
                                  !this.nextIconView
                                      ? Container()
                                      : Positioned(
                                          top: 100.0,
                                          right: 10.0,
                                          child: Container(
                                            width: 30.0,
                                            height: 30.0,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(30.0)),
                                            child: Icon(Icons.navigate_next),
                                          ),
                                        )
                                ],
                              )
                            ])),
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: IconButton(
                                    color: diaryImage.length >= 4
                                        ? Colors.white
                                        : Colors.grey,
                                    icon: diaryImage.length >= 4
                                        ? Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                                color:
                                                    Colors.white.withOpacity(0.6),
                                                shape: BoxShape.circle),
                                            child: Icon(
                                              CupertinoIcons.xmark,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ))
                                        : Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                                color:
                                                    Colors.white.withOpacity(0.6),
                                                shape: BoxShape.circle),
                                            child: Icon(
                                              CupertinoIcons.camera,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            )),
                                    onPressed: diaryImage.length >= 4
                                        ? () {
                                            print("이미지 초과");
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                              content: Text('이미지 초과'),
                                            ));
                                          }
                                        : () async {
                                            bool? check = await showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        AlertDialog(
                                                          title: Text(
                                                              "카메라 또는 갤러리를 통해 업로드할 수 있습니다"),
                                                          actions: <Widget>[
                                                            ElevatedButton(
                                                              child: Text("촬영"),
                                                              onPressed: () =>
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop(true),
                                                            ),
                                                            ElevatedButton(
                                                              child: Text("앨범"),
                                                              onPressed: () =>
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop(false),
                                                            ),
                                                            ElevatedButton(
                                                              child: Text("취소"),
                                                              onPressed: () async =>
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop(null),
                                                            ),
                                                          ],
                                                        )) ??
                                                null;
                                            if (check == null) return;
                                            if (check) {
                                              final pickcamera =
                                                  await _picker.pickImage(
                                                      source: ImageSource.camera);
                                              final cfile = File(
                                                  pickcamera!.path.toString());
                                              final stringcfile = base64Encode(
                                                  cfile.readAsBytesSync());
                                              updateImage.add(cfile);
                                              inputImage =
                                                  "data:image/png;base64,${stringcfile}";
                                              diaryImage.add(inputImage);
                                              await diaryImageInputProvider
                                                  .imageInput(id, inputImage);
                                              value.getdiaryImage(id);
                                            } else {
                                              final pickgallery =
                                                  await _picker.pickImage(
                                                      source:
                                                          ImageSource.gallery);
                                              final gfile = File(
                                                  pickgallery!.path.toString());
                                              final stringgfile = base64Encode(
                                                  gfile.readAsBytesSync());
                                              updateImage.add(gfile);
                                              inputImage =
                                                  "data:image/png;base64,${stringgfile}";
                                              diaryImage.add(inputImage);
                                              await diaryImageInputProvider
                                                  .imageInput(id, inputImage);
                                              value.getdiaryImage(id);
                                            }
                                            if (updateImage.length >= 2) {
                                              nextIconView = true;
                                              return;
                                            }
                                            nextIconView = false;
                                            return setState(() {});
                                          },
                                  ),
                                ),
                              ],
                            )
                          ],
                        );
                      }),
                      CustomElavatedButton(
                        text: "수정하기",
                        funPageRoute: () async {
                          _title.text == null
                              ? _selectedTitle = value.diary.title
                              : _selectedTitle = _title.text;
                          _selectedWeather == null
                              ? _selectedWeather = value.diary.weather
                              : _selectedWeather;
                          _content.text == null
                              ? _selectedContent = value.diary.content
                              : _selectedContent = _content.text;
                          _date.text == null
                              ? _selectedDate = DateFormat('yyyy-MM-dd')
                                  .format(value.diary.traveldate!)
                              : _selectedDate = _date.text;
                          _travel.text == null
                              ? _selectedTravel = value.diary.travel
                              : _selectedTravel = _travel.text;
                          if (_formKey.currentState!.validate()) {
                            await diaryUpdateProvider.update(
                                id,
                                _selectedTitle,
                                _selectedDate,
                                _selectedContent,
                                _selectedWeather,
                                _selectedTravel);
                            Get.off(() => DiaryListPage(travelId));
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),        isAwait ? UiViewModel.buildProgressBar() : Container(),]
    );
  }

  void iconView() {
    if (controller.offset >= controller.position.maxScrollExtent) {
      nextIconView = false;
    } else {
      nextIconView = true;
    }
    return;
  }
}
