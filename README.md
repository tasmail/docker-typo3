# TYPO3 docker image contains TYPO3 7.6 with gd, freetype support and imagemagic

How to run container:
docker run --restart=always --name=typo3 -d -e VIRTUAL_HOST=typo3.test.com -v /var/www/html/typo3:/var/www/html --link=mysql:db typo3