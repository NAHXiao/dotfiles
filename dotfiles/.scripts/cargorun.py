#!/usr/bin/env python
import os
import toml
import subprocess
import sys
def find_cargo_dir():
    """
    递归向上查找 Cargo.toml 文件所在目录
     Return: None or str
    """
    path = os.getcwd()
    while path != '/':
        if os.path.exists(os.path.join(path, 'Cargo.toml')):
            return path
        path = os.path.dirname(path)
    return None


def cargorun(cargo_workspace,mode):
    """
	 StdOutput: 
	 StdErr:
     Arguments: toml:str
    """
    if cargo_workspace == None : 
        print("not found Cargo.toml")
        return
    else:
        #使用toml库读取Cargo.toml文件,获取二进制文件名
        with open(os.path.join(cargo_workspace, 'Cargo.toml')) as f:
            cargo_toml = toml.load(f)
            binary_name = cargo_toml['package']['name']
            returncode=0
            try:
                if mode == 'release':
                    if os.path.exists(cargo_workspace+'/target/release/' + binary_name):
                        subprocess.run([cargo_workspace+'/target/release/' + binary_name]+ArgList,check=True)
                    else:
                        subprocess.run(['cargo','build','--release'])
                        subprocess.run([cargo_workspace+'/target/release/' + binary_name]+ArgList,check=True)
                elif mode == 'debug':
                    if os.path.exists(cargo_workspace+'/target/debug/' + binary_name):
                        subprocess.run([cargo_workspace+'/target/debug/' + binary_name]+ArgList,check=True)                
                    else:
                        subprocess.run(['cargo','build'])
                        subprocess.run([cargo_workspace+'/target/debug/' + binary_name]+ArgList,check=True)
                else:
                    subprocess.run(['cargo','run']+ArgList)
            except subprocess.CalledProcessError as e:
                returncode=e.returncode
            if not returncode:
                # success
                print("\033[32mProcess return "+str(returncode)+"\033[0m")
            else:
                print("\033[31mProcess return "+str(returncode)+"\033[0m")


argvList=sys.argv
if len(argvList)>1 and argvList[1]=='release':
    mode='release'
else:
    mode="debug"
# 以--为分界线,解析出子程序参数,写入ArgList
ArgList=[]
for i in range(len(argvList)):
    if argvList[i]=="--":
        ArgList=argvList[i+1:]
        break
try:
    cargorun(find_cargo_dir(),mode)
except KeyboardInterrupt:
    sys.exit(1)
