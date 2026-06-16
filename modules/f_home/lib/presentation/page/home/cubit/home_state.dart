import 'package:d_location/d_location.dart';
import 'package:equatable/equatable.dart';

enum LocationTrackingStatus { initial, requesting, tracking, denied, disabled }

class HomeState extends Equatable {
  const HomeState({
    this.status = LocationTrackingStatus.initial,
    this.location,
    this.isFollowing = true,
  });

  final LocationTrackingStatus status;
  final UserLocation? location;

  final bool isFollowing;

  HomeState copyWith({LocationTrackingStatus? status, UserLocation? location, bool? isFollowing}) {
    return HomeState(
      status: status ?? this.status,
      location: location ?? this.location,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }

  @override
  List<Object?> get props => <Object?>[status, location, isFollowing];
}
