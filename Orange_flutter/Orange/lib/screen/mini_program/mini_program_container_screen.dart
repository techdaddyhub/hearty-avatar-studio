import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:orange_ui/screen/contacts/widgets/user_qr_card_sheet.dart';
import 'package:orange_ui/screen/moments/create_moment_screen.dart';
import 'package:orange_ui/screen/moments/moments_screen_view_model.dart';
import 'package:orange_ui/service/crypto/e2ee_manager.dart';
import 'package:orange_ui/service/session_manager.dart';
import 'package:orange_ui/utils/color_res.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

class MiniProgramContainerScreen extends StatefulWidget {
  final String title;
  final String appId;
  final String initialUrl;

  const MiniProgramContainerScreen({
    super.key,
    required this.title,
    required this.appId,
    required this.initialUrl,
  });

  @override
  State<MiniProgramContainerScreen> createState() => _MiniProgramContainerScreenState();
}

class _MiniProgramContainerScreenState extends State<MiniProgramContainerScreen> {
  late final WebViewControllerPlus _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewControllerPlus()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'OrangeBridge',
        onMessageReceived: (JavaScriptMessage msg) {
          _handleBridgeMessage(msg.message);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            setState(() => _isLoading = false);
            _injectBridgeScript();
          },
        ),
      );

    if (widget.initialUrl.startsWith('http://') || widget.initialUrl.startsWith('https://')) {
      _controller.loadRequest(Uri.parse(widget.initialUrl));
    } else {
      // Load offline simulated HTML for built-in mini-programs
      _controller.loadHtmlString(_buildSampleMiniProgramHtml(widget.title, widget.appId));
    }
  }

  void _injectBridgeScript() {
    const script = '''
      window.OrangeBridge = {
        call: function(api, params, callback) {
          var callId = Math.random().toString(36).substring(2);
          if (callback) { window['_cb_' + callId] = callback; }
          if (window.OrangeBridgeChannel) {
            window.OrangeBridgeChannel.postMessage(JSON.stringify({api: api, params: params || {}, callId: callId}));
          } else {
            OrangeBridge.postMessage(JSON.stringify({api: api, params: params || {}, callId: callId}));
          }
        },
        _handleResponse: function(callId, result) {
          if (window['_cb_' + callId]) {
            window['_cb_' + callId](result);
            delete window['_cb_' + callId];
          }
        }
      };
      console.log('OrangeBridge initialized');
    ''';
    _controller.runJavaScript(script);
  }

  void _handleBridgeMessage(String raw) {
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final api = json['api'] as String?;
      final callId = json['callId'] as String?;
      final params = json['params'] as Map<String, dynamic>? ?? {};

      log('[OrangeBridge] API call: $api, callId: $callId, params: $params');

      switch (api) {
        case 'getUserProfile':
          final user = SessionManager.instance.getUser();
          final myId = SessionManager.instance.getUserID();
          _sendBridgeResponse(callId, {
            'userId': myId,
            'name': user?.fullname ?? 'Hearty User',
            'avatar': user?.profileImage ?? '',
            'identityKey': E2EEManager.shared.identityPublicKeyBase64,
          });
          break;

        case 'requestPayment':
          final amount = params['amount'] ?? 10;
          _showPaymentDialog(amount.toString(), () {
            _sendBridgeResponse(callId, {'success': true, 'transactionId': 'tx_${DateTime.now().millisecondsSinceEpoch}'});
          });
          break;

        case 'shareMoment':
          final text = params['text'] as String? ?? 'Shared from Mini-Program';
          Get.to(() => CreateMomentScreen(viewModel: MomentsScreenViewModel()));
          _sendBridgeResponse(callId, {'success': true});
          break;

        case 'scanQRCode':
          Get.to(() => const UserQrCardSheet());
          _sendBridgeResponse(callId, {'success': true});
          break;

        case 'closeMiniProgram':
          Navigator.pop(context);
          break;

        default:
          _sendBridgeResponse(callId, {'error': 'Unknown API $api'});
      }
    } catch (e) {
      log('[OrangeBridge] Error handling message: $e');
    }
  }

  void _sendBridgeResponse(String? callId, Map<String, dynamic> data) {
    if (callId == null) return;
    final jsonStr = jsonEncode(data);
    _controller.runJavaScript('window.OrangeBridge._handleResponse("$callId", $jsonStr);');
  }

  void _showPaymentDialog(String amount, VoidCallback onConfirmed) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('WeChat In-App Purchase', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('Confirm payment of $amount Diamonds for ${widget.title}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onConfirmed();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payment Successful!'), backgroundColor: Colors.green),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF07C160)),
              child: const Text('Pay Now', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showMoreMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Reload Mini-Program'),
                onTap: () {
                  Navigator.pop(context);
                  _controller.reload();
                },
              ),
              ListTile(
                leading: const Icon(Icons.share_outlined),
                title: const Text('Share with Contacts'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Shared ${widget.title} with contacts')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Mini-Program Info & Permissions'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  String _buildSampleMiniProgramHtml(String title, String appId) {
    return '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
        <style>
          body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; margin: 0; padding: 20px; background: #f8f9fa; color: #333; }
          .card { background: white; border-radius: 12px; padding: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.06); margin-bottom: 16px; }
          h2 { margin-top: 0; color: #191919; font-size: 20px; }
          p { color: #666; font-size: 14px; line-height: 1.5; }
          .btn { display: block; width: 100%; box-sizing: border-box; background: #07C160; color: white; border: none; border-radius: 8px; padding: 12px; font-size: 16px; font-weight: 600; cursor: pointer; margin-top: 10px; text-align: center; }
          .btn-secondary { background: #576B95; }
          .btn-outline { background: transparent; border: 1px solid #ddd; color: #333; }
          #output { background: #eee; padding: 10px; border-radius: 6px; font-family: monospace; font-size: 12px; word-break: break-all; margin-top: 10px; min-height: 40px; }
        </style>
      </head>
      <body>
        <div class="card">
          <h2>$title</h2>
          <p>App ID: <code>$appId</code></p>
          <p>This is a sandboxed WeChat-standard Mini-Program running within the secure OrangeBridge container.</p>
          <button class="btn" onclick="fetchProfile()">Get User Profile (JSBridge)</button>
          <button class="btn btn-secondary" onclick="requestPay()">Simulate In-App Diamond Pay</button>
          <button class="btn btn-outline" onclick="shareToMoments()">Share to Moments</button>
          <button class="btn btn-outline" style="color: red; border-color: red;" onclick="closeApp()">Exit Mini-Program</button>
          <div id="output">Tap a button above to test bridge communication...</div>
        </div>

        <script>
          function fetchProfile() {
            document.getElementById('output').innerText = 'Calling OrangeBridge.getUserProfile...';
            window.OrangeBridge.call('getUserProfile', {}, function(res) {
              document.getElementById('output').innerText = JSON.stringify(res, null, 2);
            });
          }
          function requestPay() {
            window.OrangeBridge.call('requestPayment', { amount: 50 }, function(res) {
              document.getElementById('output').innerText = 'Payment Result: ' + JSON.stringify(res);
            });
          }
          function shareToMoments() {
            window.OrangeBridge.call('shareMoment', { text: 'Playing with $title on Hearty Super App!' });
          }
          function closeApp() {
            window.OrangeBridge.call('closeMiniProgram', {});
          }
        </script>
      </body>
      </html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(widget.title, style: const TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // WeChat Iconic Capsule Button (胶囊控件: ... and ✕)
          Container(
            margin: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300, width: 1),
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: _showMoreMenu,
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Icon(Icons.more_horiz, size: 18, color: Colors.black87),
                  ),
                ),
                Container(width: 1, height: 16, color: Colors.grey.shade300),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Icon(Icons.radio_button_checked, size: 16, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: ColorRes.themeColor)),
        ],
      ),
    );
  }
}

