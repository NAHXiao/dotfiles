#!/bin/bash
SUFFIX=">/dev/null 2>&1"
function RUN(){
    # echo $@
    eval "$@" $SUFFIX
}
[[ "$1" == "-v" ]] && SUFFIX=""
config_json="$HOME/.scripts/systemd-scripts/dotfiles-bakup-dirs.json"
BAKUPTO="/mnt/data/backup/dotfiles"
[[ ! -w $BAKUPTO ]] && BAKUPTO="$HOME/workspace/dotfiles"
#TMP =$(mktemp -d)
LOCALREPODIR="$HOME/workspace/repo/dotfiles"
REPODOTFILEDIR="$LOCALREPODIR/dotfiles"
REMOTEREPOLINK="git@github.com:NAHXiao/dotfiles.git"
rsyncarray=($(eval echo $( /bin/cat "$config_json" 2>/dev/null |  jq -r '.[]')))
mkdir -p "$REPODOTFILEDIR"

#init REPO
cd "$LOCALREPODIR" || { echo "未知错误: cd $LOCALREPODIR Failed" ; exit  2 ; }
[[ ! -d '.git' ]] &&  {
echo "Init local repo..."
git init
git remote add origin $REMOTEREPOLINK
}
echo "pull remote repo..."
git pull origin main --allow-unrelated-histories
#updata local
echo "update local repo"
[[ ${#rsyncarray[@]} -eq 0 ]] && { echo "读取配置文件失败或配置为空" ; exit 1 ; }
rsyncarray[0]=${rsyncarray[0]%/}
for (( i=1; i<${#rsyncarray[@]}; i++ )) ; do 
rsyncarray[i]=${rsyncarray[i]%/}
TODIR="$REPODOTFILEDIR/${rsyncarray[$i]#"${rsyncarray[0]}/"}"
if [[ -d "${rsyncarray[$i]}" ]] ; then 
    RUN rsync -avz --delete "${rsyncarray[$i]}" "${TODIR%/*}"
else
    RUN rsync -avz --delete "${rsyncarray[$i]}" "${TODIR%/*}/" 
fi
done

echo "tar and bakup to $BAKUPTO ..."
mkdir -p "$BAKUPTO" 2>/dev/null
if [[ ! -d $BAKUPTO ]] ; then 
	 echo " 创建备份目录失败" 
else
		BAKFILE="dotfiles_bakup_$(date +%y%m%d_%k:%0l:%S_%N).tar.gz"
		echo "taring to $BAKUPTO/$BAKFILE"
		cd "$REPODOTFILEDIR" || { echo "未知错误: cd $REPODOTFILEDIR Failed" ; exit  2 ; }
        RUN tar -czvf $BAKUPTO/"$BAKFILE" .
		cd -
fi
[[ ! -f $BAKUPTO/"$BAKFILE" ]] && echo -e "\ntar打包失败\n"
sleep 1 
echo "add and commit to local repo..."
git add .
git commit -m "dotfiles_bakup_$(date +%y%m%d_%k:%0l:%S_%N)"
git branch -M main
echo "push to remote main repo..."
git push origin main
