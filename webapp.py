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
import os

app = Flask(__name__)
app.config.from_pyfile("settings.cfg")

assets = Environment(app)
bundles = YAMLLoader("assets.yaml").load_bundles()
assets.register(bundles)


def get_static_files():
	return map(lambda _: "static/images/" + _, os.listdir(os.path.join("static", "images")))

# -----------------------------------------------------------------------------
#
# Site pages
#
# -----------------------------------------------------------------------------
@app.route('/')
def index():
	response = make_response(render_template('home.html', files_to_preload=get_static_files()))
	return response

# -----------------------------------------------------------------------------
#
# Main
#
# -----------------------------------------------------------------------------
if __name__ == '__main__':
	# run application
	app.run(host="0.0.0.0", extra_files=("assets.yaml"))

# EOF
