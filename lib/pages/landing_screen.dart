import 'package:flutter/material.dart';
import 'package:leaf_03/animation/fade_animation.dart';
import 'package:leaf_03/localization.dart';
import 'package:leaf_03/miscellaneous/helper.dart';
import 'package:leaf_03/miscellaneous/ui.dart';
import 'package:leaf_03/pages/login_screen.dart';
import 'package:leaf_03/widgets/floaty_buttons.dart';

// Final version
// TODO: Add moving objects below the text and above the map illustration.
class LandingScreen extends StatefulWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _LandingScreenState();
  }
}

class _LandingScreenState extends State<LandingScreen> {

  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).backgroundColor,
      body: Stack(children: [
        Align(
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            heightFactor: 0.56,
            child: Container(
              foregroundDecoration: BoxDecoration(gradient: LinearGradient(stops: const [0.0, 0.48], begin: Alignment.topCenter, 
              end: Alignment.bottomCenter, colors: [Theme.of(context).backgroundColor, Theme.of(context).backgroundColor.withOpacity(0)])),
              child: Image.asset(
                Helper.isDarkMode(context)
                    ? "assets/images/landing_map_dark.png"
                    : "assets/images/landing_map_light.png",
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              FadeAnimation(
                child: Text(
                  Localization.of(context).getString("landing-title"),
                  style: UI.textStyle(
                      typeface: UI.headline0,
                      color: UI.textPrimaryColor(context)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: FadeAnimation(
                  delay: const Duration(milliseconds: 300),
                  child: Text(
                    Localization.of(context).getString("landing-subtitle"),
                    style: UI.textStyle(
                        typeface: UI.headline3,
                        color: UI.textSecondaryColor(context)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 48.0),
                child: FadeAnimation(
                  delay: const Duration(milliseconds: 600),
                  child: FloatyWidgetButton.primary(
                      context: context,
                      child: SizedBox(
                        height: 52.0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                Localization.of(context)
                                    .getString("landing-go-button"),
                                style: UI.textStyle(
                                  typeface: UI.button,
                                  color: UI.textPrimaryColorDark(context),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Icon(
                                  Icons.arrow_right_alt_outlined,
                                  color: UI.textPrimaryColorDark(context),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      onPressed: (){
                        if(!_isPressed){
                          _isPressed = true;
                          setState(() {
                            Route route = PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        const LoginScreen(),
                                transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) =>
                                    FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                transitionDuration:
                                    const Duration(milliseconds: 500));
                            Navigator.pushReplacement(context, route);
                          });
                        }else{
                          return;
                        }
                      }),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}
