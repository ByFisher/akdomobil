import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'presentation/theme/app_theme.dart';

void main() {
  runApp(const AkdoApp());
}

const Color akdoCream = AkdoAppTheme.groupedBackground;
const Color akdoGreen = AkdoAppTheme.accent;
const Color akdoBrown = AkdoAppTheme.label;
const Color akdoGold = AkdoAppTheme.accent;
const Color akdoText = AkdoAppTheme.label;
const String appVersion = '1.0.0';
const String privacyNoticeVersion = '2026-11-06-v1';

class AkdoApp extends StatelessWidget {
  const AkdoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Akdo',
      theme: AkdoAppTheme.light,
      home: const StartScreen(),
    );
  }
}

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  void _openCustomerLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MemberScreen(
          onAuthenticated: (member) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => HomeMenuScreen(member: member)),
              (_) => false,
            );
          },
        ),
      ),
    );
  }

  void _openAdminLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminScreen()),
    );
  }

  void _openStaffLogin(BuildContext context, String role) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => StaffScreen(initialRole: role)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AkdoThemeTokens>()!;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    'assets/logo/akdoqr.png',
                    height: 96,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Hoş geldiniz',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: akdoText,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Devam etmek için giriş türünüzü seçin.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: tokens.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () => _openCustomerLogin(context),
                      icon: const Icon(Icons.person_outline),
                      label: const Text('MÜŞTERİ OLARAK GİRİŞ YAP'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: () => _openAdminLogin(context),
                      icon: const Icon(Icons.admin_panel_settings_outlined),
                      label: const Text('YÖNETİCİ OLARAK GİRİŞ YAP'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: akdoText,
                        side: BorderSide(color: tokens.separator),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            tokens.cornerRadius,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: () => _openStaffLogin(context, 'chef'),
                      icon: const Icon(Icons.restaurant_menu_outlined),
                      label: const Text('AKDOŞEF GİRİŞİ'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: akdoText,
                        side: BorderSide(color: tokens.separator),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            tokens.cornerRadius,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: () => _openStaffLogin(context, 'waiter'),
                      icon: const Icon(Icons.room_service_outlined),
                      label: const Text('AKDOGARSON GİRİŞİ'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: akdoText,
                        side: BorderSide(color: tokens.separator),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            tokens.cornerRadius,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Sürüm $appVersion',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: tokens.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'LunaSoft ürünüdür.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: tokens.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ApiClient {
  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) return _configuredBaseUrl;
    if (kIsWeb) return '';
    return 'http://192.168.1.9:8081';
  }

  static const String _cookieKey = 'akdo_cookie';

  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final cookie = prefs.getString(_cookieKey);
    return {
      'Content-Type': 'application/json',
      if (cookie != null && cookie.isNotEmpty) 'Cookie': cookie,
    };
  }

  static Future<http.Response> get(String path) async {
    final response = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(),
    );
    await _saveCookie(response);
    return response;
  }

  static Future<http.Response> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    await _saveCookie(response);
    return response;
  }

  static Future<http.Response> patch(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await http.patch(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    await _saveCookie(response);
    return response;
  }

  static Future<void> _saveCookie(http.Response response) async {
    final cookie = response.headers['set-cookie'];
    if (cookie == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cookieKey, cookie.split(';').first);
  }

  static Map<String, dynamic>? jsonBody(http.Response response) {
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static String error(http.Response response, String fallback) {
    final body = jsonBody(response);
    final message = body?['error'];
    return message is String && message.isNotEmpty ? message : fallback;
  }
}

class MenuCategory {
  final String id;
  final String name;
  final String slug;
  final String icon;
  const MenuCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.icon,
  });
}

class MenuProduct {
  final String id;
  final String name;
  final String description;
  final int price;
  final String imageUrl;
  final String categoryName;
  final String categorySlug;
  final bool featured;

  const MenuProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.categoryName,
    required this.categorySlug,
    this.featured = false,
  });
}

class CartStore {
  static final Map<String, int> quantities = {};
  static String branchId = 'merkez';

  static int get count =>
      quantities.values.fold(0, (sum, value) => sum + value);
  static int total(List<MenuProduct> products) {
    var total = 0;
    for (final entry in quantities.entries) {
      MenuProduct? product;
      for (final item in products) {
        if (item.id == entry.key) {
          product = item;
          break;
        }
      }
      if (product != null) total += product.price * entry.value;
    }
    return total;
  }
}

String formatPrice(int amount) =>
    '${(amount / 100).toStringAsFixed(amount % 100 == 0 ? 0 : 2).replaceAll('.', ',')} ₺';

class HomeMenuScreen extends StatefulWidget {
  final Map<String, dynamic> member;
  const HomeMenuScreen({super.key, required this.member});
  @override
  State<HomeMenuScreen> createState() => _HomeMenuScreenState();
}

class _HomeMenuScreenState extends State<HomeMenuScreen> {
  List<MenuProduct> products = [];
  List<MenuCategory> categories = [];
  String selectedCategory = 'all';
  String branchName = 'Merkez Şube';
  String search = '';
  Map<String, dynamic>? member;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    member = widget.member;
    _loadPublicMenu();
  }

  Future<void> _loadPublicMenu() async {
    try {
      final response = await ApiClient.get('/api/public/menu');
      final body = ApiClient.jsonBody(response);
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          body == null) {
        return;
      }
      final categoryRows = body['categories'] is List
          ? List<dynamic>.from(body['categories'])
          : [];
      final productRows = body['products'] is List
          ? List<dynamic>.from(body['products'])
          : [];
      if (!mounted) return;
      setState(() {
        categories = categoryRows.whereType<Map>().map((raw) {
          final item = Map<String, dynamic>.from(raw);
          return MenuCategory(
            id: item['id'].toString(),
            name: item['name'].toString(),
            slug: item['slug'].toString(),
            icon: item['icon']?.toString() ?? '✦',
          );
        }).toList();
        products = productRows.whereType<Map>().map((raw) {
          final item = Map<String, dynamic>.from(raw);
          final category = item['category'] is Map
              ? Map<String, dynamic>.from(item['category'] as Map)
              : <String, dynamic>{};
          return MenuProduct(
            id: item['id'].toString(),
            name: item['name']?.toString() ?? '',
            description: item['description']?.toString() ?? '',
            price: (item['price'] as num?)?.toInt() ?? 0,
            imageUrl: item['imageUrl']?.toString() ?? '',
            categoryName: category['name']?.toString() ?? '',
            categorySlug: category['slug']?.toString() ?? '',
            featured: item['featured'] == true,
          );
        }).toList();
      });
    } catch (_) {}
  }

  Future<void> _logout() async {
    try {
      final response = await ApiClient.post('/api/members/logout', {});
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(ApiClient.error(response, 'Oturum kapatılamadı.'));
      }
      if (!mounted) return;
      CartStore.quantities.clear();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const StartScreen()),
        (_) => false,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  List<MenuProduct> get visible {
    final query = search.trim().toLowerTurkish();
    return products.where((product) {
      final categoryMatch =
          selectedCategory == 'all' || product.categorySlug == selectedCategory;
      final searchMatch =
          query.isEmpty ||
          '${product.name} ${product.description} ${product.categoryName}'
              .toLowerTurkish()
              .contains(query);
      return categoryMatch && searchMatch;
    }).toList();
  }

  void changeQuantity(MenuProduct product, int delta) {
    setState(() {
      final next = (CartStore.quantities[product.id] ?? 0) + delta;
      if (next <= 0) {
        CartStore.quantities.remove(product.id);
      } else {
        CartStore.quantities[product.id] = next.clamp(0, 99);
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = visible.where((item) => item.featured).toList();
    return Scaffold(
      backgroundColor: akdoCream,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                height: 30,
                color: akdoBrown,
                alignment: Alignment.center,
                child: const Text(
                  "MARAŞ'IN GELENEKSEL LEZZETİ · HER GÜN TAZE",
                  style: TextStyle(
                    color: Color(0xFFD4D4D8),
                    fontSize: 9,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
            SliverAppBar(
              pinned: true,
              backgroundColor: const Color(0xFFFAFAFA),
              surfaceTintColor: Colors.transparent,
              automaticallyImplyLeading: false,
              toolbarHeight: 74,
              title: Row(
                children: [
                  Image.asset(
                    'assets/logo/akdoqr.png',
                    width: 58,
                    height: 50,
                    fit: BoxFit.contain,
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Yönetim merkezi',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminScreen()),
                    ),
                    icon: const Icon(
                      Icons.admin_panel_settings_outlined,
                      color: akdoGreen,
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    tooltip: 'Profil menüsü',
                    onSelected: (action) {
                      if (action == 'account') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MemberScreen(
                              initialMember: member,
                              onLoggedOut: () {
                                CartStore.quantities.clear();
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (_) => const StartScreen(),
                                  ),
                                  (_) => false,
                                );
                              },
                            ),
                          ),
                        );
                      } else if (action == 'logout') {
                        _logout();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem<String>(
                        enabled: false,
                        child: SizedBox(
                          width: 210,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${member!['firstName'] ?? ''} ${member!['lastName'] ?? ''}'
                                    .trim(),
                                style: const TextStyle(
                                  color: akdoText,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Üye no: ${member!['memberNumber'] ?? '-'}',
                                style: const TextStyle(
                                  color: Color(0xFF71717A),
                                  fontSize: 12,
                                ),
                              ),
                              if (member!['username'] != null)
                                Text(
                                  'Kullanıcı adı: ${member!['username']}',
                                  style: const TextStyle(
                                    color: Color(0xFF71717A),
                                    fontSize: 12,
                                  ),
                                ),
                              if (member!['phone'] != null)
                                Text(
                                  member!['phone'].toString(),
                                  style: const TextStyle(
                                    color: Color(0xFF71717A),
                                    fontSize: 12,
                                  ),
                                ),
                              const Divider(height: 20),
                            ],
                          ),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'account',
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.person_outline),
                          title: Text('Hesabım ve bakiye'),
                          dense: true,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'logout',
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.logout),
                          title: Text('Oturumu kapat'),
                          dense: true,
                        ),
                      ),
                    ],
                    child: CircleAvatar(
                      radius: 19,
                      backgroundColor: const Color(0xFFF4F4F5),
                      foregroundColor: akdoText,
                      child: Text(
                        (member!['firstName']?.toString().isNotEmpty ?? false)
                            ? member!['firstName']
                                  .toString()
                                  .substring(0, 1)
                                  .toUpperCase()
                            : '?',
                      ),
                    ),
                  ),
                ],
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(44),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE4E4E7)),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.place_outlined,
                        size: 16,
                        color: akdoGold,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: branchName,
                            isDense: true,
                            items: const [
                              DropdownMenuItem(
                                value: 'Merkez Şube',
                                child: Text(
                                  'Merkez Şube',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                            onChanged: (_) {},
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TableOrderScreen(),
                          ),
                        ),
                        child: const Text(
                          'MASADAN SİPARİŞ',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(child: _HeroSection()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: TextField(
                  onChanged: (value) => setState(() => search = value),
                  decoration: const InputDecoration(
                    hintText: 'Menüde ara',
                    prefixIcon: Icon(Icons.search, size: 19),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _CategoryChip(
                      label: 'Tümü',
                      active: selectedCategory == 'all',
                      onTap: () => setState(() => selectedCategory = 'all'),
                    ),
                    ...categories.map(
                      (category) => _CategoryChip(
                        label: '${category.icon}  ${category.name}',
                        active: selectedCategory == category.slug,
                        onTap: () =>
                            setState(() => selectedCategory = category.slug),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (search.isEmpty && selectedCategory == 'all' && top.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AKDO SEÇKİSİ',
                        style: TextStyle(
                          fontSize: 9,
                          color: akdoGold,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _FeaturedCard(
                        product: top.first,
                        quantity: CartStore.quantities[top.first.id] ?? 0,
                        onChange: (delta) => changeQuantity(top.first, delta),
                      ),
                    ],
                  ),
                ),
              ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
              sliver: SliverList.builder(
                itemCount: visible.length,
                itemBuilder: (context, index) {
                  final product = visible[index];
                  return _ProductCard(
                    product: product,
                    quantity: CartStore.quantities[product.id] ?? 0,
                    onChange: (delta) => changeQuantity(product, delta),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: CartStore.count == 0
          ? null
          : FloatingActionButton.extended(
              backgroundColor: akdoGreen,
              foregroundColor: Colors.white,
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CartScreen(products: products),
                  ),
                );
                setState(() {});
              },
              label: Text(
                '${CartStore.count}  ·  ${formatPrice(CartStore.total(products))}',
              ),
              icon: const Icon(Icons.shopping_bag_outlined),
            ),
      drawer: _MainDrawer(
        onMember: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MemberScreen(initialMember: member),
          ),
        ),
        onTable: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TableOrderScreen()),
        ),
        onStaff: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const StaffScreen()),
        ),
        onAdmin: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdminScreen()),
        ),
        onTracking: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TrackingScreen()),
        ),
        onNotifications: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationsScreen()),
        ),
      ),
    );
  }
}

