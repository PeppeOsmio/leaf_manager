import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:leaf_03/animation/fade_animation.dart';
import 'package:leaf_03/db.dart';
import 'package:leaf_03/localization.dart';
import 'package:leaf_03/miscellaneous/helper.dart';
import 'package:leaf_03/miscellaneous/ui.dart';
import 'package:leaf_03/pages/new_farm_screen.dart';
import 'package:leaf_03/pages/overview_screen.dart';
import 'package:leaf_03/pages/splash_screen.dart';

import 'package:leaf_03/widgets/bottom_navy_bar.dart';
import 'package:leaf_03/widgets/floaty_buttons.dart';

class DashboardScreen extends StatefulWidget {
  final User user;

  const DashboardScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _DashboardScreenState();
  }
}

enum _DashboardScreenEnum { fields, devices, contacts, settings }

class _DashboardScreenState extends State<DashboardScreen> {
  late _DashboardScreenEnum _currentDashboardScreen;

  @override
  void initState() {
    super.initState();
    _currentDashboardScreen = _DashboardScreenEnum.fields;
  }

  @override
  Widget build(BuildContext context) {
    Widget? pageContent;
    switch (_currentDashboardScreen) {
      default:
        pageContent = _FieldsFragment(user: widget.user);
        break;
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).backgroundColor,
      body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300), child: pageContent),
      bottomNavigationBar:
          //bottom navigation bar
          BottomNavyBar(
        selectedItemColor: UI.textPrimaryColor(context),
        decoration: BoxDecoration(
          color: UI.cardBackgroundColor(context),
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32.0), topRight: Radius.circular(32.0)),
        ),
        items: [
          BottomNavyBarItem(icon: Icons.home_outlined, title: "Dashboard"),
          BottomNavyBarItem(
              icon: Icons.devices_outlined,
              title: Localization.of(context).getString("sensors")),
          BottomNavyBarItem(
              icon: Icons.question_answer_outlined,
              title: Localization.of(context).getString("contact-us")),
          BottomNavyBarItem(
              icon: Icons.settings_outlined,
              title: Localization.of(context).getString("settings")),
        ],
        onItemSelected: (index) {
          _currentDashboardScreen = _DashboardScreenEnum.values[index];
        },
      ),
    );
  }
}

class _FieldsFragment extends StatefulWidget {
  final User user;

  const _FieldsFragment({required this.user});

  @override
  State<StatefulWidget> createState() {
    return _FieldsFragmentState();
  }
}

