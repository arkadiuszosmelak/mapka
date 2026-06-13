import 'package:app/routing/app_routes.dart';
import 'package:app/routing/guards/onboarding_guard.dart';
import 'package:core/core.dart';
import 'package:f_onboarding/f_onboarding.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'onboarding_guard_test.mocks.dart';

@GenerateNiceMocks(<MockSpec<dynamic>>[
  MockSpec<OnboardingService>(),
  MockSpec<GoRouterState>(),
])
void main() {
  late MockOnboardingService service;
  late OnboardingGuard guard;

  setUp(() {
    service = MockOnboardingService();
    guard = OnboardingGuard(service);
  });

  GoRouterState stateAt(String location) {
    final MockGoRouterState state = MockGoRouterState();
    when(state.matchedLocation).thenReturn(location);
    return state;
  }

  test('redirects an onboarding route to home once completed', () async {
    when(service.isCompleted()).thenAnswer((_) async => true);

    final RouteDefinition? result = await guard(stateAt(OnboardingRoutes.intro.path));

    expect(result, AppRoutes.home);
  });

  test('allows onboarding while it is not completed', () async {
    when(service.isCompleted()).thenAnswer((_) async => false);

    final RouteDefinition? result = await guard(stateAt(OnboardingRoutes.intro.path));

    expect(result, isNull);
  });

  test('ignores routes outside onboarding without touching the service', () async {
    final RouteDefinition? result = await guard(stateAt(AppRoutes.home.path));

    expect(result, isNull);
    verifyNever(service.isCompleted());
  });
}
