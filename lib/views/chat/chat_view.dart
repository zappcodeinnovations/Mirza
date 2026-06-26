import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/chat_controller.dart';
import '../../core/app_icons.dart';
import '../../core/app_theme.dart';
import '../../models/chat_model.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isChatOpen = false;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleSend() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();
    Provider.of<ChatController>(context, listen: false).sendMessage(text).then((
      _,
    ) {
      _scrollToBottom();
    });
  }

  void _toggleChat() {
    setState(() {
      _isChatOpen = !_isChatOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ChatController>(context);

    // Auto-scroll when messages update
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      
      appBar: AppBar(
        title: const Text(
          'Mirza AI Assistant',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.neonGreen,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(AppIcons.delete, color: AppTheme.neonPink),
            tooltip: 'Clear Conversation History',
            onPressed: () => controller.clearChat(),
          ),
        ],
      ),
      backgroundColor: AppTheme.darkBg,
      body: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            right: 16,
            bottom: _isChatOpen ? 16 : 24,
            width: _isChatOpen ? MediaQuery.sizeOf(context).width - 32 : 72,
            height: _isChatOpen ? MediaQuery.sizeOf(context).height * 0.72 : 72,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 220),
              opacity: 1,
              child: Material(
                color: Colors.transparent,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    color: AppTheme.darkBg, // Change to darkBg for contrast against bubbles
                    borderRadius: BorderRadius.circular(_isChatOpen ? 28 : 36),
                    border: Border.all(color: AppTheme.neonBlue.withOpacity(0.3), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.neonBlue.withOpacity(0.15),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: _isChatOpen
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Column(
                            children: [
                              _buildChatHeader(controller),
                              Expanded(
                                child: ListView.separated(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.all(20),
                                  itemCount: controller.messages.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 16),
                                  itemBuilder: (context, index) {
                                    final msg = controller.messages[index];
                                    return _buildMessageRow(msg);
                                  },
                                ),
                              ),
                              if (controller.isTyping)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 20.0,
                                    right: 20.0,
                                    bottom: 10.0,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.darkBg,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: const Row(
                                          children: [
                                            SizedBox(
                                              width: 14,
                                              height: 14,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(AppTheme.neonBlue),
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'Mirza is checking inventory status...',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF94A3B8),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              _buildInputBar(),
                            ],
                          ),
                        )
                      : InkWell(
                          borderRadius: BorderRadius.circular(36),
                          onTap: _toggleChat,
                          child: const Center(
                            child: Icon(
                              AppIcons.robot,
                              color: Colors.white,
                              size: 34,
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ),
          if (_isChatOpen)
            Positioned(
              right: 24,
              bottom: MediaQuery.sizeOf(context).height * 0.72 + 28,
              child: FloatingActionButton.small(
                onPressed: _toggleChat,
                backgroundColor: AppTheme.neonPink,
                child: const Icon(AppIcons.close, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChatHeader(ChatController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.darkBg,
        border: Border(
          bottom: BorderSide(color: AppTheme.darkAccent, width: 1.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.primaryGradient,
            ),
            child: const Icon(
              AppIcons.robot,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mirza AI Assistant',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Tap a chip or ask about stock, returns, and SKU data',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(AppIcons.refresh, color: AppTheme.neonBlue),
            onPressed: controller.clearChat,
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        border: Border(top: BorderSide(color: AppTheme.darkAccent, width: 1.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Ask about SKU codes, stock, returns...',
                fillColor: AppTheme.darkBg,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: AppTheme.neonBlue.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              style: const TextStyle(color: Color(0xFF223025), fontSize: 14),
              onSubmitted: (_) => _handleSend(),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _handleSend,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.primaryGradient,
              ),
              child: const Icon(AppIcons.send, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageRow(ChatMessage msg) {
    return Row(
      mainAxisAlignment: msg.isUser
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!msg.isUser) ...[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.neonBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(AppIcons.robot, color: AppTheme.neonBlue, size: 18),
          ),
          const SizedBox(width: 10),
        ],
        Flexible(
          child: Column(
            crossAxisAlignment: msg.isUser
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              // Bubble content
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: msg.isUser ? const Color(0xFF223025) : AppTheme.darkSurface,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(msg.isUser ? 20 : 4),
                    bottomRight: Radius.circular(msg.isUser ? 4 : 20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: msg.isUser ? null : Border.all(
                    color: AppTheme.darkAccent,
                    width: 1.0,
                  ),
                ),
                child: Text(
                  msg.stockCard != null ? msg.stockCard!.comment : msg.text,
                  style: GoogleFonts.inter(
                    color: msg.isUser ? Colors.white : const Color(0xFF223025),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),

              // Render custom parsed Graphical stock card (if stock card is parsed!)
              if (msg.stockCard != null) ...[
                const SizedBox(height: 10),
                _buildGraphicalStockCard(msg.stockCard!),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGraphicalStockCard(StockCardData card) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.neonBlue, width: 2.0),
        boxShadow: [
          BoxShadow(
            color: AppTheme.neonBlue.withOpacity(0.15),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header info
          Row(
            children: [
              const Icon(
                AppIcons.inventory2,
                color: AppTheme.neonBlue,
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.sku.isNotEmpty ? card.sku : "MK070338_05",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    if (card.name.isNotEmpty)
                      Text(
                        card.name,
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(color: AppTheme.darkAccent, height: 20),

          // Total Stock Value
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total System Stock",
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "${card.totalStock} units",
                style: const TextStyle(
                  color: AppTheme.neonOrange,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Horizontal Progress metrics per Warehouse BU segment
          _buildWarehouseBar(
            "Online Stock (BU-3001)",
            card.onlineStock,
            card.totalStock,
            AppTheme.neonGreen,
          ),
          const SizedBox(height: 10),
          _buildWarehouseBar(
            "Warehouse Stock (BU-3004)",
            card.warehouseStock,
            card.totalStock,
            AppTheme.neonBlue,
          ),
          const SizedBox(height: 10),
          _buildWarehouseBar(
            "Other Stock (BU-3006)",
            card.otherStock,
            card.totalStock,
            AppTheme.neonPurple,
          ),
        ],
      ),
    );
  }

  Widget _buildWarehouseBar(String label, int val, int total, Color barColor) {
    final double percent = total > 0 ? (val / total).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
            ),
            Text(
              "$val un",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 6,
            backgroundColor: AppTheme.darkBg,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ],
    );
  }
}
