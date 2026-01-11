class LogInState  {
  String? error ;
  bool isLoading ;
  bool isSuccess ;

  LogInState({
    this.error,
    this.isLoading = false,
    this.isSuccess = false,
  });

  LogInState copyWith({
    String? error,
    bool? isLoading,
    bool? isSuccess,
  }) {
    return LogInState(
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

