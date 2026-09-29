# Send an email
JobQueue.enqueue(MyApp.Mailer, :send_welcome_email, [user_id: 123])

# Process an image
JobQueue.enqueue(MyApp.ImageProcessor, :resize_image, ["/path/to/image.jpg", 300, 200])

# Call an API
JobQueue.enqueue(MyApp.ApiClient, :sync_user_data, [user_id: 456])

# Even complex data structures
JobQueue.enqueue(MyApp.ReportGenerator, :generate_report, [%{
  user_id: 789,
  date_range: Date.range(~D[2024-01-01], ~D[2024-01-31]),
  format: :pdf
}])