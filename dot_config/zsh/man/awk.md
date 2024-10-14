- match正则捕获组
```bash
echo "abc 123 def 456" | awk 'BEGIN{FPAT="[0-9]+"} {print $1, $2}'
```
