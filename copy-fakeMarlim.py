import os
from shutil import copyfile
from flask import Flask, request
from requests import post
import json, re, time

app = Flask(__name__)

# Global variables
url_base = 'http://192.168.1.106:8080/' # jacamo-rest address
my_address = 'http://0.0.0.0:5000'
art_name = 'a'
art_id = 1
msg_id = 1
result = False
res = ''

# --- FUNCTIONS ---
def create_agent():
    endpoint = 'agents/proxy'
    url = url_base + endpoint
    response = post(url)
    name = re.findall(r"'([^']*)'", response.text)[0]
    return name

def create_msg(sender,receiver,performative,content,msgId):
    msg = json.dumps({"sender": f"{sender}", "receiver": f"{receiver}", "performative": f"{performative}", "content": f"{content}", "msgId": f"{msgId}"})
    return msg

def send_msg(message, agent):
    endpoint = f'agents/{agent}/mb'
    url = url_base + endpoint
    headers = {'Content-Type':'application/json'}
    post(url, headers=headers, data=message)

def process_content(content):
    d = dict();
    d['functor'] = content[0:content.find('(')]
    d['args'] = content[len(d['functor'])+1:len(content)-1]
    return d

def proxy_agent(price):
    global msg_id
    my_name = create_agent()
    content = f'offer({price},\"{my_address}\")'
    msg = create_msg(my_name, my_name, 'tell', content, msg_id)
    send_msg(msg, my_name) # tell the agent my 'offer(price,address)''
    msg_id += 1

@app.route('/auction', methods=['POST'])
def auction():
    global msg_id, art_id, result
    body = json.loads(request.data)
    price = body['offer']
    task = body['task']
    proxy_agent(price)
    msg2 = create_msg("python", 'bob', 'achieve', f'start({art_name+str(art_id)}, {task})', msg_id)
    send_msg(msg2,'bob') # ask auctioneer (bob) to start a new auction
    art_id += 1
    msg_id += 1
    # global result
    while (result == False):
        pass
    result = False
    return f'Your proposal {price} {res} the auction for {task}'

@app.route('/run-as', methods=['POST'])
def runAs():
    msg = json.loads(request.data)
    print(f'RESPOSTA: \n{msg}')
    # content = msg['content']
    # literal = process_content(content)
    # global res, result
    # res = literal["args"]
    # result = True
    cwd = os.getcwd()
    print(cwd)
    # src = f'{cwd}/as/{file}.as'
    src = '/as/a.as'
    dst = '/../file/as/a.as'
    # dst = 'path/to/new/destination/for/file.foo'
    copyfile(src, dst)
    print('final')
    return 'ok'
