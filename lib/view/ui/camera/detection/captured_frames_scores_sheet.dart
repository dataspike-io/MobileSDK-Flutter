import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/domain/models/states/upload_image_state_v2.dart';
import 'package:dataspikemobilesdk/face_detector/captured_frames_scorer.dart';
import 'ml_scores_overlay.dart';

/// Debug: shown instead of the regular liveness result when
/// `DataspikeDependencies.showCapturedFrameScores` is on — the on-device ML
/// scores of every captured photo plus the server verdict.
class CapturedFramesScoresSheet extends StatelessWidget {
  const CapturedFramesScoresSheet({
    super.key,
    required this.frames,
    required this.serverResult,
  });

  final List<CapturedFrameScore> frames;

  /// Null when nothing was sent (dry run).
  final UploadImageStateV2? serverResult;

  bool get _passed => serverResult is UploadImageSuccessV2;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.9;
    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Final scores · ${frames.length} photos',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: MlScoresPanel(child: _ServerVerdict(serverResult)),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: frames.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _FrameCard(index: i, frame: frames[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(_passed ? 'Continue' : 'Try again'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServerVerdict extends StatelessWidget {
  const _ServerVerdict(this.result);

  final UploadImageStateV2? result;

  @override
  Widget build(BuildContext context) {
    final r = result;
    final lines = <Widget>[];
    if (r == null) {
      lines.add(
        MlScoresDetails.row([
          MlScoresDetails.label('server  '),
          MlScoresDetails.value('not sent (dry run)'),
        ]),
      );
    } else if (r is UploadImageSuccessV2) {
      lines.add(
        MlScoresDetails.row([
          MlScoresDetails.label('server  '),
          MlScoresDetails.check('passed', true),
          MlScoresDetails.label('  ${r.documentIds.length} documents'),
        ]),
      );
    } else if (r is UploadImageErrorV2) {
      lines.add(
        MlScoresDetails.row([
          MlScoresDetails.label('server  '),
          MlScoresDetails.error('rejected ${r.code}'),
          MlScoresDetails.label('  ${r.message}'),
        ]),
      );
      for (final e in r.framesErrors) {
        lines.add(
          MlScoresDetails.row([
            MlScoresDetails.label('  batch '),
            MlScoresDetails.error('${e.code}'),
            MlScoresDetails.label(' ${e.message}'),
          ]),
        );
      }
      // Order as returned by the server; it covers only the frames the
      // model returned a breakdown for.
      for (final f in r.framesResults) {
        final id = f.documentId ?? '?';
        final shortId = id.length > 8 ? id.substring(id.length - 8) : id;
        lines.add(
          MlScoresDetails.row([
            MlScoresDetails.label('  frame …$shortId '),
            if (f.errors.isEmpty)
              MlScoresDetails.check('ok', true)
            else
              MlScoresDetails.error(
                f.errors.map((e) => '${e.code} ${e.message}').join('; '),
              ),
          ]),
        );
      }
    } else {
      lines.add(
        MlScoresDetails.row([
          MlScoresDetails.label('server  '),
          MlScoresDetails.error('unexpected response'),
        ]),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: lines,
    );
  }
}

class _FrameCard extends StatelessWidget {
  const _FrameCard({required this.index, required this.frame});

  final int index;
  final CapturedFrameScore frame;

  @override
  Widget build(BuildContext context) {
    return MlScoresPanel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.memory(
              frame.jpeg,
              width: 72,
              fit: BoxFit.cover,
              gaplessPlayback: true,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MlScoresDetails.row([
                  MlScoresDetails.value('photo ${index + 1}'),
                  MlScoresDetails.label('  ${frame.width}×${frame.height}'),
                ]),
                MlScoresDetails(
                  result: frame.result,
                  faceAreaFraction: frame.faceAreaFraction,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
