.PHONY: test

test:
	docker-compose run --rm -e "RAILS_ENV=test" web rake test
