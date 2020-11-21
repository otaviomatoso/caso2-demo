import os
from shutil import copyfile
from flask import Flask, request
from requests import post
import json, re, time

app = Flask(__name__)

# Global variables

# --- FUNCTIONS ---

@app.route('/run-as', methods=['POST'])
def runAs():
    # content = request.data
    # print(content)
    # print('\n')
    # print(content.decode('utf-8'))
    file = f'{request.get_data().decode("utf-8")}.as'
    print(file)
    src = f'{os.getcwd()}\\as\\{file}'
    os.chdir('../files')
    dst = f'{os.getcwd()}\\{file}'
    os.chdir('../fake-marlim')
    # print(dst)
    copyfile(src, dst)
    return file
    # return content.decode('utf-8')

app.run()
