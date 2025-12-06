import 'package:flutter/material.dart';

/// Một item trong navigation dành cho từng role.
/// 
/// - [icon]: biểu tượng hiển thị trong sidebar hoặc bottom navigation.
/// - [label]: tên hiển thị.
/// - [builder]: hàm trả về widget màn hình tương ứng khi chọn menu.
///
/// Ví dụ:
/// RoleDestination(
///   icon: Icons.dashboard,
///   label: 'Tổng quan',
///   builder: (_) => DashboardScreen(),
/// );
class RoleDestination {
  final IconData icon;
  final String label;
  final WidgetBuilder builder;

  const RoleDestination({
    required this.icon,
    required this.label,
    required this.builder,
  });
}
