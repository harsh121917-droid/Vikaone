import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../../data/models/property_model.dart';
import '../../../data/models/home_video_model.dart';
import '../../../data/repositories/property_repository.dart';
import '../../../data/repositories/home_video_repository.dart';

class HomeController extends GetxController {
  final PropertyRepository _repo = Get.find();
  final HomeVideoRepository _videoRepo = Get.find();

  final isLoading = false.obs;
  final featuredProps = <PropertyModel>[].obs;
  final errorMsg = ''.obs;
  final selectedCategory = (-1).obs;
  final selectedTab = 0.obs;

  // ── YouTube Home Videos State ──
  final homeVideos = <HomeVideoModel>[].obs;
  final isVideosLoading = false.obs;
  final currentVideoIndex = 0.obs;
  final isAutoSlidePaused = false.obs;
  final isVideoPlaying = false.obs;
  PageController? videoPageController;
  Timer? _slideTimer;

  @override
  void onInit() {
    super.onInit();
    videoPageController = PageController();
    loadFeatured();
    loadHomeVideos();
  }

  Future<void> loadFeatured() async {
    try {
      isLoading.value = true;
      var props = await _repo.getProperties(featured: true, limit: 20);
      if (props.isEmpty) props = await _repo.getProperties(limit: 20);
      featuredProps.value = props;
    } on DioException catch (e) {
      errorMsg.value = e.response?.data?['message'] ?? 'Failed to load';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadHomeVideos() async {
    try {
      isVideosLoading.value = true;
      final list = await _videoRepo.getHomeVideos();
      homeVideos.assignAll(list);
      if (homeVideos.length > 1) {
        _startAutoSlide();
      }
    } catch (_) {
    } finally {
      isVideosLoading.value = false;
    }
  }

  void _startAutoSlide() {
    _slideTimer?.cancel();
    _slideTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (isAutoSlidePaused.value || isVideoPlaying.value || homeVideos.length <= 1) {
        return;
      }
      if (videoPageController != null && videoPageController!.hasClients) {
        final nextIdx = (currentVideoIndex.value + 1) % homeVideos.length;
        videoPageController!.animateToPage(
          nextIdx,
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  void onVideoPageChanged(int index) {
    currentVideoIndex.value = index;
  }

  void pauseAutoSlide() {
    isAutoSlidePaused.value = true;
  }

  void resumeAutoSlide() {
    isAutoSlidePaused.value = false;
  }

  void setVideoPlaying(bool playing) {
    isVideoPlaying.value = playing;
    if (playing) {
      pauseAutoSlide();
    } else {
      resumeAutoSlide();
    }
  }

  void nextVideo() {
    if (homeVideos.isEmpty) return;
    final nextIdx = (currentVideoIndex.value + 1) % homeVideos.length;
    videoPageController?.animateToPage(
      nextIdx,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void prevVideo() {
    if (homeVideos.isEmpty) return;
    final prevIdx = (currentVideoIndex.value - 1 + homeVideos.length) % homeVideos.length;
    videoPageController?.animateToPage(
      prevIdx,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  void onClose() {
    _slideTimer?.cancel();
    videoPageController?.dispose();
    super.onClose();
  }
}
