import 'dart:math';

import 'package:fl_clash/clash/clash.dart';
import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Widget currentProxyNameBuilder({
  required String groupName,
  required Widget Function(String) builder,
}) {
  return Selector2<AppState, Config, String>(
    selector: (_, appState, config) {
      final group = appState.getGroupWithName(groupName);
      return config.currentSelectedMap[groupName] ?? group?.now ?? '';
    },
    builder: (_, value, ___) {
      return builder(value);
    },
  );
}

double get listHeaderHeight {
  final measure = globalState.appController.measure;
  return 24 + measure.titleMediumHeight + 4 + measure.bodyMediumHeight;
}

double getItemHeight(ProxyCardType proxyCardType) {
  final measure = globalState.appController.measure;
  final baseHeight =
      12 * 2 + measure.bodyMediumHeight * 2 + measure.bodySmallHeight + 8;
  return switch (proxyCardType) {
    ProxyCardType.expand => baseHeight + measure.labelSmallHeight + 8,
    ProxyCardType.shrink => baseHeight,
    ProxyCardType.min => baseHeight - measure.bodyMediumHeight,
  };
}

delayTest(List<Proxy> proxies) async {
  final appController = globalState.appController;
  for (final proxy in proxies) {
    final proxyName =
        appController.appState.getRealProxyName(proxy.name) ?? proxy.name;
    globalState.appController.setDelay(
      Delay(
        name: proxyName,
        value: 0,
      ),
    );
    clashCore.getDelay(proxyName).then((delay) {
      globalState.appController.setDelay(delay);
    });
  }
  await Future.delayed(httpTimeoutDuration + moreDuration);
  appController.appState.sortNum++;
}

double getScrollToSelectedOffset({
  required String groupName,
  required List<Proxy> proxies,
}) {
  final appController = globalState.appController;
  final columns = appController.columns;
  final proxyCardType = appController.config.proxyCardType;
  final selectedName = appController.getCurrentSelectedName(groupName);
  final findSelectedIndex = proxies.indexWhere(
    (proxy) => proxy.name == selectedName,
  );
  final selectedIndex = findSelectedIndex != -1 ? findSelectedIndex : 0;
  final rows = ((selectedIndex - 1) / columns).ceil();
  return max(rows * (getItemHeight(proxyCardType) + 8) - 8, 0);
}
