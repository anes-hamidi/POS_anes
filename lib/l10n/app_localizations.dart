import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'My POS'**
  String get appTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @businessInfo.
  ///
  /// In en, this message translates to:
  /// **'Business Information'**
  String get businessInfo;

  /// No description provided for @printer.
  ///
  /// In en, this message translates to:
  /// **'Printer'**
  String get printer;

  /// No description provided for @backupRestore.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backupRestore;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @adjustQuantity.
  ///
  /// In en, this message translates to:
  /// **'Adjust Quantity - {productName}'**
  String adjustQuantity(Object productName);

  /// No description provided for @businessInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage store details, logo, and contact info'**
  String get businessInfoSubtitle;

  /// No description provided for @editBusinessInfo.
  ///
  /// In en, this message translates to:
  /// **'Edit Business Info'**
  String get editBusinessInfo;

  /// No description provided for @printerSettings.
  ///
  /// In en, this message translates to:
  /// **'Printer Settings'**
  String get printerSettings;

  /// No description provided for @printerSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Connect and manage printers'**
  String get printerSettingsSubtitle;

  /// No description provided for @printerConnection.
  ///
  /// In en, this message translates to:
  /// **'Printer Connection'**
  String get printerConnection;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get connecting;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected to {printerName}'**
  String connected(Object printerName);

  /// No description provided for @disconnected.
  ///
  /// In en, this message translates to:
  /// **'🔌 Disconnected'**
  String get disconnected;

  /// No description provided for @selectPrinter.
  ///
  /// In en, this message translates to:
  /// **'Select Printer'**
  String get selectPrinter;

  /// No description provided for @connectedToPrinter.
  ///
  /// In en, this message translates to:
  /// **'✅ Connected to {printerName}'**
  String connectedToPrinter(Object printerName);

  /// No description provided for @connectionFailed.
  ///
  /// In en, this message translates to:
  /// **'❌ Connection failed: {error}'**
  String connectionFailed(Object error);

  /// No description provided for @failedToGetPrinters.
  ///
  /// In en, this message translates to:
  /// **'❌ Failed to get printers: {error}'**
  String failedToGetPrinters(Object error);

  /// No description provided for @disconnectedMessage.
  ///
  /// In en, this message translates to:
  /// **'🔌 Disconnected'**
  String get disconnectedMessage;

  /// No description provided for @databaseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Backup or restore your data'**
  String get databaseSubtitle;

  /// No description provided for @backupSaved.
  ///
  /// In en, this message translates to:
  /// **'✅ Backup saved at {path}'**
  String backupSaved(Object path);

  /// No description provided for @backupFailed.
  ///
  /// In en, this message translates to:
  /// **'❌ Backup failed: {error}'**
  String backupFailed(Object error);

  /// No description provided for @restoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'✅ Database restored successfully'**
  String get restoreSuccess;

  /// No description provided for @restoreFailed.
  ///
  /// In en, this message translates to:
  /// **'❌ Restore failed: {error}'**
  String restoreFailed(Object error);

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @appSettings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// No description provided for @appSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Customize your app experience'**
  String get appSettingsSubtitle;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Change app language'**
  String get languageSubtitle;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @enterValidBarcode.
  ///
  /// In en, this message translates to:
  /// **'Please enter or scan a barcode'**
  String get enterValidBarcode;

  /// No description provided for @pos.
  ///
  /// In en, this message translates to:
  /// **'POS'**
  String get pos;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving..'**
  String get saving;

  /// No description provided for @enterValidQuantity.
  ///
  /// In en, this message translates to:
  /// **'Enter Valid Quantity'**
  String get enterValidQuantity;

  /// No description provided for @enterValidCost.
  ///
  /// In en, this message translates to:
  /// **'Enter Valid Cost'**
  String get enterValidCost;

  /// No description provided for @enterValidPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter Valid Price'**
  String get enterValidPrice;

  /// No description provided for @posTitle.
  ///
  /// In en, this message translates to:
  /// **'Point of Sale'**
  String get posTitle;

  /// No description provided for @unknownDevice.
  ///
  /// In en, this message translates to:
  /// **'Unknown device'**
  String get unknownDevice;

  /// No description provided for @scanBarcode.
  ///
  /// In en, this message translates to:
  /// **'Scan barcode'**
  String get scanBarcode;

  /// No description provided for @showAll.
  ///
  /// In en, this message translates to:
  /// **'Show all products'**
  String get showAll;

  /// No description provided for @topProduct.
  ///
  /// In en, this message translates to:
  /// **'Top {rankIndex}'**
  String topProduct(Object rankIndex);

  /// No description provided for @showTop.
  ///
  /// In en, this message translates to:
  /// **'Show top products'**
  String get showTop;

  /// No description provided for @categoryBoisson.
  ///
  /// In en, this message translates to:
  /// **'Drinks'**
  String get categoryBoisson;

  /// No description provided for @categoryJus.
  ///
  /// In en, this message translates to:
  /// **'Juices'**
  String get categoryJus;

  /// No description provided for @categoryJusGaz.
  ///
  /// In en, this message translates to:
  /// **'Soda'**
  String get categoryJusGaz;

  /// No description provided for @categoryCanet.
  ///
  /// In en, this message translates to:
  /// **'Cans'**
  String get categoryCanet;

  /// No description provided for @categoryMini.
  ///
  /// In en, this message translates to:
  /// **'Mini'**
  String get categoryMini;

  /// No description provided for @categoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryAll;

  /// No description provided for @productAdded.
  ///
  /// In en, this message translates to:
  /// **'Product {productName} added to cart'**
  String productAdded(Object productName);

  /// No description provided for @productNotFound.
  ///
  /// In en, this message translates to:
  /// **'Product not found'**
  String get productNotFound;

  /// No description provided for @scanError.
  ///
  /// In en, this message translates to:
  /// **'Scan error'**
  String get scanError;

  /// No description provided for @errorLoadingRanked.
  ///
  /// In en, this message translates to:
  /// **'Error loading ranked products'**
  String get errorLoadingRanked;

  /// No description provided for @noRankingData.
  ///
  /// In en, this message translates to:
  /// **'No ranking data available'**
  String get noRankingData;

  /// No description provided for @errorLoadingProducts.
  ///
  /// In en, this message translates to:
  /// **'Error loading products'**
  String get errorLoadingProducts;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProductsFound;

  /// No description provided for @currencySymbol.
  ///
  /// In en, this message translates to:
  /// **'DA'**
  String get currencySymbol;

  /// No description provided for @currentQty.
  ///
  /// In en, this message translates to:
  /// **'Current Qty:'**
  String get currentQty;

  /// No description provided for @newTotal.
  ///
  /// In en, this message translates to:
  /// **'New Total'**
  String get newTotal;

  /// No description provided for @setExactQuantity.
  ///
  /// In en, this message translates to:
  /// **'Set Exact Quantity'**
  String get setExactQuantity;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @choosePrinter.
  ///
  /// In en, this message translates to:
  /// **'Choose Printer'**
  String get choosePrinter;

  /// No description provided for @connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// No description provided for @searchByNameCategoryOrSku.
  ///
  /// In en, this message translates to:
  /// **'Search by name, category, or SKU...'**
  String get searchByNameCategoryOrSku;

  /// No description provided for @allowSaleWithoutStock.
  ///
  /// In en, this message translates to:
  /// **'Allow sale without stock'**
  String get allowSaleWithoutStock;

  /// No description provided for @allowSaleWithoutStockDesc.
  ///
  /// In en, this message translates to:
  /// **'When enabled, products with zero stock can be sold without confirmation.'**
  String get allowSaleWithoutStockDesc;

  /// No description provided for @businessInformation.
  ///
  /// In en, this message translates to:
  /// **'Business Information'**
  String get businessInformation;

  /// No description provided for @manageStoreDetails.
  ///
  /// In en, this message translates to:
  /// **'Manage store details, logo, and contact info'**
  String get manageStoreDetails;

  /// No description provided for @businessName.
  ///
  /// In en, this message translates to:
  /// **'Business Name'**
  String get businessName;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @businessInfoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Business information updated successfully'**
  String get businessInfoUpdated;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get outOfStock;

  /// No description provided for @productOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'The product {productName} is out of stock.'**
  String productOutOfStock(Object productName);

  /// No description provided for @proceedWithoutStock.
  ///
  /// In en, this message translates to:
  /// **'Proceed Without Stock'**
  String get proceedWithoutStock;

  /// No description provided for @stock.
  ///
  /// In en, this message translates to:
  /// **'Stock: {value}'**
  String stock(Object value);

  /// No description provided for @errorgeting.
  ///
  /// In en, this message translates to:
  /// **'Error loading'**
  String errorgeting(Object error);

  /// No description provided for @totalInvoices.
  ///
  /// In en, this message translates to:
  /// **'Total Invoices'**
  String get totalInvoices;

  /// No description provided for @totalSpending.
  ///
  /// In en, this message translates to:
  /// **'Total Spending'**
  String get totalSpending;

  /// No description provided for @invoices.
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get invoices;

  /// No description provided for @noInvoicesForCustomer.
  ///
  /// In en, this message translates to:
  /// **'No invoices found for this customer.'**
  String get noInvoicesForCustomer;

  /// No description provided for @invoiceNumber.
  ///
  /// In en, this message translates to:
  /// **'Invoice #: {number}'**
  String invoiceNumber(Object number);

  /// No description provided for @invoiceDate.
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String invoiceDate(Object date);

  /// No description provided for @areYouSureDeleteCustomer.
  ///
  /// In en, this message translates to:
  /// **'are You Sure You wante to Delete {customerName}؟'**
  String areYouSureDeleteCustomer(Object customerName);

  /// No description provided for @backupToGoogleDrive.
  ///
  /// In en, this message translates to:
  /// **'Backup to Google Drive'**
  String get backupToGoogleDrive;

  /// No description provided for @backupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup completed successfully'**
  String get backupSuccess;

  /// No description provided for @restoreFromGoogleDrive.
  ///
  /// In en, this message translates to:
  /// **'Restore from Google Drive'**
  String get restoreFromGoogleDrive;

  /// No description provided for @invoiceTotal.
  ///
  /// In en, this message translates to:
  /// **'Total: {amount} DA'**
  String invoiceTotal(Object amount);

  /// No description provided for @invoiceSent.
  ///
  /// In en, this message translates to:
  /// **'Invoice sent to printer.'**
  String get invoiceSent;

  /// No description provided for @errorPrinting.
  ///
  /// In en, this message translates to:
  /// **'Error printing: {error}'**
  String errorPrinting(Object error);

  /// No description provided for @invoice.
  ///
  /// In en, this message translates to:
  /// **'INVOICE'**
  String get invoice;

  /// No description provided for @billedTo.
  ///
  /// In en, this message translates to:
  /// **'Billed To:'**
  String get billedTo;

  /// No description provided for @cphone.
  ///
  /// In en, this message translates to:
  /// **'Phone: {phone}'**
  String cphone(Object phone);

  /// No description provided for @cemail.
  ///
  /// In en, this message translates to:
  /// **'Email: {email}'**
  String cemail(Object email);

  /// No description provided for @item.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get item;

  /// No description provided for @qty.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get qty;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @totalItems.
  ///
  /// In en, this message translates to:
  /// **'Total Items'**
  String get totalItems;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'TOTAL:'**
  String get totalAmount;

  /// No description provided for @currencyFormat.
  ///
  /// In en, this message translates to:
  /// **'{totalSpending} DA'**
  String currencyFormat(Object totalSpending);

  /// No description provided for @walkInCustomer.
  ///
  /// In en, this message translates to:
  /// **'Walk-in Customer'**
  String get walkInCustomer;

  /// No description provided for @selectCustomer.
  ///
  /// In en, this message translates to:
  /// **'Select Customer'**
  String get selectCustomer;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'🛒 Cart'**
  String get cart;

  /// No description provided for @payments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payments;

  /// No description provided for @cartCleared.
  ///
  /// In en, this message translates to:
  /// **'Cart cleared'**
  String get cartCleared;

  /// No description provided for @completeSale.
  ///
  /// In en, this message translates to:
  /// **'Complete Sale'**
  String get completeSale;

  /// No description provided for @chooseAction.
  ///
  /// In en, this message translates to:
  /// **'Choose Action'**
  String get chooseAction;

  /// No description provided for @removeItem.
  ///
  /// In en, this message translates to:
  /// **'Remove Item?'**
  String get removeItem;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @barcode.
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get barcode;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @contactPerson.
  ///
  /// In en, this message translates to:
  /// **'Contact Person'**
  String get contactPerson;

  /// No description provided for @lowStockWarning.
  ///
  /// In en, this message translates to:
  /// **'⚠ Low Stock Warning'**
  String get lowStockWarning;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'please Enter Name'**
  String get pleaseEnterName;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @yourBusinessName.
  ///
  /// In en, this message translates to:
  /// **'Your Business Name'**
  String get yourBusinessName;

  /// No description provided for @contactEmail.
  ///
  /// In en, this message translates to:
  /// **'contact@yourbusiness.com'**
  String get contactEmail;

  /// No description provided for @contactPhone.
  ///
  /// In en, this message translates to:
  /// **'+1 234 567 890'**
  String get contactPhone;

  /// No description provided for @noCustomerSelected.
  ///
  /// In en, this message translates to:
  /// **'No Customer Selected'**
  String get noCustomerSelected;

  /// No description provided for @withoutCustomer.
  ///
  /// In en, this message translates to:
  /// **'Without Customer'**
  String get withoutCustomer;

  /// No description provided for @createCustomer.
  ///
  /// In en, this message translates to:
  /// **'Create Customer'**
  String get createCustomer;

  /// No description provided for @posScreen.
  ///
  /// In en, this message translates to:
  /// **'POS Screen'**
  String get posScreen;

  /// No description provided for @manageCustomers.
  ///
  /// In en, this message translates to:
  /// **'Manage Customers'**
  String get manageCustomers;

  /// No description provided for @invoiceDetails.
  ///
  /// In en, this message translates to:
  /// **'Invoice Details'**
  String get invoiceDetails;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @connectAndManagePrinters.
  ///
  /// In en, this message translates to:
  /// **'Connect and manage printers'**
  String get connectAndManagePrinters;

  /// No description provided for @database.
  ///
  /// In en, this message translates to:
  /// **'Database'**
  String get database;

  /// No description provided for @backupOrRestoreData.
  ///
  /// In en, this message translates to:
  /// **'Backup or restore your data'**
  String get backupOrRestoreData;

  /// No description provided for @editCustomer.
  ///
  /// In en, this message translates to:
  /// **'Edit Customer'**
  String get editCustomer;

  /// No description provided for @saveCustomer.
  ///
  /// In en, this message translates to:
  /// **'Save Customer'**
  String get saveCustomer;

  /// No description provided for @backupDatabase.
  ///
  /// In en, this message translates to:
  /// **'Backup Database'**
  String get backupDatabase;

  /// No description provided for @restoreDatabase.
  ///
  /// In en, this message translates to:
  /// **'Restore Database'**
  String get restoreDatabase;

  /// No description provided for @customizeAppExperience.
  ///
  /// In en, this message translates to:
  /// **'Customize your app experience'**
  String get customizeAppExperience;

  /// No description provided for @changeAppLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change app language'**
  String get changeAppLanguage;

  /// No description provided for @productName.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get productName;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @cost.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get cost;

  /// No description provided for @addNewCustomer.
  ///
  /// In en, this message translates to:
  /// **'Add New Customer'**
  String get addNewCustomer;

  /// No description provided for @clearCart.
  ///
  /// In en, this message translates to:
  /// **'Clear Cart'**
  String get clearCart;

  /// No description provided for @clearCartConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear the cart?'**
  String get clearCartConfirmation;

  /// No description provided for @completeSaleConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Do you want to complete this sale?'**
  String get completeSaleConfirmation;

  /// No description provided for @saveOrPrintPrompt.
  ///
  /// In en, this message translates to:
  /// **'Would you like to save or print the invoice?'**
  String get saveOrPrintPrompt;

  /// No description provided for @saveAndPrint.
  ///
  /// In en, this message translates to:
  /// **'Save and Print'**
  String get saveAndPrint;

  /// No description provided for @saveOnly.
  ///
  /// In en, this message translates to:
  /// **'Save Only'**
  String get saveOnly;

  /// No description provided for @saleCompletedAndInvoicePrinted.
  ///
  /// In en, this message translates to:
  /// **'Sale completed and invoice printed successfully.'**
  String get saleCompletedAndInvoicePrinted;

  /// No description provided for @saleCompletedWithoutPrinting.
  ///
  /// In en, this message translates to:
  /// **'Sale completed without printing the invoice.'**
  String get saleCompletedWithoutPrinting;

  /// No description provided for @errorCompletingSale.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while completing the sale.'**
  String get errorCompletingSale;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @saveProduct.
  ///
  /// In en, this message translates to:
  /// **'Save Product'**
  String get saveProduct;

  /// No description provided for @deleteCustomer.
  ///
  /// In en, this message translates to:
  /// **'Delete Customer'**
  String get deleteCustomer;

  /// No description provided for @deleteProduct.
  ///
  /// In en, this message translates to:
  /// **'Delete Product'**
  String get deleteProduct;

  /// No description provided for @noCustomersFound.
  ///
  /// In en, this message translates to:
  /// **'no Customers Found'**
  String get noCustomersFound;

  /// No description provided for @getStartedByAddingYourFirstCustomer.
  ///
  /// In en, this message translates to:
  /// **'get Started By Adding Your First Customer'**
  String get getStartedByAddingYourFirstCustomer;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @addNewProduct.
  ///
  /// In en, this message translates to:
  /// **'Add New Product'**
  String get addNewProduct;

  /// No description provided for @editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get editProduct;

  /// No description provided for @pleaseEnterAName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name.'**
  String get pleaseEnterAName;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @toggleTheme.
  ///
  /// In en, this message translates to:
  /// **'Toggle Theme'**
  String get toggleTheme;

  /// No description provided for @customers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customers;

  /// No description provided for @sales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get sales;

  /// No description provided for @areYouSureDeleteProduct.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {productName}?'**
  String areYouSureDeleteProduct(Object productName);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
