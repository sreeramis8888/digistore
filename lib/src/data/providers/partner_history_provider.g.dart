// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'partner_history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PartnerHistory)
final partnerHistoryProvider = PartnerHistoryProvider._();

final class PartnerHistoryProvider
    extends $NotifierProvider<PartnerHistory, PartnerHistoryState> {
  PartnerHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'partnerHistoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$partnerHistoryHash();

  @$internal
  @override
  PartnerHistory create() => PartnerHistory();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PartnerHistoryState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PartnerHistoryState>(value),
    );
  }
}

String _$partnerHistoryHash() => r'b16f757a24ba6cbf39b1046b7d6ef8731bc98977';

abstract class _$PartnerHistory extends $Notifier<PartnerHistoryState> {
  PartnerHistoryState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PartnerHistoryState, PartnerHistoryState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PartnerHistoryState, PartnerHistoryState>,
              PartnerHistoryState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
