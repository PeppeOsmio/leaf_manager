import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:leaf_03/animation/fade_animation.dart';
import 'package:leaf_03/db.dart';
import 'package:leaf_03/exceptions.dart';
import 'package:leaf_03/localization.dart';
import 'package:leaf_03/miscellaneous/helper.dart';
import 'package:leaf_03/miscellaneous/ui.dart';
import 'package:leaf_03/pages/landing_screen.dart';
import 'package:leaf_03/pages/signup_screen.dart';
import 'package:leaf_03/widgets/floaty_buttons.dart';
import 'package:leaf_03/widgets/text_field_label.dart';
import 'package:leaf_03/widgets/toolbar.dart';

import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return LoginScreenState();
  }
}

class LoginScreenState extends State<LoginScreen> {
  late bool mObscurePassword;
  bool _isPressed = false;

  //servono a controllare i campi di inserimento del testo
  final TextEditingController _emailController = TextEditingController(),
      _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    mObscurePassword = true;
  }

  @override
  Widget build(BuildContext context) {
    int ttbDelayIndex = 0; // Top to bottom delay index.
    int bttDelayIndex = 0; // Bottom to top delay index.
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            FadeAnimation(
              delay: Duration(milliseconds: 300 * (ttbDelayIndex++)),
              //toolbar di sopra
              child: Toolbar(
                navigationItem:
                    //bottone per andare indietro
                    ActionItem(
                  icon: Icon(
                    Icons.chevron_left_outlined,
                    color: UI.textPrimaryColor(context),
                  ),
                  onPressed: () {
                    if (!_isPressed) {
                      _isPressed = true;
                      Route route = PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const LandingScreen(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) =>
                                  FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                          transitionDuration:
                              const Duration(milliseconds: 500));
                      Navigator.pushReplacement(context, route);
                    } else {
                      return;
                    }
                  },
                ),
              ),
            ),
            Expanded(
                child: SizedBox(
              width: double.infinity,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: FractionallySizedBox(
                        widthFactor: 0.8,
                        child: FadeAnimation(
                          delay:
                              Duration(milliseconds: 300 * (ttbDelayIndex++)),
                          child:
                              //titolo della pagina di login
                              Text(
                            Localization.of(context).getString("login-title"),
                            style: UI.textStyle(
                                typeface: UI.headline0,
                                color: UI.textPrimaryColor(context)),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FadeAnimation(
                            delay:
                                Duration(milliseconds: 300 * (ttbDelayIndex++)),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //campo per la email
                                  TextFormFieldLabel(
                                    label: Localization.of(context)
                                        .getString("input-email"),
                                  ),
                                  TextFormField(
                                    maxLines: 1,
                                    autocorrect: false,
                                    controller: _emailController,
                                    decoration: InputDecoration(
                                        filled: true,
                                        fillColor: UI
                                            .textfieldBackgroundColor(context),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 16.0,
                                                horizontal: 16.0),
                                        hintText: "john.doe123@example.com",
                                        hintStyle: UI.textStyle(
                                            typeface: UI.headline4.copyWith(
                                                fontWeight: FontWeight.w400),
                                            color:
                                                UI.textSecondaryColor(context)),
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                            borderRadius:
                                                BorderRadius.circular(12.0))),
                                    style: UI.textStyle(
                                        typeface: UI.headline4.copyWith(
                                            fontWeight: FontWeight.w400),
                                        color: UI.textPrimaryColor(context)),
                                  ),
                                ]),
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                          FadeAnimation(
                            delay:
                                Duration(milliseconds: 300 * (ttbDelayIndex++)),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //campo per la password
                                  TextFormFieldLabel(
                                    label: Localization.of(context)
                                        .getString("input-password"),
                                  ),
                                  TextFormField(
                                    maxLines: 1,
                                    controller: _passwordController,
                                    obscureText: mObscurePassword,
                                    obscuringCharacter: "●",
                                    autocorrect: false,
                                    decoration: InputDecoration(
                                        filled: true,
                                        fillColor: UI
                                            .textfieldBackgroundColor(context),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 16.0,
                                                horizontal: 16.0),
                                        hintText: mObscurePassword
                                            ? "●●●●●●●●"
                                            : "\$Leaf007",
                                        hintStyle: UI.textStyle(
                                            typeface: UI.headline4.copyWith(
                                                fontWeight: FontWeight.w400),
                                            color:
                                                UI.textSecondaryColor(context)),
                                        suffixIconConstraints:
                                            const BoxConstraints(
                                                maxWidth: 36.0,
                                                maxHeight: 24.0),
                                        suffixIcon: Padding(
                                          padding: const EdgeInsets.only(
                                              right: 12.0),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: () => setState(() {
                                                mObscurePassword =
                                                    !mObscurePassword;
                                              }),
                                              customBorder:
                                                  const CircleBorder(),
                                              child: Icon(
                                                  mObscurePassword
                                                      ? Icons
                                                          .visibility_outlined
                                                      : Icons
                                                          .visibility_off_outlined,
                                                  color: UI.textPrimaryColor(
                                                      context)),
                                            ),
                                          ),
                                        ),
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                            borderRadius:
                                                BorderRadius.circular(12.0))),
                                    style: UI.textStyle(
                                        typeface: UI.headline4.copyWith(
                                            fontWeight: FontWeight.w400),
                                        color: UI.textPrimaryColor(context)),
                                  ),
                                ]),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  FadeAnimation(
                    direction: FadeDirection.bottomToTop,
                    delay: Duration(milliseconds: 300 * (bttDelayIndex++)),
                    child:
                        //bottone per il login
                        FloatyWidgetButton.primary(
                            onPressed: () async {
                              if (!_isPressed) {
                                _isPressed = true;
                                try {
                                  var user = await Helper.login2(
                                      _emailController.text,
                                      _passwordController.text);
                                  Helper.writeUserCredentials(Credentials(
                                      _emailController.text,
                                      _passwordController.text));
                                  Route route = MaterialPageRoute(
                                      builder: (context) =>
                                          DashboardScreen(user: user));
                                  Navigator.pushReplacement(context, route);
                                } on LoginException catch (e) {
                                  log(e.toString());
                                  _isPressed = false;
                                  Helper.showSnackBar(
                                      message: Text(
                                        Localization.of(context)
                                            .getString(e.message.toString()),
                                        style: UI.textStyle(
                                            typeface: UI.body,
                                            color: UI
                                                .textPrimaryColorDark(context)),
                                      ),
                                      context: context,
                                      snackBarBehavior:
                                          SnackBarBehavior.floating);
                                } catch (e) {
                                  _isPressed = false;
                                  log(e.toString());
                                  Helper.showSnackBar(
                                      message: Text(Localization.of(context)
                                          .getString("network-error")),
                                      context: context,
                                      snackBarBehavior:
                                          SnackBarBehavior.floating);
                                }
                              } else {
                                return;
                              }
                            },
                            child: SizedBox(
                              height: 52,
                              child: Container(
                                alignment: Alignment.center,
                                child: Text(
                                  Localization.of(context)
                                      .getString("login-button"),
                                  style: UI.textStyle(
                                      typeface: UI.button,
                                      color: UI.textPrimaryColorDark(context)),
                                ),
                              ),
                            ),
                            context: context),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: FadeAnimation(
                      direction: FadeDirection.bottomToTop,
                      delay: Duration(milliseconds: 300 * (bttDelayIndex++)),
                      child: FloatyWidgetButton.secondary(
                          onPressed: () {},
                          child: SizedBox(
                            height: 52,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                //bottone continua con google
                                Text(
                                  "google",
                                  style: UI.fontAwesomeStyle(
                                      typeface: UI.button,
                                      color: UI.textPrimaryColor(context)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 12.0),
                                  child: Text(
                                    Localization.of(context)
                                        .getString("continue-with-google"),
                                    style: UI.textStyle(
                                        typeface: UI.button,
                                        color: UI.textPrimaryColor(context)),
                                  ),
                                )
                              ],
                            ),
                          ),
                          context: context),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: FadeAnimation(
                        direction: FadeDirection.bottomToTop,
                        delay: Duration(milliseconds: 300 * (bttDelayIndex++)),
                        child: FloatyWidgetButton.tertiary(
                            onPressed: () {
                              Route route = PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      const SignupScreen(),
                                  transitionsBuilder: (context, animation,
                                          secondaryAnimation, child) =>
                                      FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      ),
                                  transitionDuration:
                                      const Duration(milliseconds: 500));
                              Navigator.pushReplacement(context, route);
                            },
                            child: SizedBox(
                              height: 52,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  //bottone "non hai un account"
                                  Text(
                                    Localization.of(context)
                                        .getString("dont-have-account"),
                                    style: UI.textStyle(
                                        typeface: UI.button,
                                        color: UI.textPrimaryColor(context)),
                                  ),
                                ],
                              ),
                            )),
                      ))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
