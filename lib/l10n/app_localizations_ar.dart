// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'نظام نقاط البيع';

  @override
  String get settings => 'الإعدادات';

  @override
  String get businessInfo => 'معلومات المتجر';

  @override
  String get printer => 'الطابعة';

  @override
  String get backupRestore => 'النسخ الاحتياطي والاستعادة';

  @override
  String get language => 'اللغة';

  @override
  String adjustQuantity(Object productName) {
    return 'تعديل الكمية - $productName';
  }

  @override
  String get businessInfoSubtitle => 'إدارة تفاصيل المتجر، الشعار، ومعلومات الاتصال';

  @override
  String get editBusinessInfo => 'تعديل معلومات العمل';

  @override
  String get printerSettings => 'إعدادات الطابعة';

  @override
  String get printerSettingsSubtitle => 'الاتصال وإدارة الطابعات';

  @override
  String get printerConnection => 'اتصال الطابعة';

  @override
  String get connecting => 'جارٍ الاتصال…';

  @override
  String connected(Object printerName) {
    return 'متصل بـ $printerName';
  }

  @override
  String get disconnected => '🔌 غير متصل';

  @override
  String get selectPrinter => 'اختر طابعة';

  @override
  String connectedToPrinter(Object printerName) {
    return '✅ تم الاتصال بـ $printerName';
  }

  @override
  String connectionFailed(Object error) {
    return '❌ فشل الاتصال: $error';
  }

  @override
  String failedToGetPrinters(Object error) {
    return '❌ فشل في الحصول على الطابعات: $error';
  }

  @override
  String get disconnectedMessage => '🔌 تم قطع الاتصال';

  @override
  String get databaseSubtitle => 'نسخ احتياطي أو استعادة بياناتك';

  @override
  String backupSaved(Object path) {
    return '✅ تم حفظ النسخة الاحتياطية في $path';
  }

  @override
  String backupFailed(Object error) {
    return '❌ فشل النسخ الاحتياطي: $error';
  }

  @override
  String get restoreSuccess => '✅ تم استعادة قاعدة البيانات بنجاح';

  @override
  String restoreFailed(Object error) {
    return '❌ فشلت الاستعادة: $error';
  }

  @override
  String get lightMode => 'الوضع المضيء';

  @override
  String get appSettings => 'إعدادات التطبيق';

  @override
  String get appSettingsSubtitle => 'تخصيص تجربة التطبيق';

  @override
  String get darkMode => 'الوضع المظلم';

  @override
  String get languageSubtitle => 'تغيير لغة التطبيق';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get apply => 'تطبيق';

  @override
  String get english => 'الإنجليزية';

  @override
  String get arabic => 'العربية';

  @override
  String get enterValidBarcode => 'امسح او ادخل الباركود';

  @override
  String get pos => 'البيع';

  @override
  String get items => 'الوحدات';

  @override
  String get saving => 'حفض..';

  @override
  String get enterValidQuantity => ' ادخل الكمية الصحيحة';

  @override
  String get enterValidCost => 'ادخل سعر التكلفة ';

  @override
  String get enterValidPrice => 'ادخل سعر البيع ';

  @override
  String get posTitle => 'نقطة البيع';

  @override
  String get unknownDevice => 'جهاز غير معروف';

  @override
  String get scanBarcode => 'مسح الباركود';

  @override
  String get showAll => 'عرض كل المنتجات';

  @override
  String topProduct(Object rankIndex) {
    return 'افضل منتج $rankIndex';
  }

  @override
  String get showTop => 'عرض المنتجات الأعلى';

  @override
  String get categoryBoisson => 'مشروبات';

  @override
  String get categoryJus => 'عصائر';

  @override
  String get categoryJusGaz => 'مشروبات غازية';

  @override
  String get categoryCanet => 'علب';

  @override
  String get categoryMini => 'صغيرة';

  @override
  String get categoryAll => 'الكل';

  @override
  String productAdded(Object productName) {
    return 'تمت إضافة المنتج $productName إلى السلة';
  }

  @override
  String get productNotFound => 'المنتج غير موجود';

  @override
  String get scanError => 'خطأ في المسح';

  @override
  String get errorLoadingRanked => 'خطأ في تحميل المنتجات المرتبة';

  @override
  String get noRankingData => 'لا توجد بيانات تصنيف';

  @override
  String get errorLoadingProducts => 'خطأ في تحميل المنتجات';

  @override
  String get noProductsFound => 'لم يتم العثور على منتجات';

  @override
  String get currencySymbol => 'د.ج';

  @override
  String get currentQty => ' الكمية المتاحة';

  @override
  String get newTotal => 'الكمية الجديدة';

  @override
  String get setExactQuantity => 'تعيين الكمية بالضبط';

  @override
  String get save => 'حفظ';

  @override
  String get edit => 'تعديل';

  @override
  String get delete => 'حذف';

  @override
  String get choosePrinter => 'اختر طابعة';

  @override
  String get connect => 'اتصل';

  @override
  String get searchByNameCategoryOrSku => 'البحث بالاسم أو الفئة أو رمز SKU...';

  @override
  String get allowSaleWithoutStock => 'السماح بالبيع بدون مخزون';

  @override
  String get allowSaleWithoutStockDesc => 'عند التفعيل، يمكن بيع المنتجات التي ليس لها مخزون بدون تأكيد.';

  @override
  String get businessInformation => 'معلومات العمل';

  @override
  String get manageStoreDetails => 'إدارة تفاصيل المتجر والشعار ومعلومات الاتصال';

  @override
  String get businessName => 'اسم المتجر';

  @override
  String get phone => 'الهاتف';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get address => 'العنوان';

  @override
  String get businessInfoUpdated => 'تم تحديث معلومات العمل بنجاح';

  @override
  String get outOfStock => 'نفد المخزون';

  @override
  String productOutOfStock(Object productName) {
    return 'المنتج $productName غير متوفر في المخزون.';
  }

  @override
  String get proceedWithoutStock => 'المتابعة بدون مخزون';

  @override
  String stock(Object value) {
    return 'المخزون: $value';
  }

  @override
  String errorgeting(Object error) {
    return 'خطأ أثناء التحميل: $error';
  }

  @override
  String get totalInvoices => 'إجمالي الفواتير';

  @override
  String get totalSpending => 'إجمالي الإنفاق';

  @override
  String get invoices => 'الفواتير';

  @override
  String get noInvoicesForCustomer => 'لا توجد فواتير لهذا الزبون.';

  @override
  String invoiceNumber(Object number) {
    return 'فاتورة رقم $number';
  }

  @override
  String invoiceDate(Object date) {
    return 'التاريخ: $date';
  }

  @override
  String areYouSureDeleteCustomer(Object customerName) {
    return 'هل أنت متأكد أنك تريد حذف $customerName؟';
  }

  @override
  String get backupToGoogleDrive => 'نسخ احتياطي إلى Google Drive';

  @override
  String get backupSuccess => 'تم النسخ الاحتياطي بنجاح';

  @override
  String get restoreFromGoogleDrive => 'استعادة من Google Drive';

  @override
  String invoiceTotal(Object amount) {
    return 'المجموع: $amount دج';
  }

  @override
  String get invoiceSent => 'تم إرسال الفاتورة إلى الطابعة.';

  @override
  String errorPrinting(Object error) {
    return 'خطأ أثناء الطباعة: $error';
  }

  @override
  String get invoice => 'فاتورة';

  @override
  String get billedTo => 'موجهة إلى:';

  @override
  String cphone(Object phone) {
    return 'Phone: $phone';
  }

  @override
  String cemail(Object email) {
    return 'Email: $email';
  }

  @override
  String get item => 'المنتج';

  @override
  String get qty => 'الكمية';

  @override
  String get subtotal => 'المجموع الجزئي';

  @override
  String get totalItems => 'إجمالي العناصر';

  @override
  String get products => 'المنتجات';

  @override
  String get totalAmount => 'الإجمالي:';

  @override
  String currencyFormat(Object totalSpending) {
    return '$totalSpending د.ج ';
  }

  @override
  String get walkInCustomer => 'زبون عابر';

  @override
  String get selectCustomer => 'اختر عميل';

  @override
  String get close => 'إغلاق';

  @override
  String get cart => '🛒 عربة التسوق';

  @override
  String get payments => 'المدفوعات';

  @override
  String get cartCleared => 'تم مسح العربة';

  @override
  String get completeSale => 'إتمام البيع';

  @override
  String get chooseAction => 'اختر الإجراء';

  @override
  String get removeItem => 'إزالة المنتج؟';

  @override
  String get remove => 'إزالة';

  @override
  String get barcode => 'الباركود';

  @override
  String get name => 'الاسم';

  @override
  String get contactPerson => 'الشخص المسؤول';

  @override
  String get lowStockWarning => '⚠ تحذير من انخفاض المخزون';

  @override
  String get pleaseEnterName => 'ادخل الاسم';

  @override
  String get ok => 'موافق';

  @override
  String get yourBusinessName => 'EasySales';

  @override
  String get contactEmail => 'aneshamididev@gmail.com';

  @override
  String get contactPhone => '0673336972';

  @override
  String get noCustomerSelected => 'لم يتم اختيار عميل';

  @override
  String get withoutCustomer => 'بدون عميل';

  @override
  String get createCustomer => 'إنشاء عميل';

  @override
  String get posScreen => 'شاشة نقاط البيع';

  @override
  String get manageCustomers => 'إدارة العملاء';

  @override
  String get invoiceDetails => 'تفاصيل الفاتورة';

  @override
  String get dashboard => 'لوحة القيادة';

  @override
  String get connectAndManagePrinters => 'توصيل الطابعات وإدارتها';

  @override
  String get database => 'قاعدة البيانات';

  @override
  String get backupOrRestoreData => 'نسخ احتياطي أو استعادة البيانات';

  @override
  String get editCustomer => 'تعديل العميل';

  @override
  String get saveCustomer => 'حفظ العميل';

  @override
  String get backupDatabase => 'نسخ احتياطي لقاعدة البيانات';

  @override
  String get restoreDatabase => 'استعادة قاعدة البيانات';

  @override
  String get customizeAppExperience => 'تخصيص تجربة التطبيق';

  @override
  String get changeAppLanguage => 'تغيير لغة التطبيق';

  @override
  String get productName => 'اسم المنتج';

  @override
  String get description => 'الوصف';

  @override
  String get price => 'السعر';

  @override
  String get cost => 'التكلفة';

  @override
  String get addNewCustomer => 'اضافة عميل';

  @override
  String get clearCart => 'تفريغ السلة';

  @override
  String get clearCartConfirmation => 'هل أنت متأكد أنك تريد تفريغ السلة؟';

  @override
  String get completeSaleConfirmation => 'هل تريد إتمام عملية البيع؟';

  @override
  String get saveOrPrintPrompt => 'هل ترغب في حفظ أو طباعة الفاتورة؟';

  @override
  String get saveAndPrint => 'حفظ وطباعة';

  @override
  String get saveOnly => 'حفظ فقط';

  @override
  String get saleCompletedAndInvoicePrinted => 'تمت عملية البيع وتمت طباعة الفاتورة بنجاح.';

  @override
  String get saleCompletedWithoutPrinting => 'تمت عملية البيع بدون طباعة الفاتورة.';

  @override
  String get errorCompletingSale => 'حدث خطأ أثناء إتمام عملية البيع.';

  @override
  String get quantity => 'الكمية';

  @override
  String get saveProduct => 'حفظ المنتج';

  @override
  String get deleteCustomer => 'مسح العميل';

  @override
  String get deleteProduct => 'حذف المنتج';

  @override
  String get noCustomersFound => 'لا يوجد عملاء';

  @override
  String get getStartedByAddingYourFirstCustomer => 'ابدء باضافة اول عميل';

  @override
  String get category => 'الفئة';

  @override
  String get addNewProduct => 'إضافة منتج جديد';

  @override
  String get editProduct => 'تعديل المنتج';

  @override
  String get pleaseEnterAName => 'الرجاء إدخال اسم.';

  @override
  String get dashboardTitle => 'لوحة القيادة';

  @override
  String get toggleTheme => 'تبديل النمط';

  @override
  String get customers => 'العملاء';

  @override
  String get sales => 'المبيعات';

  @override
  String areYouSureDeleteProduct(Object productName) {
    return 'هل أنت متأكد أنك تريد حذف $productName؟';
  }
}
