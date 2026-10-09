import 'package:flutter/foundation.dart';
import 'package:flutter_period_tracker/core/providers.dart';
import 'package:flutter_period_tracker/core/services/notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/hygiene_product.dart';

@immutable
class HygieneTimerState {
  const HygieneTimerState({required this.product, this.endsAt});

  final HygieneProduct product;

  /// A lejárat időpontja; `null`, ha nem fut időzítő.
  final DateTime? endsAt;

  bool get isActive => endsAt != null;

  Duration remaining(DateTime now) {
    final end = endsAt;
    if (end == null) return product.defaultDuration;
    final left = end.difference(now);
    return left.isNegative ? Duration.zero : left;
  }
}

/// Az időzítő a lejárati időponttal él (nem másodpercszámlálóval), ezért
/// túléli a képernyő elhagyását és az app újraindítását is. A lejáratkor
/// az operációs rendszer küldi az értesítést.
class HygieneTimerNotifier extends Notifier<HygieneTimerState> {
  static const _productKey = 'hygiene_product';
  static const _endsAtKey = 'hygiene_ends_at';

  @override
  HygieneTimerState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final product = HygieneProduct.values
            .asNameMap()[prefs.getString(_productKey)] ??
        HygieneProduct.pad;
    final ms = prefs.getInt(_endsAtKey);
    return HygieneTimerState(
      product: product,
      endsAt: ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms),
    );
  }

  Future<void> selectProduct(HygieneProduct product) async {
    if (state.isActive) return;
    await ref.read(sharedPreferencesProvider).setString(_productKey, product.name);
    state = HygieneTimerState(product: product);
  }

  Future<void> start() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final endsAt = DateTime.now().add(state.product.defaultDuration);
    await prefs.setString(_productKey, state.product.name);
    await prefs.setInt(_endsAtKey, endsAt.millisecondsSinceEpoch);
    final notifications = ref.read(notificationServiceProvider);
    await notifications.requestPermission();
    await notifications.scheduleOnce(
      id: NotificationIds.hygieneTimer,
      title: 'Emlékeztető',
      body: 'Eltelt a beállított idő, ideje cserélni vagy tisztítani.',
      at: endsAt,
    );
    state = HygieneTimerState(product: state.product, endsAt: endsAt);
  }

  Future<void> stop() async {
    await ref.read(sharedPreferencesProvider).remove(_endsAtKey);
    await ref.read(notificationServiceProvider).cancel(NotificationIds.hygieneTimer);
    state = HygieneTimerState(product: state.product);
  }
}

final hygieneTimerProvider =
    NotifierProvider<HygieneTimerNotifier, HygieneTimerState>(
  HygieneTimerNotifier.new,
);
