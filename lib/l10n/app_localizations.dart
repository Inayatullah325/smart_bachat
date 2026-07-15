import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ur.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('ur'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Bachat'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @currentBalance.
  ///
  /// In en, this message translates to:
  /// **'Current Balance'**
  String get currentBalance;

  /// No description provided for @totalIncome.
  ///
  /// In en, this message translates to:
  /// **'Total Income'**
  String get totalIncome;

  /// No description provided for @totalExpenses.
  ///
  /// In en, this message translates to:
  /// **'Total Expenses'**
  String get totalExpenses;

  /// No description provided for @savings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get savings;

  /// No description provided for @addIncome.
  ///
  /// In en, this message translates to:
  /// **'Add Income'**
  String get addIncome;

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpense;

  /// No description provided for @setupTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Smart Bachat'**
  String get setupTitle;

  /// No description provided for @setupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Personalize your experience by choosing your language and currency.'**
  String get setupSubtitle;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @selectCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select Currency'**
  String get selectCurrency;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @proceed.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get proceed;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @urdu.
  ///
  /// In en, this message translates to:
  /// **'Urdu'**
  String get urdu;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get hindi;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @chinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get chinese;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @emptyBalance.
  ///
  /// In en, this message translates to:
  /// **'No balance found'**
  String get emptyBalance;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @languageSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved successfully!'**
  String get languageSaved;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @welcome_back.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcome_back;

  /// No description provided for @login_continue.
  ///
  /// In en, this message translates to:
  /// **'Login to continue your journey'**
  String get login_continue;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgot_password;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'LOGIN'**
  String get login;

  /// No description provided for @dont_have_account.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dont_have_account;

  /// No description provided for @sign_up.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get sign_up;

  /// No description provided for @enter_email_password.
  ///
  /// In en, this message translates to:
  /// **'Please enter both email and password.'**
  String get enter_email_password;

  /// No description provided for @allIncome.
  ///
  /// In en, this message translates to:
  /// **'All Income'**
  String get allIncome;

  /// No description provided for @allExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get allExpenses;

  /// No description provided for @categorySelection.
  ///
  /// In en, this message translates to:
  /// **'Category Selection'**
  String get categorySelection;

  /// No description provided for @searchCategories.
  ///
  /// In en, this message translates to:
  /// **'Search categories...'**
  String get searchCategories;

  /// No description provided for @noCategoriesFound.
  ///
  /// In en, this message translates to:
  /// **'No categories found'**
  String get noCategoriesFound;

  /// No description provided for @tapToSelect.
  ///
  /// In en, this message translates to:
  /// **'Tap to select'**
  String get tapToSelect;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @enterExpenseHere.
  ///
  /// In en, this message translates to:
  /// **'Enter expense here'**
  String get enterExpenseHere;

  /// No description provided for @pleaseSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Please select a date'**
  String get pleaseSelectDate;

  /// No description provided for @pleaseEnterExpense.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid expense amount'**
  String get pleaseEnterExpense;

  /// No description provided for @pleaseEnterPositiveNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid positive number'**
  String get pleaseEnterPositiveNumber;

  /// No description provided for @expenseAdded.
  ///
  /// In en, this message translates to:
  /// **'Expense Added'**
  String get expenseAdded;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @emailCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Email cannot be empty'**
  String get emailCannotBeEmpty;

  /// No description provided for @registrationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registration successful! Please login.'**
  String get registrationSuccess;

  /// No description provided for @fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields.'**
  String get fillAllFields;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @signUpGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Sign up to get started!'**
  String get signUpGetStarted;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'SIGN UP'**
  String get signUp;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @selectImageSource.
  ///
  /// In en, this message translates to:
  /// **'Select Image Source'**
  String get selectImageSource;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Notification'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this? This cannot be undone.'**
  String get deleteConfirmContent;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @dailyNotifications.
  ///
  /// In en, this message translates to:
  /// **'Daily Notifications'**
  String get dailyNotifications;

  /// No description provided for @reminderWithSound.
  ///
  /// In en, this message translates to:
  /// **'Reminder with sound at set time'**
  String get reminderWithSound;

  /// No description provided for @notificationsOff.
  ///
  /// In en, this message translates to:
  /// **'Notifications are turned off'**
  String get notificationsOff;

  /// No description provided for @dailyReminderSet.
  ///
  /// In en, this message translates to:
  /// **'Daily Reminder Set'**
  String get dailyReminderSet;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @recentNotifications.
  ///
  /// In en, this message translates to:
  /// **'Recent Notifications'**
  String get recentNotifications;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsYet;

  /// No description provided for @notificationsWillAppear.
  ///
  /// In en, this message translates to:
  /// **'Fired reminders will appear here.'**
  String get notificationsWillAppear;

  /// No description provided for @enableNotificationsHint.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications to get reminders.'**
  String get enableNotificationsHint;

  /// No description provided for @dailyNotificationsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Daily reminders enabled'**
  String get dailyNotificationsEnabled;

  /// No description provided for @dailyNotificationsTurnedOff.
  ///
  /// In en, this message translates to:
  /// **'Daily reminders turned off'**
  String get dailyNotificationsTurnedOff;

  /// No description provided for @turnOnNotificationsFirst.
  ///
  /// In en, this message translates to:
  /// **'Turn on notifications first'**
  String get turnOnNotificationsFirst;

  /// No description provided for @notificationDeleted.
  ///
  /// In en, this message translates to:
  /// **'Notification deleted'**
  String get notificationDeleted;

  /// No description provided for @successIncomeAdded.
  ///
  /// In en, this message translates to:
  /// **'Success! Income added'**
  String get successIncomeAdded;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @noAccountFound.
  ///
  /// In en, this message translates to:
  /// **'No account found with this email. Please check and try again.'**
  String get noAccountFound;

  /// No description provided for @passwordResetSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Password Reset!'**
  String get passwordResetSuccessTitle;

  /// No description provided for @passwordResetSuccessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your new password is ready'**
  String get passwordResetSuccessSubtitle;

  /// No description provided for @passwordResetSuccessCopyHint.
  ///
  /// In en, this message translates to:
  /// **'Copy this password and use it to login. You can change it in your profile settings.'**
  String get passwordResetSuccessCopyHint;

  /// No description provided for @passwordCopiedAlert.
  ///
  /// In en, this message translates to:
  /// **'Password copied!'**
  String get passwordCopiedAlert;

  /// No description provided for @goToLogin.
  ///
  /// In en, this message translates to:
  /// **'Go to Login'**
  String get goToLogin;

  /// No description provided for @forgotPasswordInstruction.
  ///
  /// In en, this message translates to:
  /// **'Enter your registered email and we\'ll generate a new password for you.'**
  String get forgotPasswordInstruction;

  /// No description provided for @rememberPasswordQuestion.
  ///
  /// In en, this message translates to:
  /// **'Remember your password? '**
  String get rememberPasswordQuestion;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get pleaseEnterValidEmail;

  /// No description provided for @emailHintText.
  ///
  /// In en, this message translates to:
  /// **'yourname@example.com'**
  String get emailHintText;

  /// No description provided for @incomeEntry.
  ///
  /// In en, this message translates to:
  /// **'Income Entry'**
  String get incomeEntry;

  /// No description provided for @enterIncomeHere.
  ///
  /// In en, this message translates to:
  /// **'Enter income here'**
  String get enterIncomeHere;

  /// No description provided for @pleaseEnterIncome.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid income amount'**
  String get pleaseEnterIncome;

  /// No description provided for @editExpense.
  ///
  /// In en, this message translates to:
  /// **'Edit Expense'**
  String get editExpense;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @editIncome.
  ///
  /// In en, this message translates to:
  /// **'Edit Income'**
  String get editIncome;

  /// No description provided for @updateExpense.
  ///
  /// In en, this message translates to:
  /// **'Update Expense'**
  String get updateExpense;

  /// No description provided for @updateIncome.
  ///
  /// In en, this message translates to:
  /// **'Update Income'**
  String get updateIncome;

  /// No description provided for @updatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Updated successfully'**
  String get updatedSuccessfully;

  /// No description provided for @pleaseSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get pleaseSelectCategory;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to logout?'**
  String get logoutConfirm;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @currentMonth.
  ///
  /// In en, this message translates to:
  /// **'Current Month'**
  String get currentMonth;

  /// No description provided for @thisYear.
  ///
  /// In en, this message translates to:
  /// **'This Year'**
  String get thisYear;

  /// No description provided for @prevYears.
  ///
  /// In en, this message translates to:
  /// **'Previous Years'**
  String get prevYears;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available.'**
  String get noData;

  /// No description provided for @noIncomeRecords.
  ///
  /// In en, this message translates to:
  /// **'No income records yet.'**
  String get noIncomeRecords;

  /// No description provided for @deleteExpenseConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to delete this expense?'**
  String get deleteExpenseConfirm;

  /// No description provided for @deleteIncomeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to delete this income?'**
  String get deleteIncomeConfirm;

  /// No description provided for @recordDeleted.
  ///
  /// In en, this message translates to:
  /// **'Record Deleted'**
  String get recordDeleted;

  /// No description provided for @incomeDeleted.
  ///
  /// In en, this message translates to:
  /// **'Income Deleted'**
  String get incomeDeleted;

  /// No description provided for @yearText.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get yearText;

  /// No description provided for @monthText.
  ///
  /// In en, this message translates to:
  /// **'month'**
  String get monthText;

  /// No description provided for @monthsText.
  ///
  /// In en, this message translates to:
  /// **'months'**
  String get monthsText;

  /// No description provided for @recordText.
  ///
  /// In en, this message translates to:
  /// **'record'**
  String get recordText;

  /// No description provided for @recordsText.
  ///
  /// In en, this message translates to:
  /// **'records'**
  String get recordsText;

  /// No description provided for @allExpensesTitle.
  ///
  /// In en, this message translates to:
  /// **'All Expenses'**
  String get allExpensesTitle;

  /// No description provided for @allIncomeTitle.
  ///
  /// In en, this message translates to:
  /// **'All Income'**
  String get allIncomeTitle;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @figure.
  ///
  /// In en, this message translates to:
  /// **'Figure'**
  String get figure;

  /// No description provided for @chart.
  ///
  /// In en, this message translates to:
  /// **'Chart'**
  String get chart;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @noExpenseData.
  ///
  /// In en, this message translates to:
  /// **'No expense data found.'**
  String get noExpenseData;

  /// No description provided for @noDataForCharts.
  ///
  /// In en, this message translates to:
  /// **'No data for charts.'**
  String get noDataForCharts;

  /// No description provided for @currentYear.
  ///
  /// In en, this message translates to:
  /// **'Current Year'**
  String get currentYear;

  /// No description provided for @prevYearsHistory.
  ///
  /// In en, this message translates to:
  /// **'Previous Years History'**
  String get prevYearsHistory;

  /// No description provided for @currentYearBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Here is the breakdown of your income, expenses and total savings for each month of the current year.'**
  String get currentYearBreakdown;

  /// No description provided for @expensesDistribution.
  ///
  /// In en, this message translates to:
  /// **'Expenses Distribution'**
  String get expensesDistribution;

  /// No description provided for @comparisonByCategory.
  ///
  /// In en, this message translates to:
  /// **'Comparison by Category'**
  String get comparisonByCategory;

  /// No description provided for @totalIn.
  ///
  /// In en, this message translates to:
  /// **'Total In'**
  String get totalIn;

  /// No description provided for @totalOut.
  ///
  /// In en, this message translates to:
  /// **'Total Out'**
  String get totalOut;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving'**
  String get saving;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Bal'**
  String get balance;

  /// No description provided for @expenseLabel.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expenseLabel;

  /// No description provided for @totalSaving.
  ///
  /// In en, this message translates to:
  /// **'Total Saving'**
  String get totalSaving;

  /// No description provided for @yearSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get yearSummary;

  /// No description provided for @editExpenseConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to edit this expense?'**
  String get editExpenseConfirm;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @totalAvailableBalance.
  ///
  /// In en, this message translates to:
  /// **'Total Available Balance'**
  String get totalAvailableBalance;

  /// No description provided for @personalFinanceManager.
  ///
  /// In en, this message translates to:
  /// **'Personal Finance Manager'**
  String get personalFinanceManager;

  /// No description provided for @yearIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get yearIncome;

  /// No description provided for @yearSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving'**
  String get yearSaving;

  /// No description provided for @yearExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get yearExpenses;

  /// No description provided for @currentMonthSummary.
  ///
  /// In en, this message translates to:
  /// **'Current Month Summary'**
  String get currentMonthSummary;

  /// No description provided for @thisMonthSaving.
  ///
  /// In en, this message translates to:
  /// **'This Month Saving'**
  String get thisMonthSaving;

  /// No description provided for @overBudget.
  ///
  /// In en, this message translates to:
  /// **'Over Budget'**
  String get overBudget;

  /// No description provided for @quickAnalyticsSavings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get quickAnalyticsSavings;

  /// No description provided for @quickAnalyticsSpending.
  ///
  /// In en, this message translates to:
  /// **'Spending'**
  String get quickAnalyticsSpending;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @overall.
  ///
  /// In en, this message translates to:
  /// **'Overall'**
  String get overall;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @noActivityYet.
  ///
  /// In en, this message translates to:
  /// **'No activity recorded yet.'**
  String get noActivityYet;

  /// No description provided for @addIncomeLabel.
  ///
  /// In en, this message translates to:
  /// **'Add Income'**
  String get addIncomeLabel;

  /// No description provided for @addExpenseLabel.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpenseLabel;

  /// No description provided for @deleteRecordConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to delete this record?'**
  String get deleteRecordConfirm;

  /// No description provided for @editTransactionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to edit this transaction?'**
  String get editTransactionConfirm;

  /// No description provided for @recordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Success! Record updated'**
  String get recordUpdated;

  /// No description provided for @catGroceries.
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get catGroceries;

  /// No description provided for @catHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get catHealth;

  /// No description provided for @catEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get catEducation;

  /// No description provided for @catTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get catTransport;

  /// No description provided for @catBills.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get catBills;

  /// No description provided for @catRent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get catRent;

  /// No description provided for @catSalaries.
  ///
  /// In en, this message translates to:
  /// **'Salaries'**
  String get catSalaries;

  /// No description provided for @catCharity.
  ///
  /// In en, this message translates to:
  /// **'Charity'**
  String get catCharity;

  /// No description provided for @catShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get catShopping;

  /// No description provided for @catMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get catMaintenance;

  /// No description provided for @catHousehold.
  ///
  /// In en, this message translates to:
  /// **'Household'**
  String get catHousehold;

  /// No description provided for @catPets.
  ///
  /// In en, this message translates to:
  /// **'Pets'**
  String get catPets;

  /// No description provided for @catSports.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get catSports;

  /// No description provided for @catEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get catEntertainment;

  /// No description provided for @catGifts.
  ///
  /// In en, this message translates to:
  /// **'Gifts'**
  String get catGifts;

  /// No description provided for @catVacations.
  ///
  /// In en, this message translates to:
  /// **'Vacations'**
  String get catVacations;

  /// No description provided for @catRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get catRestaurant;

  /// No description provided for @catOthers.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get catOthers;

  /// No description provided for @userNameDefault.
  ///
  /// In en, this message translates to:
  /// **'User Name'**
  String get userNameDefault;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'selected'**
  String get selected;

  /// No description provided for @deselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect All'**
  String get deselectAll;

  /// No description provided for @notifTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Bachat Reminder 💰'**
  String get notifTitle;

  /// No description provided for @notifBody.
  ///
  /// In en, this message translates to:
  /// **'Don\'t forget to add today\'s income & expenses. Smart tracking leads to smart savings! ✨'**
  String get notifBody;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'en',
    'es',
    'fr',
    'hi',
    'ur',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'ur':
      return AppLocalizationsUr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
