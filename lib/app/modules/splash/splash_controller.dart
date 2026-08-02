import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../routes/app_pages.dart';

class SplashController extends GetxController {
  final _storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _navigateToNext();
  }

  void _navigateToNext() async {
    // Elegant delay for the splash animation to finish
    await Future.delayed(const Duration(milliseconds: 3500));
    
    // Forcing onboarding to show after splash as requested
    Get.offAllNamed(Routes.ONBOARDING);
  }
}
