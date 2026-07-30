import 'package:get/get.dart';
import 'package:real_estate/modules/digi_gold/views/buy_gold_view.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/main_shell_view.dart';
import '../modules/properties/bindings/property_detail_binding.dart';
import '../modules/properties/views/property_detail_view.dart';
import '../modules/kyc/bindings/kyc_binding.dart';
import '../modules/kyc/views/kyc_view.dart';
import '../modules/savings/views/my_plans_view.dart';
import '../modules/wishlist/views/wishlist_view.dart';
import '../modules/wishlist/views/admin_wishlist_view.dart';
import '../modules/transactions/views/transaction_history_view.dart';
import '../modules/lock/views/passcode_setup_view.dart';
import '../modules/lock/views/passcode_setup_view.dart' show LockScreenView;
import '../modules/lock/views/security_settings_view.dart';
import '../modules/digi_gold/views/digi_gold_view.dart';
import '../modules/digi_gold/views/digi_gold_savings_view.dart';
import '../modules/digi_gold/views/gold_schemes_view.dart';
import '../modules/digi_gold/views/sell_gold_view.dart';
// import '../modules/digi_gold/views/buy_gold_view.dart';
import '../modules/digi_gold/views/my_gold_view.dart';
import '../modules/wallet/views/wallet_view.dart';
import '../modules/wallet/views/bank_accounts_view.dart';
import '../modules/wallet/views/add_bank_account_view.dart';
import '../modules/wallet/controllers/wallet_controller.dart';

abstract class AppRoutes {
  static const login          = '/login';
  static const register       = '/register';
  static const home           = '/home';
  static const properties     = '/properties';
  static const propertyDetail = '/properties/detail';
  static const investments    = '/investments';
  static const profile        = '/profile';
  static const kyc            = '/kyc';
  static const myPlans        = '/savings/my-plans';
  static const wishlist       = '/wishlist';
  static const adminWishlist  = '/admin/wishlist';
  static const transactions   = '/transactions';
  static const passcodeSetup  = '/passcode-setup';
  static const lockScreen     = '/lock';
  static const security       = '/security';
  static const digiGold         = '/digi-gold';
  static const digiGoldSavings  = '/digi-gold/savings';
  static const goldSchemes      = '/digi-gold/schemes';
  static const sellGold          = '/digi-gold/sell';
  static const buyGold           = '/digi-gold/buy';
  static const myGold            = '/digi-gold/my-gold';
  static const wallet            = '/wallet';
  static const bankAccounts      = '/wallet/banks';
  static const addBankAccount    = '/wallet/banks/add';
}

final appPages = [
  GetPage(name: AppRoutes.login,          page: () => const LoginView(),              binding: AuthBinding()),
  GetPage(name: AppRoutes.register,       page: () => const RegisterView(),           binding: AuthBinding()),
  GetPage(name: AppRoutes.home,           page: () => const MainShellView(),          binding: HomeBinding()),
  GetPage(name: AppRoutes.propertyDetail, page: () => const PropertyDetailView(),     binding: PropertyDetailBinding()),
  GetPage(name: AppRoutes.kyc,            page: () => const KycView(),               binding: KycBinding()),
  GetPage(name: AppRoutes.myPlans,        page: () => const MyPlansView()),
  GetPage(name: AppRoutes.wishlist,       page: () => const WishlistView()),
  GetPage(name: AppRoutes.adminWishlist,  page: () => const AdminWishlistView()),
  GetPage(name: AppRoutes.transactions,   page: () => const TransactionHistoryView()),
  GetPage(name: AppRoutes.passcodeSetup,  page: () => const PasscodeSetupView()),
  GetPage(name: AppRoutes.lockScreen,     page: () => const LockScreenView()),
  GetPage(name: AppRoutes.security,       page: () => const SecuritySettingsView()),
  GetPage(name: AppRoutes.digiGold,        page: () => const DigiGoldView()),
  GetPage(name: AppRoutes.digiGoldSavings, page: () => const DigiGoldSavingsView(), binding: BindingsBuilder(() {
    if (!Get.isRegistered<WalletController>()) Get.put(WalletController());
  })),
  GetPage(name: AppRoutes.goldSchemes, page: () => const GoldSchemesView(), binding: BindingsBuilder(() {
    if (!Get.isRegistered<WalletController>()) Get.put(WalletController());
  })),
  GetPage(name: AppRoutes.sellGold,        page: () => const SellGoldView(), binding: BindingsBuilder(() {
    if (!Get.isRegistered<WalletController>()) Get.put(WalletController());
  })),
  GetPage(name: AppRoutes.buyGold,         page: () => const BuyGoldView(), binding: BindingsBuilder(() {
    if (!Get.isRegistered<WalletController>()) Get.put(WalletController());
  })),
  GetPage(name: AppRoutes.myGold,          page: () => const MyGoldView()),
  GetPage(name: AppRoutes.wallet,          page: () => const WalletView(), binding: BindingsBuilder(() {
    if (!Get.isRegistered<WalletController>()) Get.put(WalletController());
  })),
  GetPage(name: AppRoutes.bankAccounts,    page: () => const BankAccountsView(), binding: BindingsBuilder(() {
    if (!Get.isRegistered<WalletController>()) Get.put(WalletController());
  })),
  GetPage(name: AppRoutes.addBankAccount,  page: () => const AddBankAccountView(), binding: BindingsBuilder(() {
    if (!Get.isRegistered<WalletController>()) Get.put(WalletController());
  })),
];