#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
无依赖EPUB打包程序
支持从指定目录结构打包EPUB文件
"""

import os
import sys
import zipfile
import glob
import uuid
from datetime import datetime
import mimetypes
import argparse

class EpubPackager:
    def __init__(self, source_dir, output_file="output.epub", title="Generated EPUB"):
        self.source_dir = source_dir
        self.output_file = output_file
        self.title = title
        self.content_files = []
        self.cover_file = None
        self.index_file = None
        self.chapter_titles = []
        
    def validate_structure(self):
        """验证目录结构"""
        print("验证目录结构...")
        
        # 检查content目录
        content_dir = os.path.join(self.source_dir, "content")
        if not os.path.exists(content_dir):
            raise FileNotFoundError("content目录不存在")
        
        # 查找内容文件 (00000-xxxxx格式)
        # 使用更宽泛的模式匹配所有5位数字开头的文件
        content_pattern = os.path.join(content_dir, "*-*")
        all_matches = glob.glob(content_pattern)
        
        # 过滤出符合5位数字-xxx格式的文件
        import re
        content_matches = []
        pattern = re.compile(r'^\d{5}-.*')
        
        for file_path in all_matches:
            filename = os.path.basename(file_path)
            if pattern.match(filename):
                content_matches.append(file_path)
        
        if not content_matches:
            raise FileNotFoundError("未找到符合格式的内容文件 (NNNNN-xxxxx，其中N为数字)")
        
        # 按数字序号排序内容文件
        self.content_files = sorted(content_matches, key=lambda x: int(os.path.basename(x)[:5]))
        print(f"找到 {len(self.content_files)} 个内容文件")
        
        # 查找封面文件
        cover_pattern = os.path.join(self.source_dir, "cover.*")
        cover_matches = glob.glob(cover_pattern)
        if len(cover_matches) == 0:
            raise FileNotFoundError("未找到封面文件 (cover.*)")
        if len(cover_matches) > 1:
            raise ValueError(f"找到多个封面文件，不符合唯一性要求: {cover_matches}")
        
        self.cover_file = cover_matches[0]
        print(f"找到封面文件: {os.path.basename(self.cover_file)}")
        
        # 查找index文件
        index_pattern = os.path.join(self.source_dir, "index*")
        index_matches = glob.glob(index_pattern)
        if index_matches:
            if len(index_matches) > 1:
                print(f"警告: 找到多个index文件: {index_matches}")
            self.index_file = index_matches[0]
            print(f"找到索引文件: {os.path.basename(self.index_file)}")
        
        # 验证内容文件数量与索引行数匹配（如果有索引文件）
        if self.index_file:
            try:
                with open(self.index_file, 'r', encoding='utf-8') as f:
                    index_lines = [line.strip() for line in f.readlines() if line.strip()]
                if len(self.content_files) != len(index_lines):
                    raise ValueError(f"内容文件数量 ({len(self.content_files)}) 与索引行数 ({len(index_lines)}) 不匹配")
                self.chapter_titles = index_lines
                print("内容文件数量与索引匹配 ✓")
                print(f"加载了 {len(self.chapter_titles)} 个章节标题")
            except Exception as e:
                print(f"警告: 无法验证索引文件: {e}")
        else:
            # 如果没有索引文件，使用默认标题
            self.chapter_titles = [f"Chapter {i+1:05d}" for i in range(len(self.content_files))]
    
    def get_mime_type(self, file_path):
        """获取文件MIME类型"""
        mime_type, _ = mimetypes.guess_type(file_path)
        if mime_type is None:
            ext = os.path.splitext(file_path)[1].lower()
            mime_map = {
                '.jpg': 'image/jpeg',
                '.jpeg': 'image/jpeg',
                '.png': 'image/png',
                '.gif': 'image/gif',
                '.html': 'application/xhtml+xml',
                '.xhtml': 'application/xhtml+xml',
                '.css': 'text/css',
                '.js': 'text/javascript',
                '.nb': 'text/plain'  # 假设.nb文件为文本文件
            }
            mime_type = mime_map.get(ext, 'application/octet-stream')
        return mime_type
    
    def create_mimetype(self, zip_file):
        """创建mimetype文件"""
        zip_file.writestr("mimetype", "application/epub+zip", compress_type=zipfile.ZIP_STORED)
    
    def create_meta_inf(self, zip_file):
        """创建META-INF目录和container.xml"""
        container_xml = '''<?xml version="1.0" encoding="UTF-8"?>
<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
  <rootfiles>
    <rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/>
  </rootfiles>
</container>'''
        zip_file.writestr("META-INF/container.xml", container_xml)
    
    def content2html(self,title:str,contents:str)->str:
        ret=f'''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>{title}</title>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <style type="text/css">
        body {{ line-height: 1.6; margin: 2em; }}
        h1 {{ color: #333; border-bottom: 2px solid #333; padding-bottom: 0.5em; }}
        pre {{ white-space: pre-wrap; word-wrap: break-word; }}
    </style>
</head>
<body>
    <h1>{title}</h1>'''
        for content in contents.split('\n'):
            ret+=f"{content}<br/>"
        ret+='''
</body>
</html>'''
        return ret
    def convert_content_to_html(self, content_file, chapter_index):
        """将内容文件转换为HTML格式"""
        try:
            with open(content_file, 'r', encoding='utf-8') as f:
                content = f.read()
        except:
            try:
                with open(content_file, 'r', encoding='gbk') as f:
                    content = f.read()
            except:
                with open(content_file, 'rb') as f:
                    content = f.read().decode('utf-8', errors='ignore')
        
        # 获取章节标题
        chapter_title = self.chapter_titles[chapter_index] if chapter_index < len(self.chapter_titles) else f"Chapter {chapter_index+1}"
        
        return self.content2html(chapter_title, content)

    
    def create_cover_html(self):
        """创建封面HTML页面"""
        assert(self.cover_file)
        cover_ext = os.path.splitext(self.cover_file)[1]
        cover_html = f'''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Cover</title>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <style type="text/css">
        body {{ margin: 0; padding: 0; text-align: center; }}
        img {{ max-width: 100%; max-height: 100%; }}
    </style>
</head>
<body>
    <img src="cover{cover_ext}" alt="Cover"/>
</body>
</html>'''
        return cover_html
    
    def create_content_opf(self):
        """创建content.opf文件"""
        book_id = str(uuid.uuid4())
        timestamp = datetime.now().strftime("%Y-%m-%dT%H:%M:%SZ")
        
        # 构建manifest项目
        manifest_items = []
        spine_items = []
        
        # 封面
        assert(self.cover_file)
        cover_ext = os.path.splitext(self.cover_file)[1]
        cover_mime = self.get_mime_type(self.cover_file)
        manifest_items.append(f'    <item id="cover-image" href="cover{cover_ext}" media-type="{cover_mime}"/>')
        manifest_items.append('    <item id="cover" href="cover.xhtml" media-type="application/xhtml+xml"/>')
        spine_items.append('    <itemref idref="cover"/>')
        
        # 内容文件
        for i, _ in enumerate(self.content_files):
            item_id = f"chapter{i:05d}"
            filename = f"chapter{i:05d}.xhtml"
            manifest_items.append(f'    <item id="{item_id}" href="{filename}" media-type="application/xhtml+xml"/>')
            spine_items.append(f'    <itemref idref="{item_id}"/>')
        
        opf_content = f'''<?xml version="1.0" encoding="UTF-8"?>
<package xmlns="http://www.idpf.org/2007/opf" unique-identifier="BookId" version="2.0">
  <metadata xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:opf="http://www.idpf.org/2007/opf">
    <dc:identifier id="BookId">{book_id}</dc:identifier>
    <dc:title>{self.title}</dc:title>
    <dc:language>zh-CN</dc:language>
    <dc:date>{timestamp}</dc:date>
    <meta name="cover" content="cover-image"/>
  </metadata>
  <manifest>
{chr(10).join(manifest_items)}
  </manifest>
  <spine toc="ncx">
{chr(10).join(spine_items)}
  </spine>
  <guide>
    <reference type="cover" title="Cover" href="cover.xhtml"/>
  </guide>
</package>'''
        return opf_content
    
    def create_toc_ncx(self):
        """创建toc.ncx文件"""
        book_id = str(uuid.uuid4())
        
        nav_points = []
        for i, content_file in enumerate(self.content_files):
            chapter_title = self.chapter_titles[i]
            nav_points.append(f'''    <navPoint id="navPoint-{i+1}" playOrder="{i+1}">
      <navLabel>
        <text>{chapter_title}</text>
      </navLabel>
      <content src="chapter{i:05d}.xhtml"/>
    </navPoint>''')
        
        ncx_content = f'''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE ncx PUBLIC "-//NISO//DTD ncx 2005-1//EN" "http://www.daisy.org/z3986/2005/ncx-2005-1.dtd">
<ncx xmlns="http://www.daisy.org/z3986/2005/ncx/" version="2005-1">
  <head>
    <meta name="dtb:uid" content="{book_id}"/>
    <meta name="dtb:depth" content="1"/>
    <meta name="dtb:totalPageCount" content="0"/>
    <meta name="dtb:maxPageNumber" content="0"/>
  </head>
  <docTitle>
    <text>{self.title}</text>
  </docTitle>
  <navMap>
{chr(10).join(nav_points)}
  </navMap>
</ncx>'''
        return ncx_content
    
    def package_epub(self):
        """打包EPUB文件"""
        print(f"开始打包EPUB文件: {self.output_file}")
        
        with zipfile.ZipFile(self.output_file, 'w', zipfile.ZIP_DEFLATED) as zip_file:
            # 1. 创建mimetype文件
            self.create_mimetype(zip_file)
            
            # 2. 创建META-INF
            self.create_meta_inf(zip_file)
            
            # 3. 创建OEBPS目录内容
            # 封面图片
            assert(self.cover_file)
            cover_ext = os.path.splitext(self.cover_file)[1]
            with open(self.cover_file, 'rb') as f:
                zip_file.writestr(f"OEBPS/cover{cover_ext}", f.read())
            
            # 封面HTML
            zip_file.writestr("OEBPS/cover.xhtml", self.create_cover_html())
            
            # 内容文件
            for i, content_file in enumerate(self.content_files):
                html_content = self.convert_content_to_html(content_file, i)
                zip_file.writestr(f"OEBPS/chapter{i:05d}.xhtml", html_content)
                chapter_title = self.chapter_titles[i]
                print(f"已添加章节 {i+1}/{len(self.content_files)}: {chapter_title}")
            
            # OPF文件
            zip_file.writestr("OEBPS/content.opf", self.create_content_opf())
            
            # NCX文件
            zip_file.writestr("OEBPS/toc.ncx", self.create_toc_ncx())
        
        print(f"EPUB文件创建完成: {self.output_file}")
        print(f"文件大小: {os.path.getsize(self.output_file) / 1024:.1f} KB")

def main():
    parser = argparse.ArgumentParser(
        description='无依赖EPUB打包程序，将指定目录结构打包为EPUB文件',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='''
目录结构要求:
  .
  ├── content/               (正文目录)
  │   ├── 00000-xxxxx.nb    (第1章，格式为5位数字-任意名称)
  │   ├── 00001-xxxxx.nb    (第2章)
  │   └── ...
  ├── cover.jpg/png...      (封面，名称必须为cover，扩展名任意)
  └── index                 (可选，每行对应一章标题)

示例:
  %(prog)s ./book_source
  %(prog)s ./book_source -o output.epub
  %(prog)s ./book_source -t "我的小说" -o my_book.epub
        '''
    )
    
    parser.add_argument('source_dir', 
                       help='源目录路径')
    parser.add_argument('-o', '--output', 
                       help='输出EPUB文件名 (默认: output.epub 或 <书名>.epub)')
    parser.add_argument('-t', '--title', 
                       default='Generated EPUB',
                       help='书籍标题 (默认: Generated EPUB)')
    
    args = parser.parse_args()
    
    # 处理输出文件名逻辑
    if args.output is None:
        if args.title != 'Generated EPUB':
            # 如果指定了标题但没指定输出文件，使用标题作为文件名
            # 清理文件名中的非法字符
            safe_title = "".join(c for c in args.title if c.isalnum() or c in (' ', '-', '_', '(', ')', '[', ']')).strip()
            safe_title = safe_title.replace(' ', '_')  # 将空格替换为下划线
            if not safe_title:  # 如果清理后为空，使用默认名称
                safe_title = 'Generated_EPUB'
            args.output = f"{safe_title}.epub"
        else:
            args.output = 'output.epub'
    
    if not os.path.exists(args.source_dir):
        print(f"错误: 源目录不存在: {args.source_dir}")
        sys.exit(1)
    
    try:
        packager = EpubPackager(args.source_dir, args.output, args.title)
        packager.validate_structure()
        packager.package_epub()
        print("✓ EPUB打包完成!")
        
    except Exception as e:
        print(f"错误: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
