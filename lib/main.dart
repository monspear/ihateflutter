import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // main 함수에서 async 사용하기 위함
  await Firebase.initializeApp(); // firebase 앱 시작
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const BmiMain(title: 'Bmi 계산기'),
    );
  }
}

class BmiMain extends StatefulWidget {
  const BmiMain({super.key, required this.title});

  final String title;

  @override
  State<BmiMain> createState() => _BmiMainState();
}


class _BmiMainState extends State<BmiMain> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  double height = 0;
  double weight = 0;
  double resultBmi = 0;

  List<String> name = [];
  List<String> result = [];
  List<String> bmiNum = [];
  int n  = 1;
  @override
  void dispose(){ // 위젯을 종료한다는 것을 알리는 함수(자원 해체)
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future insertUser(String name, String result, String bmiNum) async{
    final docUser = FirebaseFirestore.instance.collection('BMIresult').doc(name);
    final json = {
      'bmiNum' : bmiNum,
      'health' : result,
      'name' : name
    };

    await docUser.set(json);
  }
  Future readUser() async{
    /*
    Stream<List<Map<String,dynamic>>> docUser = FirebaseFirestore.instance
        .collection('BMIresult')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc.data()).toList());

     */
    final docUser_length = FirebaseFirestore.instance.collection('BMIresult').get().then(
        (querySnapshot){
          for( var docSnapshot in querySnapshot.docs){
            //print('${docSnapshot.id} => ${docSnapshot.data()}');
            print(docSnapshot.data()['name'].toString());
            //result.add(User().setUser(docSnapshot.data()['name'].toString(),
              //  docSnapshot.data()['health'].toString(),
                //docSnapshot.data()['bmiNum'].toString()));
            //print(result.contains(1));
            //name.add(docSnapshot.data()['name'].toString());
            //result.add(docSnapshot.data()['health'].toString());
            //bmiNum.add(docSnapshot.data()['bmiNum'].toString());
            //n++;
            //print(n);
            print('${docSnapshot.data()['name']}');
            print('${docSnapshot.data()['health']}');
            print('${docSnapshot.data()['bmiNum']}');
          }
        },
    );

    //final snapshot = await docUser.count();
    //print(snapshot);


  }

  Widget returnSizedBox(){
    return SizedBox(
      height: 16,
    );
  }
  Widget returnText(int i){
    return Text('${name[i]}  ${result[i]}  ${bmiNum[i]}',
      style: TextStyle(fontSize: 36),
    );
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("비만도(BMI) 계산기"),
      ),
      body: InteractiveViewer(                          // 화면 확대 축소 담당
        boundaryMargin: const EdgeInsets.all(20.0),
        minScale: 1.0,
        maxScale: 2.0,

        child: Container(
          padding: const EdgeInsets.all(15.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                SizedBox(                             // 텍스트 폼 사이의 틈
                  height: 16.0,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),     // 텍스트 외곽선 그리기
                    hintText: '이름',                   // placeholder
                  ),
                  controller: _nameController,
                  validator: (value){
                    if(value!.trim().isEmpty){
                      return '이름을 입력하세요';
                    } else{
                      return null;
                    }
                  },
                  keyboardType: TextInputType.text, // 문자만 입력 가능하게
                ),
                SizedBox(                             // 텍스트 폼 사이의 틈
                  height: 16.0,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),     // 텍스트 외곽선 그리기
                    hintText: '키',                   // placeholder
                  ),
                  controller: _heightController,
                  validator: (value){
                    if(value!.trim().isEmpty){
                      return '키를 입력하세요';
                    } else{
                      return null;
                    }
                  },
                  keyboardType: TextInputType.number, // 숫자만 입력 가능하게
                ),
                SizedBox(                             // 텍스트 폼 사이의 틈
                  height: 16.0,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),     // 텍스트 외곽선 그리기
                    hintText: '몸무게',                   // placeholder
                  ),
                  controller: _weightController,
                  validator: (value){
                    if(value!.trim().isEmpty){
                      return '몸무게를 입력하세요';
                    } else{
                      return null;
                    }
                  },
                  keyboardType: TextInputType.number, // 숫자만 입력 가능하게
                ),
                Container(
                  margin: EdgeInsets.only(top:16),
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: (){
                      if(_formKey.currentState!.validate()){
                        height = double.parse(_heightController.text.trim());
                        weight = double.parse(_weightController.text.trim());
                        resultBmi = weight / ((height / 100) * (height/100));

                        insertUser((_nameController.text.trim()).toString(), _calcBmi(resultBmi), resultBmi.toString());
                        readUser();
                        Navigator.push(
                            context,
                            MaterialPageRoute(  // BmiReasult 생성자에 이름,키,몸무게값을 전달
                                builder: (context) => BmiReasult(
                                  (_nameController.text.trim()).toString(),
                                  double.parse(_heightController.text.trim()),
                                  double.parse(_weightController.text.trim()),
                                )));
                      }
                    },
                    child: Text("결과"),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget buildIcon(double bmi) {
  if (bmi >= 30) { // 2단계비만 이상일 때, 아이콘
    return Icon(
      Icons.sentiment_very_dissatisfied,
      color: Colors.red,
      size: 100,
    );
  } else if (bmi >= 18.5) { // 2단계비만 미만 정상체중 사이일 때, 아이콘
    return Icon(
      Icons.sentiment_satisfied,
      color: Colors.green,
      size: 100,
    );
  } else { // 저체중일때 아이콘
    return Icon(
      Icons.sentiment_dissatisfied,
      color: Colors.orange,
      size: 100,
    );
  }
}
String _calcBmi(double bmi){
  var result = "저체중";
  if(bmi >= 35){
    result = "고도비만";
  } else if( bmi >= 30){
    result = "2단계비만";
  } else if( bmi >= 25){
    result = "1단계비만";
  } else if( bmi >= 23){
    result = "과체중";
  } else if( bmi >= 18.5){
    result = "정상";
  }

  return result;
}

class BmiReasult extends StatelessWidget{


  late final String name;
  double height = 0;
  double weight = 0;

  BmiReasult(this.name,this.height,this.weight); // 생성자

  @override
  Widget build(BuildContext context){
    final double bmi = weight / ((height / 100) * (height/100));

    return Scaffold(
      appBar: AppBar(
        title: Text("비만도(BMI) 계산기"),
      ),
      body: InteractiveViewer(                          // 화면 확대 축소 담당
        boundaryMargin: const EdgeInsets.all(20.0),
        minScale: 1.0,
        maxScale: 2.0,

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,  // 화면 중앙에 배치
          children: <Widget>[
            Text(' 결과값을 저장하였습니다.',
              style: TextStyle(fontSize: 36),
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              _calcBmi(bmi),
              style: TextStyle(fontSize: 36),
            ),
            SizedBox(
              height: 16,
            ),
            buildIcon(bmi),
          ],
        ),
      ),
    );
  }




}