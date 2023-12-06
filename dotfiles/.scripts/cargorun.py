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
                        subprocess.run([cargo_workspace+'/target/release/' + binary_name],check=True)
                    else:
                        subprocess.run(['cargo','build','--release'])
                        subprocess.run([cargo_workspace+'/target/release/' + binary_name],check=True)
                elif mode == 'debug':
                    if os.path.exists(cargo_workspace+'/target/debug/' + binary_name):
                        subprocess.run([cargo_workspace+'/target/debug/' + binary_name],check=True)                
                    else:
                        subprocess.run(['cargo','build'])
                        subprocess.run([cargo_workspace+'/target/debug/' + binary_name],check=True)
                else:
                    subprocess.run(['cargo','run'])
            except subprocess.CalledProcessError as e:
                returncode=e.returncode
            if not returncode:
                # success
                print("\033[32mProcess return "+str(returncode)+"\033[0m")
            else:
                print("\033[31mProcess return "+str(returncode)+"\033[0m")


argvList=sys.argv
if len(argvList)>1:
    mode=argvList[1]
else:
    mode="debug"

try:
    cargorun(find_cargo_dir(),mode)
except KeyboardInterrupt:
    sys.exit(1)
