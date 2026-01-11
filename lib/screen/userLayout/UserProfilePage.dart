import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

class ProfileState {
  final bool isLoading;
  final bool isEditing;
  final String name;
  final String email;
  final String imageUrl;

  const ProfileState({
    this.isLoading = true,
    this.isEditing = false,
    this.name = '',
    this.email = '',
    this.imageUrl = '',
  });

  ProfileState copyWith({
    bool? isLoading,
    bool? isEditing,
    String? name,
    String? email,
    String? imageUrl,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      isEditing: isEditing ?? this.isEditing,
      name: name ?? this.name,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

final profileControllerProvider =
StateNotifierProvider<ProfileController, ProfileState>(
      (ref) => ProfileController(),
);

class ProfileController extends StateNotifier<ProfileState> {
  ProfileController() : super(const ProfileState()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    await Future.delayed(const Duration(seconds: 2)); // simulate API
    state = state.copyWith(
      isLoading: false,
      name: 'Meet Vaghel',
      email: 'meet@email.com',
    );
  }

  void toggleEdit() {
    state = state.copyWith(isEditing: !state.isEditing);
  }

  void updateName(String value) {
    state = state.copyWith(name: value);
  }

  Future<void> saveProfile() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1)); // simulate save
    state = state.copyWith(isLoading: false, isEditing: false);
  }
}

class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: [
          const CircleAvatar(radius: 50),
          const SizedBox(height: 24),
          Container(height: 48, width: double.infinity, color: Colors.white),
          const SizedBox(height: 16),
          Container(height: 48, width: double.infinity, color: Colors.white),
        ],
      ),
    );
  }
}

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileControllerProvider);
    final controller = ref.read(profileControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(state.isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              state.isEditing
                  ? controller.saveProfile()
                  : controller.toggleEdit();
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 900;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: state.isLoading
                    ? const ProfileShimmer()
                    : Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child:  Column(
                      children: [
                        _Avatar(state),
                        const SizedBox(height: 24),
                        _ProfileForm(state, controller),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
class _Avatar extends StatelessWidget {
  final ProfileState state;
  const _Avatar(this.state);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 55,
          backgroundImage:
          state.imageUrl.isNotEmpty ? NetworkImage(state.imageUrl) : null,
          child: state.imageUrl.isEmpty
              ? const Icon(Icons.person, size: 55)
              : null,
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            // connect image_picker + firebase storage here
          },
          child: const Text('Change Photo'),
        ),
      ],
    );
  }
}
class _ProfileForm extends StatelessWidget {
  final ProfileState state;
  final ProfileController controller;

  const _ProfileForm(this.state, this.controller);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          initialValue: state.name,
          enabled: state.isEditing,
          decoration: const InputDecoration(
            labelText: 'Full Name',
            border: OutlineInputBorder(),
          ),
          onChanged: controller.updateName,
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: state.email,
          enabled: false,
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}


