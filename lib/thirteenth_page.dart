import 'package:flutter/material.dart';
import 'package:infertilityapp/app_ui.dart';

class ThirteenthPage extends StatelessWidget {
  const ThirteenthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Information',
      decor: BgDecor.soft,
      drawer: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
              decoration: const BoxDecoration(gradient: kBrandGradient),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.info_outline_rounded,
                        color: Colors.white, size: 28),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Information Menu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.article_outlined,
                  color: AppColors.primary),
              title: const Text('Guidelines',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.help_outline_rounded,
                  color: AppColors.primary),
              title: const Text('FAQ',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 12),
            const GradientIconBadge(
              icon: Icons.info_outline_rounded,
              size: 88,
              iconSize: 44,
            ),
            const SizedBox(height: 20),
            SectionCard(
              title: 'Fertility Health Resources',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Explore clinical information, guidance, and helpful tools designed to support each stage of patient care.',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
