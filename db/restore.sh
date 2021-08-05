if [ -z "$1" ]
then
  echo "No dump file argument supplied, example: $0 db/dumps/dump.pgc"
  exit 1
fi
rails db:drop db:create &&
  pg_restore -vd klarschiff_backoffice_development $1
bin/rails db:environment:set RAILS_ENV=development
