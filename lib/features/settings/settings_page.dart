import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wasfa_sha3beya/core/theme_controller.dart';
import 'package:wasfa_sha3beya/core/widgets/banner_ad_widget.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeCtrl = ThemeController.to;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: [
          _SettingsHeader(theme: theme, isDark: isDark),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                const SizedBox(height: 16),
                _ProfileCard(theme: theme, isDark: isDark),
                const SizedBox(height: 24),
                _ThemeSelector(themeCtrl: themeCtrl, theme: theme),
                const SizedBox(height: 24),
                _SectionTitle(title: 'القانونية والسياسات', theme: theme),
                const SizedBox(height: 8),
                _PolicyTile(
                  icon: Icons.privacy_tip_rounded,
                  title: 'سياسة الخصوصية',
                  theme: theme,
                  onTap: () => _showPolicyDialog(
                    context,
                    'سياسة الخصوصية',
                    'نحن في تطبيق "ترتيبة ست البيت" نهتم بخصوصيتك. جميع بياناتك مخزنة محلياً على جهازك فقط ولا تتم مشاركتها مع أي جهة خارجية. نحن لا نجمع أي معلومات شخصية أو نستخدم أي أنظمة تتبع. يمكنك استخدام التطبيق بكل أمان وثقة.',
                  ),
                ),
                const SizedBox(height: 4),
                _PolicyTile(
                  icon: Icons.description_rounded,
                  title: 'شروط الاستخدام',
                  theme: theme,
                  onTap: () => _showPolicyDialog(
                    context,
                    'شروط الاستخدام',
                    'باستخدامك لتطبيق "ترتيبة ست البيت" فإنك توافق على هذه الشروط. التطبيق يقدم لأغراض التخطيط والتنظيم المنزلي فقط. نحن لا نتحمل مسؤولية أي قرارات تتخذ بناءً على المعلومات المقدمة في التطبيق. جميع المحتويات مقدمة "كما هي" دون أي ضمانات.',
                  ),
                ),
                const SizedBox(height: 4),
                _PolicyTile(
                  icon: Icons.star_rounded,
                  title: 'تقييم التطبيق',
                  theme: theme,
                  onTap: () => _showComingSoon(context),
                ),
                const SizedBox(height: 4),
                _PolicyTile(
                  icon: Icons.share_rounded,
                  title: 'مشاركة التطبيق مع العائلة',
                  theme: theme,
                  onTap: () => Share.share(
                    'جربي تطبيق "ترتيبة ست البيت" الرائع لتنظيم المنزل والمطبخ!',
                  ),
                ),
                const SizedBox(height: 4),
                _PolicyTile(
                  icon: Icons.info_outline_rounded,
                  title: 'إصدار التطبيق',
                  subtitle: 'v1.0.0',
                  theme: theme,
                  onTap: () {},
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: const BannerAdWidget(),
            ),
          ),
        ],
      ),
    );
  }

  void _showPolicyDialog(BuildContext context, String title, String body) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                body,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.8),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('موافق'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.star_rounded,
                size: 56,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              const Text(
                'قريباً في المتاجر!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'سيتم تفعيل خاصية التقييم عند إطلاق التطبيق في متجري Google Play و App Store.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('حسناً'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  final ThemeData theme;
  final bool isDark;
  const _SettingsHeader({required this.theme, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF3A1A4A), const Color(0xFF1C0F21)]
              : [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 24),
          child: Stack(
            children: [
              Positioned(
                right: 4,
                top: 0,
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward_rounded),
                  color: Colors.white,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Center(
                child: Text(
                  'الإعدادات',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final ThemeData theme;
  final bool isDark;
  const _ProfileCard({required this.theme, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF3A1A4A), const Color(0xFF24122E)]
              : [theme.colorScheme.primary.withValues(alpha: 0.08), theme.colorScheme.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.secondary.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [theme.colorScheme.primary, const Color(0xFF4A0E4E)]
                    : [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.person_rounded,
              color: theme.colorScheme.onPrimary,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'حساب ست البيت',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'النسخة الممتازة الكاملة (Offline Mode)',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  final ThemeController themeCtrl;
  final ThemeData theme;
  const _ThemeSelector({required this.themeCtrl, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _SectionTitle(title: 'سمة التطبيق', theme: theme),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ThemeCard(
                label: 'Midnight Rose',
                isActive: themeCtrl.themeIndex == 0,
                colors: const [Color(0xFF7B3F6E), Color(0xFF4A0E4E)],
                isDark: true,
                accentColor: const Color(0xFFE8B4B8),
                onTap: () => themeCtrl.switchTheme(0),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ThemeCard(
                label: 'Teal Premium',
                isActive: themeCtrl.themeIndex == 1,
                colors: [Colors.teal, Colors.teal.shade700],
                isDark: false,
                accentColor: Colors.teal.shade300,
                onTap: () => themeCtrl.switchTheme(1),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final String label;
  final bool isActive;
  final List<Color> colors;
  final bool isDark;
  final Color? accentColor;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.label,
    required this.isActive,
    required this.colors,
    required this.isDark,
    this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: theme.colorScheme.surface,
          border: Border.all(
            color: isActive
                ? (accentColor ?? colors.first)
                : theme.colorScheme.outline,
            width: isActive ? 2.5 : 1.5,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: (accentColor ?? colors.first).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: accentColor != null
                  ? Center(
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    )
                  : const SizedBox(),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive
                    ? (accentColor ?? colors.first)
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final ThemeData theme;
  const _SectionTitle({required this.title, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _PolicyTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final ThemeData theme;
  final VoidCallback onTap;

  const _PolicyTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: theme.colorScheme.surface,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          splashColor: theme.colorScheme.primary.withValues(alpha: 0.1),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: theme.colorScheme.secondary,
                  size: 24,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      if (subtitle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            subtitle!,
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_left_rounded,
                  color: theme.colorScheme.secondary,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
