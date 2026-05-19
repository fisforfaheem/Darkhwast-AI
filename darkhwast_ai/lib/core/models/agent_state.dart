enum AgentStatus { idle, loading, complete, error }

class AgentState<T> {
  final AgentStatus status;
  final T? result;
  final String? agentMessage;
  final String? errorMessage;
  final List<String> facts;
  final DateTime? startedAt;
  final DateTime? completedAt;

  const AgentState({
    this.status = AgentStatus.idle,
    this.result,
    this.agentMessage,
    this.errorMessage,
    this.facts = const [],
    this.startedAt,
    this.completedAt,
  });

  bool get isLoading => status == AgentStatus.loading;
  bool get isComplete => status == AgentStatus.complete;
  bool get isError => status == AgentStatus.error;

  int? get durationMs {
    if (startedAt == null || completedAt == null) return null;
    return completedAt!.difference(startedAt!).inMilliseconds;
  }

  AgentState<T> copyWith({
    AgentStatus? status,
    T? result,
    String? agentMessage,
    String? errorMessage,
    List<String>? facts,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return AgentState<T>(
      status: status ?? this.status,
      result: result ?? this.result,
      agentMessage: agentMessage ?? this.agentMessage,
      errorMessage: errorMessage ?? this.errorMessage,
      facts: facts ?? this.facts,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  factory AgentState.idle() => const AgentState(status: AgentStatus.idle);

  factory AgentState.loading(String message) => AgentState(
        status: AgentStatus.loading,
        agentMessage: message,
        startedAt: DateTime.now(),
      );

  factory AgentState.complete(
    T result, {
    String? message,
    List<String> facts = const [],
    DateTime? startedAt,
  }) {
    final done = DateTime.now();
    return AgentState(
      status: AgentStatus.complete,
      result: result,
      agentMessage: message,
      facts: facts,
      startedAt: startedAt,
      completedAt: done,
    );
  }

  factory AgentState.error(String message, {DateTime? startedAt}) => AgentState(
        status: AgentStatus.error,
        errorMessage: message,
        agentMessage: message,
        startedAt: startedAt,
        completedAt: DateTime.now(),
      );
}