class _FieldsFragmentState extends State<_FieldsFragment> {
  late List<Farm> _farms;
  late CropLoader _cropLoader;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _cropLoader = CropLoader.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SafeArea(
              bottom: false,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: IconButton(
                        onPressed: () async {
                          await Helper.deleteUserCredentials();
                          Route route = MaterialPageRoute(
                              builder: (context) => const SplashScreen());
                          Navigator.pushReplacement(context, route);
                        },
                        icon: Icon(Icons.logout_outlined,
                            color: Helper.isDarkMode(context)
                                ? UI.primaryColorDark
                                : UI.primaryColorLight)),
                  ),
                  const Spacer(),
                  Container(
                      height: 68.0,
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      alignment: Alignment.centerRight,
                      // TODO: Make the profile picture dynamic.
                      //  and add onTap to show profile info.
                      child: Container(
                        width: 36,
                        height: 36,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          boxShadow: const [
                            BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.08),
                                offset: Offset(0.0, 2.0),
                                blurRadius: 12.0)
                          ],
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Material(
                          borderRadius: BorderRadius.circular(12.0),
                          color: UI.toolbarActionButtonColor(context),
                          child: InkWell(
                            onTap: () {},
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Image.asset(
                                "assets/images/avatar.png",
                              ),
                            ),
                          ),
                        ),
                      )),
                ],
              ),
            ),
            FadeAnimation(
              child: Padding(
                  padding:
                      const EdgeInsets.only(left: 24.0, right: 24.0, top: 16.0),
                  child: Text(
                      Localization.of(context)
                              .getString("dashboard-welcome-title") +
                          "\n${widget.user.firstName} ${widget.user.lastName}",
                      style: UI.textStyle(
                          typeface: UI.headline1,
                          color: UI.textPrimaryColor(context)))),
            ),
            _buildFarmListView()
          ],
        ),
        Positioned(
          right: 24.0,
          bottom: 24.0,
          child: FadeAnimation(
            direction: FadeDirection.bottomToTop,
            delay: const Duration(milliseconds: 600),
            child: FloatyActionButton(
              onPressed: () async {
                if (!_isPressed) {
                  _isPressed = true;
                  Route route = MaterialPageRoute(
                      builder: (context) => NewFarmScreen(
                            userId: widget.user.userId,
                          ));
                  await Navigator.push(context, route).then((value) {
                    _isPressed = false;
                    setState(() {});
                  });
                } else {
                  return;
                }
              },
              color: UI.buttonPrimaryColor(context),
              icon: Icon(Icons.add_outlined,
                  color: UI.textPrimaryColorDark(context)),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildFarmListView() {
    return FutureBuilder(
      future: _loadFarmsList(),
      builder: (BuildContext context, AsyncSnapshot<List<Farm>> snapshot) {
        if (snapshot.hasError) {
          return Expanded(
              child: FadeAnimation(
            child: Container(
              padding: const EdgeInsets.only(bottom: 104.0),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Image(
                    image:
                        AssetImage("assets/resources/network_error_state.png"),
                    height: 256.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      Localization.of(context)
                          .getString("generic-error-message"),
                      style: UI.textStyle(
                          typeface: UI.headline4
                              .copyWith(fontWeight: FontWeight.w400),
                          color: UI.textPrimaryColor(context)),
                    ),
                  )
                ],
              ),
            ),
          ));
        }
        if (snapshot.hasData) {
          _farms = snapshot.data!;
          if (_farms.isNotEmpty) {
            return Expanded(
              child: FadeAnimation(
                child: ListView.separated(
                    padding: const EdgeInsets.only(top: 24.0, bottom: 80.0),
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          // TODO: open farm overview
                        },
                        child: _buildFarmListItem(farm: _farms[index]),
                      );
                    },
                    itemCount: _farms.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider(
                        height: 1.0,
                        thickness: 1.0,
                        indent: 24.0,
                        color: UI.dividerColor(context),
                      );
                    }),
              ),
            );
          } else {
            return Expanded(
                child: FadeAnimation(
              child: Container(
                padding: const EdgeInsets.only(bottom: 104.0),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Image(
                      image: AssetImage(
                          "assets/resources/empty_map_list_state.png"),
                      height: 256.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        Localization.of(context).getString("tap-plus"),
                        style: UI.textStyle(
                            typeface: UI.headline4
                                .copyWith(fontWeight: FontWeight.w400),
                            color: UI.textPrimaryColor(context)),
                      ),
                    )
                  ],
                ),
              ),
            ));
          }
        }

        // If it has none of the previous states, then
        // show a loading circle which style will adapt
        // to the used platform.
        return const Expanded(
            child: SizedBox.expand(
                child: FadeAnimation(
                    //il center serve per renderlo più piccolino
                    child:
                        Center(child: CircularProgressIndicator.adaptive()))));
      },
    );
  }

  Widget _buildFarmListItem({required Farm farm}) {
    var crop = _cropLoader.getCropFromId(farm.cropId);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          if (!_isPressed) {
            _isPressed = true;
            Route route = MaterialPageRoute(
              builder: (context) => OverviewScreen(
                farm: farm,
                userId: widget.user.userId,
              ),
            );
            await Navigator.push(context, route).then((value) {
              _isPressed = false;
              setState(() {});
            });
          } else {
            return;
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Row(
            children: [
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.only(right: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      farm.farmName,
                      style: UI.textStyle(
                          typeface: UI.headline3
                              .copyWith(fontWeight: FontWeight.w500),
                          color: UI.textPrimaryColor(context)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        Localization.of(context).getString(crop!.name),
                        style: UI.textStyle(
                            typeface: UI.body,
                            color: UI.textSecondaryColor(context)),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 16.0),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 4.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: UI.applicationBrandColor.withOpacity(0.24)),
                      child: Text(
                        Localization.of(context).getString(crop.type),
                        style: UI.textStyle(
                            typeface:
                                UI.body.copyWith(fontWeight: FontWeight.w500),
                            color: UI.textPrimaryColor(context)),
                      ),
                    )
                  ],
                ),
              )),
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: UI.cropCircleBackgroundColor(context)),
                child: crop != null
                    ? Image(
                        image: AssetImage(
                        "assets/resources/${crop.name}.png",
                      ))
                    : null,
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<List<Farm>> _loadFarmsList() async {
    List<Farm> list = [];
    // I think that's an unnecessary try/catch block
    try {
      await Helper.loadFarmsFromDB(widget.user.userId, context)
          .then((value) => list.addAll(value));
    } catch (e) {
      return Future.error(e);
    }
    return list;
  }
}
