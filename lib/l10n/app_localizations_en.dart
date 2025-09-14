// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'My POS';

  @override
  String get settings => 'Settings';

  @override
  String get businessInfo => 'Business Information';

  @override
  String get printer => 'Printer';

  @override
  String get backupRestore => 'Backup & Restore';

  @override
  String get language => 'Language';

  @override
  String adjustQuantity(Object productName) {
    return 'Adjust Quantity - $productName';
  }

  @override
  String get businessInfoSubtitle => 'Manage store details, logo, and contact info';

  @override
  String get editBusinessInfo => 'Edit Business Info';

  @override
  String get printerSettings => 'Printer Settings';

  @override
  String get printerSettingsSubtitle => 'Connect and manage printers';

  @override
  String get printerConnection => 'Printer Connection';

  @override
  String get connecting => 'Connecting…';

  @override
  String connected(Object printerName) {
    return 'Connected to $printerName';
  }

  @override
  String get disconnected => '🔌 Disconnected';

  @override
  String get selectPrinter => 'Select Printer';

  @override
  String connectedToPrinter(Object printerName) {
    return '✅ Connected to $printerName';
  }

  @override
  String connectionFailed(Object error) {
    return '❌ Connection failed: $error';
  }

  @override
  String failedToGetPrinters(Object error) {
    return '❌ Failed to get printers: $error';
  }

  @override
  String get disconnectedMessage => '🔌 Disconnected';

  @override
  String get databaseSubtitle => 'Backup or restore your data';

  @override
  String backupSaved(Object path) {
    return '✅ Backup saved at $path';
  }

  @override
  String backupFailed(Object error) {
    return '❌ Backup failed: $error';
  }

  @override
  String get restoreSuccess => '✅ Database restored successfully';

  @override
  String restoreFailed(Object error) {
    return '❌ Restore failed: $error';
  }

  @override
  String get lightMode => 'Light Mode';

  @override
  String get appSettings => 'App Settings';

  @override
  String get appSettingsSubtitle => 'Customize your app experience';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get languageSubtitle => 'Change app language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get cancel => 'Cancel';

  @override
  String get apply => 'Apply';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get enterValidBarcode => 'Please enter or scan a barcode';

  @override
  String get pos => 'POS';

  @override
  String get items => 'Items';

  @override
  String get saving => 'Saving..';

  @override
  String get enterValidQuantity => 'Enter Valid Quantity';

  @override
  String get enterValidCost => 'Enter Valid Cost';

  @override
  String get enterValidPrice => 'Enter Valid Price';

  @override
  String get posTitle => 'Point of Sale';

  @override
  String get unknownDevice => 'Unknown device';

  @override
  String get scanBarcode => 'Scan barcode';

  @override
  String get showAll => 'Show all products';

  @override
  String topProduct(Object rankIndex) {
    return 'Top $rankIndex';
  }

  @override
  String get showTop => 'Show top products';

  @override
  String get categoryBoisson => 'Drinks';

  @override
  String get categoryJus => 'Juices';

  @override
  String get categoryJusGaz => 'Soda';

  @override
  String get categoryCanet => 'Cans';

  @override
  String get categoryMini => 'Mini';

  @override
  String get categoryAll => 'All';

  @override
  String productAdded(Object productName) {
    return 'Product $productName added to cart';
  }

  @override
  String get productNotFound => 'Product not found';

  @override
  String get scanError => 'Scan error';

  @override
  String get errorLoadingRanked => 'Error loading ranked products';

  @override
  String get noRankingData => 'No ranking data available';

  @override
  String get errorLoadingProducts => 'Error loading products';

  @override
  String get noProductsFound => 'No products found';

  @override
  String get currencySymbol => 'DA';

  @override
  String get currentQty => 'Current Qty:';

  @override
  String get newTotal => 'New Total';

  @override
  String get setExactQuantity => 'Set Exact Quantity';

  @override
  String get save => 'Save';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get choosePrinter => 'Choose Printer';

  @override
  String get connect => 'Connect';

  @override
  String get searchByNameCategoryOrSku => 'Search by name, category, or SKU...';

  @override
  String get allowSaleWithoutStock => 'Allow sale without stock';

  @override
  String get allowSaleWithoutStockDesc => 'When enabled, products with zero stock can be sold without confirmation.';

  @override
  String get businessInformation => 'Business Information';

  @override
  String get manageStoreDetails => 'Manage store details, logo, and contact info';

  @override
  String get businessName => 'Business Name';

  @override
  String get phone => 'Phone';

  @override
  String get email => 'Email';

  @override
  String get address => 'Address';

  @override
  String get businessInfoUpdated => 'Business information updated successfully';

  @override
  String get outOfStock => 'Out of Stock';

  @override
  String productOutOfStock(Object productName) {
    return 'The product $productName is out of stock.';
  }

  @override
  String get proceedWithoutStock => 'Proceed Without Stock';

  @override
  String stock(Object value) {
    return 'Stock: $value';
  }

  @override
  String errorgeting(Object error) {
    return 'Error loading';
  }

  @override
  String get totalInvoices => 'Total Invoices';

  @override
  String get totalSpending => 'Total Spending';

  @override
  String get invoices => 'Invoices';

  @override
  String get noInvoicesForCustomer => 'No invoices found for this customer.';

  @override
  String invoiceNumber(Object number) {
    return 'Invoice #: $number';
  }

  @override
  String invoiceDate(Object date) {
    return 'Date: $date';
  }

  @override
  String areYouSureDeleteCustomer(Object customerName) {
    return 'are You Sure You wante to Delete $customerName؟';
  }

  @override
  String get backupToGoogleDrive => 'Backup to Google Drive';

  @override
  String get backupSuccess => 'Backup completed successfully';

  @override
  String get restoreFromGoogleDrive => 'Restore from Google Drive';

  @override
  String invoiceTotal(Object amount) {
    return 'Total: $amount DA';
  }

  @override
  String get invoiceSent => 'Invoice sent to printer.';

  @override
  String errorPrinting(Object error) {
    return 'Error printing: $error';
  }

  @override
  String get invoice => 'INVOICE';

  @override
  String get billedTo => 'Billed To:';

  @override
  String cphone(Object phone) {
    return 'Phone: $phone';
  }

  @override
  String cemail(Object email) {
    return 'Email: $email';
  }

  @override
  String get item => 'Item';

  @override
  String get qty => 'Qty';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get totalItems => 'Total Items';

  @override
  String get products => 'Products';

  @override
  String get totalAmount => 'TOTAL:';

  @override
  String currencyFormat(Object totalSpending) {
    return '$totalSpending DA';
  }

  @override
  String get walkInCustomer => 'Walk-in Customer';

  @override
  String get selectCustomer => 'Select Customer';

  @override
  String get close => 'Close';

  @override
  String get cart => '🛒 Cart';

  @override
  String get payments => 'Payments';

  @override
  String get cartCleared => 'Cart cleared';

  @override
  String get completeSale => 'Complete Sale';

  @override
  String get chooseAction => 'Choose Action';

  @override
  String get removeItem => 'Remove Item?';

  @override
  String get remove => 'Remove';

  @override
  String get barcode => 'Barcode';

  @override
  String get name => 'Name';

  @override
  String get contactPerson => 'Contact Person';

  @override
  String get lowStockWarning => '⚠ Low Stock Warning';

  @override
  String get pleaseEnterName => 'please Enter Name';

  @override
  String get ok => 'OK';

  @override
  String get yourBusinessName => 'Your Business Name';

  @override
  String get contactEmail => 'contact@yourbusiness.com';

  @override
  String get contactPhone => '+1 234 567 890';

  @override
  String get noCustomerSelected => 'No Customer Selected';

  @override
  String get withoutCustomer => 'Without Customer';

  @override
  String get createCustomer => 'Create Customer';

  @override
  String get posScreen => 'POS Screen';

  @override
  String get manageCustomers => 'Manage Customers';

  @override
  String get invoiceDetails => 'Invoice Details';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get connectAndManagePrinters => 'Connect and manage printers';

  @override
  String get database => 'Database';

  @override
  String get backupOrRestoreData => 'Backup or restore your data';

  @override
  String get editCustomer => 'Edit Customer';

  @override
  String get saveCustomer => 'Save Customer';

  @override
  String get backupDatabase => 'Backup Database';

  @override
  String get restoreDatabase => 'Restore Database';

  @override
  String get customizeAppExperience => 'Customize your app experience';

  @override
  String get changeAppLanguage => 'Change app language';

  @override
  String get productName => 'Product Name';

  @override
  String get description => 'Description';

  @override
  String get price => 'Price';

  @override
  String get cost => 'Cost';

  @override
  String get addNewCustomer => 'Add New Customer';

  @override
  String get clearCart => 'Clear Cart';

  @override
  String get clearCartConfirmation => 'Are you sure you want to clear the cart?';

  @override
  String get completeSaleConfirmation => 'Do you want to complete this sale?';

  @override
  String get saveOrPrintPrompt => 'Would you like to save or print the invoice?';

  @override
  String get saveAndPrint => 'Save and Print';

  @override
  String get saveOnly => 'Save Only';

  @override
  String get saleCompletedAndInvoicePrinted => 'Sale completed and invoice printed successfully.';

  @override
  String get saleCompletedWithoutPrinting => 'Sale completed without printing the invoice.';

  @override
  String get errorCompletingSale => 'An error occurred while completing the sale.';

  @override
  String get quantity => 'Quantity';

  @override
  String get saveProduct => 'Save Product';

  @override
  String get deleteCustomer => 'Delete Customer';

  @override
  String get deleteProduct => 'Delete Product';

  @override
  String get noCustomersFound => 'no Customers Found';

  @override
  String get getStartedByAddingYourFirstCustomer => 'get Started By Adding Your First Customer';

  @override
  String get category => 'Category';

  @override
  String get addNewProduct => 'Add New Product';

  @override
  String get editProduct => 'Edit Product';

  @override
  String get pleaseEnterAName => 'Please enter a name.';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get toggleTheme => 'Toggle Theme';

  @override
  String get customers => 'Customers';

  @override
  String get sales => 'Sales';

  @override
  String areYouSureDeleteProduct(Object productName) {
    return 'Are you sure you want to delete $productName?';
  }
}
