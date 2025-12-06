import 'package:flutter/material.dart';

import 'role_destination.dart';
import '../services/auth_service.dart';
import '../constants/app_routes.dart';

class RoleShell extends StatefulWidget {
  final String appBarTitle;
  final String sideTitle;
  final Color sideHeaderColor;
  final List<RoleDestination> destinations;

  const RoleShell({
    super.key,
    required this.appBarTitle,
    required this.sideTitle,
    required this.sideHeaderColor,
    required this.destinations,
  });

  @override
  State<RoleShell> createState() => _RoleShellState();
}

class _RoleShellState extends State<RoleShell> {
  int _selectedIndex = 0;
  bool _isSidebarVisible = true; // bật/tắt sidebar

  static const double _sidebarWidth = 280;
  static const _animDuration = Duration(milliseconds: 250);
  static const Curve _animCurve = Curves.easeInOut;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 800;
    final currentDestination = widget.destinations[_selectedIndex];
    final colorScheme = Theme.of(context).colorScheme;

    // Sidebar
    Widget buildSidebar() {
      return Container(
        width: _sidebarWidth,
        color: colorScheme.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header sidebar (tên role)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
              color: widget.sideHeaderColor,
              child: Text(
                widget.sideTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Phần menu chính + nút đăng xuất
            Expanded(
              child: Column(
                children: [
                  // MENU CHÍNH
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.destinations.length,
                      itemBuilder: (context, index) {
                        final d = widget.destinations[index];
                        final selected = index == _selectedIndex;

                        return Material(
                          color: selected
                              ? colorScheme.primary.withOpacity(0.06)
                              : Colors.transparent,
                          child: ListTile(
                            leading: Icon(
                              d.icon,
                              color: selected
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
                            ),
                            title: Text(
                              d.label,
                              style: TextStyle(
                                color: selected
                                    ? colorScheme.primary
                                    : colorScheme.onSurface,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                _selectedIndex = index;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  const Divider(height: 1),

                  // NÚT ĐĂNG XUẤT
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.redAccent),
                    title: const Text('Đăng xuất'),
                    onTap: () async {
                      await AuthService.logout();

                      if (!mounted) return;
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        UpnestRoutes.login,
                        (route) => false, // xoá toàn bộ stack, không back lại được
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            if (isWide)
              IconButton(
                icon: Icon(
                  _isSidebarVisible ? Icons.arrow_back_ios_new : Icons.menu,
                ),
                onPressed: () {
                  setState(() {
                    _isSidebarVisible = !_isSidebarVisible;
                  });
                },
              ),
            const SizedBox(width: 4),
            Text(widget.appBarTitle),
          ],
        ),
      ),

      // BODY: sidebar chỉ trượt (slide) bằng AnimatedContainer
      body: Row(
        children: [
          if (isWide)
            AnimatedContainer(
              duration: _animDuration,
              curve: _animCurve,
              width: _isSidebarVisible ? _sidebarWidth : 0,
              child: ClipRect(
                child: Align(
                  alignment: Alignment.centerLeft,
                  widthFactor: 1,
                  child: buildSidebar(),
                ),
              ),
            ),
          Expanded(
            child: currentDestination.builder(context),
          ),
        ],
      ),

      // BOTTOM NAV cho mobile
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              destinations: widget.destinations
                  .map(
                    (d) => NavigationDestination(
                      icon: Icon(d.icon),
                      label: d.label,
                    ),
                  )
                  .toList(),
            ),
    );
  }
}
