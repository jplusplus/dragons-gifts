# Makefile -- DragonGifts

WEBAPP     = $(wildcard webapp.py)
BUILD_TIME = `date +%s`

run:
	. `pwd`/.env ; python $(WEBAPP)

install:
	virtualenv venv --no-site-packages --distribute --prompt=DragonGifts
	. `pwd`/.env ; pip install -r requirements.txt

freeze:
	# Remove everything but the .git direcotry 
	find ./build -type f -not -name '.git' | xargs
	# Freeze the flask app
	. `pwd`/.env ; python -c "from webapp import app; from flask_frozen import Freezer; freezer = Freezer(app); freezer.freeze()"
	rm build/static/.webassets-cache/ -r
	sed -i 's/\/static/static/g' build/index.html
	mv build/index.html build/home.html
	# One-line micro server with heroku
	echo '<?php include_once("home.html"); ?>' > build/index.php
	echo $(BUILD_TIME)
	# Commit changes
	cd build; \
		git add -A .; 
		git commit -am "Build "$(BUILD_TIME)

deploy:
	make freeze
	cd build; \
		git push heroku master

# EOF
