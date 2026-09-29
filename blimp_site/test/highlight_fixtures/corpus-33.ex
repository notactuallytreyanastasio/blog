{module, function, args} = Job.decode_job(payload)
result = apply(module, function, args)