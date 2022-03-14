import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../management/models.dart';

part 'models.freezed.dart';

enum Availability { enabled, disabled, unsupported }

enum SubPage { oath, fido, otp, piv, management }

extension SubPages on SubPage {
  String get displayName {
    switch (this) {
      case SubPage.oath:
        return 'Authenticator';
      case SubPage.fido:
        return 'WebAuthn';
      case SubPage.otp:
        return 'One-Time Passwords';
      case SubPage.piv:
        return 'Certificates';
      case SubPage.management:
        return 'Toggle applications';
    }
  }

  bool _inCapabilities(int capabilities) {
    switch (this) {
      case SubPage.oath:
        return Capability.oath.value & capabilities != 0;
      case SubPage.fido:
        return (Capability.u2f.value | Capability.fido2.value) & capabilities !=
            0;
      case SubPage.otp:
        return Capability.otp.value & capabilities != 0;
      case SubPage.piv:
        return Capability.piv.value & capabilities != 0;
      case SubPage.management:
        return true;
    }
  }

  Availability getAvailability(YubiKeyData data) {
    if (this == SubPage.management) {
      final version = data.info.version;
      final available = (version.major > 4 || // YK5 and up
          (version.major == 4 && version.minor >= 1) || // YK4.1 and up
          version.major == 3); // NEO
      // Management can't be disabled
      return available ? Availability.enabled : Availability.unsupported;
    }

    final int supported =
        data.info.supportedCapabilities[data.node.transport] ?? 0;
    final int enabled =
        data.info.config.enabledCapabilities[data.node.transport] ?? 0;

    return _inCapabilities(supported)
        ? (_inCapabilities(enabled)
            ? Availability.enabled
            : Availability.disabled)
        : Availability.unsupported;
  }
}

@freezed
class YubiKeyData with _$YubiKeyData {
  factory YubiKeyData(DeviceNode node, String name, DeviceInfo info) =
      _YubiKeyData;
}

const _listEquality = ListEquality();

class DevicePath {
  final List<String> segments;

  DevicePath(List<String> path) : segments = List.unmodifiable(path);

  @override
  bool operator ==(Object other) =>
      other is DevicePath && _listEquality.equals(segments, other.segments);

  @override
  int get hashCode => Object.hashAll(segments);
}

@freezed
class DeviceNode with _$DeviceNode {
  const DeviceNode._();
  factory DeviceNode.usbYubiKey(
      DevicePath path, String name, int pid, DeviceInfo? info) = UsbYubiKeyNode;
  factory DeviceNode.nfcReader(DevicePath path, String name) = NfcReaderNode;

  Transport get transport =>
      map(usbYubiKey: (_) => Transport.usb, nfcReader: (_) => Transport.nfc);
}

@freezed
class MenuAction with _$MenuAction {
  factory MenuAction(
      {required String text,
      required Widget icon,
      void Function(BuildContext context)? action}) = _MenuAction;
}

@freezed
class WindowState with _$WindowState {
  factory WindowState({
    required bool focused,
    required bool visible,
    required bool active,
  }) = _WindowState;
}
