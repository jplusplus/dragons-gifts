# Makefile -- DragonGifts

WEBAPP     = $(wildcard webapp.py)

run:
	. `pwd`/.env ; python $(WEBAPP)

install:
	virtualenv venv --no-site-packages --distribute --prompt=DragonGifts
	. `pwd`/.env ; pip install -r requirements.txt

freeze:
	. `pwd`/.env ; python -c "from webapp import app; from flask_frozen import Freezer; freezer = Freezer(app); freezer.freeze()"
	rm build/static/.webassets-cache/ -r
	sed -i 's/\/static/static/g' build/index.html

# EOF
