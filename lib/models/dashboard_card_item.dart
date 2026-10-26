import 'package:flutter/material.dart';

/// Representation of an endpoint card displayed in the Dashboard.
class DashboardCardItem {
  final String title;
  final String subtitle;
  final String description;
  final String routePath;
  final String routeName;
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;
  final String endpointUrl;
  final String countBadge;

  const DashboardCardItem({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.routePath,
    required this.routeName,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
    required this.endpointUrl,
    required this.countBadge,
  });
}
