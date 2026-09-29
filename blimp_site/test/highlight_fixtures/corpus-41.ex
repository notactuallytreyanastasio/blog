defmodule JobProcessor.CircuitBreaker do
  use GenServer

  def should_process_job?(job_type) do
    GenServer.call(__MODULE__, {:should_process, job_type})
  end

  def record_success(job_type) do
    GenServer.cast(__MODULE__, {:success, job_type})
  end

  def record_failure(job_type, error) do
    GenServer.cast(__MODULE__, {:failure, job_type, error})
  end

  def handle_call({:should_process, job_type}, _from, state) do
    circuit_state = Map.get(state.circuits, job_type, :closed)

    case circuit_state do
      :closed -> {:reply, true, state}
      :open ->
        if circuit_should_retry?(state, job_type) do
          {:reply, true, transition_to_half_open(state, job_type)}
        else
          {:reply, false, state}
        end
      :half_open -> {:reply, true, state}
    end
  end
end