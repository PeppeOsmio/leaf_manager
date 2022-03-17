import 'package:flutter/material.dart';
import 'package:leaf_03/animation/fade_animation.dart';
import 'package:leaf_03/db.dart';
import 'package:leaf_03/exceptions.dart';
import 'package:leaf_03/localization.dart';
import 'package:leaf_03/miscellaneous/helper.dart';
import 'package:leaf_03/miscellaneous/ui.dart';
import 'package:leaf_03/pages/dashboard_screen.dart';
import 'package:leaf_03/pages/landing_screen.dart';
import 'package:leaf_03/pages/login_screen.dart';
import 'package:leaf_03/widgets/floaty_buttons.dart';
import 'package:leaf_03/widgets/round_checkbox_tile.dart';
import 'package:leaf_03/widgets/text_field_label.dart';
import 'package:leaf_03/widgets/toolbar.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SignupScreenState();
  }
}

class SignupScreenState extends State<SignupScreen> {
  late bool _mObscurePassword;
  late bool _isFirstNameValid, _isLastNameValid, _isEmailValid;
  late List<bool> _isPasswordValid;
  bool _isPressed = false;

  late TextEditingController _firstNameController,
      _lastNameController,
      _emailController,
      _passwordController;

  @override
  void initState() {
    super.initState();
    _mObscurePassword = true;
    _isFirstNameValid = _isLastNameValid = _isEmailValid = false;
    _isPasswordValid = [
      false, // must have at least 8 characters
      false, // must have lowercase and uppercase letters
      false // must contain a special character or a number
    ];

    _firstNameController = TextEditingController()
      ..addListener(() {
        if (_firstNameController.text.isNotEmpty != _isFirstNameValid) {
          setState(() {
            _isFirstNameValid = !_isFirstNameValid;
          });
        }
      });

    _lastNameController = TextEditingController()
      ..addListener(() {
        _isLastNameValid = _lastNameController.text.isNotEmpty;
      });

    _emailController = TextEditingController()
      ..addListener(() {
        final bool valid = Helper.isEmailValid(_emailController.text);
        if (valid != _isEmailValid) {
          setState(() {
            _isEmailValid = valid;
          });
        }
      });
    _passwordController = TextEditingController()
      ..addListener(() {
        if (_passwordController.text.isEmpty) {
          setState(() {
            _isPasswordValid = [false, false, false];
          });
          return;
        }

        final valid = Helper.isPasswordValid(_passwordController.text);

        if (_isPasswordValid != valid) {
          setState(() {
            _isPasswordValid = valid;
          });
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    int ttbDelayIndex = 0; // Top to bottom delay index.
    int bttDelayIndex = 0; // Bottom to top delay index.
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: Toolbar(
        navigationItem: ActionItem(
          icon: Icon(
            Icons.chevron_left_outlined,
            color: UI.textPrimaryColor(context),
          ),
          onPressed: () {
            if(!_isPressed){
              _isPressed = true;
              Route route = PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const LandingScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) =>
                        FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                transitionDuration: const Duration(milliseconds: 500));
            Navigator.pushReplacement(context, route);
            }else{
              return;
            }
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
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
                          child: Text(
                            Localization.of(context)
                                .getString("signup-title"),
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
                          Row(
                            children: [
                              Expanded(
                                child: FadeAnimation(
                                  delay: Duration(
                                      milliseconds: 300 * (ttbDelayIndex++)),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextFormFieldLabel(
                                        label: Localization.of(context)
                                            .getString("input-first-name"),
                                      ),
                                      TextFormField(
                                        maxLines: 1,
                                        controller: _firstNameController,
                                        decoration: InputDecoration(
                                            filled: true,
                                            fillColor:
                                                UI.textfieldBackgroundColor(
                                                    context),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 16.0,
                                                    horizontal: 16.0),
                                            hintText: "John",
                                            hintStyle: UI.textStyle(
                                                typeface: UI.headline4
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.w400),
                                                color: UI.textSecondaryColor(
                                                    context)),
                                            border: OutlineInputBorder(
                                                borderSide: BorderSide.none,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        12.0))),
                                        style: UI.textStyle(
                                            typeface: UI.headline4.copyWith(
                                                fontWeight: FontWeight.w400),
                                            color:
                                                UI.textPrimaryColor(context)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 16,
                              ),
                              Expanded(
                                child: FadeAnimation(
                                  delay: Duration(
                                      milliseconds: 300 * (ttbDelayIndex++)),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextFormFieldLabel(
                                        label: Localization.of(context)
                                            .getString("input-last-name"),
                                      ),
                                      TextFormField(
                                        maxLines: 1,
                                        controller: _lastNameController,
                                        decoration: InputDecoration(
                                            filled: true,
                                            fillColor:
                                                UI.textfieldBackgroundColor(
                                                    context),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 16.0,
                                                    horizontal: 16.0),
                                            hintText: "Doe",
                                            hintStyle: UI.textStyle(
                                                typeface: UI.headline4
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.w400),
                                                color: UI.textSecondaryColor(
                                                    context)),
                                            border: OutlineInputBorder(
                                                borderSide: BorderSide.none,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        12.0))),
                                        style: UI.textStyle(
                                            typeface: UI.headline4.copyWith(
                                                fontWeight: FontWeight.w400),
                                            color:
                                                UI.textPrimaryColor(context)),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                          FadeAnimation(
                            delay: Duration(
                                milliseconds: 300 * (ttbDelayIndex++)),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormFieldLabel(
                                    label: Localization.of(context)
                                        .getString("input-email"),
                                  ),
                                  TextFormField(
                                    maxLines: 1,
                                    controller: _emailController,
                                    autocorrect: false,
                                    decoration: InputDecoration(
                                        filled: true,
                                        fillColor:
                                            UI.textfieldBackgroundColor(
                                                context),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 16.0,
                                                horizontal: 16.0),
                                        hintText: "john.doe123@example.com",
                                        hintStyle: UI.textStyle(
                                            typeface: UI.headline4.copyWith(
                                                fontWeight: FontWeight.w400),
                                            color: UI
                                                .textSecondaryColor(context)),
                                        suffixIconConstraints:
                                            const BoxConstraints(
                                                maxWidth: 36.0,
                                                maxHeight: 24.0),
                                        suffixIcon: _isEmailValid
                                            ? Padding(
                                                padding:
                                                    const EdgeInsets.only(
                                                        right: 12.0),
                                                child: FadeAnimation(
                                                  direction:
                                                      FadeDirection.none,
                                                  duration: const Duration(
                                                      milliseconds: 150),
                                                  child: Icon(
                                                      Icons.check_outlined,
                                                      color:
                                                          UI.textPrimaryColor(
                                                              context)),
                                                ),
                                              )
                                            : null,
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
                            delay: Duration(
                                milliseconds: 300 * (ttbDelayIndex++)),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormFieldLabel(
                                    label: Localization.of(context)
                                        .getString("input-password"),
                                  ),
                                  TextFormField(
                                    maxLines: 1,
                                    controller: _passwordController,
                                    obscureText: _mObscurePassword,
                                    obscuringCharacter: "●",
                                    autocorrect: false,
                                    decoration: InputDecoration(
                                        filled: true,
                                        fillColor:
                                            UI.textfieldBackgroundColor(
                                                context),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 16.0,
                                                horizontal: 16.0),
                                        hintText: _mObscurePassword
                                            ? "●●●●●●●●"
                                            : "\$Leaf007",
                                        hintStyle: UI.textStyle(
                                            typeface: UI.headline4.copyWith(
                                                fontWeight: FontWeight.w400),
                                            color: UI
                                                .textSecondaryColor(context)),
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
                                                _mObscurePassword =
                                                    !_mObscurePassword;
                                              }),
                                              customBorder:
                                                  const CircleBorder(),
                                              child: Icon(
                                                  _mObscurePassword
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
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 16.0,
                                left: 4.0,
                                right: 4.0,
                                bottom: 24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FadeAnimation(
                                  delay: Duration(
                                      milliseconds: 300 * ttbDelayIndex),
                                  child: RoundCheckBoxTile(
                                    enabled: _isPasswordValid[0],
                                    title: Localization.of(context)
                                        .getString("password-requirement-0"),
                                  ),
                                ),
                                FadeAnimation(
                                  delay: Duration(
                                      milliseconds: 300 * ttbDelayIndex),
                                  child: RoundCheckBoxTile(
                                    enabled: _isPasswordValid[1],
                                    title: Localization.of(context)
                                        .getString("password-requirement-1"),
                                  ),
                                ),
                                FadeAnimation(
                                  delay: Duration(
                                      milliseconds: 300 * ttbDelayIndex),
                                  child: RoundCheckBoxTile(
                                    enabled: _isPasswordValid[2],
                                    title: Localization.of(context)
                                        .getString("password-requirement-2"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )),
            Padding(
              padding:
                  const EdgeInsets.only(left: 24.0, bottom: 24.0, right: 24.0),
              child: Column(
                children: [
                  FadeAnimation(
                    direction: FadeDirection.bottomToTop,
                    delay: Duration(milliseconds: 300 * (bttDelayIndex++)),
                    child: FloatyWidgetButton.primary(
                        onPressed: () async {
                          if (_isPasswordValid[0] &&
                              _isPasswordValid[1] &&
                              _isPasswordValid[2]) {
                            //con il try/catch java style non puoi usare future.then
                            //ma devi assegnare il future completato a una variabile
                            if(!_isPressed){
                              _isPressed = true;
                              try {
                              User signInUser;
                              signInUser = await Helper.register2(
                                  _firstNameController.text,
                                  _lastNameController.text,
                                  _emailController.text,
                                  _passwordController.text);
                              Helper.writeUserCredentials(Credentials(
                                  _emailController.text,
                                  _passwordController.text));
                              Route route = MaterialPageRoute(
                                  builder: (context) => DashboardScreen(
                                        user: signInUser,
                                      ));
                              Navigator.pushReplacement(context, route);
                            } on RegisterException catch (e) {
                              _isPressed = false;
                              Helper.showSnackBar(
                                  message: Text(
                                    Localization.of(context)
                                        .getString(e.message.toString()),
                                    style: UI.textStyle(
                                        typeface: UI.body,
                                        color:
                                            UI.textPrimaryColorDark(context)),
                                  ),
                                  context: context,
                                  snackBarBehavior: SnackBarBehavior.floating);
                            } catch (e) {
                              _isPressed = false;
                              Helper.showSnackBar(
                                  message: Text(Localization.of(context)
                                      .getString("network-error")),
                                  context: context,
                                  snackBarBehavior: SnackBarBehavior.floating);
                              }
                            }else{//se il pulsante è già stato premuto e non ci sono errori
                              return;
                            }
                          } else {
                            Helper.showSnackBar(
                                message: Text(Localization.of(context)
                                    .getString("invalid-password")),
                                context: context,
                                snackBarBehavior: SnackBarBehavior.floating);
                          }
                        },
                        child: SizedBox(
                          height: 52,
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              Localization.of(context)
                                  .getString("signup-create-button"),
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
                              if(!_isPressed){
                                _isPressed = true;
                                Route route = PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
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
                              }else{
                                return;
                              }
                            },
                            child: SizedBox(
                              height: 52,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    Localization.of(context)
                                        .getString("already-have-account"),
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
