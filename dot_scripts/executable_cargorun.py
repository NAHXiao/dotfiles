#!/usr/bin/env python
import os
from typing_extensions import List
import toml
import shutil
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


def echo_gaps():
    terminal_width = shutil.get_terminal_size().columns
    print("-" * terminal_width)

def echo2gaps():
    terminal_width = shutil.get_terminal_size().columns
    print("-" * terminal_width)
    print("-" * terminal_width)

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
                    # if os.path.exists(cargo_workspace+'/target/release/' + binary_name):
                    #     subprocess.run([cargo_workspace+'/target/release/' + binary_name]+SubArgList,check=True)
                    # else:
                        subprocess.run(['cargo','build','--release'],check=True)
                        echo2gaps()
                        subprocess.run([cargo_workspace+'/target/release/' + binary_name]+SubArgList,check=True)
                elif mode == 'debug':
                    # if os.path.exists(cargo_workspace+'/target/debug/' + binary_name):
                    #     subprocess.run([cargo_workspace+'/target/debug/' + binary_name]+SubArgList,check=True)                
                    # else:
                        subprocess.run(['cargo','build'],check=True)
                        echo2gaps()
                        subprocess.run([cargo_workspace+'/target/debug/' + binary_name]+SubArgList,check=True)
                else:
                    print("TODO")
                    pass
                    # subprocess.run(['cargo','run']+SubArgList)
            except subprocess.CalledProcessError as e:
                returncode=e.returncode
            if not returncode:
                # success
                print("\033[32mProcess return "+str(returncode)+"\033[0m")
            else:
                print("\033[31mProcess return "+str(returncode)+"\033[0m")


def get_filename_and_out(rustcArgs:List):
    """
	 StdOutput: 
	 StdErr:
     Arguments:
    Return: (filename,outname)
    """
    filename=''
    outname=''
    lastarg=rustcArgs[0]
    for arg in rustcArgs:
        if arg.endswith(".rs"):
            if lastarg not in ("-o",'--out-dir') :
                if filename:
                    sys.exit("too many source files")
                filename=arg
            else:
                outname=arg
        lastarg=arg
    if outname=='':
        outname=os.path.splitext(filename)[0]
    return (filename,outname)


def rustc_run(rustcArgs:List,SubArgs:List):
    """
	 StdOutput: 
	 StdErr:
     Arguments:
    """
    if len(rustcArgs)==0:
        sys.exit("no source files")
    _,outname=get_filename_and_out(rustcArgs)
    rustcArgs.append("-g")
    returncode=0
    try:
        subprocess.run(["rustc",]+rustcArgs,check=True)
        echo2gaps()
        subprocess.run([outname,]+SubArgs,check=True)
    except subprocess.CalledProcessError as e:
        returncode=e.returncode
    if not returncode:
        # success
        print("\033[32mProcess return "+str(returncode)+"\033[0m")
    else:
        print("\033[31mProcess return "+str(returncode)+"\033[0m")
            

    

#################全局变量#####################

argvList=sys.argv
mode='debug'
use_default_args=False
DefaultArgsFile=''
CustomArgsFile=''
SubArgList=[]
RustcArgs=[]
def set_globals(global_var_name:str,new_value):
    globals()[global_var_name]=new_value
