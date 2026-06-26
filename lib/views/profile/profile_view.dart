import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../core/app_icons.dart';
import '../../core/app_theme.dart';
import '../auth/login_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthController>(context, listen: false).loadProfile();
    });
  }

  void _handleLogout(BuildContext context, AuthController controller) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          title: Text('Log Out', style: theme.textTheme.titleLarge),
          content: Text(
            'Are you sure you want to end your active session in Mirza Internationals portal?',
            style: theme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                controller.logout().then((_) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginView()),
                    (route) => false,
                  );
                });
              },
              child: const Text(
                'Log Out',
                style: TextStyle(
                  color: AppTheme.neonPink,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<AuthController>(context);
    final user = controller.currentUser;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Account',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: controller.isLoading && user == null
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.neonBlue),
              ),
            )
          : RefreshIndicator(
              onRefresh: () => Provider.of<AuthController>(
                context,
                listen: false,
              ).loadProfile(),
              color: AppTheme.neonBlue,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.neonGreen.withOpacity(0.18),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 92,
                            height: 92,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.25),
                                width: 1.4,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                user?.firstName.isNotEmpty == true
                                    ? user!.firstName[0].toUpperCase()
                                    : user?.username.isNotEmpty == true
                                    ? user!.username[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            user?.firstName.isNotEmpty == true
                                ? '${user!.firstName} ${user.lastName}'
                                : 'System Operator',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontSize: 22,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '@${user?.username ?? 'testuser'}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle(context, 'Profile Information'),
                    const SizedBox(height: 12),
                    _buildCard(
                      context,
                      child: Column(
                        children: [
                          _buildInfoRow(
                            context,
                            icon: AppIcons.accountBox,
                            keyLabel: 'User ID',
                            value: user?.userId ?? '12',
                          ),
                          const SizedBox(height: 14),
                          Divider(color: colorScheme.outlineVariant, height: 1),
                          const SizedBox(height: 14),
                          _buildInfoRow(
                            context,
                            icon: AppIcons.email,
                            keyLabel: 'Email Address',
                            value: user?.email.isNotEmpty == true
                                ? user!.email
                                : 'operator@mirza.com',
                          ),
                          const SizedBox(height: 14),
                          Divider(color: colorScheme.outlineVariant, height: 1),
                          const SizedBox(height: 14),
                          _buildInfoRow(
                            context,
                            icon: AppIcons.call,
                            keyLabel: 'Phone Number',
                            value: user?.mobileNumber.isNotEmpty == true
                                ? user!.mobileNumber
                                : '+91 76660 48941',
                          ),
                          const SizedBox(height: 14),
                          Divider(color: colorScheme.outlineVariant, height: 1),
                          const SizedBox(height: 14),
                          _buildInfoRow(
                            context,
                            icon: AppIcons.male,
                            keyLabel: 'Gender Group',
                            value: user?.gender.isNotEmpty == true
                                ? user!.gender
                                : 'Male',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle(context, 'Security & Session'),
                    const SizedBox(height: 12),
                    _buildActionTile(
                      context,
                      label: 'Update Profile Details',
                      icon: AppIcons.editNote,
                      accentColor: AppTheme.neonBlue,
                      onTap: () => _showUpdateProfileSheet(context, controller),
                    ),
                    const SizedBox(height: 12),
                    _buildActionTile(
                      context,
                      label: 'Change Portal Password',
                      icon: AppIcons.lockReset,
                      accentColor: AppTheme.neonPurple,
                      onTap: () =>
                          _showChangePasswordSheet(context, controller),
                    ),
                    // const SizedBox(height: 12),
                    // _buildActionTile(
                    //   context,
                    //   label: 'Log Out Portal',
                    //   icon: AppIcons.logout,
                    //   accentColor: AppTheme.neonPink,
                    //   onTap: () => _handleLogout(context, controller),
                    // ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required Widget child}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.dividerColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String keyLabel,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                keyLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: accentColor, size: 22),
        ),
        title: Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        trailing: Icon(
          AppIcons.arrowForward,
          color: theme.colorScheme.onSurface.withOpacity(0.45),
          size: 14,
        ),
      ),
    );
  }

  void _showUpdateProfileSheet(
    BuildContext context,
    AuthController controller,
  ) {
    final formKey = GlobalKey<FormState>();
    final fNameController = TextEditingController(
      text: controller.currentUser?.firstName,
    );
    final lNameController = TextEditingController(
      text: controller.currentUser?.lastName,
    );
    final phoneController = TextEditingController(
      text: controller.currentUser?.mobileNumber,
    );
    final genderController = TextEditingController(
      text: controller.currentUser?.gender.isEmpty == true
          ? 'Male'
          : controller.currentUser?.gender,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            top: 24,
            left: 20,
            right: 20,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Update Profile',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Edit your portal identity details.',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: fNameController,
                  decoration: const InputDecoration(labelText: 'First Name'),
                  validator: (v) =>
                      v?.trim().isEmpty == true ? 'Cannot be empty' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: lNameController,
                  decoration: const InputDecoration(labelText: 'Last Name'),
                  validator: (v) =>
                      v?.trim().isEmpty == true ? 'Cannot be empty' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Mobile Number'),
                  keyboardType: TextInputType.phone,
                  validator: (v) =>
                      v?.trim().isEmpty == true ? 'Cannot be empty' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: genderController,
                  decoration: const InputDecoration(
                    labelText: 'Gender (Male/Female/Other)',
                  ),
                  validator: (v) =>
                      v?.trim().isEmpty == true ? 'Cannot be empty' : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    controller
                        .updateProfile(
                          firstName: fNameController.text.trim(),
                          lastName: lNameController.text.trim(),
                          mobileNumber: phoneController.text.trim(),
                          gender: genderController.text.trim(),
                        )
                        .then((ok) {
                          if (ok) {
                            Navigator.pop(sheetContext);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Profile details updated successfully!',
                                ),
                                backgroundColor: AppTheme.neonGreen,
                              ),
                            );
                          }
                        });
                  },
                  icon: const Icon(AppIcons.check),
                  label: const Text('SAVE CHANGES'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showChangePasswordSheet(
    BuildContext context,
    AuthController controller,
  ) {
    final formKey = GlobalKey<FormState>();
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            top: 24,
            left: 20,
            right: 20,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Change Portal Password',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Keep your portal account secure with a fresh password.',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: oldPassController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Old Password'),
                  validator: (v) =>
                      v?.isEmpty == true ? 'Please specify old password' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: newPassController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'New Password'),
                  validator: (v) {
                    if (v == null || v.isEmpty)
                      return 'Please specify new password';
                    if (v.length < 6)
                      return 'Password must be at least 6 characters long';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    controller
                        .changePassword(
                          oldPassword: oldPassController.text,
                          newPassword: newPassController.text,
                        )
                        .then((ok) {
                          if (ok) {
                            Navigator.pop(sheetContext);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Password changed. Please log in again.',
                                ),
                                backgroundColor: AppTheme.neonGreen,
                              ),
                            );
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginView(),
                              ),
                              (route) => false,
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  controller.errorMessage ??
                                      'Password change failed',
                                ),
                                backgroundColor: AppTheme.neonPink,
                              ),
                            );
                          }
                        });
                  },
                  icon: const Icon(AppIcons.lockReset),
                  label: const Text('CHANGE PASSWORD'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}
