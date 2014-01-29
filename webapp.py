#!/usr/bin/env python
# Encoding: utf-8
# -----------------------------------------------------------------------------
# Project : Dragons Gifts
# -----------------------------------------------------------------------------
# Author : Edouard Richard                                  <edou4rd@gmail.com>
# -----------------------------------------------------------------------------
# License : GNU Lesser General Public License
# -----------------------------------------------------------------------------
# Creation : 16-Jan-2014
# Last mod : 16-Jan-2014
# -----------------------------------------------------------------------------
from flask import Flask, render_template, request, send_file, \
	send_from_directory, Response, abort, session, redirect, url_for, make_response
from flask.ext.assets import Environment, Bundle, YAMLLoader

app = Flask(__name__)
app.config.from_pyfile("settings.cfg")
assets = Environment(app)

# js = Bundle('js.', 'base.js', 'widgets.js',
#             filters='jsmin', output='gen/packed.js')
# assets.register('js_all', js)
bundles = YAMLLoader("assets.yaml").load_bundles()
# css = Bundle('../assets/css/switchbutton.css',
#             output='gen/style.css')

assets.register(bundles)

# -----------------------------------------------------------------------------
#
# Site pages
#
# -----------------------------------------------------------------------------
@app.route('/')
def index():
	response = make_response(render_template('home.html'))
	return response

# -----------------------------------------------------------------------------
#
# Main
#
# -----------------------------------------------------------------------------
if __name__ == '__main__':
	# run application
	app.run(host="0.0.0.0", extra_files=("assets.yaml",))

# EOF
