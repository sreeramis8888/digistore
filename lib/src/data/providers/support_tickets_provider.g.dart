// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_tickets_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SupportTickets)
final supportTicketsProvider = SupportTicketsProvider._();

final class SupportTicketsProvider
    extends $NotifierProvider<SupportTickets, SupportTicketsState> {
  SupportTicketsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'supportTicketsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$supportTicketsHash();

  @$internal
  @override
  SupportTickets create() => SupportTickets();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SupportTicketsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SupportTicketsState>(value),
    );
  }
}

String _$supportTicketsHash() => r'4430872ce0dfcce3e2687d34d4cccd6fd6d18290';

abstract class _$SupportTickets extends $Notifier<SupportTicketsState> {
  SupportTicketsState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SupportTicketsState, SupportTicketsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SupportTicketsState, SupportTicketsState>,
              SupportTicketsState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
