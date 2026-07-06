import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/user_service.dart';
import '../models/profile_model.dart';

final userServiceProvider = Provider<UserService>((ref) => UserService());

final allUsersProvider = FutureProvider<List<Profile>>((ref) async {
  return ref.read(userServiceProvider).getAllUsers();
});

final helpdeskUsersProvider = FutureProvider<List<Profile>>((ref) async {
  return ref.read(userServiceProvider).getHelpdeskUsers();
});