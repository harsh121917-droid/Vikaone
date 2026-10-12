import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/services/lock_service.dart';
import '../../../core/theme/controllers/theme_controller.dart';

class PropertyDocumentViewerScreen extends StatefulWidget {
  const PropertyDocumentViewerScreen({
    super.key,
    required this.url,
    required this.title,
    this.category,
  });

  final String url;
  final String title;
  final String? category;

  @override
  State<PropertyDocumentViewerScreen> createState() =>
      _PropertyDocumentViewerScreenState();
}

class _PropertyDocumentViewerScreenState
    extends State<PropertyDocumentViewerScreen> {
  late final WebViewController _controller;
  int _progress = 0;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();

    // Suppress lock while document viewing is in progress
    if (Get.isRegistered<LockService>()) {
      LockService.to.suppressLockFor(const Duration(minutes: 10));
    }

    _initWebview();
  }

  String _buildViewerUrl(String rawUrl) {
    final clean = rawUrl.trim();
    final lower = clean.toLowerCase();
    // If it's a PDF or cloud storage link, use Google Docs Viewer for seamless in-app rendering
    if (lower.endsWith('.pdf') ||
        lower.contains('.pdf?') ||
        lower.contains('cloudinary') ||
        lower.contains('amazonaws') ||
        lower.contains('drive.google') ||
        lower.contains('storage')) {
      return 'https://docs.google.com/viewer?url=${Uri.encodeComponent(clean)}&embedded=true';
    }
    return clean;
  }

  void _initWebview() {
    final targetUrl = _buildViewerUrl(widget.url);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (p) {
            if (mounted) {
              setState(() {
                _progress = p;
                if (p >= 100) _isLoading = false;
              });
            }
          },
          onPageStarted: (url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _hasError = false;
              });
            }
          },
          onPageFinished: (url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (error) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _hasError = true;
                _errorMessage = error.description;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(targetUrl));
  }

  Future<void> _openInExternalBrowser() async {
    HapticFeedback.selectionClick();
    if (Get.isRegistered<LockService>()) {
      LockService.to.suppressLockFor(const Duration(minutes: 10));
    }
    final uri = Uri.parse(widget.url.trim());
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      }
    } catch (_) {
      Get.snackbar(
        'Notice',
        'Could not open document in external browser.',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
    }
  }

  void _copyLink() {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: widget.url.trim()));
    Get.snackbar(
      'Link Copied',
      'Document URL copied to clipboard.',
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = ThemeController.to.isDark.value;
      final bg = dark ? const Color(0xFF060B16) : const Color(0xFFF8FAFC);
      final cardBg = dark ? const Color(0xFF0E1626) : Colors.white;
      final border = dark ? const Color(0xFF1E2D4A) : const Color(0xFFE2E8F0);
      final textP = dark ? const Color(0xFFEDF0FF) : const Color(0xFF0F172A);
      final textS = dark ? const Color(0xFF8A95B0) : const Color(0xFF64748B);

      return Scaffold(
        backgroundColor: bg,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Container(
            decoration: BoxDecoration(
              color: cardBg,
              border: Border(bottom: BorderSide(color: border)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(dark ? 0.3 : 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    // Back button — returns directly to Property Detail
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: textP,
                        size: 22,
                      ),
                      tooltip: 'Back to Property Details',
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Get.back();
                      },
                    ),
                    const SizedBox(width: 4),

                    // Document Badge & Title
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1.5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2563EB).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: const Color(0xFF2563EB).withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  widget.category?.toUpperCase() ?? 'VERIFIED DOCUMENT',
                                  style: const TextStyle(
                                    color: Color(0xFF2563EB),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.verified_user_rounded,
                                size: 12,
                                color: Color(0xFF10B981),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.title,
                            style: TextStyle(
                              color: textP,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Actions
                    IconButton(
                      icon: Icon(
                        Icons.copy_rounded,
                        color: textS,
                        size: 18,
                      ),
                      tooltip: 'Copy Link',
                      onPressed: _copyLink,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.refresh_rounded,
                        color: textS,
                        size: 20,
                      ),
                      tooltip: 'Reload Document',
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        _controller.reload();
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.open_in_new_rounded,
                        color: Color(0xFF2563EB),
                        size: 20,
                      ),
                      tooltip: 'Open in Browser',
                      onPressed: _openInExternalBrowser,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            // WebView
            WebViewWidget(controller: _controller),

            // Linear Progress Bar
            if (_isLoading)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  value: _progress > 0 ? _progress / 100 : null,
                  backgroundColor: Colors.transparent,
                  color: const Color(0xFF2563EB),
                  minHeight: 3,
                ),
              ),

            // Loading Splash Screen
            if (_isLoading && _progress < 40)
              Positioned.fill(
                child: Container(
                  color: bg,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2563EB).withOpacity(0.35),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.picture_as_pdf_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading Document Preview...',
                          style: TextStyle(
                            color: textP,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Rendering official high-resolution PDF preview',
                          style: TextStyle(
                            color: textS,
                            fontSize: 11.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Error View
            if (_hasError)
              Positioned.fill(
                child: Container(
                  color: bg,
                  padding: const EdgeInsets.all(28),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.error_outline_rounded,
                            color: Color(0xFFEF4444),
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Could Not Load Preview',
                          style: TextStyle(
                            color: textP,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _errorMessage.isNotEmpty
                              ? _errorMessage
                              : 'Please check your internet connection and try again.',
                          style: TextStyle(
                            color: textS,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _hasError = false;
                                  _isLoading = true;
                                });
                                _controller.reload();
                              },
                              icon: const Icon(Icons.refresh_rounded, size: 16),
                              label: const Text('Retry'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                              onPressed: _openInExternalBrowser,
                              icon: const Icon(Icons.open_in_browser_rounded, size: 16),
                              label: const Text('Open Browser'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF2563EB),
                                side: const BorderSide(color: Color(0xFF2563EB)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}
