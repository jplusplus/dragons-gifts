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
	find ./build -not -path "./build/.git*" -not -path "./build" | xargs rm -rf
	# Freeze the flask app
	. `pwd`/.env ; python -c "from webapp import app; from flask_frozen import Freezer; freezer = Freezer(app); freezer.freeze()"
	rm build/static/.webassets-cache/ -r
	sed -i 's/\/static/static/g' build/index.html

# EOF