class TrackingScreen extends StatefulWidget {
  final String? initialToken;
  const TrackingScreen({super.key, this.initialToken});
  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final token = TextEditingController();
  Map<String, dynamic>? order;
  String? error;
  Timer? timer;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialToken != null) {
      token.text = widget.initialToken!;
      loadOrder();
      timer = Timer.periodic(const Duration(seconds: 5), (_) => loadOrder());
    }
  }

  Future<void> loadOrder() async {
    if (token.text.isEmpty) return;
    setState(() => loading = true);
    try {
      final response = await ApiClient.get(
        '/api/orders/${Uri.encodeComponent(token.text)}',
      );
      final body = ApiClient.jsonBody(response);
      if (response.statusCode < 200 || response.statusCode >= 300)
        throw Exception(ApiClient.error(response, 'Sipariş bulunamadı.'));
      setState(() {
        order = Map<String, dynamic>.from(body!['order'] as Map);
        error = null;
      });
    } catch (e) {
      setState(() => error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const labels = {
      'PENDING': 'Sipariş alındı',
      'PREPARING': 'Hazırlanıyor',
      'READY': 'Garson bekleniyor',
      'SERVED': 'Teslim edildi',
    };
    return Scaffold(
      appBar: AppBar(
        backgroundColor: akdoCream,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Sipariş Takibi',
          style: TextStyle(fontFamily: 'Georgia'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: token,
            decoration: const InputDecoration(
              labelText: 'Takip kodu',
              prefixIcon: Icon(Icons.route_outlined),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: loading ? null : loadOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: akdoGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('DURUMU SORGULA'),
            ),
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                error!,
                style: const TextStyle(color: Color(0xFFA63E35)),
              ),
            ),
          if (order != null) ...[
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE4E4E7)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SİPARİŞ TAKİBİ',
                    style: TextStyle(
                      fontSize: 9,
                      color: akdoGold,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.8,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    '${order!['branch']['name']} · ${order!['table']['name']}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: akdoGreen,
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (order!['status'] == 'CANCELLED')
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        order!['paymentStatus'] == 'REFUNDED'
                            ? 'Sipariş iptal edildi. Tutar üye bakiyenize iade edildi.'
                            : 'Sipariş iptal edildi.',
                        style: const TextStyle(
                          color: Color(0xFFB42318),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    ...labels.entries.map((stage) {
                      final statuses = [
                        'PENDING',
                        'PREPARING',
                        'READY',
                        'SERVED',
                      ];
                      final current = statuses.indexOf(
                        order!['status']?.toString() ?? '',
                      );
                      final index = statuses.indexOf(stage.key);
                      final complete = index <= current;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        child: Row(
                          children: [
                            Icon(
                              complete
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              size: 19,
                              color: complete
                                  ? const Color(0xFF09090B)
                                  : const Color(0xFFA1A1AA),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              stage.value,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: complete
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: complete
                                    ? akdoGreen
                                    : const Color(0xFF71717A),
                              ),
                            ),
                            if (index == current &&
                                order!['status'] != 'SERVED') ...[
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF4F4F5),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Güncel',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: akdoGreen,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }),
                  const Divider(height: 28),
                  const Text(
                    'Sipariş özeti',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...List<Map<String, dynamic>>.from(order!['items'] as List)
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${item['quantity']} × ${item['name']}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              Text(
                                formatPrice(
                                  (item['quantity'] as num).toInt() *
                                      (item['price'] as num).toInt(),
                                ),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Toplam',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        formatPrice((order!['total'] as num).toInt()),
                        style: const TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 18,
                          color: akdoGold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> notifications = [];
  String? error;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final response = await ApiClient.get('/api/members/notifications');
      final body = ApiClient.jsonBody(response);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(ApiClient.error(response, 'Bildirimler alınamadı.'));
      }
      final rows = body?['notifications'];
      if (rows is! List) {
        throw Exception('Bildirim listesi alınamadı.');
      }
      if (!mounted) return;
      setState(() {
        notifications = rows
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      });
    } catch (e) {
      if (mounted) {
        setState(() => error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _markRead(String id) async {
    try {
      final response = await ApiClient.patch(
        '/api/members/notifications/${Uri.encodeComponent(id)}',
        {'read': true},
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(ApiClient.error(response, 'Bildirim güncellenemedi.'));
      }
      if (!mounted) return;
      setState(() {
        notifications = notifications.map((item) {
          if (item['id'] == id) {
            return {...item, 'readAt': DateTime.now().toIso8601String()};
          }
          return item;
        }).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  String _dateLabel(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '');
    if (date == null) return '';
    final local = date.toLocal();
    return '${local.day.toString().padLeft(2, '0')}.${local.month.toString().padLeft(2, '0')}.${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: akdoCream,
        surfaceTintColor: Colors.transparent,
        title: const Text('Bildirimler'),
        actions: [
          IconButton(
            tooltip: 'Yenile',
            onPressed: loading ? null : loadNotifications,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: loading && notifications.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : error != null && notifications.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(error!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: loadNotifications,
                      child: const Text('Yeniden dene'),
                    ),
                  ],
                ),
              ),
            )
          : notifications.isEmpty
          ? const Center(child: Text('Henüz bildiriminiz yok.'))
          : RefreshIndicator(
              onRefresh: loadNotifications,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = notifications[index];
                  final isUnread = item['readAt'] == null;
                  return Material(
                    color: isUnread ? const Color(0xFFF4F4F5) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    child: ListTile(
                      leading: Icon(
                        item['type'] == 'ORDER_STATUS' ||
                                item['type'] == 'ORDER_CANCELLED'
                            ? Icons.receipt_long_outlined
                            : Icons.notifications_none,
                        color: akdoText,
                      ),
                      title: Text(
                        item['title']?.toString() ?? 'Bildirim',
                        style: TextStyle(
                          fontWeight: isUnread
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        '${item['body']?.toString() ?? ''}\n${_dateLabel(item['createdAt'])}',
                      ),
                      isThreeLine: true,
                      onTap: isUnread
                          ? () => _markRead(item['id'].toString())
                          : null,
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class TableOrderScreen extends StatefulWidget {
  const TableOrderScreen({super.key});
  @override
  State<TableOrderScreen> createState() => _TableOrderScreenState();
}

class _TableOrderScreenState extends State<TableOrderScreen> {
  final code = TextEditingController();
  List<Map<String, dynamic>> products = [];
  Map<String, dynamic>? menu;
  final quantities = <String, int>{};
  bool loading = false;
  bool placing = false;
  String? error;

  Future<void> loadMenu() async {
    if (code.text.length != 6) return;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final response = await ApiClient.get(
        '/api/orders/menu?code=${code.text}',
      );
      if (response.statusCode == 401) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MemberScreen(returnTo: true)),
        );
        return;
      }
      if (response.statusCode < 200 || response.statusCode >= 300)
        throw Exception(ApiClient.error(response, 'Masa menüsü açılamadı.'));
      final body = ApiClient.jsonBody(response)!;
      setState(() {
        menu = body;
        products = List<Map<String, dynamic>>.from(body['products'] as List);
        quantities.clear();
      });
    } catch (e) {
      setState(() => error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  int get total {
    var sum = 0;
    for (final entry in quantities.entries) {
      for (final product in products) {
        if (product['id'] == entry.key)
          sum += ((product['price'] as num).toInt() * entry.value);
      }
    }
    return sum;
  }

  Future<void> placeOrder() async {
    setState(() {
      placing = true;
      error = null;
    });
    try {
      final response = await ApiClient.post('/api/orders', {
        'tableCode': code.text,
        'items': quantities.entries
            .map((e) => {'productId': e.key, 'quantity': e.value})
            .toList(),
      });
      final body = ApiClient.jsonBody(response);
      if (response.statusCode < 200 || response.statusCode >= 300)
        throw Exception(ApiClient.error(response, 'Sipariş oluşturulamadı.'));
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              TrackingScreen(initialToken: body?['trackingToken']?.toString()),
        ),
      );
    } catch (e) {
      setState(() => error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => placing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: akdoCream,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Masadan Sipariş',
          style: TextStyle(fontFamily: 'Georgia'),
        ),
      ),
      body: menu == null
          ? _TableCodeForm(
              code: code,
              loading: loading,
              error: error,
              onLoad: loadMenu,
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: akdoGreen,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${menu!['branchName']}'.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 9,
                          color: Color(0xFFD4D4D8),
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        menu!['table']['name']?.toString() ?? 'Masa',
                        style: const TextStyle(
                          fontSize: 28,
                          color: Colors.white,
                          fontFamily: 'Georgia',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ...products.map((product) {
                  final quantity = quantities[product['id']] ?? 0;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE4E4E7)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['name'] ?? '',
                                style: const TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 17,
                                ),
                              ),
                              Text(
                                product['description'] ?? '',
                                maxLines: 2,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF71717A),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                formatPrice((product['price'] as num).toInt()),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: akdoGold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _QuantityButton(
                          quantity: quantity,
                          onChange: (delta) => setState(() {
                            final next =
                                (quantities[product['id']] ?? 0) + delta;
                            if (next <= 0)
                              quantities.remove(product['id']);
                            else
                              quantities[product['id']] = next.clamp(0, 99);
                          }),
                        ),
                      ],
                    ),
                  );
                }),
                if (error != null)
                  Text(
                    error!,
                    style: const TextStyle(color: Color(0xFFA63E35)),
                  ),
                const SizedBox(height: 10),
                Text(
                  'Toplam: ${formatPrice(total)}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 18,
                    fontFamily: 'Georgia',
                    color: akdoGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: placing || quantities.isEmpty
                        ? null
                        : placeOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: akdoGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: placing
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('SİPARİŞ VER'),
                  ),
                ),
              ],
            ),
    );
  }
}

class _TableCodeForm extends StatelessWidget {
  final TextEditingController code;
  final bool loading;
  final String? error;
  final VoidCallback onLoad;
  const _TableCodeForm({
    required this.code,
    required this.loading,
    required this.error,
    required this.onLoad,
  });
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: const Color(0xFFE4E4E7)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.shopping_bag_outlined, color: akdoGold),
              const SizedBox(height: 20),
              const Text(
                'MASADAN SİPARİŞ',
                style: TextStyle(
                  fontSize: 9,
                  color: akdoGold,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.8,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Masa kodunuzu girin',
                style: TextStyle(
                  fontSize: 30,
                  fontFamily: 'Georgia',
                  color: akdoGreen,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Masanızdaki altı haneli kodla doğru şubenin menüsünü açın.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: Color(0xFF71717A),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: code,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  labelText: '6 haneli masa kodu',
                  counterText: '',
                ),
                onChanged: (value) {
                  final clean = value.replaceAll(RegExp(r'[^0-9]'), '');
                  code.text = clean.length > 6 ? clean.substring(0, 6) : clean;
                },
              ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    error!,
                    style: const TextStyle(
                      color: Color(0xFFA63E35),
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 14),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: loading ? null : onLoad,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: akdoGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('MENÜYÜ AÇ'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class MemberScreen extends StatefulWidget {
  final bool returnTo;
  final Map<String, dynamic>? initialMember;
  final ValueChanged<Map<String, dynamic>>? onAuthenticated;
  final VoidCallback? onLoggedOut;
  const MemberScreen({
    super.key,
    this.returnTo = false,
    this.initialMember,
    this.onAuthenticated,
    this.onLoggedOut,
  });
  @override
  State<MemberScreen> createState() => _MemberScreenState();
}

class _MemberScreenState extends State<MemberScreen> {
  bool register = false;
  bool privacyNoticeAccepted = false;
  bool busy = false;
  String? error;
  Map<String, dynamic>? member;
  List<Map<String, dynamic>> orders = [];
  bool loadingOrders = false;
  final username = TextEditingController();
  final password = TextEditingController();
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final phone = TextEditingController();
  final requestAmount = TextEditingController();

  @override
  void initState() {
    super.initState();
    member = widget.initialMember;
    if (member != null) _loadOrders();
  }

  @override
  void dispose() {
    username.dispose();
    password.dispose();
    firstName.dispose();
    lastName.dispose();
    phone.dispose();
    requestAmount.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final normalizedUsername = username.text.trim();
    if (normalizedUsername.length < 3) {
      setState(() => error = 'Kullanıcı adı en az 3 karakter olmalıdır.');
      return;
    }
    if (register && firstName.text.trim().isEmpty) {
      setState(() => error = 'Ad alanını doldurun.');
      return;
    }
    if (register && lastName.text.trim().isEmpty) {
      setState(() => error = 'Soyad alanını doldurun.');
      return;
    }
    if (register && !privacyNoticeAccepted) {
      setState(() => error = 'KVKK bilgilendirmesini okuyup onaylayın.');
      return;
    }
    if (password.text.length < (register ? 8 : 1)) {
      setState(
        () => error = register
            ? 'Parola en az 8 karakter olmalıdır.'
            : 'Parolanızı girin.',
      );
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final response = register
          ? await ApiClient.post('/api/members/register', {
              'username': normalizedUsername,
              'firstName': firstName.text,
              'lastName': lastName.text,
              'phone': phone.text.trim(),
              'password': password.text,
              'privacyNoticeVersion': privacyNoticeVersion,
            })
          : await ApiClient.post('/api/members/login', {
              'username': normalizedUsername,
              'password': password.text,
            });
      final body = ApiClient.jsonBody(response);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          ApiClient.error(
            response,
            register ? 'Üyelik oluşturulamadı.' : 'Giriş yapılamadı.',
          ),
        );
      }
      if (body?['member'] is! Map) {
        throw Exception(
          register
              ? 'Üyelik yanıtı alınamadı. Lütfen tekrar deneyin.'
              : 'Giriş yanıtı alınamadı. Lütfen tekrar deneyin.',
        );
      }
      final authenticatedMember = Map<String, dynamic>.from(
        body!['member'] as Map,
      );
      setState(() => member = authenticatedMember);
      await _loadOrders();
      if (register && member != null && widget.onAuthenticated == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Üye numaranız: ${member!['memberNumber']}')),
        );
      }
      widget.onAuthenticated?.call(authenticatedMember);
    } catch (e) {
      if (mounted) {
        setState(() => error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _loadOrders() async {
    if (member == null) return;
    setState(() {
      loadingOrders = true;
      error = null;
    });
    try {
      final response = await ApiClient.get('/api/members/profile');
      final body = ApiClient.jsonBody(response);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(ApiClient.error(response, 'Siparişler alınamadı.'));
      }
      final orderRows = body?['orders'];
      if (orderRows is! List) {
        throw Exception('Sipariş listesi alınamadı.');
      }
      if (!mounted) return;
      setState(() {
        orders = orderRows
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
        if (body?['member'] is Map) {
          member = Map<String, dynamic>.from(body!['member'] as Map);
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() => error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => loadingOrders = false);
    }
  }

  Future<void> balanceRequest() async {
    final amount = int.tryParse(
      requestAmount.text.replaceAll(RegExp(r'[^0-9]'), ''),
    );
    if (amount == null || amount < 10) {
      setState(() => error = 'En az 10 ₺ tutar girin.');
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final response = await ApiClient.post('/api/members/balance-requests', {
        'amount': amount * 100,
      });
      if (response.statusCode < 200 || response.statusCode >= 300)
        throw Exception(
          ApiClient.error(response, 'Bakiye talebi oluşturulamadı.'),
        );
      requestAmount.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bakiye talebi kasada onay bekliyor.')),
      );
    } catch (e) {
      setState(() => error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> logout() async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final response = await ApiClient.post('/api/members/logout', {});
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(ApiClient.error(response, 'Oturum kapatılamadı.'));
      }
      if (!mounted) return;
      setState(() => member = null);
      widget.onLoggedOut?.call();
    } catch (e) {
      if (!mounted) return;
      setState(() => error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: akdoCream,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'AKDO ÜYELİK',
          style: TextStyle(fontSize: 13, letterSpacing: 1.5),
        ),
      ),
      body: member != null
          ? _MemberDashboard(
              member: member!,
              onLogout: logout,
              requestAmount: requestAmount,
              onRequest: balanceRequest,
              error: error,
              busy: busy,
              orders: orders,
              loadingOrders: loadingOrders,
              onRefreshOrders: _loadOrders,
            )
          : _MemberAuth(
              register: register,
              busy: busy,
              error: error,
              username: username,
              password: password,
              firstName: firstName,
              lastName: lastName,
              phone: phone,
              privacyNoticeAccepted: privacyNoticeAccepted,
              onPrivacyNoticeChanged: (value) =>
                  setState(() => privacyNoticeAccepted = value),
              onMode: (value) => setState(() {
                register = value;
                privacyNoticeAccepted = false;
                error = null;
              }),
              onSubmit: submit,
            ),
    );
  }
}

class _MemberAuth extends StatelessWidget {
  final bool register, busy;
  final bool privacyNoticeAccepted;
  final String? error;
  final TextEditingController username, password, firstName, lastName, phone;
  final ValueChanged<bool> onMode;
  final ValueChanged<bool> onPrivacyNoticeChanged;
  final VoidCallback onSubmit;
  const _MemberAuth({
    required this.register,
    required this.busy,
    required this.error,
    required this.username,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.privacyNoticeAccepted,
    required this.onMode,
    required this.onPrivacyNoticeChanged,
    required this.onSubmit,
  });

  Future<void> _showPrivacyNotice(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('KVKK bilgilendirmesi'),
        content: const SingleChildScrollView(
          child: Text(
            'Üyelik ve sipariş hizmetlerinin sunulması için adınız, soyadınız, '
            'kullanıcı adınız ve isteğe bağlı telefon numaranız; üyelik hesabının '
            'oluşturulması ve yönetilmesi, kimlik doğrulama, siparişlerin ve '
            'bakiye hareketlerinin yürütülmesi amaçlarıyla işlenebilir. '
            'Hesabınız üzerinden sipariş ve bildirim bilgileri de görüntülenir.\n\n'
            'Bu açıklama kısa bir bilgilendirme özetidir; veri sorumlusunun '
            'kimliği ve iletişim bilgileri, işleme şartları, aktarım yapılan '
            'taraflar, saklama süreleri ve ilgili kişi başvuru yöntemi gibi '
            'bilgileri içeren işletmeye ait tam KVKK aydınlatma metninin yerini '
            'almaz. Bu özet için hukuki inceleme ve tam metnin işletme bilgileriyle '
            'tamamlanması gerekir.\n\n'
            'Kutucuğu işaretlemeniz, bu bilgilendirmeyi okuduğunuzu kaydeder; '
            'tek başına açık rıza yerine geçmez.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('KAPAT'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 18),
        const Text(
          'AKDO ÜYELİK',
          style: TextStyle(
            fontSize: 9,
            color: akdoGold,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.8,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          register ? 'Üye ol' : 'Üye girişi',
          style: const TextStyle(
            fontSize: 34,
            fontFamily: 'Georgia',
            color: akdoGreen,
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F4F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: _Segment(
                  label: 'Giriş yap',
                  active: !register,
                  onTap: () => onMode(false),
                ),
              ),
              Expanded(
                child: _Segment(
                  label: 'Üye ol',
                  active: register,
                  onTap: () => onMode(true),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (register) ...[
          TextField(
            controller: firstName,
            key: const Key('member-first-name'),
            decoration: const InputDecoration(labelText: 'Ad'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: lastName,
            key: const Key('member-last-name'),
            decoration: const InputDecoration(labelText: 'Soyad'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: username,
            key: const Key('member-username'),
            textInputAction: TextInputAction.next,
            maxLength: 80,
            decoration: const InputDecoration(
              labelText: 'Kullanıcı adı',
              counterText: '',
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Telefon numarası (isteğe bağlı)',
            ),
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            key: const Key('privacy-notice-acceptance'),
            value: privacyNoticeAccepted,
            onChanged: busy
                ? null
                : (value) => onPrivacyNoticeChanged(value ?? false),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text(
              "KVKK bilgilendirmesini okudum ve anladım.",
              style: TextStyle(fontSize: 13),
            ),
            subtitle: const Text(
              'Bu onay açık rıza yerine geçmez.',
              style: TextStyle(fontSize: 11),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => _showPrivacyNotice(context),
              icon: const Icon(Icons.info_outline, size: 18),
              label: const Text('KVKK bilgilendirmesini görüntüle'),
            ),
          ),
        ] else ...[
          TextField(
            controller: username,
            key: const Key('member-username'),
            textInputAction: TextInputAction.next,
            maxLength: 80,
            decoration: const InputDecoration(labelText: 'Kullanıcı adı'),
          ),
        ],
        const SizedBox(height: 10),
        TextField(
          controller: password,
          key: const Key('member-password'),
          obscureText: true,
          decoration: InputDecoration(
            labelText: register ? 'En az 8 karakterli parola' : 'Parola',
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              error!,
              style: const TextStyle(color: Color(0xFFA63E35), fontSize: 12),
            ),
          ),
        const SizedBox(height: 16),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: akdoGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: busy ? null : onSubmit,
            child: busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(register ? 'ÜYELİK OLUŞTUR' : 'GİRİŞ YAP'),
          ),
        ),
      ],
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _Segment({
    required this.label,
    required this.active,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: active ? akdoGreen : const Color(0xFF71717A),
          ),
        ),
      ),
    );
  }
}

class _MemberDashboard extends StatelessWidget {
  final Map<String, dynamic> member;
  final VoidCallback onLogout, onRequest;
  final TextEditingController requestAmount;
  final String? error;
  final bool busy;
  final List<Map<String, dynamic>> orders;
  final bool loadingOrders;
  final VoidCallback onRefreshOrders;
  const _MemberDashboard({
    required this.member,
    required this.onLogout,
    required this.onRequest,
    required this.requestAmount,
    required this.error,
    required this.busy,
    required this.orders,
    required this.loadingOrders,
    required this.onRefreshOrders,
  });
  @override
  Widget build(BuildContext context) {
    final balance = (member['balance'] as num?)?.toInt() ?? 0;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE4E4E7)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                color: akdoGold,
              ),
              const SizedBox(height: 12),
              const Text(
                'AKDO ÜYELİK · AKDOKASA',
                style: TextStyle(
                  fontSize: 9,
                  color: akdoGold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Merhaba, ${member['firstName']}',
                style: const TextStyle(fontSize: 32, fontFamily: 'Georgia'),
              ),
              Text(
                'Üye no: ${member['memberNumber']}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF71717A)),
              ),
              const SizedBox(height: 22),
              const Text(
                'KULLANILABİLİR BAKİYE',
                style: TextStyle(fontSize: 9, color: Color(0xFF71717A)),
              ),
              Text(
                formatPrice(balance),
                style: const TextStyle(
                  fontSize: 38,
                  fontFamily: 'Georgia',
                  color: akdoGold,
                ),
              ),
              const SizedBox(height: 18),
              OutlinedButton(
                onPressed: onLogout,
                child: const Text('ÜYE OTURUMUNU KAPAT'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE4E4E7)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Siparişlerim',
                      style: TextStyle(fontSize: 24, fontFamily: 'Georgia'),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Siparişleri yenile',
                    onPressed: loadingOrders ? null : onRefreshOrders,
                    icon: loadingOrders
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                  ),
                ],
              ),
              if (orders.isEmpty && loadingOrders)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (orders.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    'Henüz sipariş geçmişiniz bulunmuyor.',
                    style: TextStyle(color: Color(0xFF71717A), fontSize: 13),
                  ),
                )
              else
                ...orders.map((order) {
                  final items = order['items'] is List
                      ? List<Map<String, dynamic>>.from(
                          (order['items'] as List).whereType<Map>(),
                        )
                      : <Map<String, dynamic>>[];
                  final status = order['status']?.toString() ?? '';
                  final statusLabel = switch (status) {
                    'PENDING' => 'Onay bekliyor',
                    'PREPARING' => 'Hazırlanıyor',
                    'READY' => 'Hazır',
                    'SERVED' => 'Tamamlandı',
                    'CANCELLED' => 'İptal edildi · bakiye iade edildi',
                    _ => status.isEmpty ? 'Durum bilinmiyor' : status,
                  };
                  final createdAt = DateTime.tryParse(
                    order['createdAt']?.toString() ?? '',
                  );
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE4E4E7)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                '${(order['table'] as Map?)?['name'] ?? 'Masa'} · ${(order['branch'] as Map?)?['name'] ?? 'Şube'}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              formatPrice(
                                (order['total'] as num?)?.toInt() ?? 0,
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (createdAt != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${createdAt.day.toString().padLeft(2, '0')}.${createdAt.month.toString().padLeft(2, '0')}.${createdAt.year} · ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              color: Color(0xFF71717A),
                              fontSize: 11,
                            ),
                          ),
                        ],
                        if (items.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            items
                                .map(
                                  (item) =>
                                      '${item['quantity']} × ${item['name']}',
                                )
                                .join(' · '),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 11,
                            color: status == 'SERVED'
                                ? const Color(0xFF71717A)
                                : akdoText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE4E4E7)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bakiyene ekle',
                style: TextStyle(fontSize: 24, fontFamily: 'Georgia'),
              ),
              const SizedBox(height: 5),
              const Text(
                'Yükleme talebiniz kasada onay bekler.',
                style: TextStyle(fontSize: 11, color: Color(0xFF71717A)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: requestAmount,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Yükleme tutarı (₺)',
                ),
              ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    error!,
                    style: const TextStyle(
                      color: Color(0xFFA63E35),
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: busy ? null : onRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: akdoGreen,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('TALEP OLUŞTUR'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

extension TurkishLower on String {
  String toLowerTurkish() =>
      toLowerCase().replaceAll('İ', 'i').replaceAll('I', 'ı');
}

class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: akdoBrown,
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    akdoBrown,
                    akdoBrown.withValues(alpha: 0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'MARAŞ LEZZETLERİ',
                  style: TextStyle(
                    color: Color(0xFFD4D4D8),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Maraş usulü\ndondurma & tatlı',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    height: 1.05,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 14),
                Text(
                  'Her gün taze · Geleneksel tarifler',
                  style: TextStyle(color: Color(0xFFD4D4D8), fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _CategoryChip({
    required this.label,
    required this.active,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? akdoGreen : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: active ? akdoGreen : const Color(0xFFE4E4E7),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : const Color(0xFF3F3F46),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final MenuProduct product;
  final int quantity;
  final ValueChanged<int> onChange;
  const _FeaturedCard({
    required this.product,
    required this.quantity,
    required this.onChange,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      decoration: BoxDecoration(
        color: const Color(0xFF18181B),
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -18,
            bottom: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF3F3F46),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontFamily: 'Georgia',
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 210,
                  child: Text(
                    product.description,
                    style: const TextStyle(
                      color: Color(0xFFD4D4D8),
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Text(
                      formatPrice(product.price),
                      style: const TextStyle(
                        color: Color(0xFFA1A1AA),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    _QuantityButton(quantity: quantity, onChange: onChange),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final MenuProduct product;
  final int quantity;
  final ValueChanged<int> onChange;
  const _ProductCard({
    required this.product,
    required this.quantity,
    required this.onChange,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4E4E7)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF4F4F5), Color(0xFFD4D4D8)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: product.imageUrl.isEmpty
                ? const Icon(
                    Icons.icecream_outlined,
                    color: Color(0xFF71717A),
                    size: 36,
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _AdminImage(product.imageUrl, width: 92, height: 92),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 92,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontFamily: 'Georgia',
                      color: akdoText,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    product.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      height: 1.4,
                      color: Color(0xFF71717A),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        formatPrice(product.price),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: akdoGold,
                        ),
                      ),
                      const Spacer(),
                      _QuantityButton(quantity: quantity, onChange: onChange),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChange;
  const _QuantityButton({required this.quantity, required this.onChange});
  @override
  Widget build(BuildContext context) {
    if (quantity == 0) {
      return InkWell(
        onTap: () => onChange(1),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: akdoGreen,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, size: 16, color: Colors.white),
              SizedBox(width: 3),
              Text(
                'EKLE',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4E4E7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 28, height: 28),
            icon: const Icon(Icons.remove, size: 14),
            onPressed: () => onChange(-1),
          ),
          Text(
            '$quantity',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 28, height: 28),
            icon: const Icon(Icons.add, size: 14),
            onPressed: quantity < 99 ? () => onChange(1) : null,
          ),
        ],
      ),
    );
  }
}

class _MainDrawer extends StatelessWidget {
  final VoidCallback onMember, onTable, onStaff, onAdmin, onTracking;
  final VoidCallback onNotifications;
  const _MainDrawer({
    required this.onMember,
    required this.onTable,
    required this.onStaff,
    required this.onAdmin,
    required this.onTracking,
    required this.onNotifications,
  });
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFFAFAFA),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
          children: [
            Image.asset('assets/logo/akdoqr.png', height: 58),
            const SizedBox(height: 20),
            _DrawerItem(
              icon: Icons.person_outline,
              label: 'Üye giriş / profil',
              onTap: onMember,
            ),
            _DrawerItem(
              icon: Icons.qr_code_scanner,
              label: 'Masa siparişi',
              onTap: onTable,
            ),
            _DrawerItem(
              icon: Icons.route_outlined,
              label: 'Sipariş takibi',
              onTap: onTracking,
            ),
            _DrawerItem(
              icon: Icons.notifications_none,
              label: 'Bildirimler',
              onTap: onNotifications,
            ),
            const Divider(height: 32),
            _DrawerItem(
              icon: Icons.restaurant_menu_outlined,
              label: 'Şef / garson personel',
              onTap: onStaff,
            ),
            _DrawerItem(
              icon: Icons.dashboard_customize_outlined,
              label: 'Yönetim merkezi',
              onTap: onAdmin,
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 20, color: akdoGold),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: akdoText,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}

class CartScreen extends StatefulWidget {
  final List<MenuProduct> products;
  const CartScreen({super.key, required this.products});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final tableCode = TextEditingController();
  String? error;
  bool placing = false;

  List<MapEntry<MenuProduct, int>> get items {
    final result = <MapEntry<MenuProduct, int>>[];
    for (final entry in CartStore.quantities.entries) {
      for (final product in widget.products) {
        if (product.id == entry.key) result.add(MapEntry(product, entry.value));
      }
    }
    return result;
  }

  Future<void> placeOrder() async {
    if (tableCode.text.length != 6) {
      setState(() => error = '6 haneli masa kodunu girin.');
      return;
    }
    setState(() {
      placing = true;
      error = null;
    });
    try {
      final response = await ApiClient.post('/api/orders', {
        'tableCode': tableCode.text,
        'items': items
            .map((item) => {'productId': item.key.id, 'quantity': item.value})
            .toList(),
      });
      final body = ApiClient.jsonBody(response);
      if (response.statusCode == 401) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MemberScreen(returnTo: true)),
        );
        return;
      }
      if (response.statusCode < 200 || response.statusCode >= 300)
        throw Exception(ApiClient.error(response, 'Sipariş oluşturulamadı.'));
      final token = body?['trackingToken'];
      CartStore.quantities.clear();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TrackingScreen(initialToken: token?.toString()),
        ),
      );
    } catch (e) {
      setState(() => error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => placing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: akdoCream,
        surfaceTintColor: Colors.transparent,
        foregroundColor: akdoText,
        title: const Text(
          'Siparişiniz',
          style: TextStyle(fontFamily: 'Georgia'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'MENÜDEN SİPARİŞ',
            style: TextStyle(
              fontSize: 9,
              color: akdoGold,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Sepetiniz',
            style: TextStyle(
              fontSize: 34,
              fontFamily: 'Georgia',
              color: akdoText,
            ),
          ),
          const SizedBox(height: 18),
          if (items.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE4E4E7)),
              ),
              child: const Column(
                children: [
                  Icon(Icons.shopping_bag_outlined, color: akdoGold),
                  SizedBox(height: 8),
                  Text('Sepetiniz henüz boş'),
                ],
              ),
            )
          else
            ...items.map(
              (item) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE4E4E7)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.key.name,
                            style: const TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 17,
                            ),
                          ),
                          Text(
                            formatPrice(item.key.price),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF71717A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _QuantityButton(
                      quantity: item.value,
                      onChange: (delta) {
                        setState(() {
                          final next = item.value + delta;
                          if (next <= 0)
                            CartStore.quantities.remove(item.key.id);
                          else
                            CartStore.quantities[item.key.id] = next.clamp(
                              0,
                              99,
                            );
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          const Text(
            '6 haneli masa kodu',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: tableCode,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 6,
            decoration: const InputDecoration(
              hintText: '••••••',
              counterText: '',
            ),
            onChanged: (value) {
              final clean = value.replaceAll(RegExp(r'[^0-9]'), '');
              final next = clean.length > 6 ? clean.substring(0, 6) : clean;
              setState(() => tableCode.text = next);
            },
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                error!,
                style: const TextStyle(color: Color(0xFFA63E35), fontSize: 12),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Toplam',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                formatPrice(CartStore.total(widget.products)),
                style: const TextStyle(
                  fontSize: 20,
                  fontFamily: 'Georgia',
                  color: akdoGold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: akdoGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: placing || items.isEmpty ? null : placeOrder,
              child: placing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('SİPARİŞİ TAMAMLA'),
            ),
          ),
        ],
      ),
    );
  }
}

class StaffScreen extends StatefulWidget {
  final String initialRole;

  const StaffScreen({super.key, this.initialRole = 'chef'});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  late String role;
  bool authenticated = false;
  bool loading = false;
  String? error;
  final username = TextEditingController();
  final password = TextEditingController();
  List<dynamic> orders = [];
  Timer? timer;

  @override
  void initState() {
    super.initState();
    role = widget.initialRole;
  }

  Future<void> login() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final response = await ApiClient.post('/api/staff/login', {
        'role': role,
        'username': username.text,
        'password': password.text,
      });
      if (response.statusCode < 200 || response.statusCode >= 300)
        throw Exception(ApiClient.error(response, 'Giriş yapılamadı.'));
      setState(() => authenticated = true);
      loadOrders();
      timer ??= Timer.periodic(const Duration(seconds: 5), (_) => loadOrders());
    } catch (e) {
      setState(() => error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> loadOrders() async {
    try {
      final response = await ApiClient.get('/api/staff/orders');
      final body = ApiClient.jsonBody(response);
      if (response.statusCode < 200 || response.statusCode >= 300)
        throw Exception(ApiClient.error(response, 'Siparişler alınamadı.'));
      setState(() {
        orders = List<dynamic>.from(body!['orders'] as List);
        error = null;
      });
    } catch (e) {
      setState(() => error = e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> updateOrder(String id, String status) async {
    final response = await ApiClient.patch('/api/staff/orders/$id', {
      'status': status,
    });
    if (response.statusCode < 200 || response.statusCode >= 300) {
      setState(
        () =>
            error = ApiClient.error(response, 'Sipariş durumu güncellenemedi.'),
      );
      return;
    }
    loadOrders();
  }

  Future<void> cancelOrder(Map<String, dynamic> order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Siparişi iptal et?'),
        content: const Text(
          'Sipariş iptal edilecek. Üye bakiyesiyle ödenen siparişin tutarı '
          'müşteri bakiyesine geri eklenecek.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('VAZGEÇ'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('İPTAL ET VE İADE ET'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await updateOrder(order['id'].toString(), 'CANCELLED');
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = role == 'chef' ? 'AkdoŞef' : 'AkdoGarson';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: akdoCream,
        surfaceTintColor: Colors.transparent,
        title: Text(title, style: const TextStyle(fontFamily: 'Georgia')),
      ),
      body: !authenticated
          ? ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE4E4E7)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.restaurant_menu, color: akdoGold),
                      const SizedBox(height: 14),
                      Text(
                        '$title personel girişi',
                        style: const TextStyle(
                          fontSize: 28,
                          fontFamily: 'Georgia',
                          color: akdoGreen,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _Segment(
                              label: 'Şef',
                              active: role == 'chef',
                              onTap: () => setState(() => role = 'chef'),
                            ),
                          ),
                          Expanded(
                            child: _Segment(
                              label: 'Garson',
                              active: role == 'waiter',
                              onTap: () => setState(() => role = 'waiter'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: username,
                        decoration: const InputDecoration(
                          labelText: 'Kullanıcı adı',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: password,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'Parola'),
                      ),
                      if (error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            error!,
                            style: const TextStyle(color: Color(0xFFA63E35)),
                          ),
                        ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: loading ? null : login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: akdoGreen,
                            foregroundColor: Colors.white,
                          ),
                          child: loading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text('GİRİŞ YAP'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : RefreshIndicator(
              onRefresh: loadOrders,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '$title siparişleri',
                          style: const TextStyle(
                            fontSize: 24,
                            fontFamily: 'Georgia',
                            color: akdoGreen,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          await ApiClient.post('/api/staff/logout', {});
                          timer?.cancel();
                          setState(() {
                            authenticated = false;
                            orders.clear();
                          });
                        },
                        icon: const Icon(Icons.logout),
                      ),
                    ],
                  ),
                  if (error != null)
                    Text(
                      error!,
                      style: const TextStyle(color: Color(0xFFA63E35)),
                    ),
                  ...orders.map((raw) {
                    final order = Map<String, dynamic>.from(raw as Map);
                    final status = order['status'];
                    final items = List<dynamic>.from(order['items'] as List);
                    final nextStatus = role == 'chef'
                        ? (status == 'PENDING' ? 'PREPARING' : 'READY')
                        : 'SERVED';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE4E4E7)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${order['table']['name']} · ${order['branch']['name']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: akdoGreen,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...items.map((rawItem) {
                            final item = Map<String, dynamic>.from(
                              rawItem as Map,
                            );
                            return Text(
                              '${item['quantity']} × ${item['name']}',
                              style: const TextStyle(fontSize: 12),
                            );
                          }),
                          const Divider(),
                          Row(
                            children: [
                              Text(
                                formatPrice((order['total'] as num).toInt()),
                                style: const TextStyle(
                                  fontFamily: 'Georgia',
                                  color: akdoGold,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              ElevatedButton(
                                onPressed: status == 'SERVED'
                                    ? null
                                    : () =>
                                          updateOrder(order['id'], nextStatus),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: role == 'chef'
                                      ? akdoGreen
                                      : akdoGold,
                                  foregroundColor: Colors.white,
                                ),
                                child: Text(
                                  role == 'chef'
                                      ? (status == 'PENDING'
                                            ? 'HAZIRLAMAYA BAŞLA'
                                            : 'HAZIR')
                                      : 'TESLİM ET',
                                ),
                              ),
                              if (role == 'chef' &&
                                  (status == 'PENDING' ||
                                      status == 'PREPARING')) ...[
                                const SizedBox(width: 8),
                                IconButton(
                                  tooltip:
                                      'Siparişi iptal et ve bakiyeyi iade et',
                                  onPressed: () => cancelOrder(order),
                                  color: const Color(0xFFB42318),
                                  icon: const Icon(Icons.cancel_outlined),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  bool authenticated = false;
  bool loading = false;
  String? error;
  String active = 'Genel Bakış';
  final username = TextEditingController();
  final password = TextEditingController();
  final adminSearch = TextEditingController();
  String adminSearchQuery = '';
  List<dynamic> rows = [];
  final sections = const [
    'Genel Bakış',
    'Şubeler',
    'Kategoriler',
    'Menü',
    'Masa kodları',
    'Kullanıcılar',
    'Bildirim gönder',
    'AkdoKasa',
    'Finans defteri',
    'Çalışanlar',
  ];

  @override
  void dispose() {
    username.dispose();
    password.dispose();
    adminSearch.dispose();
    super.dispose();
  }

  Future<void> login() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final response = await ApiClient.post('/api/admin/login', {
        'username': username.text,
        'password': password.text,
      });
      if (response.statusCode < 200 || response.statusCode >= 300)
        throw Exception(ApiClient.error(response, 'Giriş yapılamadı.'));
      setState(() => authenticated = true);
      loadSection();
    } catch (e) {
      setState(() => error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  String endpointFor(String section) {
    switch (section) {
      case 'Şubeler':
        return '/api/admin/branches';
      case 'Kategoriler':
        return '/api/admin/categories';
      case 'Menü':
        return '/api/admin/products';
      case 'Masa kodları':
        return '/api/admin/tables';
      case 'Kullanıcılar':
        return '/api/admin/members';
      case 'AkdoKasa':
        return '/api/admin/cash/requests';
      case 'Finans defteri':
        return '/api/admin/ledger';
      case 'Çalışanlar':
        return '/api/admin/employees';
      default:
        return '/api/admin/branches';
    }
  }

  List<dynamic> get filteredRows {
    final query = adminSearchQuery.trim().toLowerTurkish();
    if (query.isEmpty) return rows;
    return rows.where((raw) {
      if (raw == null) return false;
      String searchable;
      if (raw is Map) {
        searchable = jsonEncode(raw).toLowerTurkish();
      } else {
        searchable = raw.toString().toLowerTurkish();
      }
      return searchable.contains(query);
    }).toList();
  }

  void selectSection(String section) {
    setState(() {
      active = section;
      adminSearchQuery = '';
      adminSearch.clear();
      if (section == 'Bildirim gönder') rows = [];
    });
    if (section != 'Bildirim gönder') loadSection();
  }

  Future<void> loadSection() async {
    if (active == 'Bildirim gönder') return;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final response = await ApiClient.get(endpointFor(active));
      final body = ApiClient.jsonBody(response);
      if (response.statusCode < 200 || response.statusCode >= 300)
        throw Exception(ApiClient.error(response, 'Veriler alınamadı.'));
      if (body != null) {
        final key = body.keys.firstWhere(
          (key) => body[key] is List,
          orElse: () => '',
        );
        rows = key.isEmpty ? [] : List<dynamic>.from(body[key] as List);
      }
    } catch (e) {
      setState(() => error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  String _rowId(Map<String, dynamic> row) => row['id']?.toString() ?? '';

  Future<void> _showLedgerDetail(Map<String, dynamic> row) async {
    if (active != 'Finans defteri') return;

    String dateLabel = '-';
    final rawDate = row['at']?.toString();
    final parsedDate = rawDate == null ? null : DateTime.tryParse(rawDate);
    if (parsedDate != null) {
      final local = parsedDate.toLocal();
      dateLabel =
          '${local.day.toString().padLeft(2, '0')}.${local.month.toString().padLeft(2, '0')}.${local.year} '
          '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    }

    final amount = (row['amount'] as num?)?.toInt() ?? 0;
    final member = row['member'] is Map
        ? Map<String, dynamic>.from(row['member'] as Map)
        : <String, dynamic>{};
    final memberName =
        '${member['firstName']?.toString() ?? ''} ${member['lastName']?.toString() ?? ''}'
            .trim();
    final items = row['items'] is List
        ? List<dynamic>.from(row['items'] as List)
        : [];

    String kindLabel(String? kind) {
      switch (kind) {
        case 'ORDER_PAYMENT':
          return 'Sipariş tahsilatı';
        case 'BALANCE_TOPUP':
          return 'Bakiye yükleme';
        case 'BALANCE_ADJUSTMENT':
          return 'Bakiye düzeltmesi';
        default:
          return kind?.isNotEmpty == true ? kind! : 'Finans işlemi';
      }
    }

    String paymentLabel(String? method) {
      switch (method) {
        case 'MEMBER_BALANCE':
          return 'AkdoKasa';
        case 'CASH':
          return 'Nakit';
        case 'EXTERNAL_POS':
          return 'Harici POS';
        default:
          return 'Belirtilmemiş';
      }
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(kindLabel(row['kind']?.toString())),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row['description']?.toString().isNotEmpty == true
                      ? row['description'].toString()
                      : 'İşlem açıklaması bulunmuyor',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                _LedgerDetailLine('Tutar', formatPrice(amount)),
                _LedgerDetailLine('İşlem zamanı', dateLabel),
                _LedgerDetailLine('Durum', row['status']?.toString() ?? '-'),
                _LedgerDetailLine(
                  'Ödeme yöntemi',
                  paymentLabel(row['paymentMethod']?.toString()),
                ),
                if (row['branchName']?.toString().isNotEmpty == true)
                  _LedgerDetailLine('Şube', row['branchName'].toString()),
                if (row['tableName']?.toString().isNotEmpty == true)
                  _LedgerDetailLine('Masa', row['tableName'].toString()),
                if (memberName.isNotEmpty)
                  _LedgerDetailLine(
                    'Üye',
                    '$memberName · #${member['memberNumber']?.toString() ?? '-'}',
                  ),
                if (row['performedBy']?.toString().isNotEmpty == true)
                  _LedgerDetailLine(
                    'İşlemi yapan',
                    row['performedBy'].toString(),
                  ),
                if ((row['cashChange'] as num?)?.toInt() != null &&
                    (row['cashChange'] as num).toInt() != 0)
                  _LedgerDetailLine(
                    'Kasa hareketi',
                    formatPrice((row['cashChange'] as num).toInt()),
                  ),
                if ((row['balanceChange'] as num?)?.toInt() != null &&
                    (row['balanceChange'] as num).toInt() != 0)
                  _LedgerDetailLine(
                    'Bakiye hareketi',
                    formatPrice((row['balanceChange'] as num).toInt()),
                  ),
                if (row['reviewNote']?.toString().isNotEmpty == true)
                  _LedgerDetailLine(
                    'Değerlendirme notu',
                    row['reviewNote'].toString(),
                  ),
                if (row['orderId']?.toString().isNotEmpty == true)
                  _LedgerDetailLine('Sipariş ID', row['orderId'].toString()),
                if (items.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Text(
                    'Sipariş kalemleri',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  ...items.map((rawItem) {
                    final item = Map<String, dynamic>.from(rawItem as Map);
                    final quantity = (item['quantity'] as num?)?.toInt() ?? 1;
                    final price = (item['price'] as num?)?.toInt() ?? 0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '$quantity × ${item['name']} · ${formatPrice(price)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('KAPAT'),
          ),
        ],
      ),
    );
  }

  Future<void> _adjustMemberBalance(Map<String, dynamic> row) async {
    if (active != 'Kullanıcılar') return;
    final id = _rowId(row);
    if (id.isEmpty) return;
    final amount = TextEditingController();
    final description = TextEditingController(
      text: 'Yönetici bakiye düzenlemesi',
    );
    String direction = 'CREDIT';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (_, setDialogState) => AlertDialog(
          title: const Text('Kullanıcı bakiyesi'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${row['firstName']?.toString() ?? ''} '
                  '${row['lastName']?.toString() ?? ''}'
                  ' · ${formatPrice((row['balance'] as num?)?.toInt() ?? 0)}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'CREDIT',
                      label: Text('Bakiyeye ekle'),
                    ),
                    ButtonSegment(value: 'DEBIT', label: Text('Bakiyeden düş')),
                  ],
                  selected: {direction},
                  onSelectionChanged: (values) {
                    if (values.isEmpty) return;
                    setDialogState(() => direction = values.first);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amount,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Tutar (₺)',
                    hintText: 'Örn. 250',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: description,
                  decoration: const InputDecoration(
                    labelText: 'İşlem açıklaması',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('VAZGEÇ'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('UYGULA'),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true) return;
    final parsedAmount = double.tryParse(
      amount.text.trim().replaceAll(',', '.'),
    );
    if (parsedAmount == null || parsedAmount <= 0) {
      setState(() => error = 'Geçerli bir bakiye tutarı girin.');
      return;
    }
    if (description.text.trim().isEmpty) {
      setState(() => error = 'Bakiye işlemi için açıklama girin.');
      return;
    }
    final amountInKurus = (parsedAmount * 100).round();
    if (amountInKurus > 100000000) {
      setState(() => error = 'Bakiye tutarı izin verilen sınırı aşıyor.');
      return;
    }
    try {
      final response = await ApiClient.post('/api/admin/members/$id/balance', {
        'direction': direction,
        'amount': amountInKurus,
        'description': description.text.trim(),
      });
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(ApiClient.error(response, 'Bakiye güncellenemedi.'));
      }
      await loadSection();
    } catch (e) {
      if (!mounted) return;
      setState(() => error = e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _toggleRow(Map<String, dynamic> row) async {
    final id = _rowId(row);
    if (id.isEmpty) return;
    final isActive = row['isActive'] == true;
    String path = '';
    Map<String, dynamic> body = {};
    if (active == 'Şubeler') {
      path = '/api/admin/branches/$id';
      body = {'isActive': !isActive};
    } else if (active == 'Kategoriler') {
      path = '/api/admin/categories/$id?branchId=${row['branchId'] ?? ''}';
      body = {'isActive': !isActive};
    } else if (active == 'Menü') {
      path = '/api/admin/products/$id?branchId=${row['branchId'] ?? ''}';
      body = {'isActive': !isActive};
    } else if (active == 'Masa kodları') {
      path = '/api/admin/tables/$id';
      body = {'isActive': !isActive};
    } else if (active == 'Kullanıcılar') {
      path = '/api/admin/members/$id';
      body = {'isActive': !isActive};
    } else if (active == 'Çalışanlar') {
      path = '/api/admin/employees/$id';
      body = {'isActive': !isActive};
    } else {
      return;
    }
    try {
      final response = await ApiClient.patch(path, body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(ApiClient.error(response, 'Durum güncellenemedi.'));
      }
      await loadSection();
    } catch (e) {
      if (!mounted) return;
      setState(() => error = e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _reviewCash(Map<String, dynamic> row, String status) async {
    final id = _rowId(row);
    if (id.isEmpty) return;
    try {
      final response = await ApiClient.post('/api/admin/cash/requests/$id', {
        'status': status,
        'reviewNote': '',
      });
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(ApiClient.error(response, 'Talep değerlendirilemedi.'));
      }
      await loadSection();
    } catch (e) {
      if (!mounted) return;
      setState(() => error = e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _editRow(Map<String, dynamic> row) async {
    if (active == 'Finans defteri' || active == 'AkdoKasa') return;
    if (active == 'Çalışanlar') {
      final username = TextEditingController(
        text: row['username']?.toString() ?? '',
      );
      final password = TextEditingController();
      String role = row['role']?.toString() == 'chef' ? 'chef' : 'waiter';
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (_, setDialogState) => AlertDialog(
            title: const Text('Çalışan bilgilerini düzenle'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: username,
                    decoration: const InputDecoration(
                      labelText: 'Kullanıcı adı',
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: role,
                    decoration: const InputDecoration(labelText: 'Rütbe'),
                    items: const [
                      DropdownMenuItem(value: 'chef', child: Text('Şef')),
                      DropdownMenuItem(value: 'waiter', child: Text('Garson')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => role = value);
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: password,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Yeni parola (boş bırakılırsa değişmez)',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('VAZGEÇ'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('KAYDET'),
              ),
            ],
          ),
        ),
      );
      if (confirmed != true) return;
      if (username.text.trim().length < 3) {
        setState(() => error = 'Kullanıcı adı en az 3 karakter olmalıdır.');
        return;
      }
      if (password.text.isNotEmpty && password.text.length < 8) {
        setState(() => error = 'Yeni parola en az 8 karakter olmalıdır.');
        return;
      }
      final id = _rowId(row);
      if (id.isEmpty) return;
      final body = <String, dynamic>{
        'username': username.text.trim(),
        'role': role,
        if (password.text.isNotEmpty) 'password': password.text,
      };
      try {
        final response = await ApiClient.patch(
          '/api/admin/employees/$id',
          body,
        );
        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw Exception(ApiClient.error(response, 'Çalışan güncellenemedi.'));
        }
        await loadSection();
      } catch (e) {
        if (!mounted) return;
        setState(() => error = e.toString().replaceFirst('Exception: ', ''));
      }
      return;
    }
    if (active == 'Menü') {
      final name = TextEditingController(text: row['name']?.toString() ?? '');
      final description = TextEditingController(
        text: row['description']?.toString() ?? '',
      );
      final price = TextEditingController(
        text: row['price'] == null
            ? ''
            : ((row['price'] as num).toDouble() / 100).toStringAsFixed(
                (row['price'] as num) % 100 == 0 ? 0 : 2,
              ),
      );
      final imageUrl = TextEditingController(
        text: row['imageUrl']?.toString() ?? '',
      );
      final allergens = TextEditingController(
        text: row['allergens']?.toString() ?? '',
      );
      final stock = TextEditingController(
        text: row['stock']?.toString() ?? '0',
      );
      bool featured = row['featured'] == true;

      final categoryResponse = await ApiClient.get('/api/admin/categories');
      final categoryBody = ApiClient.jsonBody(categoryResponse);
      final categoryRows = categoryBody == null
          ? <dynamic>[]
          : List<dynamic>.from(
              (categoryBody['categories'] is List
                  ? categoryBody['categories']
                  : <dynamic>[]),
            );
      final categoryList = categoryRows
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
      final currentCategoryId = row['category'] is Map
          ? (row['category'] as Map)['id']?.toString()
          : row['categoryId']?.toString();
      String categoryId =
          categoryList.any((item) => item['id'].toString() == currentCategoryId)
          ? currentCategoryId!
          : (categoryList.isEmpty ? '' : categoryList.first['id'].toString());

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (_, setDialogState) => AlertDialog(
            title: const Text('Ürünü düzenle'),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: name,
                      decoration: const InputDecoration(labelText: 'Ürün adı'),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: categoryId.isEmpty ? null : categoryId,
                      decoration: const InputDecoration(labelText: 'Kategori'),
                      items: categoryList
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item['id'].toString(),
                              child: Text(item['name'].toString()),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => categoryId = value);
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: price,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(labelText: 'Fiyat (₺)'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: stock,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Stok'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: description,
                      maxLength: 500,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Ürün açıklaması',
                        hintText: 'Ürünün içeriğini ve özelliklerini yazın',
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: imageUrl,
                      decoration: const InputDecoration(
                        labelText: 'Görsel adresi',
                      ),
                      onChanged: (_) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () async {
                        try {
                          final uploaded = await _uploadProductImage();
                          if (uploaded != null) {
                            setDialogState(() => imageUrl.text = uploaded);
                          }
                        } catch (e) {
                          setState(
                            () => error = e.toString().replaceFirst(
                              'Exception: ',
                              '',
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.upload_outlined),
                      label: const Text('Görseli cihazdan değiştir'),
                    ),
                    if (imageUrl.text.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: _AdminImage(imageUrl.text.trim(), height: 120),
                        ),
                      ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: allergens,
                      decoration: const InputDecoration(
                        labelText: 'Alerjenler',
                      ),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: featured,
                      onChanged: (value) =>
                          setDialogState(() => featured = value),
                      title: const Text('Öne çıkan ürün'),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('VAZGEÇ'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('KAYDET'),
              ),
            ],
          ),
        ),
      );
      if (confirmed != true) return;
      final parsedPrice = double.tryParse(
        price.text.trim().replaceAll(',', '.'),
      );
      final parsedStock = int.tryParse(stock.text.trim());
      if (name.text.trim().length < 2 ||
          parsedPrice == null ||
          parsedPrice <= 0 ||
          categoryId.isEmpty) {
        setState(
          () => error =
              'Ürün adı, kategori ve geçerli fiyat alanlarını kontrol edin.',
        );
        return;
      }
      if (parsedStock == null || parsedStock < 0 || parsedStock > 100000) {
        setState(() => error = 'Stok 0-100000 arasında olmalıdır.');
        return;
      }
      final id = _rowId(row);
      if (id.isEmpty) return;
      try {
        final response = await ApiClient.patch(
          '/api/admin/products/$id?branchId=${row['branchId'] ?? 'default-branch'}',
          {
            'name': name.text.trim(),
            'categoryId': categoryId,
            'price': (parsedPrice * 100).round(),
            'description': description.text.trim(),
            'imageUrl': imageUrl.text.trim(),
            'allergens': allergens.text.trim(),
            'stock': parsedStock,
            'featured': featured,
          },
        );
        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw Exception(ApiClient.error(response, 'Ürün güncellenemedi.'));
        }
        await loadSection();
      } catch (e) {
        if (!mounted) return;
        setState(() => error = e.toString().replaceFirst('Exception: ', ''));
      }
      return;
    }
    final initial =
        row['name']?.toString() ??
        row['username']?.toString() ??
        row['firstName']?.toString() ??
        '';
    final controller = TextEditingController(text: initial);
    final label = active == 'Kullanıcılar'
        ? 'Ad'
        : active == 'Çalışanlar'
        ? 'Kullanıcı adı'
        : 'Ad';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('$active düzenle'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: label),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('VAZGEÇ'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('KAYDET'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final id = _rowId(row);
    if (id.isEmpty) return;
    String path = '';
    Map<String, dynamic> body = {};
    if (active == 'Şubeler') {
      path = '/api/admin/branches/$id';
      body = {'name': controller.text.trim()};
    } else if (active == 'Kategoriler') {
      path = '/api/admin/categories/$id?branchId=${row['branchId'] ?? ''}';
      body = {'name': controller.text.trim()};
    } else if (active == 'Menü') {
      path = '/api/admin/products/$id?branchId=${row['branchId'] ?? ''}';
      body = {'name': controller.text.trim()};
    } else if (active == 'Kullanıcılar') {
      path = '/api/admin/members/$id';
      body = {'firstName': controller.text.trim()};
    } else if (active == 'Çalışanlar') {
      path = '/api/admin/employees/$id';
      body = {'username': controller.text.trim()};
    } else {
      return;
    }
    try {
      final response = await ApiClient.patch(path, body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(ApiClient.error(response, 'Kayıt güncellenemedi.'));
      }
      await loadSection();
    } catch (e) {
      if (!mounted) return;
      setState(() => error = e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _createEmployee() async {
    final username = TextEditingController();
    final password = TextEditingController();
    String role = 'waiter';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (_, setDialogState) => AlertDialog(
          title: const Text('Çalışan ekle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: username,
                decoration: const InputDecoration(labelText: 'Kullanıcı adı'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: password,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Parola (en az 8 karakter)',
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: role,
                decoration: const InputDecoration(labelText: 'Rütbe'),
                items: const [
                  DropdownMenuItem(value: 'chef', child: Text('Şef')),
                  DropdownMenuItem(value: 'waiter', child: Text('Garson')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() => role = value);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('VAZGEÇ'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('EKLE'),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true) return;
    if (username.text.trim().length < 3) {
      setState(() => error = 'Kullanıcı adı en az 3 karakter olmalıdır.');
      return;
    }
    if (password.text.length < 8) {
      setState(() => error = 'Çalışan parolası en az 8 karakter olmalıdır.');
      return;
    }
    try {
      final response = await ApiClient.post('/api/admin/employees', {
        'username': username.text.trim(),
        'password': password.text,
        'role': role,
      });
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(ApiClient.error(response, 'Çalışan eklenemedi.'));
      }
      await loadSection();
    } catch (e) {
      if (!mounted) return;
      setState(() => error = e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<String?> _uploadProductImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 85,
    );
    if (picked == null) return null;
    final bytes = await picked.readAsBytes();
    if (bytes.lengthInBytes > 5 * 1024 * 1024) {
      setState(() => error = 'Görsel boyutu en fazla 5 MB olabilir.');
      return null;
    }
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiClient.baseUrl}/api/admin/uploads/image'),
    );
    request.headers.addAll(await ApiClient._headers());
    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: picked.name),
    );
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final body = ApiClient.jsonBody(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(ApiClient.error(response, 'Görsel yüklenemedi.'));
    }
    return body?['imageUrl']?.toString();
  }

  Future<void> _createProduct() async {
    final branchResponse = await ApiClient.get('/api/admin/branches');
    final branchBody = ApiClient.jsonBody(branchResponse);
    final branches = branchBody == null
        ? <dynamic>[]
        : List<dynamic>.from(
            (branchBody['branches'] is List
                    ? branchBody['branches']
                    : branchBody.values.firstWhere(
                        (value) => value is List,
                        orElse: () => <dynamic>[],
                      ))
                as List,
          );
    if (branches.isEmpty) {
      if (!mounted) return;
      setState(() => error = 'Ürün eklemek için önce bir şube oluşturun.');
      return;
    }
    final branchList = branches
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
    final branch = branchList.firstWhere(
      (item) => item['isDefault'] == true,
      orElse: () => branchList.first,
    );

    final categoryResponse = await ApiClient.get('/api/admin/categories');
    final categoryBody = ApiClient.jsonBody(categoryResponse);
    final categories = categoryBody == null
        ? <dynamic>[]
        : List<dynamic>.from(
            (categoryBody['categories'] is List
                    ? categoryBody['categories']
                    : categoryBody.values.firstWhere(
                        (value) => value is List,
                        orElse: () => <dynamic>[],
                      ))
                as List,
          );
    final categoryList = categories
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .where((item) => item['isActive'] == true)
        .toList();
    if (categoryList.isEmpty) {
      if (!mounted) return;
      setState(
        () => error = 'Ürün eklemek için önce aktif bir kategori oluşturun.',
      );
      return;
    }

    final name = TextEditingController();
    final description = TextEditingController();
    final price = TextEditingController();
    final imageUrl = TextEditingController();
    final allergens = TextEditingController();
    final stock = TextEditingController(text: '20');
    String categoryId = categoryList.first['id'].toString();
    bool featured = false;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Yeni ürün ekle'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: name,
                    decoration: const InputDecoration(labelText: 'Ürün adı'),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: categoryId,
                    decoration: const InputDecoration(labelText: 'Kategori'),
                    items: categoryList
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item['id'].toString(),
                            child: Text(item['name'].toString()),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => categoryId = value);
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: price,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Fiyat (₺)',
                      hintText: '125.00',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: stock,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Stok'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: description,
                    maxLength: 500,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Ürün açıklaması',
                      hintText: 'Ürünün içeriğini ve özelliklerini yazın',
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: imageUrl,
                    decoration: const InputDecoration(
                      labelText: 'Görsel adresi (isteğe bağlı)',
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () async {
                      try {
                        final uploaded = await _uploadProductImage();
                        if (uploaded != null) {
                          setDialogState(() => imageUrl.text = uploaded);
                        }
                      } catch (e) {
                        setDialogState(
                          () => error = e.toString().replaceFirst(
                            'Exception: ',
                            '',
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.upload_outlined),
                    label: const Text('Cihazdan görsel yükle'),
                  ),
                  if (imageUrl.text.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: _AdminImage(imageUrl.text.trim(), height: 120),
                      ),
                    ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: allergens,
                    decoration: const InputDecoration(labelText: 'Alerjenler'),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: featured,
                    onChanged: (value) =>
                        setDialogState(() => featured = value),
                    title: const Text('Öne çıkan ürün'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('VAZGEÇ'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('EKLE'),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true) return;

    final parsedPrice = double.tryParse(price.text.trim().replaceAll(',', '.'));
    final parsedStock = int.tryParse(stock.text.trim());
    if (name.text.trim().length < 2 ||
        parsedPrice == null ||
        parsedPrice <= 0) {
      setState(
        () => error = 'Ürün adı ve geçerli fiyat alanlarını kontrol edin.',
      );
      return;
    }
    final priceInKurus = (parsedPrice * 100).round();
    if (priceInKurus <= 0 || priceInKurus > 100000) {
      setState(() => error = 'Fiyat 0-1000 ₺ arasında olmalıdır.');
      return;
    }
    if (parsedStock == null || parsedStock < 0 || parsedStock > 100000) {
      setState(() => error = 'Stok 0-100000 arasında olmalıdır.');
      return;
    }

    try {
      final response = await ApiClient.post(
        '/api/admin/products?branchId=${branch['id']}',
        {
          'name': name.text.trim(),
          'categoryId': categoryId,
          'price': priceInKurus,
          'description': description.text.trim(),
          'imageUrl': imageUrl.text.trim(),
          'allergens': allergens.text.trim(),
          'stock': parsedStock,
          'featured': featured,
        },
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(ApiClient.error(response, 'Ürün eklenemedi.'));
      }
      await loadSection();
    } catch (e) {
      if (!mounted) return;
      setState(() => error = e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _sendNotification() async {
    final title = TextEditingController();
    final message = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Üyelere bildirim gönder'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: title,
                maxLength: 80,
                decoration: const InputDecoration(
                  labelText: 'Bildirim başlığı',
                ),
              ),
              TextField(
                controller: message,
                maxLength: 500,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Mesaj'),
              ),
              const SizedBox(height: 8),
              const Text(
                'Bildirim tüm aktif üyelere uygulama içi bildirim olarak iletilir.',
                style: TextStyle(fontSize: 12, color: Color(0xFF71717A)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('VAZGEÇ'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('GÖNDER'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      title.dispose();
      message.dispose();
      return;
    }

    final titleText = title.text.trim();
    final messageText = message.text.trim();
    title.dispose();
    message.dispose();
    if (titleText.isEmpty || messageText.isEmpty) {
      setState(() => error = 'Bildirim başlığı ve mesajını girin.');
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });
    try {
      final response = await ApiClient.post('/api/admin/notifications', {
        'title': titleText,
        'body': messageText,
      });
      final body = ApiClient.jsonBody(response);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(ApiClient.error(response, 'Bildirim gönderilemedi.'));
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${body?['sentCount'] ?? 0} üyeye bildirim gönderildi.',
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _createRow() async {
    if (active == 'Finans defteri' ||
        active == 'Genel Bakış' ||
        active == 'AkdoKasa')
      return;
    if (active == 'Bildirim gönder') {
      await _sendNotification();
      return;
    }
    if (active == 'Çalışanlar') {
      await _createEmployee();
      return;
    }
    if (active == 'Menü') {
      await _createProduct();
      return;
    }
    List<Map<String, dynamic>> locations = [];
    if (active == 'Şubeler') {
      try {
        final response = await ApiClient.get('/api/public/locations');
        final body = ApiClient.jsonBody(response);
        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw Exception(ApiClient.error(response, 'İl listesi alınamadı.'));
        }
        final rows = body?['locations'];
        if (rows is! List) throw Exception('İl listesi alınamadı.');
        locations = rows
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      } catch (e) {
        if (!mounted) return;
        setState(() => error = e.toString().replaceFirst('Exception: ', ''));
        return;
      }
    }
    if (!mounted) return;
    final name = TextEditingController();
    final second = TextEditingController();
    final third = TextEditingController();
    String? city;
    String? district;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('$active ekle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: name,
                  decoration: InputDecoration(
                    labelText: active == 'Kullanıcılar'
                        ? 'Ad'
                        : 'Ad / kullanıcı adı',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: second,
                  decoration: InputDecoration(
                    labelText: active == 'Kullanıcılar' ? 'Soyad' : 'Ek bilgi',
                  ),
                ),
                if (active == 'Şubeler') ...[
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: city,
                    decoration: const InputDecoration(labelText: 'İl'),
                    items: locations
                        .map(
                          (location) => DropdownMenuItem<String>(
                            value: location['city'].toString(),
                            child: Text(location['city'].toString()),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        city = value;
                        district = null;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: district,
                    decoration: const InputDecoration(labelText: 'İlçe'),
                    items: locations
                        .where((location) => location['city'] == city)
                        .expand(
                          (location) => (location['districts'] as List).map(
                            (districtName) => DropdownMenuItem<String>(
                              value: districtName.toString(),
                              child: Text(districtName.toString()),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: city == null
                        ? null
                        : (value) => setDialogState(() => district = value),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: third,
                    decoration: const InputDecoration(labelText: 'Adres'),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('VAZGEÇ'),
            ),
            ElevatedButton(
              onPressed:
                  active == 'Şubeler' && (city == null || district == null)
                  ? null
                  : () => Navigator.pop(dialogContext, true),
              child: const Text('EKLE'),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true || name.text.trim().isEmpty) return;
    if (active == 'Şubeler' && (city == null || district == null)) {
      setState(() => error = 'İl ve ilçe seçin.');
      return;
    }
    Map<String, dynamic> body = {};
    String path = '';
    if (active == 'Şubeler') {
      path = '/api/admin/branches';
      body = {
        'name': name.text.trim(),
        'city': city?.trim() ?? '',
        'district': district?.trim() ?? '',
        if (third.text.trim().isNotEmpty) 'address': third.text.trim(),
      };
    } else if (active == 'Kullanıcılar') {
      path = '/api/admin/members';
      body = {
        'firstName': name.text.trim(),
        'lastName': second.text.trim(),
        'phone': '',
        'password': 'Akdo1234',
        'initialBalance': 0,
      };
    } else if (active == 'Çalışanlar') {
      await _createEmployee();
      return;
    } else if (active == 'Masa kodları') {
      final branchResponse = await ApiClient.get('/api/admin/branches');
      final branchBody = ApiClient.jsonBody(branchResponse);
      final branches = branchBody == null
          ? <dynamic>[]
          : List<dynamic>.from(
              (branchBody['branches'] is List
                      ? branchBody['branches']
                      : branchBody.values.firstWhere(
                          (value) => value is List,
                          orElse: () => <dynamic>[],
                        ))
                  as List,
            );
      if (branches.isEmpty) {
        setState(() => error = 'Masa eklemek için önce bir şube oluşturun.');
        return;
      }
      final branch = Map<String, dynamic>.from(branches.first as Map);
      path = '/api/admin/tables';
      body = {'name': name.text.trim(), 'branchId': branch['id']};
    } else if (active == 'Kategoriler') {
      final branchResponse = await ApiClient.get('/api/admin/branches');
      final branchBody = ApiClient.jsonBody(branchResponse);
      final branches = branchBody == null
          ? <dynamic>[]
          : List<dynamic>.from(
              (branchBody['branches'] is List
                      ? branchBody['branches']
                      : branchBody.values.firstWhere(
                          (value) => value is List,
                          orElse: () => <dynamic>[],
                        ))
                  as List,
            );
      if (branches.isEmpty) {
        setState(
          () => error = 'Kategori eklemek için önce bir şube oluşturun.',
        );
        return;
      }
      final branch = Map<String, dynamic>.from(
        branches.cast<Map>().firstWhere(
          (item) => item['isDefault'] == true,
          orElse: () => branches.first as Map,
        ) as Map,
      );
      path = '/api/admin/categories?branchId=${branch['id']}';
      body = {'name': name.text.trim(), 'icon': '✦'};
    } else {
      if (!mounted) return;
      setState(
        () => error = 'Bu bölüm için ekleme ayrı veri seçimi gerektirir.',
      );
      return;
    }

    try {
      final response = await ApiClient.post(path, body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(ApiClient.error(response, 'Kayıt eklenemedi.'));
      }
      await loadSection();
    } catch (e) {
      if (!mounted) return;
      setState(() => error = e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF09090B),
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Image.asset('assets/logo/akdoyonetim.jpg', height: 42),
      ),
      drawer: authenticated
          ? Drawer(
              backgroundColor: akdoGreen,
              child: SafeArea(
                child: ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'ÇALIŞMA ALANI',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 9,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    ...sections.map(
                      (section) => ListTile(
                        title: Text(
                          section,
                          style: TextStyle(
                            fontSize: 13,
                            color: active == section
                                ? const Color(0xFFD4D4D8)
                                : Colors.white70,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          selectSection(section);
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.white54),
                      title: const Text(
                        'Oturuımı kapat',
                        style: TextStyle(color: Colors.white70),
                      ),
                      onTap: () async {
                        await ApiClient.post('/api/admin/logout', {});
                        setState(() {
                          authenticated = false;
                          rows.clear();
                        });
                        if (mounted) Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            )
          : null,
      floatingActionButton:
          authenticated &&
              active != 'Genel Bakış' &&
              active != 'AkdoKasa' &&
              active != 'Finans defteri'
          ? FloatingActionButton(
              onPressed: _createRow,
              backgroundColor: akdoGold,
              foregroundColor: Colors.white,
              child: Icon(
                active == 'Bildirim gönder' ? Icons.send_outlined : Icons.add,
              ),
            )
          : null,
      body: !authenticated
          ? ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE4E4E7)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset('assets/logo/akdoyonetim.jpg', height: 64),
                      const SizedBox(height: 16),
                      const Text(
                        'Yönetim Merkezi',
                        style: TextStyle(
                          fontSize: 30,
                          fontFamily: 'Georgia',
                          color: akdoGreen,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: username,
                        decoration: const InputDecoration(
                          labelText: 'Kullanıcı adı',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: password,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'Parola'),
                      ),
                      if (error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            error!,
                            style: const TextStyle(color: Color(0xFFA63E35)),
                          ),
                        ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: loading ? null : login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: akdoGreen,
                            foregroundColor: Colors.white,
                          ),
                          child: loading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text('GİRİŞ YAP'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : RefreshIndicator(
              onRefresh: loadSection,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    active,
                    style: const TextStyle(
                      fontSize: 28,
                      fontFamily: 'Georgia',
                      color: akdoGreen,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (active == 'Bildirim gönder')
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE4E4E7)),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.notifications_active_outlined, size: 28),
                          SizedBox(height: 12),
                          Text(
                            'Aktif üyelere duyuru gönderin.',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Gönderdiğiniz duyuru üyelerin bildirimler ekranında görünür. '
                            'Sipariş durumu değişiklikleri de otomatik bildirilir.',
                            style: TextStyle(
                              color: Color(0xFF71717A),
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Başlamak için sağ alttaki gönder düğmesine dokunun.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    )
                  else if (active != 'Genel Bakış')
                    TextField(
                      controller: adminSearch,
                      onChanged: (value) =>
                          setState(() => adminSearchQuery = value),
                      decoration: InputDecoration(
                        hintText: '$active içinde ara',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: adminSearchQuery.isEmpty
                            ? null
                            : IconButton(
                                onPressed: () {
                                  adminSearch.clear();
                                  setState(() => adminSearchQuery = '');
                                },
                                icon: const Icon(Icons.close),
                              ),
                        filled: true,
                        fillColor: const Color(0xFFFFFFFF),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFE4E4E7),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFE4E4E7),
                          ),
                        ),
                      ),
                    ),
                  if (active != 'Genel Bakış') const SizedBox(height: 10),
                  if (loading) const LinearProgressIndicator(),
                  if (error != null)
                    Text(
                      error!,
                      style: const TextStyle(color: Color(0xFFA63E35)),
                    ),
                  if (!loading &&
                      active != 'Genel Bakış' &&
                      active != 'Bildirim gönder' &&
                      filteredRows.isEmpty &&
                      error == null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        adminSearchQuery.trim().isEmpty
                            ? 'Bu bölümde kayıt bulunamadı.'
                            : 'Aramanızla eşleşen kayıt bulunamadı.',
                        style: const TextStyle(
                          color: Color(0xFF71717A),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  if (active == 'Genel Bakış') ...[
                    _AdminOverviewCard(
                      title: 'Şubeler',
                      value: 'Şube yönetimi',
                      onTap: () => selectSection('Şubeler'),
                    ),
                    _AdminOverviewCard(
                      title: 'Siparişler',
                      value: 'Personel akışı',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const StaffScreen()),
                      ),
                    ),
                    _AdminOverviewCard(
                      title: 'Üyeler',
                      value: 'AkdoKasa bakiyeleri',
                      onTap: () => selectSection('Kullanıcılar'),
                    ),
                  ] else
                    ...filteredRows.map((raw) {
                      final row = raw is Map
                          ? Map<String, dynamic>.from(raw)
                          : <String, dynamic>{};
                      final title = active == 'Kullanıcılar'
                          ? '${row['firstName']?.toString() ?? ''} ${row['lastName']?.toString() ?? ''}'
                                .trim()
                          : active == 'AkdoKasa'
                          ? '${row['member'] is Map ? Map<String, dynamic>.from(row['member'] as Map)['firstName']?.toString() ?? '' : ''} '
                                '${row['member'] is Map ? Map<String, dynamic>.from(row['member'] as Map)['lastName']?.toString() ?? '' : ''}'
                          : row['name']?.toString() ??
                                row['firstName']?.toString() ??
                                row['username']?.toString() ??
                                row['title']?.toString() ??
                                row['description']?.toString() ??
                                row['id']?.toString() ??
                                '';
                      final subtitle = active == 'Kullanıcılar'
                          ? '#${row['memberNumber']?.toString() ?? ''} · ${row['firstName']?.toString() ?? ''} ${row['lastName']?.toString() ?? ''} · Bakiye: ${formatPrice((row['balance'] as num?)?.toInt() ?? 0)}'
                          : active == 'AkdoKasa'
                          ? '${formatPrice((row['amount'] as num?)?.toInt() ?? 0)} · Üye #${row['member'] is Map ? Map<String, dynamic>.from(row['member'] as Map)['memberNumber']?.toString() ?? '' : ''}'
                          : row['address']?.toString() ??
                                row['city']?.toString() ??
                                row['status']?.toString() ??
                                row['memberNumber']?.toString() ??
                                row['code']?.toString() ??
                                row['role']?.toString() ??
                                (row['amount'] != null
                                    ? '${formatPrice((row['amount'] as num).toInt())} · ${row['kind']?.toString() ?? ''}'
                                    : '');
                      return InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: active == 'Finans defteri'
                            ? () => _showLedgerDetail(row)
                            : null,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE4E4E7)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontFamily: 'Georgia',
                                        fontSize: 16,
                                      ),
                                    ),
                                    if (subtitle.isNotEmpty)
                                      Text(
                                        subtitle,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF71717A),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (active == 'AkdoKasa')
                                PopupMenuButton<String>(
                                  onSelected: (status) {
                                    _reviewCash(
                                      row,
                                      status == 'APPROVED'
                                          ? 'APPROVED'
                                          : 'REJECTED',
                                    );
                                  },
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(
                                      value: 'APPROVED',
                                      child: Text('Onayla'),
                                    ),
                                    PopupMenuItem(
                                      value: 'REJECTED',
                                      child: Text('Reddet'),
                                    ),
                                  ],
                                )
                              else if (active != 'Finans defteri' &&
                                  active != 'Genel Bakış')
                                PopupMenuButton<String>(
                                  onSelected: (action) {
                                    if (action == 'edit') _editRow(row);
                                    if (action == 'toggle') _toggleRow(row);
                                    if (action == 'balance') {
                                      _adjustMemberBalance(row);
                                    }
                                  },
                                  itemBuilder: (_) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Düzenle'),
                                    ),
                                    if (active == 'Kullanıcılar')
                                      const PopupMenuItem(
                                        value: 'balance',
                                        child: Text('Bakiye işlemi'),
                                      ),
                                    PopupMenuItem(
                                      value: 'toggle',
                                      child: Text(
                                        row['isActive'] == true
                                            ? 'Pasife al'
                                            : 'Aktifleştir',
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }
}

class _LedgerDetailLine extends StatelessWidget {
  const _LedgerDetailLine(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF71717A), fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminImage extends StatelessWidget {
  const _AdminImage(this.url, {this.width, this.height});

  final String url;
  final double? width;
  final double? height;

  String get resolvedUrl {
    if (url.startsWith('/')) return '${ApiClient.baseUrl}$url';
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Image.network(
      resolvedUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: width,
        height: height,
        color: const Color(0xFFF4F4F5),
        alignment: Alignment.center,
        child: const Icon(
          Icons.image_not_supported_outlined,
          color: Color(0xFF71717A),
        ),
      ),
    );
  }
}

class _AdminOverviewCard extends StatelessWidget {
  final String title, value;
  final VoidCallback onTap;
  const _AdminOverviewCard({
    required this.title,
    required this.value,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE4E4E7)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Georgia',
                      color: akdoGreen,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF71717A),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: akdoGold),
          ],
        ),
      ),
    );
  }
}
