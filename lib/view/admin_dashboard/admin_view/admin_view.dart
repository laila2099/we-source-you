import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:we_source_you/core/constant/app_color.dart';
import 'package:we_source_you/core/constant/text_style.dart';
import 'package:we_source_you/routes/app_routes.dart';
import 'package:we_source_you/view/team/widget/team_card.dart';
import 'package:we_source_you/widgets/circular_icon/circular_icon.dart';
import 'package:we_source_you/widgets/glass_morphism.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  late TabController tabController;
  String search = '';
  String filterType = 'all';
  int activeTabIndex = 0;
  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      if (tabController.indexIsChanging ||
          tabController.index != activeTabIndex) {
        setState(() {
          activeTabIndex = tabController.index;
        });
      }
    });
    super.initState();
  }

  // دالة لجلب عدد المستخدمين الكلي
  Stream<int> _getUsersCount() {
    return firestore
        .collection('users')
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  // دالة لجلب عدد طلبات KYC المعلقة
  Stream<int> _getKycCount() {
    return firestore
        .collection('users')
        .where('kycStatus', isEqualTo: 'pending')
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  int _getCrossAxisCount(double width) {
    if (width >= 1100) {
      return 3; // Desktop
    } else if (width >= 700) {
      return 2; // Tablet
    } else {
      return 1; // Mobile
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(
          'Admin Dashboard',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        bottom: TabBar(
          controller: tabController,
          labelStyle: AppTextStyles.h4(context),
          tabs: [
            Tab(
              child: StreamBuilder<int>(
                stream: _getUsersCount(),
                builder: (context, snap) => Text('Users (${snap.data ?? 0})'),
              ),
            ),
            Tab(
              child: StreamBuilder<int>(
                stream: _getKycCount(),
                builder: (context, snap) =>
                    Text('KYC Requests (${snap.data ?? 0})'),
              ),
            ),
          ],
        ),
        leading: IconButton(
          tooltip: Text("Back to Home".tr).data,
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.offAllNamed(AppRoutes.home),
        ),
      ),

      body: Column(
        children: [
          AnimatedBuilder(
            animation: tabController,
            builder: (context, _) {
              // يظهر الفلتر فقط عندما يكون الـ index هو 0 (تبويب Users)
              return tabController.index == 0
                  ? _filters()
                  : const SizedBox.shrink();
            },
          ),

          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [_usersTab(), _kycTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filters() {
    final screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth >= 1200
        ? 600
        : (screenWidth >= 800 ? screenWidth * 0.7 : screenWidth * 0.95);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Container(
          width: containerWidth,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ), // تقليل padding الداخلي
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => search = v),
                  textAlignVertical: TextAlignVertical.center,
                  decoration: const InputDecoration(
                    hintText: 'Search...',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search, size: 18),
                    contentPadding: EdgeInsets.zero,
                    isDense: true, // يجعل الارتفاع أصغر ليتناسب مع الفلتر
                  ),
                ),
              ),

              // الفلتر بحجم أصغر وتلقائي
              IntrinsicWidth(
                // يجعل الودجت تأخذ عرض النص فقط
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 80, // الحد الأدنى للعرض
                    maxWidth: 220, // الحد الأقصى للعرض لمنع الـ Overflow
                    minHeight: 35,
                    maxHeight: 40,
                  ),
                  child: GlassDropdownOverlay(
                    value: filterType,
                    items: ['All', 'Individual', 'Company'],
                    onChanged: (v) => setState(() => filterType = v),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- USERS TAB ----------------
  Widget _usersTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name = ((data['fullName'] ?? data['companyName'] ?? ''))
              .toString()
              .toLowerCase();
          final type = data['type'] ?? '';

          final matchesSearch = name.contains(search.toLowerCase());
          final matchesType = filterType == 'all' ? true : filterType == type;

          return matchesSearch && matchesType;
        }).toList();

        return LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.15, // عدليها حسب شكل الكرت
              ),
              itemCount: users.length,
              itemBuilder: (_, i) {
                final data = users[i].data() as Map<String, dynamic>;
                return AdminUserCard(user: data);
              },
            );
          },
        );
      },
    );
  }

  // ---------------- KYC TAB ----------------
  Widget _kycTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection('users')
          .where('kycStatus', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No KYC Requests',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2, // عدليها إذا حسيتي الكرت طويل/قصير
              ),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (_, i) {
                return _kycCard(snapshot.data!.docs[i]);
              },
            );
          },
        );
      },
    );
  }

  Widget _kycCard(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final uid = doc.id;
    final kyc = data['kyc'] ?? {};
    final String displayName = data['type'] == 'company'
        ? (data['companyName'] ?? 'No Name')
        : (data['fullName'] ?? 'No Name');

    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          12,
          8,
          12,
          8,
        ), // 👈 تقليل البادنج العلوي والسفلي (8 بدلاً من 12)
        child: Column(
          mainAxisSize: MainAxisSize.min, // 👈 جعل العمود يأخذ أقل مساحة ممكنة
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              displayName,
              maxLines: 1, // 👈 منع النص من النزول لسطر جديد
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                // 👈 استخدام bodyMedium بدلاً من Large
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20), // 👈 تصغير المسافة (كانت 10)
            // عرض الصور بحجم أصغر
            SizedBox(
              height: 60, // 👈 تحديد ارتفاع ثابت ومضغوط للصور
              child: ListView(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                children: [
                  if ((kyc['idFileUrl'] ?? '').isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _imageThumb(
                        kyc['idFileUrl'],
                        height: 40,
                      ), // مرري الارتفاع للدالة
                    ),
                  if ((kyc['selfieUrl'] ?? '').isNotEmpty)
                    _imageThumb(kyc['selfieUrl'], height: 40),
                ],
              ),
            ),

            const SizedBox(height: 45), // 👈 تصغير المسافة قبل الأزرار

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // استخدام أزرار بحجم أصغر (Sized)
                SizedBox(
                  height: 32, // 👈 تحديد ارتفاع للأزرار
                  child: ElevatedButton(
                    onPressed: () => _updateKyc(uid, 'approved'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 127, 218, 130),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ), // تقليل البادنج الداخلي
                      textStyle: const TextStyle(fontSize: 12), // تصغير الخط
                    ),
                    child: const Text('Approve'),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 32,
                  child: ElevatedButton(
                    onPressed: () => _updateKyc(uid, 'rejected'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- HELPERS ----------------
  void _updateKyc(String uid, String status) async {
    await firestore.collection('users').doc(uid).update({'kycStatus': status});

    Get.snackbar(
      'Success',
      'KYC $status',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  Widget _imageThumb(String url, {double height = 50}) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) =>
              Dialog(child: InteractiveViewer(child: Image.network(url))),
        );
      },
      child: Image.network(url, height: 80, width: 80, fit: BoxFit.cover),
    );
  }
}

