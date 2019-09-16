#!/bin/bash
echo "Getting laravel........"
curl -L https://github.com/laravel/laravel/archive/5.7.zip > laravel.zip &&\
echo "Unzipping......"
find . -type f -name "*.zip" -exec unzip {} \; &&\
echo "Removing lavaravel zip file...."
find . -type f -name "*.zip" -exec rm -rf {} \; &&\
echo "Copy contents to current directory..."
cp -Rp -n $(pwd)/laravel-5.7/. $(pwd)
echo "Remove laravel folder......"
rm -rf $(pwd)/laravel-5.7
echo "Installing Vendors"
docker run --rm -v $(pwd):/app composer install
echo "Copy .env"
cp ./docker_config/jupyter.env .env
echo "Run the container...."

docker-compose up -d --build

echo "List all runnig containers"
docker ps
echo "Generate the fingerprint keys"
docker-compose exec web php artisan key:generate
echo "Cache the setting for speed.........."
docker-compose exec web php artisan config:cache
#for redis issues in memory
docker-compose exec echo never > /sys/kernel/mm/transparent_hugepage/enabled >> /etc/rc.local
echo "Run the yarn in the disposable container............"
docker run --rm -it -v $(pwd):/app -w /app node yarn
echo "Openning the browser.........."
open http://localhost
echo "Watch APP in dev mode..........."
docker run --rm -it -v $(pwd):/app -w /app node yarn dev
