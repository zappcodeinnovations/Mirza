import 'package:flutter/material.dart';

import '../../../core/app_icons.dart';
import '../../../core/app_theme.dart';
import '../../../controllers/dashboard_controller.dart';
import 'dashboard_filter_widgets.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final DashboardController controller;

  const DashboardAppBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,

      leadingWidth: 80,

      leading: Padding(
        padding: const EdgeInsets.only(left: 14, top: 8, bottom: 8),

        child: GestureDetector(
          onTap: () {
            Scaffold.of(context).openDrawer();
          },

          child: Container(
            child: Center(
              child: CircleAvatar(
                radius: 18,

                backgroundColor: AppTheme.neonGreen,

                child: const Icon(
                  AppIcons.person,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ),

      /// =========================
      /// CENTER LOGO
      /// =========================
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// BRAND NAME
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "MIRZA",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: AppTheme.neonGreen,
                ),
              ),
            ],
          ),
        ],
      ),

      actions: [
        /// NOTIFICATIONS
        Container(
          margin: const EdgeInsets.only(top: 8, bottom: 8, right: 10),

          // decoration: BoxDecoration(
          //   color: AppTheme.darkSurface,

          //   borderRadius:
          //       BorderRadius.circular(16),

          //   border: Border.all(
          //     color: AppTheme.darkAccent,
          //   ),

          //   boxShadow: [
          //     BoxShadow(
          //       color: Colors.black
          //           .withOpacity(0.12),
          //       blurRadius: 8,
          //       offset: const Offset(0, 3),
          //     ),
          //   ],
          // ),
          child: Stack(
            children: [
              IconButton(
                icon: const Icon(
                  AppIcons.notifications,
                  color: AppTheme.neonGreen,
                ),

                onPressed: () {
                  Navigator.pushNamed(context, '/notifications');
                },
              ),

              Positioned(
                top: 10,
                right: 10,

                child: Container(
                  width: 9,
                  height: 9,

                  decoration: const BoxDecoration(
                    color: AppTheme.neonPink,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),

        /// FILTER BUTTON
        Container(
          margin: const EdgeInsets.only(top: 8, bottom: 8, right: 14),

          child: IconButton(
            icon: const Icon(AppIcons.filter, color: AppTheme.neonGreen),

            tooltip: "Filter Dashboard",

            onPressed: () {
              showDashboardFilterBottomSheet(context, controller);
            },
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
