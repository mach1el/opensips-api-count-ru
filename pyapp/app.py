#!/usr/bin/env python3

import psycopg2
import configparser
from flask import abort
from flask import make_response
from flask import Flask, request, jsonify

app = Flask(__name__)
parser = configparser.ConfigParser()
parser.read('servers')

def count(data):
  filter = ['200','408','486','487','600']
  counted = [code[0] for code in data if code[0] in filter]
  return len(counted)


def request_db(requester,extension):
  try:
    node = parser['node']
    conn = psycopg2.connect(
      host     = node['db_host'],
      port     = node['db_port'],
      user     = node['db_user'],
      password = node['db_password'],
      database = node['db_name']
    )
    cur = conn.cursor()
    cur.execute("select sip_code from acc where exten='%s'" % extension)
    data = cur.fetchall()
    return count(data)

  except: abort(404)

@app.errorhandler(404)
def not_found(error):
	return make_response(jsonify({'error' : 'Not found'}), 404)

@app.route('/check',methods=['GET'])
def checker():
  args = request.args
  requester = args.get('from')
  phone_num = args.get('extension')
  resp = request_db(requester,phone_num)
  if resp >= 6:
    return make_response(jsonify({'status' : 'FAILED'}),504)
  else:
    return make_response(jsonify({'status' : 'PASSED'}),200)

if __name__ == '__main__':
	app.run(host="0.0.0.0",port=2000,debug=True)