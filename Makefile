dump: env-var
	docker-compose exec -T pgsql pg_dump -U "$(DBUSER)" -d "$(DBNAME)" | gzip > ./backups/oro_db_$(shell date +%Y_%m_%d_%H_%M_%S).gz

# make restore FILE=./backups/file.gz
restore: env-var $(if $(DUMP), dump) unset-db
	gunzip < $(FILE) | docker-compose exec -T pgsql psql -U "$(DBUSER)" -d "$(DBNAME)"

vendor: composer.lock
	rm -rf ./vendor
	symfony composer install --no-progress --prefer-dist --optimize-autoloader

env-var:
	$(eval DBPASS = $(shell symfony var:export ORO_DB_PASSWORD))
	$(eval DBUSER = $(shell symfony var:export ORO_DB_USER))
	$(eval DBNAME = $(shell symfony var:export ORO_DB_NAME))
	$(eval DBPORT = $(shell symfony var:export ORO_DB_PORT))
	$(eval DBHOST = $(shell symfony var:export ORO_DB_HOST))

composer.lock:
	COMPOSER_MEMORY_LIMIT=-1 symfony composer update