class AdminUserCard extends StatelessWidget {
  final Map<String, dynamic> user;

  const AdminUserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final name = user['fullName'] ?? user['companyName'] ?? 'Unknown';

    final title = user['type'] == 'company'
        ? 'Company'
        : (user['mediaWorkTypes'] != null &&
                  (user['mediaWorkTypes'] as List).isNotEmpty
              ? user['mediaWorkTypes'][0]
              : 'Individual');

    final country = user['country'] ?? '';
    final specialties = (user['mediaWorkTypes'] ?? []).cast<String>();
    final socialLinksRaw = user['socialLinks'];
    final socialLinks = socialLinksRaw is Map<String, dynamic>
        ? socialLinksRaw
        : {};

    return GlassContainer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            /// ---------- HEADER ----------
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircularIcon(
                  gradientColors: const [
                    AppColors.lightBlue,
                    Color.fromARGB(80, 155, 39, 176),
                  ],
                  child: Center(
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        title,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium!.copyWith(color: Colors.grey),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            country,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// ---------- SPECIALTIES ----------
            if (specialties.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List<Widget>.from(
                  specialties.map((e) => SpecialtyTag(tag: e)),
                ),
              ),

            const SizedBox(height: 5),
            const Divider(),
            const SizedBox(height: 5),

            /// ---------- BASIC INFO ----------
            _infoRow('Email', user['email'], context),
            _infoRow('Phone', user['phone'], context),
            _infoRow('Type', user['type'], context),
            _infoRow('KYC', user['kycStatus'] ?? 'not submitted', context),
            _infoRow('Account Type', user['type'], context),
            const SizedBox(height: 5),
            for (final entry in socialLinks.entries)
              _linkRow(entry.key, entry.value.toString()),

            /// ---------- ACTION ----------
            SizedBox(width: double.infinity),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String? value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        '$label: ${value ?? '-'}',
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

Widget _linkRow(String label, String url) {
  return GestureDetector(
    onTap: () async {
      final uri = Uri.tryParse(url);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // لو الرابط غير صالح
        debugPrint('Cannot open URL: $url');
      }
    },
    child: Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        '$label: $url',
        style: const TextStyle(
          color: Colors.blueAccent,
          decoration: TextDecoration.underline,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}

class GlassDropdownOverlay extends StatefulWidget {
  final String value;
  final List<String> items;
  final void Function(String) onChanged;

  const GlassDropdownOverlay({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  State<GlassDropdownOverlay> createState() => _GlassDropdownOverlayState();
}

class _GlassDropdownOverlayState extends State<GlassDropdownOverlay> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  void _toggleDropdown() {
    if (_overlayEntry == null) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _showOverlay() {
    final overlay = Overlay.of(context)!;
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final position = renderBox.localToGlobal(Offset.zero);
    final overlayWidth = size.width < 160 ? 160.0 : size.width;
    double leftPosition = position.dx;
    final screenWidth = MediaQuery.of(context).size.width;
    if (leftPosition + overlayWidth > screenWidth) {
      leftPosition =
          screenWidth - overlayWidth - 10; // 10 بكسل هامش عن حافة الشاشة
    }
    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _removeOverlay,
        behavior: HitTestBehavior.translucent,
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              Positioned(
                top: position.dy + size.height + 4,
                left: leftPosition,
                width: overlayWidth,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 200, // أعلى ارتفاع للقائمة
                  ),
                  child: GlassContainer(
                    borderRadius: 8,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: widget.items.map((item) {
                          return InkWell(
                            onTap: () {
                              widget.onChanged(item.toLowerCase());
                              _removeOverlay();
                            },
                            child: Container(
                              // استخدم Container لإضافة مساحة ضغط مريحة
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Text(
                                item,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: InkWell(
        onTap: _toggleDropdown,
        child: GlassContainer(
          borderRadius: 8,
          padding: EdgeInsets.zero, // ✅ إلغاء الـ 16 بكسل الافتراضية
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  // ✅ الآن سيأخذ النص كل المساحة المتاحة بعد إلغاء الـ padding الكبير
                  child: Text(
                    widget.value[0].toUpperCase() + widget.value.substring(1),
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
