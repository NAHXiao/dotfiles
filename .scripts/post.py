#!/usr/bin/env python3
import json
import sys
from os import path
if len(sys.argv)==1:
    dir='.'
else:
    dir=sys.argv[1]
output='run.py' if dir == '.' else f'{dir}.py'
request=json.load(open(path.join(dir,"request.json")))
body=json.load(open(path.join(dir,"request_body.json")))

headers=request["headers"]
url=request["url"]
method=request["method"]

prestr='''from collections import namedtuple
from typing import Callable
import requests
Result = namedtuple('Result', ['response', 'result'])
def post(url:str, headers:dict,
         data:dict, trytime:int=10,
         target:Callable[[requests.Response],bool]=lambda _:True,
         abort:Callable[[requests.Response],bool]=lambda _:False,
         eachmsg:Callable[[requests.Response],None]=lambda _:None,
         lastmsg:Callable[[requests.Response],None]=lambda _:None
         )->Result:
    response=requests.Response()
    for _ in range(0,trytime):
        try:
            response=requests.post(url, headers=headers, data=data)
            if target(response):
                lastmsg(response)
                return Result(response,True)
            elif abort(response):
                lastmsg(response)
                return Result(response,False)
            eachmsg(response)
        except:
            pass
    try:
        lastmsg(response)
    except:pass
    return Result(response,False)
'''

headers_str=json.dumps(headers,indent=4)+'\n'
body_str=json.dumps(body,indent=4)+'\n'
fnstr=f'''
def fn():
    url="{url}"
    headers={headers_str}
    body={body_str}
    result=post(url, headers, body)
    print(result.response.json())

fn()
'''
with open(output,"w") as f:
    f.write(prestr)
    f.write(fnstr)
    f.close()
print(f"output to {output}")
