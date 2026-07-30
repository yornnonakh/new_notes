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
    await Future.delayed(const Duration(seconds: 3));
    
    bool isFirstTime = _storage.read('isFirstTime') ?? true;
    String? token = _storage.read('token');

    if (isFirstTime) {
      Get.offAllNamed(Routes.ONBOARDING);
    } else if (token == null) {
      Get.offAllNamed(Routes.LOGIN);
    } else {
      Get.offAllNamed(Routes.FOLDER);
    }
  }
}
