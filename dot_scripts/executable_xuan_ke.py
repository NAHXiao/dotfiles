#!/usr/bin/env python
import requests
import unicodedata
import urllib3
import threading
import curses

from urllib3.util.timeout import time
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)


# 需手动修改
ROUTE= '6070cb668825e3ed2a462f9e3b4be234'
Authorization='eyJhbGciOiJIUzUxMiJ9.eyJ0aW1lIjoxNzQxMTU3NzQ1MjA5LCJsb2dpbl91c2VyX2tleSI6IjU1MjIwMjE0IiwidG9rZW4iOiJyc2tpZmZxMWNjaTZtcGtmZzM1NTcyYjExOSJ9.114_Vz36ASUlvxaAlRkVIm5mm9LhifPbDnxegfqIC_DPGPVidOXQFyOdqPFsunUPig7UqJv6x0RKLE_DDHbWmA'

# ExitMsg=("课容量已满","该课程已在选课结果中")
ExitMsg=("该课程已在选课结果中") #Listen模式

# "课程名(部分匹配即可但要确保只有一个匹配)":"教师名(若只有一个可空,部分匹配即可)"
addList={
}
###################################################################
batchId='1a12e5ac0f634a42948c23388109e21b'
ClazzType="TJKC"  #默认
# ClazzType="FANKC" #退补选
###################################################################
COOKIES = {
    'route':ROUTE,
    'Authorization':Authorization,
}

def add(clazzType:str,clazzId:str,secretVal:str):
    data={'clazzType': clazzType,'clazzId':clazzId,"secretVal":secretVal}
    headers = {
        'Accept': 'application/json, text/plain, */*',
        'Accept-Language': 'zh-CN,zh;q=0.9',
        'Authorization':Authorization,
        'Cookie': 'route='+ROUTE+'; Authorization='+Authorization,
        'Connection': 'keep-alive',
        'Content-Type': 'application/x-www-form-urlencoded',
        'Origin': 'https://icourses.jlu.edu.cn',
        'Referer': 'https://icourses.jlu.edu.cn/xsxk/elective/grablessons?batchId='+batchId,
        'Sec-Fetch-Dest': 'empty',
        'Sec-Fetch-Mode': 'cors',
        'Sec-Fetch-Site': 'same-origin',
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36',
        'batchId': batchId,
        'sec-ch-ua': '"Chromium";v="128", "Not;A=Brand";v="24", "Google Chrome";v="128"',
        'sec-ch-ua-mobile': '?0',
        'sec-ch-ua-platform': '"Windows"',
    }
    
    try:
        response = requests.post('https://icourses.jlu.edu.cn/xsxk/elective/jlu/clazz/add', cookies=COOKIES, headers=headers, data=data,verify=False)
        return (response.json()["code"] in (0,200),response.json()["msg"])
    except KeyboardInterrupt:raise KeyboardInterrupt
    except Exception as e:
        return (False,str(e))


#####################################################################################################
"""
return: {
    "Software Architecture": {
        "HONGJI YANG,李大利": {
            "clazzId": "202420252ae2255101401",
            "secretVal": "8CL+v9fIGiT8veCZu+ABOxKvpsZyU9TuVR0gcXDsd6Iqs0braOXE7ISseE02fILbiNtNuMm9X70WIvngVNj0kY3qI41/jkhkr8QcVmXXMlQ51yvMnKWBmLUFxGPV7rb24etikkm8ZiXA6NUuk2rzO3I7ZGD0xch38htJxDAKaiE="
        }
    }
}
"""
def get_list():
    ret={}
    headers = {
        'Accept': 'application/json, text/plain, */*',
        'Accept-Language': 'zh-CN,zh;q=0.9',
        'Authorization': Authorization,
        'Connection': 'keep-alive',
        'Content-Type': 'application/json;charset=UTF-8',
        'Origin': 'https://icourses.jlu.edu.cn',
        'Referer': 'https://icourses.jlu.edu.cn/xsxk/elective/grablessons?batchId='+batchId,
        'Sec-Fetch-Dest': 'empty',
        'Sec-Fetch-Mode': 'cors',
        'Sec-Fetch-Site': 'same-origin',
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36',
        'batchId':batchId,
        'sec-ch-ua': '"Chromium";v="128", "Not;A=Brand";v="24", "Google Chrome";v="128"',
        'sec-ch-ua-mobile': '?0',
        'sec-ch-ua-platform': '"Windows"',
    }
    
    json_data = {
        'teachingClassType': ClazzType,
        'pageNumber': 1,
        'pageSize': 100,
        'orderBy': '',
        'campus': '01',
    }
    
    response = requests.post(
        'https://icourses.jlu.edu.cn/xsxk/elective/jlu/clazz/list',
        cookies=COOKIES,
        headers=headers,
        json=json_data,verify=False
    )
    try:
        l=response.json()["data"]["rows"]
        for i in l:
            tec2IdAndSecret={}
            for tc in i["tcList"]:
                tec2IdAndSecret[tc["SKJS"]]={
                   "clazzId":tc["JXBID"],
                   "secretVal":tc["secretVal"],
                }
            ret[i["KCM"]]=tec2IdAndSecret
    except KeyboardInterrupt:raise KeyboardInterrupt
    except Exception:
        print("COOKIE已过期")
        exit()
    return ret

