import 'package:flutter/material.dart';
import 'package:leaf_03/db.dart';
import 'package:leaf_03/exceptions.dart';
import 'package:leaf_03/localization.dart';
import 'package:leaf_03/miscellaneous/helper.dart';
import 'package:leaf_03/miscellaneous/ui.dart';
import 'package:leaf_03/pages/dashboard_screen.dart';
import 'package:leaf_03/pages/landing_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Final version
class CircleRevealClipper extends CustomClipper<Path> {
  final Offset center;
  final double radius;

  CircleRevealClipper({this.center = Offset.zero, this.radius = 0.0});

  @override
  Path getClip(Size size) {
    return Path()..addOval(Rect.fromCircle(radius: radius, center: center));
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

// TODO: Match icon and text colors.
class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Loading crop list when application starts.
    CropLoader.getInstance().loadCropList(context);

    // Loading map style when application starts.
    MapTheme.getInstance().loadMapStyles(context);

    //carichiamo le credenziali dell'utente salvate in locale
    Helper.loadUserCredentials().then((value) async {
      //se le troviamo (cioè value!=null) allora facciamo il login
      if (value != null) {
        try {
          var user = await Helper.login2(value.email, value.password);
          Future.delayed(const Duration(milliseconds: 1500), () {
            Navigator.of(context)
                .pushReplacement(_createPageRouteBuilder(DashboardScreen(
              user: user,
            )));
          });
        } on LoginException catch (_) {
          Navigator.of(context)
              .pushReplacement(_createPageRouteBuilder(const LandingScreen()));
        } catch (e) {
          Helper.showSnackBar(
              message: Text(
                Localization.of(context).getString("network-error"),
                style: UI.textStyle(
                    typeface: UI.body, color: UI.textPrimaryColorDark(context)),
              ),
              context: context,
              snackBarBehavior: SnackBarBehavior.floating);
        }
      } else {
        //altrimenti andiamo alla landing screen
        Future.delayed(const Duration(milliseconds: 1500), () {
          Navigator.of(context)
              .pushReplacement(_createPageRouteBuilder(const LandingScreen()));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: Center(
              child: SizedBox(
                width: 192.0,
                height: 192.0,
                child: Image.asset(
                  "assets/images/splash_app_icon.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 24.0,
              right: 24.0,
              bottom: 48.0,
            ),
            child: Column(
              children: [
                Text(
                  "LEAF_03 project from",
                  textAlign: TextAlign.center,
                  style: UI.textStyle(color: UI.textSecondaryColor(context)),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    "Gruppo IS_12",
                    textAlign: TextAlign.center,
                    style: UI.textStyle(
                        typeface:
                            UI.headline3.copyWith(fontWeight: FontWeight.w500),
                        color: UI.applicationBrandColor),
                  ),
                ),
              ],
            ),
          )
        ]),
      ),
    );
  }

  PageRouteBuilder _createPageRouteBuilder(Widget secondPage) {
    return PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var screenSize = MediaQuery.of(context).size;
          Offset center =
              Offset(screenSize.width * 0.5, screenSize.height * 0.5);
          double beginRadius = 0.0;
          double endRadius = screenSize.height * 0.6;

          var tween = Tween(begin: beginRadius, end: endRadius);
          var radiusTweenAnimation = animation.drive(tween);

          return Container(
            width: screenSize.width,
            height: screenSize.height,
            decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.12 * animation.value)),
            child: ClipPath(
              clipper: kIsWeb ? null : CircleRevealClipper(
                  radius: radiusTweenAnimation.value, center: center),
              child: child,
            ),
          );
        },
        pageBuilder: (context, animation, secondaryAnimation) => secondPage);
  }
}
