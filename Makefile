APP = salmon-unselfish-aphid

.PHONY: logs console deploy server test

logs:
	gigalixir logs -a $(APP)

console:
	gigalixir ps:remote_console -a $(APP)

deploy:
	git push gigalixir main

server:
	mix phx.server

test:
	mix test