#################参数定义#####################
#True表示参数错误
ArgEnumDict={
        '-m=':lambda x: set_globals('mode',x)if x=='release' or x=='debug' or x=='singlefile' or x=='checktoml' else True,
        '--mode=':lambda x: set_globals('mode',x)if x=='release' or x=='debug' or x=='singlefile' or x=='checktoml' else True,
        '-c=':lambda x: set_globals('use_default_args',True) or set_globals('CustomArgsFile',x),
        '--config=':lambda x: set_globals('use_default_args',True) or set_globals('CustomArgsFile',x),
}
ArgOptionDict={
        '-r':lambda:set_globals('mode','release'),
        '--release':lambda:set_globals('mode','release'),
        '-d':lambda:set_globals('mode','debug'),
        '--debug':lambda:set_globals('mode','debug'),
        '-D':lambda:set_globals('use_default_args',True),
        '--default-args':lambda:set_globals('use_default_args',True),
        '-h':lambda:print("Usage: cargorun [options] [--] [subargs]") or sys.exit(0),
        '--help':lambda:print(\
'''
Usage: cargorun [options] [--] [subargs]
Options:
    -r, --release: build in release mode
    -d, --debug: build in debug mode
    -m=<debug|release|singlefile|checktoml>, --mode=<...>: build in mode
    -D, --default-args: use and update default args
    -c=<argfile>,--config=<argfile>: indicate the default args file
    -h, --help: print this help
'''
) or sys.exit(0),
}
#################参数Parse#####################
SubArgIsSetted=False
for i in range(1,len(argvList)):
    if argvList[i]=="--":
        SubArgList=argvList[i+1:]
        SubArgIsSetted=True
        #处理use_default_args
        break
    Found=False
    for key,value in ArgOptionDict.items():
        if argvList[i]==key:
            Found=True
            value()
            break;
    if Found:continue
    for key,value in ArgEnumDict.items():
        if argvList[i].startswith(key):
            Found=True
            # print(argvList[i])
            if value(argvList[i][len(key):]):
                print("Unknown option: "+argvList[i])
                sys.exit(0)
            break;
    if not Found:
        if mode == 'singlefile':
            RustcArgs.append(argvList[i])
        else:
            print("Unknown option: "+argvList[i])
            sys.exit(0)


CargoWorkspace=find_cargo_dir()
# checktoml mode
if mode == 'checktoml':
    if CargoWorkspace:
        sys.exit(0)
    else:
        sys.exit(1)


if not CargoWorkspace and mode!='singlefile':
    print("not found Cargo.toml")
    sys.exit(1)
if not CustomArgsFile:
    if mode == 'singlefile':
        if len(RustcArgs)==0:
            sys.exit("no source files")
        filename,_=get_filename_and_out(RustcArgs)
        filenoext=os.path.splitext(filename)[0]
        DefaultArgsFile=filenoext+'.args'
        # print(DefaultArgsFile)
    else:
        DefaultArgsFile=os.path.join(str(CargoWorkspace),'.cargo_run.args')
else:
    if not os.path.exists(CustomArgsFile):
        print("not found "+CustomArgsFile)
        sys.exit(2)
#################处理arg_config选项#####################
# 1 1 use new , update
# 1 0 use new , no update
# 0 1 use default
# 0 0 pass
if SubArgIsSetted and use_default_args:
    with open(DefaultArgsFile,'w') as f:
        f.write(" ".join(SubArgList))
elif SubArgIsSetted and not use_default_args:
    pass
elif not SubArgIsSetted and use_default_args:
    try:
        with open(DefaultArgsFile,'r') as f:
            SubArgList=f.read().split()
            print("ArgList:",SubArgList)
    except FileNotFoundError:
        pass
# print(SubArgList)
#################运行#####################
try:
    if mode != 'singlefile':
        cargorun(CargoWorkspace,mode)
    else:
        # print(SubArgList)
        rustc_run(RustcArgs,SubArgList)

except KeyboardInterrupt:
    sys.exit(0)


'''
import argparse

# 全局变量
mode = 'debug'
use_default_args = False
DefaultArgsFile = ''
CustomArgsFile = ''
SubArgList = []

# 参数定义
parser = argparse.ArgumentParser(description='Command-line tool.')
parser.add_argument('-m', '--mode', choices=['debug', 'release'], default='debug', help='Build mode.')
parser.add_argument('-D', '--default-args', action='store_true', help='Use and update default args.')
parser.add_argument('-c', '--config', type=argparse.FileType('r'), help='Indicate the default args file.')

# 解析命令行参数
args, unknown_args = parser.parse_known_args()

# 更新全局变量
mode = args.mode
use_default_args = args.default_args
if args.config:
    CustomArgsFile = args.config.name

# 处理未识别的子参数
if '--' in unknown_args:
    SubArgList = unknown_args[unknown_args.index('--') + 1:]

# 其他全局变量操作可以根据需要添加
'''
