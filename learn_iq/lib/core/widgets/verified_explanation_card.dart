import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/verified_python_explanation_service.dart';
import '../theme/app_theme.dart';

class VerifiedExplanationCard extends StatelessWidget {
  final VerifiedExplanationResult result;
  final VoidCallback? onRetry;
  final bool isCompact;

  const VerifiedExplanationCard({
    super.key,
    required this.result,
    this.onRetry,
    this.isCompact = false,
  });

  Future<void> _launchSourceUrl(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      try {
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!launched && context.mounted) {
          Clipboard.setData(ClipboardData(text: url));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Source URL copied to clipboard: $url'),
              backgroundColor: AppColors.iqooCyan,
            ),
          );
        }
      } catch (_) {
        if (context.mounted) {
          Clipboard.setData(ClipboardData(text: url));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Source URL copied: $url'),
              backgroundColor: AppColors.iqooCyan,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (result.isOffline) {
      return _buildOfflineCard(context);
    }

    if (result.isUnverified) {
      return _buildUnverifiedCard(context);
    }

    return _buildVerifiedCard(context);
  }

  Widget _buildVerifiedCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isCompact ? 12 : 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.duolingoGreen.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.duolingoGreen.withValues(alpha: 0.1),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Status Badge & Subject / Version Tag
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.duolingoGreen.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.duolingoGreen.withValues(alpha: 0.4)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, size: 13, color: AppColors.duolingoGreen),
                    SizedBox(width: 4),
                    Text(
                      'WEB SEARCH VERIFIED',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: AppColors.duolingoGreen,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  result.subject.isNotEmpty ? result.subject : result.pythonVersion,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.iqooCyan,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Question context if present and not compact
          if (!isCompact && result.question.isNotEmpty) ...[
            Text(
              result.question,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Verified Explanation Body
          Text(
            result.explanation,
            style: TextStyle(
              fontSize: isCompact ? 12.5 : 13.5,
              height: 1.5,
              color: AppColors.textPrimary,
            ),
          ),

          // Code example if available
          if (result.codeExample != null && result.codeExample!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1117),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: SelectableText(
                result.codeExample!,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  color: AppColors.iqooCyan,
                  height: 1.45,
                ),
              ),
            ),
          ],

          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 10),

          // Source attribution and clickable [View Source ↗]
          if (result.sources != null && result.sources!.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: result.sources!.take(3).map((src) {
                return InkWell(
                  onTap: () => _launchSourceUrl(context, src.url),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.link, size: 12, color: AppColors.iqooCyan),
                        const SizedBox(width: 4),
                        Text(
                          src.domain,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Icon(Icons.open_in_new, size: 10, color: AppColors.iqooCyan),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ] else ...[
            Row(
              children: [
                const Icon(Icons.menu_book, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Source: ${result.sourceTitle ?? "Technical Documentation"}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (result.sourceUrl != null) ...[
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _launchSourceUrl(context, result.sourceUrl!),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.iqooCyan.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.iqooCyan.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View Source',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.iqooCyan,
                            ),
                          ),
                          SizedBox(width: 3),
                          Icon(Icons.open_in_new, size: 11, color: AppColors.iqooCyan),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOfflineCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.xpAmber.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.xpAmber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.wifi_off, size: 18, color: AppColors.xpAmber),
              ),
              const SizedBox(width: 10),
              Text(
                result.title.isNotEmpty ? result.title : "NO INTERNET CONNECTION",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                  color: AppColors.xpAmber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            result.explanation,
            style: const TextStyle(fontSize: 13, height: 1.5, color: AppColors.textSecondary),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              height: 38,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('RECONNECT & RETRY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.xpAmber,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: onRetry,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUnverifiedCard(BuildContext context) {
    Color themeColor;
    IconData statusIcon;
    String retryLabel;

    switch (result.status) {
      case VerificationStatus.searchFailed:
        themeColor = AppColors.iqooCyan;
        statusIcon = Icons.cloud_off_rounded;
        retryLabel = 'RETRY SEARCH';
        break;
      case VerificationStatus.sourceNotFound:
        themeColor = AppColors.xpAmber;
        statusIcon = Icons.search_off_rounded;
        retryLabel = 'RETRY SEARCH';
        break;
      case VerificationStatus.verificationFailed:
        themeColor = AppColors.misconceptionRed;
        statusIcon = Icons.shield_outlined;
        retryLabel = 'RETRY VERIFICATION';
        break;
      default:
        themeColor = AppColors.misconceptionRed;
        statusIcon = Icons.warning_amber_rounded;
        retryLabel = 'RETRY SEARCH';
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeColor.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: themeColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(statusIcon, size: 18, color: themeColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  result.title.isNotEmpty && !result.title.toUpperCase().contains('UNABLE TO VERIFY')
                      ? result.title
                      : 'NEED MORE CONTEXT',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                    color: themeColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            result.explanation,
            style: const TextStyle(fontSize: 13, height: 1.5, color: AppColors.textSecondary),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              height: 38,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.refresh, size: 16),
                label: Text(retryLabel, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  foregroundColor: themeColor == AppColors.iqooCyan || themeColor == AppColors.xpAmber
                      ? Colors.black
                      : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: onRetry,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A compact badge showing verified Python source attribution with an external link button
class VerifiedSourceBadge extends StatelessWidget {
  final String sourceTitle;
  final String sourceUrl;
  final String pythonVersion;

  const VerifiedSourceBadge({
    super.key,
    this.sourceTitle = 'Python Documentation',
    this.sourceUrl = 'https://docs.python.org/3/tutorial/introduction.html',
    this.pythonVersion = 'Python 3.13',
  });

  Future<void> _launchUrl(BuildContext context) async {
    final uri = Uri.tryParse(sourceUrl);
    if (uri != null) {
      try {
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!launched && context.mounted) {
          Clipboard.setData(ClipboardData(text: sourceUrl));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Source URL copied: $sourceUrl'),
              backgroundColor: AppColors.iqooCyan,
            ),
          );
        }
      } catch (_) {
        if (context.mounted) {
          Clipboard.setData(ClipboardData(text: sourceUrl));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Source URL copied: $sourceUrl'),
              backgroundColor: AppColors.iqooCyan,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified, size: 13, color: AppColors.duolingoGreen),
          const SizedBox(width: 5),
          Text(
            pythonVersion,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.duolingoGreen,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Source: $sourceTitle',
              style: const TextStyle(
                fontSize: 10.5,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          InkWell(
            onTap: () => _launchUrl(context),
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.iqooCyan.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.iqooCyan.withValues(alpha: 0.3)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View Source',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.iqooCyan,
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(Icons.open_in_new, size: 9.5, color: AppColors.iqooCyan),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
