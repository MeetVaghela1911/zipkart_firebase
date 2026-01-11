class SignInState  {
  String? error ;
  bool isLoading ;
  bool isSuccess ;

  SignInState({
    this.error,
    this.isLoading = false,
    this.isSuccess = false,
  });

  SignInState copyWith({
    String? error,
    bool? isLoading,
    bool? isSuccess,
  }) {
    return SignInState(
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

