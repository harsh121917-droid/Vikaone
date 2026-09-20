import 'package:get/get.dart';
import 'package:real_estate/data/repositories/transaction_repository.dart';
import 'package:real_estate/data/repositories/wallet_repository.dart';
import 'package:real_estate/modules/wallet/controllers/wallet_controller.dart';
import 'package:real_estate/modules/transactions/controllers/transaction_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/main_shell_controller.dart';
import '../../../data/repositories/property_repository.dart';
import '../../../data/repositories/investment_repository.dart';
import '../../../data/repositories/saving_repository.dart';
import '../../../data/repositories/wishlist_repository.dart';
import '../../../data/repositories/home_video_repository.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../properties/controllers/properties_controller.dart';
import '../../investments/controllers/investments_controller.dart';
import '../../savings/controllers/savings_controller.dart';
import '../../wishlist/controllers/wishlist_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Repositories
    Get.lazyPut<PropertyRepository>(() => PropertyRepository());
    Get.lazyPut<InvestmentRepository>(() => InvestmentRepository());
    Get.lazyPut<SavingRepository>(() => SavingRepository());
    Get.lazyPut<WishlistRepository>(() => WishlistRepository());
    Get.lazyPut<TransactionRepository>(() => TransactionRepository());
    Get.lazyPut<WalletRepository>(() => WalletRepository());
    Get.lazyPut<HomeVideoRepository>(() => HomeVideoRepository());

    // Controllers
    Get.lazyPut<AuthController>(() => AuthController());
    Get.lazyPut<MainShellController>(() => MainShellController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<PropertiesController>(() => PropertiesController());
    Get.lazyPut<InvestmentsController>(() => InvestmentsController());
    Get.lazyPut<SavingsController>(() => SavingsController());
    Get.lazyPut<WishlistController>(() => WishlistController());
    Get.lazyPut<TransactionController>(() => TransactionController());
    Get.lazyPut<WalletController>(() => WalletController());
  }
}
