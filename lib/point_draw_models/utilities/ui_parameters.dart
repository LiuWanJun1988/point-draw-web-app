import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const double textFieldHeight = 40;
const double textFieldLabelWidth = 120;
const double toolBarHeight = 40;
const double appBarHeight = 36;
const double sideBarWidth = 40;
const double tabBarHeight = 58;
const double fieldButtonWidth = 70;
const double cupertinoPickerItemHeight = 36;
const double selectedTextInputHeight = 30;
const double buttonLabelHeight = 30;
const double buttonSize = 50;
const double actionButtonSize = 28;

const double tabIconSize = 20;
const double requestItemIconSize = 32;
const double popupMenuItemIconSize = 24;
const double inlineIconSize = 20;

const double kDrawerWidth = 304.0;
const double drawItemHeight = 40;
const double kDrawerEdgeDragWidth = 20.0;
const double kDrawerMinFlingVelocity = 365.0;

const double bottomNavigationBarHeight = 48.0;
const double kDrawPadBaseWidth = 350; // to update if the drawing pad size changes due to change of UI etc.
const double kDrawPadBaseHeight = 213.8; // to update if the drawing pad size changes due to change of UI etc.
const double kButtonBarHeight = 42;

const double profilePicSize = 50;
const double chatEntryHeight = 32;
const double projectBannerWidth = 200;

const double textAreaWidthBuffer = 2;
const double defaultPanelElevation = 0.0;
const double controlPointSize = 8.0;

const double colorSelectorElevation = 6.0;

const Duration kDrawerBaseSettleDuration = Duration(milliseconds: 246);
const Size textFieldSize = Size(96, 20);

const TextStyle radioLabelTextStyle = TextStyle(fontSize: 14, color: Colors.black);

const EdgeInsets screenEdgeInsets = EdgeInsets.symmetric(horizontal:10, vertical:5);
const EdgeInsets profileImageEdgeInsets = EdgeInsets.symmetric(horizontal:0, vertical:0);
const EdgeInsets textSpanContainerEdgeInsets = EdgeInsets.symmetric(horizontal:10, vertical:5);
const EdgeInsets textParagraphEdgeInsets = EdgeInsets.fromLTRB(10,2,10,2);
const EdgeInsets textInputContainerEdgeInsets = EdgeInsets.fromLTRB(0,5,0,5);
const EdgeInsets textInputTextFieldEdgeInsets = EdgeInsets.fromLTRB(8,5,5,12);
const EdgeInsets textInputSelectedFieldEdgeInsets = EdgeInsets.fromLTRB(8, 4, 0, 4);
const EdgeInsets textInputSelectedFieldEdgeInsets2 = EdgeInsets.fromLTRB(8, 12, 0, 4);
const EdgeInsets singleLineTextEdgeInsets = EdgeInsets.symmetric(horizontal: 10, vertical:5);
const EdgeInsets fieldButtonEdgeInsets = EdgeInsets.symmetric(horizontal: 5,vertical: 3);
const EdgeInsets interButtonEdgeInsets = EdgeInsets.symmetric(horizontal: 4);
const EdgeInsets tabBarBottomMargin = EdgeInsets.fromLTRB(0,0,0,2);
const EdgeInsets interLineEdgeInsets = EdgeInsets.only(bottom: 3.0);
const EdgeInsets searchPanelEdgeInsets = EdgeInsets.symmetric(horizontal: 5, vertical: 5);
const EdgeInsets searchInputEdgeInsets = EdgeInsets.symmetric(horizontal: 0, vertical: 8);
const EdgeInsets searchResultHeaderEdgeInsets = EdgeInsets.fromLTRB(10, 5, 0, 10);
const EdgeInsets searchResultItemEdgeInsets = EdgeInsets.symmetric(horizontal: 10, vertical: 5);
const EdgeInsets searchResultPanelEdgeInsets = EdgeInsets.symmetric(horizontal: 10, vertical: 10);


const EdgeInsets drawItemEdgeInsets = EdgeInsets.symmetric(horizontal:10, vertical:5);
const EdgeInsets drawSubItemEdgeInsets = EdgeInsets.fromLTRB(40, 5, 0, 5);

// Border radius
const BorderRadius appBarTopBorderRadius = BorderRadius.only(bottomLeft:Radius.circular(20),bottomRight:Radius.circular(20));
const BorderRadius drawerBorderRadius = BorderRadius.only(bottomLeft:Radius.circular(20),topLeft:Radius.circular(20));
const BorderRadius drawerHeaderBorderRadius = BorderRadius.only(topLeft:Radius.circular(20));//, bottomLeft:Radius.circular(20), bottomRight: Radius.circular(20));
final BorderRadius smallBorderRadius = BorderRadius.circular(6);
final BorderRadius standardBorderRadius = BorderRadius.circular(12);
final BorderRadius mediumBorderRadius = BorderRadius.circular(16);
final BorderRadius largeBorderRadius = BorderRadius.circular(20);
final BorderRadius extraSmallBorderRadius = BorderRadius.circular(3);

Color primaryThemeColor = Colors.indigo.shade900;
Color secondaryThemeColor = Colors.amber;

// Landing pages theme data
var backgroundColor = Colors.indigo.shade900;
var kPrimaryColor = Colors.white;
var kButtonColor = Colors.amber;
var kButtonHoverColor = Colors.amber;
const kSecondaryColor = Colors.white;
const kTextColor = Colors.white;
double horizontalMargin = 240;
double mobileHorizontalMargin = 40;