"""
return: (key,value)
"""
def fuzzy_dict_lookup(dictionary: dict, search_key: str):
    if search_key in dictionary:
        return (search_key,dictionary[search_key])
    for key in dictionary:
        if isinstance(key, str) and search_key.lower() in key.lower():
            return (key,dictionary[key])
    raise KeyError(f"No key containing '{search_key}' found in dictionary")
# [
# ((clazzName,tecName),(realclazzName,realtecName),(clazzType,clazzId,secretVAl),isrunning,msg)
# ]
def thread_func(clazzData):
    clazzData[3]=True
    while True:
        try:
            suc,msg=add(*clazzData[2])
            clazzData[4]=msg
            if suc or msg in ExitMsg :break
        except: pass
    clazzData[3]=False

def get_display_width(text):
    """计算字符串的显示宽度，中文字符占2个单位，英文字符占1个单位"""
    return sum(2 if unicodedata.east_asian_width(c) in ['F', 'W'] else 1 for c in text)

def format_with_width(text, width):
    """根据实际显示宽度，进行对齐，确保每列有指定的宽度"""
    # 计算实际宽度
    actual_width = get_display_width(text)
    # 截取文本，如果文本过长则截断
    if actual_width > width:
        text = text[:width]
        actual_width = width
    # 根据宽度进行填充（左对齐）
    padding = width - actual_width
    return f"{text}{' ' * padding}"

def display_tui(stdscr, my_section_list,notfountmsg):
    lines=[]
    while True:
        all_exited = True
        modified=True
        idx=2
        for index,clazzData in enumerate(my_section_list):
            class_name, teacher_name = clazzData[1]
            status = "等待运行" if clazzData[3] is None else ("运行中" if clazzData[3] else "已退出")
            message = clazzData[4] if clazzData[4] else "N/A"

            if clazzData[3] == True:
                all_exited = False

            # 根据显示宽度进行格式化
            formatted_class_name = format_with_width(class_name, 30)
            formatted_teacher_name = format_with_width(teacher_name, 30)
            formatted_status = format_with_width(status, 15)
            formatted_message = format_with_width(message, 50)

            # 输出每行，保证对齐
            line=f"{formatted_class_name}{formatted_teacher_name}{formatted_status}{formatted_message}"
            if len(lines)!=len(my_section_list):
                lines.append(line)
            elif lines[index]!=line:
                lines[index]=line
            else:
                modified=False
        if modified:
            curses.curs_set(0)
            stdscr.clear()
            stdscr.addstr(0, 0, "Course Selection Status", curses.A_BOLD)
            stdscr.addstr(1, 0, f"{'课程名':<30}{'教师名':<30}{'线程状态':<15}{'提示信息':<50}", curses.A_UNDERLINE)
            for line in lines:
                idx+=1
                stdscr.addstr(idx, 0, line)
            stdscr.addstr(idx+2, 0, "错误信息:\n"+notfountmsg,curses.COLOR_RED)
            stdscr.refresh()
        if all_exited:
            while True:time.sleep(1e9)
        curses.napms(100)

if __name__ == '__main__':
    try:
        all_section_list=get_list()
        my_section_list=[]
        notfountmsg=""
        for (className,tecName) in addList.items():
            try:
                _clazzName,clazzs=fuzzy_dict_lookup(all_section_list,className)
                _tecName,clazz=fuzzy_dict_lookup(clazzs,tecName)
                clazzId=clazz["clazzId"]
                secretVal=clazz["secretVal"]
                my_section_list.append([(className,tecName),(_clazzName,_tecName),(ClazzType,clazzId,secretVal),None,None])
            except KeyError: notfountmsg+=f"未找到{className} {tecName}的课程\n"; continue
        threads = []
        for clazzData in my_section_list:
            thread = threading.Thread(target=thread_func, args=(clazzData,))
            threads.append(thread)
            thread.start()
        curses.wrapper(display_tui, my_section_list,notfountmsg)

        for thread in threads:
            thread.join()
    except KeyboardInterrupt:exit()
