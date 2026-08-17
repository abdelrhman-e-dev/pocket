import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../transactions/models/activity_item.dart';
import '../../transactions/providers/activity_provider.dart';

final accountActivityProvider =
    FutureProvider.family<List<ActivityItem>, int>((ref, accountId) async {
  final activities = await ref.watch(activityProvider.future);

  return activities.where((activity) {
    if (activity.type == ActivityType.transaction) {
      return activity.transaction!.account.id == accountId;
    }

    final transfer = activity.transfer!;

    return transfer.fromAccount.id == accountId ||
        transfer.toAccount.id == accountId;
  }).toList();
});