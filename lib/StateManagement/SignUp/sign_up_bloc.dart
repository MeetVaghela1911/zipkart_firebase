// import 'package:flutter_bloc/flutter_bloc.dart';

//
// class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
//   final UserApiService apiService;
//
//   SignUpBloc({required this.apiService}) : super(SignUpInitial()) {
//     on<SignUpSubmitted>((event, emit) async {
//       emit(SignUpLoading());
//
//       try {
//         // Call the API using ApiService
//         final response = await apiService.registerUser(
//           name: event.name,
//           email: event.email,
//           password: event.password,
//           role: event.role, // Replace with dynamic role if needed
//           phoneNumber: event.phoneNumber,
//           imagePath: event.imagePath,
//         );
//
//         if (response.statusCode == 201) {
//           emit(SignUpSuccess());
//         } else {
//           emit(SignUpFailure(error: 'Failed to register user'));
//         }
//       }
//       catch (e) {
//         emit(SignUpFailure(error: 'Error during registration1: $e'));
//       }
//     });
//   }
// }
//
// abstract class SignUpEvent {}
//
// class SignUpSubmitted extends SignUpEvent {
//   final String name;
//   final String email;
//   final String password;
//   final String phoneNumber;
//   final String role;
//   final String imagePath;
//
//   SignUpSubmitted({
//     required this.name,
//     required this.email,
//     required this.password,
//     required this.phoneNumber,
//     required this.role,
//     required this.imagePath,
//   });
// }
//
// abstract class SignUpState {}
//
// class SignUpInitial extends SignUpState {}
//
// class SignUpLoading extends SignUpState {}
//
// class SignUpSuccess extends SignUpState {}
//
// class SignUpFailure extends SignUpState {
//   final String error;
//
//   SignUpFailure({required this.error});
// }
