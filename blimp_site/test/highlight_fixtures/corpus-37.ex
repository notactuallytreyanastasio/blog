# High-priority user-facing jobs
JobQueue.enqueue(:email_queue, Mailer, :send_welcome_email, [user_id])

# Background data processing
JobQueue.enqueue(:analytics_queue, Analytics, :process_events, [batch_id])

# Heavy computational work
JobQueue.enqueue(:ml_queue, ModelTrainer, :train_model, [dataset_id])