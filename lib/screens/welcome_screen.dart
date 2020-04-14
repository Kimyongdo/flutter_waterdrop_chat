import 'package:flash_chat/components/rounded_button.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'login_screen.dart';
import 'registration_screen.dart';

class WelcomeScreen extends StatefulWidget {
  static String id = 'welcome_screen';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

//하나의 애니메이션만 사용할 경우 Single를 사용함.
class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin{

  AnimationController animationController;
  Animation animation;

  //처음 빌드하기전에 컨트롤러를 저장하기.
  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: Duration(seconds: 2),//1초동안
      vsync:this, //this는 WelcomeScreen을 의미함.
//      upperBound: 100.0,//100까지 설정하도록
    );

    //커브애니메이션 만들기 위해서 따로 추가
    //애니메이션컨트롤러 연결해서 현재포지션을 저장하고, curve효과를 넣는다.
    //curve애니메이션에서는 AnimationController의 upperBound가 0~1이여야한다.
    //대신 크기는 animation.value로 정한 이름에서 *100을 곱한다.
   // animation = CurvedAnimation(parent: animationController, curve: Curves.decelerate);

//    animationController.reverse(from: 1.0);
    animationController.forward();//0~1사이

    //forward()라면 complete을
    //revser()라면 dismissed
//    animation.addStatusListener((status) {
//      if(status == AnimationStatus.completed){
//        animationController.reverse(from: 1.0);
//      }else if(status==AnimationStatus.dismissed){
//        animationController.forward();
//      }
//    });

    //트윈애니메이션
//    animation = ColorTween(begin: Colors.white, end: Colors.lightBlueAccent).animate(animationController);
    animationController.addListener(() {
      setState(() {});
      //print(animation.value);
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      backgroundColor: Colors.red.withOpacity(animationController.value), 흰색->빨간색
//      backgroundColor: animation.value,
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Hero(
              tag: 'logo',
              child: Container(
                child: Image.asset('images/waterdrop.png'),
//                    height: animation.value*100,
                height: 60.0,
              ),
            ),
            TextLiquidFill(
              text: 'WATERDROP',
              boxBackgroundColor: Colors.white,
              waveColor: Colors.blueAccent,
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: 40.0,
                fontWeight: FontWeight.bold,
              ),
            ),

            RoundedButton(title: '로그인', colour: Colors.lightBlueAccent,
            onPressed: (){Navigator.pushNamed(context, LoginScreen.id);},
            ),
            RoundedButton(title: '계정 등록', colour: Colors.blueAccent,
              onPressed: (){Navigator.pushNamed(context, RegistrationScreen.id);},
            ),
          ],
        ),
      ),
    );
  }
}
