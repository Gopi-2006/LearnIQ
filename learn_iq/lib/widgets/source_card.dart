import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/doubt_response.dart';

class SourceCard extends StatelessWidget {
  final DoubtSource source;

  const SourceCard({
    super.key,
    required this.source,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        tileColor: const Color(0xFF151923),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
        title: Text(
          source.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13.5,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              if (source.domain != null)
                Text(
                  source.domain!,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11.5,
                  ),
                ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.cyanAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Colors.cyanAccent.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'VIEW SOURCE',
                      style: TextStyle(
                        color: Colors.cyanAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.open_in_new,
                      color: Colors.cyanAccent,
                      size: 11,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        onTap: () async {
          final uri = Uri.tryParse(source.url);
          if (uri != null) {
            try {
              await launchUrl(
                uri,
                mode: LaunchMode.externalApplication,
              );
            } catch (_) {}
          }
        },
      ),
    );
  }
}
