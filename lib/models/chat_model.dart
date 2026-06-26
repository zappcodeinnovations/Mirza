class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final StockCardData? stockCard; // Parsed card details, if available

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.stockCard,
  });
}

class StockCardData {
  final String sku;
  final String name;
  final int totalStock;
  final int onlineStock;
  final int warehouseStock;
  final int otherStock;
  final String comment;

  StockCardData({
    required this.sku,
    required this.name,
    required this.totalStock,
    required this.onlineStock,
    required this.warehouseStock,
    required this.otherStock,
    required this.comment,
  });

  // Extract structured stock layout from the API's card text
  static StockCardData? parse(String text) {
    if (!text.contains("CARD_START") || !text.contains("CARD_END")) {
      return null;
    }

    try {
      final startIndex = text.indexOf("CARD_START") + "CARD_START".length;
      final endIndex = text.indexOf("CARD_END");
      final cardContent = text.substring(startIndex, endIndex).trim();
      final explanation = text.substring(endIndex + "CARD_END".length).trim();

      String sku = "";
      String name = "";
      int total = 0;
      int online = 0;
      int warehouse = 0;
      int other = 0;

      final lines = cardContent.split("\n");
      for (var line in lines) {
        line = line.trim();
        if (line.startsWith("SKU:")) {
          final rawSku = line.substring(4).trim();
          final match = RegExp(r'([A-Za-z0-9_]+)[\s\-\t]+(.*)').firstMatch(rawSku);
          if (match != null) {
            sku = match.group(1)?.trim() ?? rawSku;
            name = match.group(2)?.trim() ?? '';
          } else {
            sku = rawSku;
          }
        } else if (line.startsWith("Total Stock:")) {
          total = _extractNumber(line);
        } else if (line.contains("Online BU-3001")) {
          online = _extractNumber(line);
        } else if (line.contains("Warehouse BU-3004")) {
          warehouse = _extractNumber(line);
        } else if (line.contains("Other BU-3006")) {
          other = _extractNumber(line);
        }
      }

      return StockCardData(
        sku: sku,
        name: name,
        totalStock: total,
        onlineStock: online,
        warehouseStock: warehouse,
        otherStock: other,
        comment: explanation,
      );
    } catch (_) {
      return null;
    }
  }

  static int _extractNumber(String s) {
    final exp = RegExp(r'\d+');
    final match = exp.firstMatch(s);
    if (match != null) {
      return int.parse(match.group(0)!);
    }
    return 0;
  }
}
